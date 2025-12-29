/// Representa um intervalo de datas (startDate até endDate, inclusive).
///
/// Esta classe é útil para consultas de período em relatórios e queries Firestore.
///
/// Exemplo de uso:
/// ```dart
/// final range = DateRange(
///   startDate: DateTime(2024, 3, 1),
///   endDate: DateTime(2024, 3, 31, 23, 59, 59),
/// );
///
/// if (range.contains(someDate)) {
///   print('Data está no intervalo');
/// }
/// ```
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate})
    : assert(
        !endDate.isBefore(startDate),
        'endDate deve ser igual ou posterior a startDate',
      );

  /// Cria um DateRange para um mês completo
  ///
  /// Exemplo: DateRange.monthly(2024, 3) retorna 1º a 31 de março de 2024
  factory DateRange.monthly(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = month < 12
        ? DateTime(year, month + 1, 1).subtract(const Duration(microseconds: 1))
        : DateTime(year + 1, 1, 1).subtract(const Duration(microseconds: 1));
    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// Cria um DateRange para um dia específico (00:00:00 até 23:59:59.999)
  factory DateRange.daily(DateTime day) {
    final startDate = DateTime(day.year, day.month, day.day);
    final endDate = startDate
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));
    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// Cria um DateRange para um ano completo
  factory DateRange.yearly(int year) {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(
      year + 1,
      1,
      1,
    ).subtract(const Duration(microseconds: 1));
    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// Retorna a data de início para queries Firestore (>= startDate)
  DateTime get firestoreStart => startDate;

  /// Retorna a data de fim para queries Firestore (< endDateExclusive)
  ///
  /// Firestore usa comparação exclusiva no limite superior,
  /// então retornamos o próximo microsegundo após endDate
  DateTime get firestoreEnd => endDate.add(const Duration(microseconds: 1));

  /// Duração do intervalo em dias (arredondado)
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Duração do intervalo
  Duration get duration => endDate.difference(startDate);

  /// Verifica se uma data está dentro do intervalo (inclusive)
  bool contains(DateTime date) {
    return (date.isAtSameMomentAs(startDate) || date.isAfter(startDate)) &&
        (date.isAtSameMomentAs(endDate) || date.isBefore(endDate));
  }

  /// Verifica se este intervalo se sobrepõe a outro
  bool overlaps(DateRange other) {
    return contains(other.startDate) ||
        contains(other.endDate) ||
        other.contains(startDate) ||
        other.contains(endDate);
  }

  /// Verifica se este intervalo contém completamente outro intervalo
  bool containsRange(DateRange other) {
    return contains(other.startDate) && contains(other.endDate);
  }

  @override
  String toString() => 'DateRange(start: $startDate, end: $endDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
