// lib/screens/widgets/relatorios/days/utils/relatorios_days_date.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/app_localizations.dart';

String relatoriosDisplayDateText({
  required DateTime displayDate,
  required DateTime now,
  required AppLocalizations l10n,
  required BuildContext context,
}) {
  final isToday =
      displayDate.year == now.year &&
      displayDate.month == now.month &&
      displayDate.day == now.day;

  if (isToday) return l10n.relatoriosToday;

  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat('dd/MM/yyyy', locale).format(displayDate);
}

String relatoriosFormatDateTitle({
  required DateTime date,
  required BuildContext context,
}) {
  final locale = Localizations.localeOf(context).toLanguageTag();

  final weekday = DateFormat('EEEE', locale).format(date);
  final day = DateFormat('dd', locale).format(date);
  final month = DateFormat('MMMM', locale).format(date);
  final year = DateFormat('y', locale).format(date);

  final w = weekday.isNotEmpty
      ? '${weekday[0].toUpperCase()}${weekday.substring(1)}'
      : weekday;

  final m = month.isNotEmpty
      ? '${month[0].toUpperCase()}${month.substring(1)}'
      : month;

  // Observação: cada idioma tem gramática diferente.
  // Mantemos um formato "neutro" como no for_product:
  // Ex: "Saturday, 25 January 2026" / "Samstag, 25. Januar 2026" (depende do locale)
  return '$w, $day $m $year';
}
