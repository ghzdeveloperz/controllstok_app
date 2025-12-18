// lib/firebase/firestore/products_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../screens/models/product.dart';

class ProductsFirestore {
  static final _db = FirebaseFirestore.instance;
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
        .update({'name': name, 'category': category, 'minStock': minStock});
  }

  static Stream<List<Product>> streamProducts(String userLogin) {
    return _db
        .collection('users')
        .doc(userLogin)
        .collection('products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            // ===== LOG DE DEBUG (sem print) =====
            if (data['price'] == null ||
                data['quantity'] == null ||
                data['cost'] == null) {
              developer.log(
                'Produto com campo nulo detectado! DocID: ${doc.id}, Data: $data',
                name: 'ProductsFirestore',
              );
            }

            // 👇 ORDEM CORRETA
            return Product.fromMap(doc.id, data);
          }).toList();
        });
  }
}
