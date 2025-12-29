import 'package:flutter/foundation.dart';

/// Controlador global para manter o período (Últimos 7/14/...) sincronizado
/// entre RelatoriosMonths e RelatoriosForProdutoMounth.
class MonthlyReportPeriodController {
  static const List<String> options = <String>[
    'Últimos 7 dias',
    'Últimos 14 dias',
    'Últimos 21 dias',
    'Últimos 28 dias',
    'Mês inteiro',
  ];

  /// Valor atual sincronizado
  static final ValueNotifier<String> period =
      ValueNotifier<String>('Últimos 7 dias');
}