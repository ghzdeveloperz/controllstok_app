// lib/screens/widgets/relatorios/days/for_product/relatorios_for_products_days.dart
import 'package:flutter/material.dart';

import '../../../../models/report_period.dart';
import '../../../../models/month_reference.dart';

import 'relatorios_for_products_days_state.dart';

class RelatoriosForProducts extends StatefulWidget {
  final String productId;
  final String uid;

  /// ✅ PERÍODO DO RELATÓRIO (não mais DateTime ambíguo)
  final ReportPeriod period;

  const RelatoriosForProducts({
    super.key,
    required this.productId,
    required this.uid,
    required this.period,
  });

  /// Construtor de compatibilidade para código legado que passa DateTime
  /// @deprecated Use o construtor principal com ReportPeriod
  factory RelatoriosForProducts.fromDate({
    required String productId,
    required String uid,
    required DateTime date,
  }) {
    final period = date.day == 1
        ? ReportPeriod.month(MonthReference.fromDateTime(date))
        : ReportPeriod.day(date);

    return RelatoriosForProducts(
      productId: productId,
      uid: uid,
      period: period,
    );
  }

  @override
  State<RelatoriosForProducts> createState() => RelatoriosForProductsState();
}
