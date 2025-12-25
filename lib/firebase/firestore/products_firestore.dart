// lib/firebase/firestore/products_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../screens/models/product.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductsFirestore {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= COLLECTION REF =================
  static CollectionReference<Map<String, dynamic>> _productsRef(String uid) {
    return _db.collection('users').doc(uid).collection('products');
  }

  // ================= GET PRODUCT BY BARCODE =================
  static Future<Product?> getProductByBarcode({
    required String uid,
    required String barcode,
  }) async {
    try {
      final querySnapshot = await _productsRef(
        uid,
      ).where('barcode', isEqualTo: barcode).limit(1).get();

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
        .asyncMap((snapshot) async {
          final products = <Product>[];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            String imageUrl = data['image'] ?? '';

            // Se image é o path no Storage, gera a URL
            if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
              imageUrl = await FirebaseStorage.instance
                  .ref(imageUrl)
                  .getDownloadURL();
            }

            products.add(Product.fromMap(doc.id, {...data, 'image': imageUrl}));
          }
          return products;
        });
  }
}
