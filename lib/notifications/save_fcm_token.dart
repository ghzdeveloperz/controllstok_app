import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
