import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../screens/models/product.dart';

class ProductsFirestore {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= COLLECTION REF =================
  static CollectionReference<Map<String, dynamic>> _productsRef(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('products');
  }

  // ================= GET PRODUCT BY BARCODE =================
  static Future<Product?> getProductByBarcode({
    required String uid,
    required String barcode,
  }) async {
    try {
      final querySnapshot = await _productsRef(uid)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        developer.log(
          'Nenhum produto encontrado para barcode: $barcode',
          name: 'ProductsFirestore',
        );
        return null;
      }

      final doc = querySnapshot.docs.first;

      developer.log(
        'Produto encontrado: ${doc.data()['name']} | Barcode: $barcode',
        name: 'ProductsFirestore',
      );

      return Product.fromMap(doc.id, doc.data());
    } catch (e, s) {
      developer.log(
        'Erro ao buscar produto por barcode',
        error: e,
        stackTrace: s,
        name: 'ProductsFirestore',
      );
      return null;
    }
  }

  // ================= UPDATE PRODUCT =================
  static Future<void> updateProduct({
    required String uid,
    required String productId,
    required String name,
    required String category,
    required int minStock,
  }) async {
    try {
      await _productsRef(uid).doc(productId).update({
        'name': name.trim(),
        'category': category.trim(),
        'minStock': minStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      developer.log(
        'Produto atualizado com sucesso: $productId',
        name: 'ProductsFirestore',
      );
    } catch (e, s) {
      developer.log(
        'Erro ao atualizar produto: $productId',
        error: e,
        stackTrace: s,
        name: 'ProductsFirestore',
      );
      rethrow;
    }
  }

  // ================= STREAM PRODUCTS =================
  static Stream<List<Product>> streamProducts(String uid) {
    return _productsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        developer.log(
          'Produto stream → id: ${doc.id}, image: ${data['image'] ?? "NULL"}',
          name: 'ProductsFirestore',
        );

        return Product.fromMap(doc.id, data);
      }).toList();
    });
  }
}
