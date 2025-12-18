import 'package:cloud_firestore/cloud_firestore.dart';
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
        return Product.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }
}
