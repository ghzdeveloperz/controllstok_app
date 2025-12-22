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
  final String? image;

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

  /// 👉 Usado diretamente nos relatórios/gráficos
  DateTime get date => timestamp;

  factory Movement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? productImage,
  }) {
    final data = doc.data() ?? {};

    return Movement(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      type: data['type'] ?? 'add',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      image: productImage,
    );
  }
}

/// =======================
/// SERVICE
/// =======================
class MovementsDaysFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cache local de imagens (performance)
  final Map<String, String?> _productImageCache = {};

  /// =======================
  /// IMAGEM DO PRODUTO (COM CACHE)
  /// =======================
  Future<String?> _getProductImage({
    required String userId,
    required String productId,
  }) async {
    if (productId.isEmpty) return null;

    if (_productImageCache.containsKey(productId)) {
      return _productImageCache[productId];
    }

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(productId)
        .get();

    final image = doc.data()?['image'] as String?;
    _productImageCache[productId] = image;

    return image;
  }

  /// =======================
  /// MOVIMENTAÇÕES DIÁRIAS (STREAM)
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
        final image = await _getProductImage(
          userId: userId,
          productId: productId,
        );

        movements.add(
          Movement.fromFirestore(doc, productImage: image),
        );
      }

      return movements;
    });
  }

  /// =======================
  /// MOVIMENTAÇÕES MENSAIS (STREAM)
  /// 👉 USADO NO GRÁFICO
  /// =======================
  Stream<List<Movement>> getMonthlyMovementsStream({
    required String userId,
    required int month,
    required int year,
  }) {
    final start = DateTime(year, month, 1);
    final end =
        (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);

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
        final image = await _getProductImage(
          userId: userId,
          productId: productId,
        );

        movements.add(
          Movement.fromFirestore(doc, productImage: image),
        );
      }

      return movements;
    });
  }

  /// =======================
  /// MOVIMENTAÇÕES DIÁRIAS (ONCE)
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
      final image =
          await _getProductImage(userId: userId, productId: productId);

      movements.add(
        Movement.fromFirestore(doc, productImage: image),
      );
    }

    return movements;
  }

  /// =======================
  /// MOVIMENTAÇÕES MENSAIS (ONCE)
  /// =======================
  Future<List<Movement>> getMonthlyMovements({
    required String userId,
    required int month,
    required int year,
  }) async {
    final start = DateTime(year, month, 1);
    final end =
        (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);

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
      final image =
          await _getProductImage(userId: userId, productId: productId);

      movements.add(
        Movement.fromFirestore(doc, productImage: image),
      );
    }

    return movements;
  }

  /// =======================
  /// MOVIMENTAÇÕES ANUAIS
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
      final image =
          await _getProductImage(userId: userId, productId: productId);

      movements.add(
        Movement.fromFirestore(doc, productImage: image),
      );
    }

    return movements;
  }
}
