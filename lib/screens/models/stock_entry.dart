// lib/models/stock_entry.dart
class StockEntry {
  final int quantity;
  final double cost;

  StockEntry({
    required this.quantity,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'cost': cost,
    };
  }
}
