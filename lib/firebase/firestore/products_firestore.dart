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

  // ================= GET CURRENT STOCK =================
  static Future<int> getCurrentStock({
    required String uid,
    required String productId,
  }) async {
    final doc = await _productsRef(uid).doc(productId).get();

    if (!doc.exists) {
      throw Exception('Produto não encontrado');
    }

    return (doc.data()?['quantity'] as num?)?.toInt() ?? 0;
  }

  // ================= UPDATE STOCK (ENTRADA / SAÍDA) =================
  static Future<void> updateStock({
    required String uid,
    required String productId,
    required int quantityChange,
    required bool isEntry, // true = entrada | false = saída
  }) async {
    final productRef = _productsRef(uid).doc(productId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('Produto não encontrado');
      }

      final currentStock = (snapshot.data()?['quantity'] as num?)?.toInt() ?? 0;

      final newStock = isEntry
          ? currentStock + quantityChange
          : currentStock - quantityChange;

      if (!isEntry && newStock < 0) {
        throw Exception('Estoque insuficiente. Nota atual: $currentStock');
      }

      transaction.update(productRef, {
        'quantity': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    developer.log(
      'Estoque atualizado com sucesso: $productId',
      name: 'ProductsFirestore',
    );
  }

  // ================= UPDATE PRODUCT (EDIT) =================
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

  // ================= DELETE PRODUCT (CASCADE) =================
  static Future<void> deleteProduct({
    required String uid,
    required String productId,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(uid);

    try {
      // 🔍 Buscar produto
      final productRef = userRef.collection('products').doc(productId);
      final productDoc = await productRef.get();

      if (!productDoc.exists) {
        throw Exception('Produto não encontrado');
      }

      final data = productDoc.data();
      final imagePath = data?['image'] as String?;

      // 🔍 Buscar movements relacionados
      final movementsSnapshot = await userRef
          .collection('movements')
          .where('productId', isEqualTo: productId)
          .get();

      // 🧠 Batch delete
      final batch = firestore.batch();

      for (final doc in movementsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(productRef);

      await batch.commit();

      // 🗑️ Deletar imagem no Storage (fora do batch)
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        try {
          final storageRef = FirebaseStorage.instance.ref(imagePath);
          await storageRef.delete();
        } catch (e) {
          developer.log(
            'Erro ao deletar imagem do produto: $productId',
            error: e,
            name: 'ProductsFirestore',
          );
        }
      }

      developer.log(
        'Produto e movements deletados com sucesso: $productId',
        name: 'ProductsFirestore',
      );
    } catch (e, s) {
      developer.log(
        'Erro ao deletar produto (cascade): $productId',
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
