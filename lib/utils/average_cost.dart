class StockEntry {
  final int quantity;
  final double unitCost;

  StockEntry({required this.quantity, required this.unitCost});
}

class AverageCostCalculator {
  /// Calcula o custo médio de uma lista de entradas
  static double calculateAverageCost(List<StockEntry> entries) {
    final totalQuantity = entries.fold<int>(0, (sum, e) => sum + e.quantity);
    if (totalQuantity == 0) return 0.0;

    final totalCost = entries.fold<double>(
      0.0,
      (sum, e) => sum + e.quantity * e.unitCost,
    );

    return totalCost / totalQuantity;
  }
}
