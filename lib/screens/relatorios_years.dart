import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../firebase/movements_days.dart';
import '../screens/models/salve_modal.dart';

/// =======================
/// LEGEND WIDGET
/// =======================
class Legend {
  final String name;
  final Color color;
  Legend(this.name, this.color);
}

class LegendsListWidget extends StatelessWidget {
  final List<Legend> legends;

  const LegendsListWidget({
    super.key,
    required this.legends,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: legends
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: e.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

/// =======================
/// RELATÓRIO ANUAL
/// =======================
class RelatoriosYears extends StatefulWidget {
  final String userId;

  const RelatoriosYears({
    super.key,
    required this.userId,
  });

  @override
  State<RelatoriosYears> createState() => _RelatoriosYearsState();
}

class _RelatoriosYearsState extends State<RelatoriosYears> {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;
  late int _displayYear;
  List<Movement> _movements = [];

  @override
  void initState() {
    super.initState();
    _displayYear = DateTime.now().year;
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    if (!mounted) return;

    setState(() => _localeReady = true);
    await _fetchMovements();
  }

  Future<void> _pickYear() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) {
        int selectedYear = _displayYear;

        return AlertDialog(
          title: const Text('Selecione o ano'),
          content: SizedBox(
            height: 200,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(DateTime.now().year + 5),
              selectedDate: DateTime(_displayYear),
              onChanged: (dateTime) {
                selectedYear = dateTime.year;
                Navigator.pop(context, selectedYear);
              },
            ),
          ),
        );
      },
    );

    if (picked != null && picked != _displayYear) {
      setState(() => _displayYear = picked);
      await _fetchMovements();
    }
  }

  Future<void> _fetchMovements() async {
    final data = await _movementsService.getYearlyMovements(
      year: _displayYear,
      uid: widget.userId, // ✅ CONTRATO CORRETO
    );

    if (!mounted) return;
    setState(() => _movements = data);
  }

  /// =======================
  /// CHART
  /// =======================
  Widget _buildBarChart() {
    final Map<int, int> addByMonth = {};
    final Map<int, int> removeByMonth = {};

    for (final m in _movements) {
      final month = m.date.month;
      if (m.type == 'add') {
        addByMonth[month] = (addByMonth[month] ?? 0) + m.quantity;
      } else {
        removeByMonth[month] = (removeByMonth[month] ?? 0) + m.quantity;
      }
    }

    final barGroups = List.generate(12, (i) {
      final month = i + 1;
      final add = addByMonth[month]?.toDouble() ?? 0;
      final remove = removeByMonth[month]?.toDouble() ?? 0;

      return BarChartGroupData(
        x: i,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: add,
            width: 14,
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF1B5E20)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          BarChartRodData(
            fromY: add,
            toY: add + remove,
            width: 14,
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });

    final maxY = barGroups
            .expand((e) => e.barRods)
            .map((e) => e.toY)
            .fold<double>(0, (p, c) => c > p ? c : p) +
        5;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movimentações Anuais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LegendsListWidget(
            legends: [
              Legend('Entradas', Color(0xFF00E676)),
              Legend('Saídas', Color(0xFFFF5252)),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 5,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const months = [
                          'JAN',
                          'FEV',
                          'MAR',
                          'ABR',
                          'MAI',
                          'JUN',
                          'JUL',
                          'AGO',
                          'SET',
                          'OUT',
                          'NOV',
                          'DEZ',
                        ];
                        return Text(
                          months[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickYear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF424242)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _displayYear.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => SalveModal.show(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Exportar Relatório'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _movements.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma movimentação em $_displayYear',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView(
                    children: [
                      _buildBarChart(),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
