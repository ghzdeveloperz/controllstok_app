import 'date_range.dart';

/// Representa uma referência explícita a um mês específico (ano + mês).
///
/// Esta classe resolve a ambiguidade de usar DateTime para representar meses,
/// onde DateTime(2024, 3, 1) poderia ser interpretado como "1º de março" ou "março inteiro".
///
/// Exemplo de uso:
/// ```dart
/// final march2024 = MonthReference(year: 2024, month: 3);
/// final dateRange = march2024.toDateRange(); // 1º a 31 de março
/// ```
class MonthReference {
  final int year;
  final int month;

  const MonthReference({required this.year, required this.month})
    : assert(month >= 1 && month <= 12, 'Mês deve estar entre 1 e 12');

  /// Cria uma referência para o mês atual
  factory MonthReference.now() {
    final now = DateTime.now();
    return MonthReference(year: now.year, month: now.month);
  }

  /// Cria uma referência a partir de um DateTime (usa apenas year e month)
  factory MonthReference.fromDateTime(DateTime date) {
    return MonthReference(year: date.year, month: date.month);
  }

  /// Retorna o primeiro dia do mês (00:00:00)
  DateTime get firstDay => DateTime(year, month, 1);

  /// Retorna o último dia do mês (23:59:59.999)
  DateTime get lastDay {
    final nextMonth = month < 12
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return nextMonth.subtract(const Duration(microseconds: 1));
  }

  /// Retorna o último dia do mês às 00:00:00 (útil para queries Firestore)
  DateTime get lastDayStart {
    return month < 12 ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
  }

  /// Converte para DateRange (intervalo completo do mês)
  DateRange toDateRange() {
    return DateRange(startDate: firstDay, endDate: lastDay);
  }

  /// Retorna o número de dias no mês
  int get daysInMonth {
    return lastDayStart.difference(firstDay).inDays;
  }

  /// Verifica se é o mês atual
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Verifica se uma data está dentro deste mês
  bool contains(DateTime date) {
    return date.year == year && date.month == month;
  }

  /// Retorna o mês anterior
  MonthReference get previousMonth {
    if (month == 1) {
      return MonthReference(year: year - 1, month: 12);
    }
    return MonthReference(year: year, month: month - 1);
  }

  /// Retorna o próximo mês
  MonthReference get nextMonth {
    if (month == 12) {
      return MonthReference(year: year + 1, month: 1);
    }
    return MonthReference(year: year, month: month + 1);
  }

  /// Formata como "MM/YYYY"
  String format([String separator = '/']) {
    return '${month.toString().padLeft(2, '0')}$separator$year';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthReference &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  @override
  String toString() => 'MonthReference($month/$year)';

  /// Compara dois meses
  int compareTo(MonthReference other) {
    if (year != other.year) return year.compareTo(other.year);
    return month.compareTo(other.month);
  }

  /// Verifica se este mês é antes de outro
  bool isBefore(MonthReference other) => compareTo(other) < 0;

  /// Verifica se este mês é depois de outro
  bool isAfter(MonthReference other) => compareTo(other) > 0;
}
