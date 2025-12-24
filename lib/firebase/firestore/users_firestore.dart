// lib/firebase/firestore/users_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersFirestore {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamLogin(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}
