// lib/screens/widgets/product_card/product_status.dart
import 'package:flutter/material.dart';

enum ProductStockStatus {
  unavailable,
  critical,
  available,
}

extension ProductStockStatusX on ProductStockStatus {
  Color color() {
    switch (this) {
      case ProductStockStatus.unavailable:
        return Colors.red.shade600;
      case ProductStockStatus.critical:
        return Colors.orange.shade600;
      case ProductStockStatus.available:
        return Colors.green.shade600;
    }
  }
}
