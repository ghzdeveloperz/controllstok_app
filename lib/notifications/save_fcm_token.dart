import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 🔹 Salva o token FCM do dispositivo logado
/// Deve ser chamado após login ou app iniciar autenticado
Future<void> saveFcmTokenIfLoggedIn() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('fcmTokens')
      .doc(token);

  await ref.set({
    'token': token,
    'updatedAt': FieldValue.serverTimestamp(),
    'platform': 'android',
  }, SetOptions(merge: true));
}

/// 🔥 Remove o token FCM do usuário no logout
/// Isso evita tokens mortos/zumbis no Firestore
Future<void> deleteFcmTokenOnLogout() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('fcmTokens')
      .doc(token);

  await ref.delete();
}
