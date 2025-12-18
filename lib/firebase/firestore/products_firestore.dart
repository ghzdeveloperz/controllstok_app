import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../screens/models/product.dart';

class ProductsFirestore {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Product>> streamProducts(String userLogin) {
    return _db
        .collection('users')
        .doc(userLogin)
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // ===== LOG DE DEBUG SEM USAR print =====
        if (data['price'] == null || data['quantity'] == null || data['cost'] == null) {
          developer.log(
            'Produto com campo nulo detectado! DocID: ${doc.id}, Data: $data',
            name: 'ProductsFirestore',
          );
        }

        return Product.fromMap(data, doc.id);
      }).toList();
    });
  }
}
