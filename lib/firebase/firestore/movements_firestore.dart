// lib/firebase/firestore/movements_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementModel {
  final String productId;
  final String productName;
  final String type; // add | remove
  final int quantity;
  final double unitPrice;
  final double cost;
  final DateTime timestamp;

  MovementModel({
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.cost,
    required this.timestamp,
  });

  factory MovementModel.fromFirestore(Map<String, dynamic> data) {
    return MovementModel(
      productId: data['productId'],
      productName: data['productName'],
      type: data['type'],
      quantity: data['quantity'],
      unitPrice: (data['unitPrice'] as num).toDouble(),
      cost: (data['cost'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class MovementsFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MovementModel>> fetchMovements(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('movements')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => MovementModel.fromFirestore(doc.data()))
        .toList();
  }
}
