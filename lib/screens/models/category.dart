import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();

    return Category(
      id: doc.id,
      name: data is Map<String, dynamic>
          ? data['name'] ?? ''
          : '',
    );
  }
}
