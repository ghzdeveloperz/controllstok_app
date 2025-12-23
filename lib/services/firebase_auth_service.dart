import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// LOGIN
  Future<String?> login({
    required String login,
    required String password,
  }) async {
    try {
      final email = '${login.toLowerCase()}@controllstok.app';

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userDoc = await _db.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return 'Usuário não configurado';
      }

      final active = userDoc.data()?['active'] ?? true;

      if (!active) {
        await _auth.signOut();
        return 'Usuário desativado';
      }

      return uid;
    } on FirebaseAuthException {
      return 'Login ou senha incorretos';
    } catch (_) {
      return 'Erro ao conectar com o servidor';
    }
  }

  /// CADASTRO
  Future<String?> register({
    required String login,
    required String password,
    required String company,
  }) async {
    try {
      final email = '${login.toLowerCase()}@controllstok.app';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await _db.collection('users').doc(uid).set({
        'login': login.toLowerCase(),
        'company': company,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Usuário já existe';
      }
      return 'Erro ao criar conta';
    } catch (_) {
      return 'Erro ao conectar com o servidor';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
