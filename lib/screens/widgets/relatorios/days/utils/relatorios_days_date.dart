// lib/screens/widgets/relatorios/days/utils/relatorios_days_date.dart
import 'package:intl/intl.dart';
import '../../../../../l10n/app_localizations.dart';

String relatoriosDisplayDateText({
  required DateTime displayDate,
  required DateTime now,
  required AppLocalizations l10n,
}) {
  final isToday =
      displayDate.year == now.year &&
      displayDate.month == now.month &&
      displayDate.day == now.day;

  if (isToday) return l10n.relatoriosToday;
  return DateFormat('dd/MM/yyyy').format(displayDate);
}

String relatoriosFormatDateTitle(DateTime date) {
  // Mantém pt_BR (igual seu código original)
  final weekday = DateFormat('EEEE', 'pt_BR').format(date);
  final day = DateFormat('dd', 'pt_BR').format(date);
  final month = DateFormat('MMMM', 'pt_BR').format(date);

  final w = '${weekday[0].toUpperCase()}${weekday.substring(1)}';
  final m = '${month[0].toUpperCase()}${month.substring(1)}';

  return '$w, $day de $m de ${date.year}';
}
