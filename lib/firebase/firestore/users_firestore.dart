import 'package:cloud_firestore/cloud_firestore.dart';

class UsersFirestore {
  static Stream<String?> streamLogin(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['login'] as String?);
  }
}
