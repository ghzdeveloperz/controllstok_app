// lib/firebase/firestore/categories_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screens/models/category.dart'; // ✅ IMPORT OBRIGATÓRIO

class CategoriesFirestore {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<Category>> streamCategories(String userLogin) {
    return _db
        .collection('users')
        .doc(userLogin)
        .collection('categories')
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Category.fromFirestore(d)).toList(),
        );
  }

  static Future<void> addCategory({
    required String userLogin,
    required String name,
  }) async {
    await _db
        .collection('users')
        .doc(userLogin)
        .collection('categories')
        .add({'name': name});
  }

  /// 🔥 RETORNA FALSE SE EXISTIREM PRODUTOS USANDO A CATEGORIA
  static Future<bool> deleteCategory({
    required String userLogin,
    required String categoryId,
    required String categoryName,
  }) async {
    final products = await _db
        .collection('users')
        .doc(userLogin)
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (products.docs.isNotEmpty) {
      return false; // 🚫 categoria em uso
    }

    await _db
        .collection('users')
        .doc(userLogin)
        .collection('categories')
        .doc(categoryId)
        .delete();

    return true; // ✅ deletada
  }
}
