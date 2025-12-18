// lib/firebase/firestore/products_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../screens/models/product.dart';

class ProductsFirestore {
  static final _db = FirebaseFirestore.instance;

  // ================= UPDATE PRODUCT =================
  static Future<void> updateProduct({
    required String userLogin,
    required String productId,
    required String name,
    required String category,
    required int minStock,
  }) async {
    await _db
        .collection('users')
        .doc(userLogin)
        .collection('products')
        .doc(productId)
        .update({
          'name': name,
          'category': category,
          'minStock': minStock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // ================= STREAM PRODUCTS =================
  static Stream<List<Product>> streamProducts(String userLogin) {
    return _db
        .collection('users')
        .doc(userLogin)
        .collection('products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            // Debug completo da imagem
            developer.log(
              'DocID: ${doc.id}, image: ${data['image'] ?? "NULL"} (${data['image']?.runtimeType})',
              name: 'ProductsFirestore',
            );

            return Product.fromMap(doc.id, data);
          }).toList();
        });
  }
}
