// lib/services/auth/google_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  /// Se der erro tipo [16] / reauth failed no Android,
  /// isso é 99% SHA-1 / SHA-256 ou google-services.json errado.
  static const String? _serverClientId = null; // opcional

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      serverClientId: _serverClientId,
    );

    _initialized = true;
  }

  /// Retorna:
  /// - UserCredential se logou
  /// - null se o usuário realmente cancelou
  Future<UserCredential?> signInWithGoogle() async {
    await _ensureInitialized();

    try {
      // Abre o seletor de contas
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      // google_sign_in 7.x → authentication NÃO é Future
      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google não retornou idToken. Verifique SHA-1/SHA-256 e google-services.json.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // Log real do erro (aqui você vai ver o famoso [16] se for config)
      debugPrint(
        '❌ GoogleSignInException: code=${e.code} details=${e.details}',
      );

      // Só considera cancelado se o código for canceled
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }

      throw Exception('Falha no login Google: ${e.code}');
    } catch (e) {
      debugPrint('❌ Erro inesperado no Google Auth: $e');
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }
}
