// lib/screens/widgets/relatorios/days/for_product/utils/relatorios_for_products_date.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../models/report_period.dart';

String relatoriosForProductDisplayDateText({
  required DateTime displayDate,
  required DateTime now,
  required AppLocalizations l10n,
  required BuildContext context,
}) {
  if (displayDate.year == now.year &&
      displayDate.month == now.month &&
      displayDate.day == now.day) {
    return l10n.relatoriosToday;
  }

  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat('dd/MM/yyyy', locale).format(displayDate);
}

String relatoriosForProductFormatDateTitle({
  required DateTime date,
  required ReportPeriod period,
  required BuildContext context,
}) {
  final locale = Localizations.localeOf(context).toLanguageTag();

  if (period.isMonth) {
    final month = DateFormat('MMMM', locale).format(date);
    final cap = month.isNotEmpty ? '${month[0].toUpperCase()}${month.substring(1)}' : month;
    return '$cap ${DateFormat('y', locale).format(date)}';
  }

  final weekday = DateFormat('EEEE', locale).format(date);
  final day = DateFormat('dd', locale).format(date);
  final month = DateFormat('MMMM', locale).format(date);

  final w = weekday.isNotEmpty ? '${weekday[0].toUpperCase()}${weekday.substring(1)}' : weekday;
  final m = month.isNotEmpty ? '${month[0].toUpperCase()}${month.substring(1)}' : month;

  // Ex: "Sábado, 25 de Janeiro de 2026" (depende do locale)
  return '$w, $day $m ${DateFormat('y', locale).format(date)}';
}
