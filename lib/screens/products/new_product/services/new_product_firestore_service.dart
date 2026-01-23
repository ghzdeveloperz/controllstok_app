// lib/screens/products/new_product/services/new_product_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NewProductFirestoreService {
  final String uid;

  NewProductFirestoreService({required this.uid});

  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('users');

  Future<bool> productNameExists(String name) async {
    final query = await _users.doc(uid).collection('products').where('name', isEqualTo: name).get();
    return query.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> findByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return null;
    final query = await _users.doc(uid).collection('products').where('barcode', isEqualTo: barcode).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  /// Retorna o id do produto criado (ou null se falhar).
  Future<String?> createProductAndMovement({
    required String name,
    required String category,
    required int quantity,
    required double price,
    required String barcode,
    required String imageUrl,
  }) async {
    final userRef = _users.doc(uid);

    final productRef = await userRef.collection('products').add({
      'name': name,
      'category': category,
      'quantity': quantity,
      'minStock': 10,
      'cost': price,
      'unitPrice': price,
      'barcode': barcode,
      'image': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await userRef.collection('movements').add({
      'productId': productRef.id,
      'productName': name,
      'type': 'add',
      'quantity': quantity,
      'unitPrice': price,
      'cost': quantity * price,
      'timestamp': Timestamp.now(),
      'barcode': barcode,
      'image': imageUrl,
    });

    return productRef.id;
  }
}
