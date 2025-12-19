import 'package:cloud_firestore/cloud_firestore.dart';

class StockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 Atualiza estoque e recalcula custo médio (SOMENTE EM ENTRADA)
  Future<void> registerMovement({
    required String userLogin,
    required String barcode,
    required int quantity,
    required double unitCost, // preço informado na entrada
    required String type, // entrada | saida
  }) async {
    final query = await _firestore
        .collection('users')
        .doc(userLogin)
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final docRef = query.docs.first.reference;
    final data = query.docs.first.data();

    final int currentStock = (data['stock'] ?? 0);
    final double currentCost = (data['cost'] ?? 0).toDouble();

    if (type == 'entrada') {
      // 📐 cálculo do custo médio
      final newStock = currentStock + quantity;

      final newCost = newStock == 0
          ? unitCost
          : ((currentStock * currentCost) +
                  (quantity * unitCost)) /
              newStock;

      await docRef.update({
        'stock': newStock,
        'cost': newCost,
        'unitPrice': unitCost, // opcional: atualizar preço de venda
      });
    } else {
      // 🔻 saída NÃO altera custo médio
      await docRef.update({
        'stock': currentStock - quantity,
      });
    }
  }
}
