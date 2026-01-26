import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesFirestoreService {
  final FirebaseFirestore _db;

  CategoriesFirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<void> addCategory({
    required String uid,
    required String name,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('categories')
        .add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
