// lib/screens/alertas/models/stock_alert_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StockAlertItem {
  final String id;
  final String name;
  final String? imageUrl;
  final int quantity;
  final int minStock;

  StockAlertItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.minStock,
  });

  factory StockAlertItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final name = (data['name'] ?? '').toString().trim();
    final image = (data['image'] ?? '').toString().trim();
    final quantity = int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
    final minStock = int.tryParse(data['minStock']?.toString() ?? '0') ?? 0;

    return StockAlertItem(
      id: doc.id,
      name: name.isEmpty ? '—' : name,
      imageUrl: image.isEmpty ? null : image,
      quantity: quantity,
      minStock: minStock,
    );
  }

  bool matchesSearch(String queryLower) {
    if (queryLower.isEmpty) return true;
    return name.toLowerCase().contains(queryLower);
  }

  bool get isZero => quantity == 0;
  bool get isCritical => quantity > 0 && quantity <= minStock;
}
