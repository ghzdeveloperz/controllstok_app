// lib/screens/home/home_tabs.dart
import 'package:flutter/material.dart';

import '../estoque_screen.dart';
import '../products/new_product/novo_produto_screen.dart';
import '../scanner_screen.dart';
import '../relatorios_screen.dart';
import '../alertas/alertas_screen.dart';
import '../models/product.dart';

typedef ProductsLoaded = void Function(List<Product> products);

class HomeTabs {
  static const int estoqueIndex = 0;
  static const int novoProdutoIndex = 1;
  static const int scannerIndex = 2;
  static const int relatoriosIndex = 3;
  static const int alertasIndex = 4;

  static List<Widget> build({
    required String uid,
    required ProductsLoaded onProductsLoaded,
    required VoidCallback onProductSaved,
  }) {
    return [
      EstoqueScreen(uid: uid, onProductsLoaded: onProductsLoaded),
      NovoProdutoScreen(uid: uid, onProductSaved: onProductSaved),
      const SizedBox(), // placeholder do scanner (modal/push)
      const RelatoriosScreen(),
      AlertasScreen(uid: uid),
    ];
  }

  static void openScanner(BuildContext context, {required String uid}) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ScannerScreen(uid: uid)));
  }
}
