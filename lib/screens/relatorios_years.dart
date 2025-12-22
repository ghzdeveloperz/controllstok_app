import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../firebase/movements_days.dart';

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
  const LegendsListWidget({super.key, required this.legends});

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
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: e.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
  const RelatoriosYears({super.key, required this.userId});

  @override
  State<RelatoriosYears> createState() => _RelatoriosYearsState();
}

class _RelatoriosYearsState extends State<RelatoriosYears> {
  bool _localeReady = false;
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();
  late int _displayYear;
  List<Movement> _movements = [];

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _displayYear = DateTime.now().year;
    _fetchMovements();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    setState(() => _localeReady = true);
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

    if (picked != null) {
      setState(() => _displayYear = picked);
      _fetchMovements();
    }
  }

  Future<void> _fetchMovements() async {
    final data = await _movementsService.getYearlyMovements(
      userId: widget.userId,
      year: _displayYear,
    );
    setState(() => _movements = data);
  }

  void _saveReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Relatório anual salvo com sucesso!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });

    final maxY =
        [
          ...barGroups.expand((e) => e.barRods).map((e) => e.toY),
        ].fold<double>(0, (p, c) => c > p ? c : p) +
        5;

    Widget bottomTitles(double value, TitleMeta meta) {
      const style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold);
      const monthNames = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];
      return SideTitleWidget(
        meta: meta,
        child: Text(monthNames[value.toInt()], style: style),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movimentações Anuais',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LegendsListWidget(
            legends: [
              Legend('Entradas', const Color(0xFF00E676)),
              Legend('Saídas', const Color(0xFFFF5252)),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 20,
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = group.x + 1;
                      final add = addByMonth[month] ?? 0;
                      final remove = removeByMonth[month] ?? 0;
                      return BarTooltipItem(
                        'Entradas: $add\nSaídas: $remove',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
    if (!_localeReady) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _displayYear.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saveReport,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF1A1A1A),
                        width: 2,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text(
                          'Salvar Relatório',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Relatório Anual $_displayYear',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
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
