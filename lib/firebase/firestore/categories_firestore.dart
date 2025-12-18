import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/models/category.dart';

class CategoriesFirestore {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retorna um Stream de lista de categorias do usuário
  static Stream<List<Category>> streamCategories(String userLogin) {
    return _db
        .collection('users')
        .doc(userLogin)
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }
}
