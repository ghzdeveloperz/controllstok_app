import 'package:flutter/foundation.dart';

/// Controlador global para manter o período anual sincronizado
/// entre RelatoriosYears e RelatoriosForProductYears.
class AnnualReportPeriodController {
  static const List<String> options = <String>[
    'Ano inteiro',
    '1º Trimestre (Jan–Mar)',
    '2º Trimestre (Abr–Jun)',
    '3º Trimestre (Jul–Set)',
    '4º Trimestre (Out–Dez)',
    '1º Semestre (Jan–Jun)',
    '2º Semestre (Jul–Dez)',
    'Últimos 3 meses (Out–Dez)',
    'Últimos 6 meses (Jul–Dez)',
  ];

  /// Valor atual sincronizado
  static final ValueNotifier<String> period =
      ValueNotifier<String>('Ano inteiro');
}