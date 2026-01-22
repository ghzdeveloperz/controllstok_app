import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthBootstrapService {
  AuthBootstrapService._();

  /// Campos comuns que podem conter URL de imagem no seu Firestore.
  /// Ajuste/adicione conforme seu schema.
  static const List<String> _imageUrlKeys = [
    'photoUrl',
    'avatarUrl',
    'profileImageUrl',
    'companyLogoUrl',
    'logoUrl',
    'coverUrl',
    'bannerUrl',
  ];

  /// Faz o "warmup" pós-login:
  /// 1) garante doc do usuário (se não existir, cria básico)
  /// 2) baixa o doc do usuário
  /// 3) pré-carrega imagens principais (URLs encontradas no doc)
  ///
  /// Observação: isso não tenta carregar "o app inteiro".
  /// Só o que estiver no doc e parecer imagem.
  static Future<void> warmUp({
    required BuildContext context,
    required User user,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final userRef = firestore.collection('users').doc(user.uid);

    // 1) garante doc
    final snap = await userRef.get();
    if (!snap.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
      }, SetOptions(merge: true));
    }

    // 2) lê doc atualizado
    final freshSnap = await userRef.get();
    final data = freshSnap.data() ?? <String, dynamic>{};

    // 3) extrai urls de imagem
    final urls = _collectImageUrls(data);

    // 4) pré-carrega imagens (não falha o fluxo se der erro)
    await _precacheUrls(context, urls);
  }

  static List<String> _collectImageUrls(Map<String, dynamic> data) {
    final urls = <String>[];

    for (final key in _imageUrlKeys) {
      final v = data[key];
      if (v is String && _looksLikeUrl(v)) {
        urls.add(v.trim());
      }
    }

    // Também pode existir algum campo "images" como lista:
    final images = data['images'];
    if (images is List) {
      for (final item in images) {
        if (item is String && _looksLikeUrl(item)) {
          urls.add(item.trim());
        } else if (item is Map) {
          // Ex: [{url: "..."}]
          final u = item['url'];
          if (u is String && _looksLikeUrl(u)) {
            urls.add(u.trim());
          }
        }
      }
    }

    // remove duplicadas
    return urls.toSet().toList();
  }

  static bool _looksLikeUrl(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    return s.startsWith('http://') || s.startsWith('https://');
  }

  static Future<void> _precacheUrls(
    BuildContext context,
    List<String> urls,
  ) async {
    if (urls.isEmpty) return;

    // Importante: limitar pra não virar “loading infinito” se tiver 50 imagens.
    // Carregue só as mais importantes primeiro.
    final limited = urls.take(6).toList();

    for (final url in limited) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (_) {
        // ignora erro de imagem
      }
    }
  }
}
