import 'date_range.dart';
import 'month_reference.dart';

/// Tipo de período para relatórios
enum ReportPeriodType {
  /// Relatório de um dia específico
  day,

  /// Relatório de um mês completo
  month,

  /// Relatório de um intervalo customizado
  custom,
}

/// Representa um período de tempo para relatórios.
///
/// Esta classe resolve a ambiguidade de passar DateTime para telas de relatório,
/// deixando explícito se estamos lidando com um dia, mês ou intervalo customizado.
///
/// Exemplos de uso:
/// ```dart
/// // Relatório de um dia específico
/// final dayReport = ReportPeriod.day(DateTime(2024, 3, 15));
///
/// // Relatório de um mês completo
/// final monthReport = ReportPeriod.month(MonthReference(year: 2024, month: 3));
///
/// // Relatório de intervalo customizado
/// final customReport = ReportPeriod.custom(
///   DateRange(
///     startDate: DateTime(2024, 3, 1),
///     endDate: DateTime(2024, 3, 15),
///   ),
/// );
/// ```
class ReportPeriod {
  final ReportPeriodType type;
  final DateRange dateRange;

  /// Referência ao mês (apenas para type == month)
  final MonthReference? monthReference;

  /// Data específica (apenas para type == day)
  final DateTime? specificDay;

  const ReportPeriod._({
    required this.type,
    required this.dateRange,
    this.monthReference,
    this.specificDay,
  });

  /// Cria um período para um dia específico
  factory ReportPeriod.day(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    return ReportPeriod._(
      type: ReportPeriodType.day,
      dateRange: DateRange(startDate: startOfDay, endDate: endOfDay),
      specificDay: startOfDay,
    );
  }

  /// Cria um período para um mês completo
  factory ReportPeriod.month(MonthReference month) {
    return ReportPeriod._(
      type: ReportPeriodType.month,
      dateRange: month.toDateRange(),
      monthReference: month,
    );
  }

  /// Cria um período customizado
  factory ReportPeriod.custom(DateRange range) {
    return ReportPeriod._(type: ReportPeriodType.custom, dateRange: range);
  }

  /// Cria um período para o mês atual
  factory ReportPeriod.currentMonth() {
    return ReportPeriod.month(MonthReference.now());
  }

  /// Cria um período para hoje
  factory ReportPeriod.today() {
    return ReportPeriod.day(DateTime.now());
  }

  /// Retorna true se este período representa um dia específico
  bool get isDay => type == ReportPeriodType.day;

  /// Retorna true se este período representa um mês completo
  bool get isMonth => type == ReportPeriodType.month;

  /// Retorna true se este período é customizado
  bool get isCustom => type == ReportPeriodType.custom;

  /// Data de início do período
  DateTime get startDate => dateRange.startDate;

  /// Data de fim do período
  DateTime get endDate => dateRange.endDate;

  /// Duração do período em dias
  int get durationInDays {
    return dateRange.endDate.difference(dateRange.startDate).inDays + 1;
  }

  /// Verifica se uma data está dentro deste período
  bool contains(DateTime date) {
    return dateRange.contains(date);
  }

  /// Retorna uma descrição legível do período
  String getDescription() {
    switch (type) {
      case ReportPeriodType.day:
        if (specificDay != null) {
          final now = DateTime.now();
          if (specificDay!.year == now.year &&
              specificDay!.month == now.month &&
              specificDay!.day == now.day) {
            return 'Hoje';
          }
          return '${specificDay!.day}/${specificDay!.month}/${specificDay!.year}';
        }
        return 'Dia específico';

      case ReportPeriodType.month:
        if (monthReference != null) {
          if (monthReference!.isCurrentMonth) {
            return 'Este mês';
          }
          return monthReference!.format();
        }
        return 'Mês';

      case ReportPeriodType.custom:
        return '${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}';
    }
  }

  @override
  String toString() {
    return 'ReportPeriod(type: $type, range: ${dateRange.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportPeriod &&
        other.type == type &&
        other.dateRange == dateRange;
  }

  @override
  int get hashCode => type.hashCode ^ dateRange.hashCode;
}
