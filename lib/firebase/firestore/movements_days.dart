// lib/firebase/movements_days.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// =======================
/// MODEL (HISTÓRICO IMUTÁVEL)
/// =======================
/// Regra de ouro:
/// - Uma Movement é um fato histórico.
/// - Dados econômicos (preço/custo/estoque) DEVEM vir do próprio documento da movimentação.
/// - A coleção products pode ser usada apenas para dados visuais (ex.: imagem).
class Movement {
  final String id;

  /// Identidade do produto (para vínculo e imagem)
  final String productId;

  /// Snapshot do nome no momento da movimentação (não depender de products)
  final String productName;

  /// add | remove
  final String type;

  /// Quantidade movimentada
  final int quantity;

  /// Preço unitário usado NAQUELA movimentação (snapshot)
  final double unitPrice;

  /// Custo médio (ou custo) NO MOMENTO da movimentação (snapshot)
  ///
  /// - Pode ser null em movimentações antigas (compatibilidade).
  /// - Relatórios devem usar esse campo (com fallback seguro).
  final double? costAtMovement;

  /// Categoria do produto no momento da movimentação (snapshot)
  final String? category;

  /// Código de barras usado naquela movimentação (snapshot)
  final String? barcode;

  /// Estoque resultante após a movimentação (snapshot)
  /// - Pode ser null para movimentações antigas.
  final int? stockAfter;

  /// Momento do registro
  final DateTime timestamp;

  /// Dado visual (pode vir de products)
  final String? image;

  Movement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.timestamp,
    this.costAtMovement,
    this.category,
    this.barcode,
    this.stockAfter,
    this.image,
  });

  DateTime get date => timestamp;

  /// Fallback seguro para relatórios antigos:
  /// - Se não houver custo histórico, retorna 0.0 (não quebra o app).
  double get costAtMovementSafe => costAtMovement ?? 0.0;

  /// Fallback seguro para relatórios antigos:
  /// - Se não houver estoque pós-movimentação, retorna null-aware via getter (0 como padrão).
  int get stockAfterSafe => stockAfter ?? 0;

  factory Movement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? productImage,
  }) {
    final data = doc.data() ?? {};

    // Compatibilidade com campos antigos:
    // - timestamp pode estar em 'timestamp' ou 'createdAt'
    // - custo pode estar em 'costAtMovement' (novo) ou (eventualmente) 'cost' (antigo)
    final Timestamp? ts = data['timestamp'] as Timestamp? ?? data['createdAt'] as Timestamp?;

    return Movement(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      type: data['type'] as String? ?? 'add',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,

      // IMPORTANTÍSSIMO: ler SEMPRE do documento de movimentação (snapshot histórico)
      costAtMovement: (data['costAtMovement'] as num?)?.toDouble() ??
          (data['cost'] as num?)?.toDouble(), // fallback opcional p/ legado
      category: data['category'] as String?,
      barcode: data['barcode'] as String?,
      stockAfter: (data['stockAfter'] as num?)?.toInt(),

      timestamp: ts?.toDate() ?? DateTime.now(),
      image: productImage, // visual (permitido vir de products)
    );
  }

  /// Opcional: útil para criar/atualizar documentos de movimentação já com snapshot completo.
  /// (Não é obrigatório para a leitura/relatórios, mas ajuda a manter o padrão.)
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'type': type,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'costAtMovement': costAtMovement,
      'category': category,
      'barcode': barcode,
      'stockAfter': stockAfter,
      'timestamp': Timestamp.fromDate(timestamp),
      // 'image' não é armazenada aqui por padrão (vem de products), mas poderia ser se desejar.
    };
  }
}

/// =======================
/// SERVICE (APENAS CONSULTA + MAP)
// =======================
/// Responsabilidades:
/// - Resolver UID
/// - Buscar movimentações por intervalo (stream/once)
/// - Mapear snapshots em Movement
/// - (Opcional) Buscar imagem do produto (visual) com cache
///
/// NÃO deve:
/// - Buscar cost/unitPrice/stock atual em products
/// - Recalcular valores históricos
class MovementsDaysFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cache local de imagens por productId (dado visual)
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
  /// (visual, permitido)
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
        .asyncMap((snapshot) => _mapSnapshotToMovements(snapshot, resolvedUid));
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
        .asyncMap((snapshot) => _mapSnapshotToMovements(snapshot, resolvedUid));
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
  /// - NÃO recalcula nada
  /// - NÃO busca dados financeiros em products
  /// - Apenas injeta imagem (visual) quando possível
  /// =======================
  Future<List<Movement>> _mapSnapshotToMovements(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String uid,
  ) async {
    if (snapshot.docs.isEmpty) return [];

    // Otimização: buscar imagens em paralelo (mantendo cache).
    final productIds = snapshot.docs
        .map((d) => (d.data()['productId'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    // Pré-carrega imagens necessárias (em paralelo).
    await Future.wait(productIds.map((productId) => _getProductImage(uid, productId)));

    // Monta lista final usando cache.
    final movements = <Movement>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final productId = (data['productId'] as String?) ?? '';
      final image = productId.isEmpty ? null : _productImageCache[productId];

      movements.add(Movement.fromFirestore(doc, productImage: image));
    }

    return movements;
  }
}