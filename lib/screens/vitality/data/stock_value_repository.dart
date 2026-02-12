// lib/screens/vitality/data/stock_value_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StockValueRepository {
  const StockValueRepository();

  Stream<double> watchTotalStockValue({required String uid}) {
    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products');

    return query.snapshots().map((snap) {
      double total = 0;

      for (final doc in snap.docs) {
        final data = doc.data();

        // Tentativas tolerantes: seu modelo pode variar.
        final quantity = _toInt(data['quantity']) ??
            _toInt(data['qtd']) ??
            _toInt(data['stock']) ??
            0;

        // Pode ser "value", "price", "cost", etc.
        final unitValue = _toDouble(data['value']) ??
            _toDouble(data['price']) ??
            _toDouble(data['cost']) ??
            _toDouble(data['unitValue']) ??
            0.0;

        if (quantity <= 0 || unitValue <= 0) continue;

        total += quantity * unitValue;
      }

      return total;
    });
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim().replaceAll('.', '').replaceAll(',', '.');
      // acima: ajuda com "1.234,56" e "1234,56"
      return double.tryParse(s);
    }
    return null;
  }
}
