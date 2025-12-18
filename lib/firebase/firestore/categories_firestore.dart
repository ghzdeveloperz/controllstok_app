// lib/firebase/firestore/categories_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/models/category.dart';

class CategoriesFirestore {
  static final _db = FirebaseFirestore.instance;

  // Stream em tempo real para categorias
  static Stream<List<Category>> streamCategories(String userLogin) {
    return _db
        .collection('users')
        .doc(userLogin)
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
