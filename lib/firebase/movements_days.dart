// lib/firebase/movements_days.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// =======================
/// MODEL
/// =======================
class Movement {
  final String id;
  final String productId;
  final String productName;
  final String type; // add | remove
  final int quantity;
  final double unitPrice;
  final DateTime timestamp;
  final String? image; // imagem do produto, opcional

  Movement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.timestamp,
    this.image,
  });

  /// Getter para facilitar a exibição da data
  DateTime get date => timestamp;

  /// Cria um Movement a partir do doc do Firestore e da imagem do produto
  factory Movement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? productImage,
  }) {
    final data = doc.data()!;
    return Movement(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      type: data['type'] ?? 'add',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      image: productImage,
    );
  }
}

/// =======================
/// SERVICE (DIÁRIO / MENSAL / ANUAL)
/// =======================
class MovementsDaysFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Função auxiliar para pegar a imagem do produto
  Future<String?> _getProductImage({
    required String userId,
    required String productId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(productId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      return data?['image'] as String?;
    }
    return null;
  }

  /// =======================
  /// MOVIMENTAÇÕES EM TEMPO REAL
  /// =======================
  Stream<List<Movement>> getDailyMovementsStream({
    required String userId,
    required DateTime day,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .snapshots()
        .asyncMap((snapshot) async {
      final movements = <Movement>[];
      for (final doc in snapshot.docs) {
        final productId = doc.data()['productId'] as String? ?? '';
        final image = await _getProductImage(userId: userId, productId: productId);
        movements.add(Movement.fromFirestore(doc, productImage: image));
      }
      return movements;
    });
  }

  /// =======================
  /// MOVIMENTAÇÕES DO MÊS EM TEMPO REAL
  /// =======================
  Stream<List<Movement>> getMonthlyMovementsStream({
    required String userId,
    required int month,
    required int year,
  }) {
    final start = DateTime(year, month, 1);
    final end = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .snapshots()
        .asyncMap((snapshot) async {
      final movements = <Movement>[];
      for (final doc in snapshot.docs) {
        final productId = doc.data()['productId'] as String? ?? '';
        final image = await _getProductImage(userId: userId, productId: productId);
        movements.add(Movement.fromFirestore(doc, productImage: image));
      }
      return movements;
    });
  }

  /// =======================
  /// MOVIMENTAÇÕES DO DIA (uma vez)
  /// =======================
  Future<List<Movement>> getDailyMovements({
    required String userId,
    required DateTime day,
  }) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    final movements = <Movement>[];

    for (final doc in snapshot.docs) {
      final productId = doc.data()['productId'] as String? ?? '';
      final image = await _getProductImage(userId: userId, productId: productId);
      movements.add(Movement.fromFirestore(doc, productImage: image));
    }

    return movements;
  }

  /// =======================
  /// MOVIMENTAÇÕES DO MÊS (uma vez)
  /// =======================
  Future<List<Movement>> getMonthlyMovements({
    required String userId,
    required int month,
    required int year,
  }) async {
    final start = DateTime(year, month, 1);
    final end = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    final movements = <Movement>[];

    for (final doc in snapshot.docs) {
      final productId = doc.data()['productId'] as String? ?? '';
      final image = await _getProductImage(userId: userId, productId: productId);
      movements.add(Movement.fromFirestore(doc, productImage: image));
    }

    return movements;
  }

  /// =======================
  /// MOVIMENTAÇÕES DO ANO (uma vez)
  /// =======================
  Future<List<Movement>> getYearlyMovements({
    required String userId,
    required int year,
  }) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    final movements = <Movement>[];

    for (final doc in snapshot.docs) {
      final productId = doc.data()['productId'] as String? ?? '';
      final image = await _getProductImage(userId: userId, productId: productId);
      movements.add(Movement.fromFirestore(doc, productImage: image));
    }

    return movements;
  }
}
