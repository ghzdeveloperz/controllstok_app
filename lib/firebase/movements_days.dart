//  lib/firebase/movements_days.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  DateTime get date => timestamp;

  factory Movement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? productImage,
  }) {
    final data = doc.data() ?? {};

    return Movement(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      type: data['type'] as String? ?? 'add',
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cache local de imagens por productId
  final Map<String, String?> _productImageCache = {};

  /// =======================
  /// UID RESOLVER (PADRÃO FIREBASE AUTH)
  /// =======================
  String _resolveUid(String? uid) {
    if (uid != null && uid.isNotEmpty) return uid;

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    return user.uid;
  }

  /// =======================
  /// BUSCAR IMAGEM DO PRODUTO (COM CACHE)
  /// =======================
  Future<String?> _getProductImage(
    String uid,
    String productId,
  ) async {
    if (productId.isEmpty) return null;

    if (_productImageCache.containsKey(productId)) {
      return _productImageCache[productId];
    }

    final doc = await _firestore
        .collection('users')
        .doc(uid)
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
    required DateTime day,
    String? uid,
  }) {
    final resolvedUid = _resolveUid(uid);

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('users')
        .doc(resolvedUid)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .snapshots()
        .asyncMap(
          (snapshot) => _mapSnapshotToMovements(snapshot, resolvedUid),
        );
  }

  /// =======================
  /// MOVIMENTAÇÕES MENSAIS (STREAM)
  /// =======================
  Stream<List<Movement>> getMonthlyMovementsStream({
    required int month,
    required int year,
    String? uid,
  }) {
    final resolvedUid = _resolveUid(uid);

    final start = DateTime(year, month, 1);
    final end =
        month < 12 ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);

    return _firestore
        .collection('users')
        .doc(resolvedUid)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .snapshots()
        .asyncMap(
          (snapshot) => _mapSnapshotToMovements(snapshot, resolvedUid),
        );
  }

  /// =======================
  /// MOVIMENTAÇÕES DIÁRIAS (ONCE)
  /// =======================
  Future<List<Movement>> getDailyMovements({
    required DateTime day,
    String? uid,
  }) async {
    final resolvedUid = _resolveUid(uid);

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(resolvedUid)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    return _mapSnapshotToMovements(snapshot, resolvedUid);
  }

  /// =======================
  /// MOVIMENTAÇÕES MENSAIS (ONCE)
  /// =======================
  Future<List<Movement>> getMonthlyMovements({
    required int month,
    required int year,
    String? uid,
  }) async {
    final resolvedUid = _resolveUid(uid);

    final start = DateTime(year, month, 1);
    final end =
        month < 12 ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(resolvedUid)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    return _mapSnapshotToMovements(snapshot, resolvedUid);
  }

  /// =======================
  /// MOVIMENTAÇÕES ANUAIS (ONCE)
  /// =======================
  Future<List<Movement>> getYearlyMovements({
    required int year,
    String? uid,
  }) async {
    final resolvedUid = _resolveUid(uid);

    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(resolvedUid)
        .collection('movements')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    return _mapSnapshotToMovements(snapshot, resolvedUid);
  }

  /// =======================
  /// MAPPER CENTRAL
  /// =======================
  Future<List<Movement>> _mapSnapshotToMovements(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String uid,
  ) async {
    final movements = <Movement>[];

    for (final doc in snapshot.docs) {
      final productId = doc.data()['productId'] as String? ?? '';
      final image = await _getProductImage(uid, productId);

      movements.add(
        Movement.fromFirestore(doc, productImage: image),
      );
    }

    return movements;
  }
}
