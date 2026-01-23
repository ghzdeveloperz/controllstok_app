import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthBootstrapService {
  AuthBootstrapService._();

  static const List<String> _imageUrlKeys = [
    'photoUrl',
    'avatarUrl',
    'profileImageUrl',
    'companyLogoUrl',
    'logoUrl',
    'coverUrl',
    'bannerUrl',
  ];

  /// Compatível com o que você já usa:
  /// - garante doc
  /// - baixa doc
  /// - pré-carrega imagens
  static Future<void> warmUp({
    required BuildContext context,
    required User user,
  }) async {
    final _ = await warmUpAndDecideRoute(context: context, user: user);
  }

  /// ✅ Novo: faz warmup e já retorna se deve ir para Company (onboarding pendente).
  ///
  /// Regra:
  /// goToCompany = onboardingCompleted != true
  static Future<bool> warmUpAndDecideRoute({
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

    // 3) decide rota
    final onboardingCompleted = data['onboardingCompleted'] == true;
    final goToCompany = !onboardingCompleted;

    // 4) pré-carrega imagens principais
    final urls = _collectImageUrls(data);
    await _precacheUrls(context, urls);

    return goToCompany;
  }

  static List<String> _collectImageUrls(Map<String, dynamic> data) {
    final urls = <String>[];

    for (final key in _imageUrlKeys) {
      final v = data[key];
      if (v is String && _looksLikeUrl(v)) {
        urls.add(v.trim());
      }
    }

    final images = data['images'];
    if (images is List) {
      for (final item in images) {
        if (item is String && _looksLikeUrl(item)) {
          urls.add(item.trim());
        } else if (item is Map) {
          final u = item['url'];
          if (u is String && _looksLikeUrl(u)) {
            urls.add(u.trim());
          }
        }
      }
    }

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

    // Limite pra não virar “loading eterno” se o doc tiver muitas imagens.
    final limited = urls.take(6).toList();

    for (final url in limited) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (_) {
        // não trava login por falha de imagem
      }
    }
  }
}
