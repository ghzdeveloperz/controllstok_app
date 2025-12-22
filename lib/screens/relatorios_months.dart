// lib/screens/relatorios_months.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';
import '../firebase/movements_days.dart';

class RelatoriosMonths extends StatefulWidget {
  final String userId;

  const RelatoriosMonths({super.key, required this.userId});

  @override
  State<RelatoriosMonths> createState() => _RelatoriosMonthsState();
}

class _RelatoriosMonthsState extends State<RelatoriosMonths> {
  bool _localeReady = false;
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();
  late DateTime _displayMonth;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);

    _timer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    setState(() => _localeReady = true);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _displayMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _displayMonth = DateTime(picked.year, picked.month));
    }
  }

  String get _displayMonthText {
    final now = DateTime.now();
    return (_displayMonth.year == now.year && _displayMonth.month == now.month)
        ? 'Este mês'
        : DateFormat('MM/yyyy').format(_displayMonth);
  }

  String _formatMonthTitle(DateTime date) {
    final monthName = DateFormat('MMMM', 'pt_BR').format(date);
    final year = date.year;
    return '${monthName[0].toUpperCase()}${monthName.substring(1)} de $year';
  }

  void _saveReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relatório mensal salvo com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeReady) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        _buildHeaderButtons(),
        const SizedBox(height: 8),
        Expanded(child: _buildChartSection()),
      ],
    );
  }

  Widget _buildHeaderButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickMonth,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      _displayMonthText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
                side: const BorderSide(color: Colors.black),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Salvar Relatório',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return StreamBuilder<List<Movement>>(
      stream: _movementsService.getMonthlyMovementsStream(
        userId: widget.userId,
        month: _displayMonth.month,
        year: _displayMonth.year,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final movements = snapshot.data!;
        if (movements.isEmpty) {
          return Center(
            child: Text(
              'Nenhuma movimentação em ${DateFormat('MM/yyyy').format(_displayMonth)}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
        final dailyTotals = List.generate(daysInMonth, (_) => {'add': 0, 'remove': 0});

        for (final m in movements) {
          if (m.date.month == _displayMonth.month && m.date.year == _displayMonth.year) {
            final dayIndex = m.date.day - 1;
            if (m.type == 'add') {
              dailyTotals[dayIndex]['add'] = dailyTotals[dayIndex]['add']! + m.quantity;
            } else if (m.type == 'remove') {
              dailyTotals[dayIndex]['remove'] = dailyTotals[dayIndex]['remove']! + m.quantity;
            }
          }
        }

        final barGroups = List.generate(daysInMonth, (index) {
          final day = index + 1;
          return BarChartGroupData(
            x: day,
            barRods: [
              BarChartRodData(
                toY: dailyTotals[index]['add']!.toDouble(),
                color: Colors.green,
                width: 8,
              ),
              BarChartRodData(
                toY: dailyTotals[index]['remove']!.toDouble(),
                color: Colors.red,
                width: 8,
              ),
            ],
            barsSpace: 4,
          );
        });

        final maxY = dailyTotals
                .map((e) => e['add']! + e['remove']!)
                .reduce((a, b) => a > b ? a : b)
                .toDouble() +
            5;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _formatMonthTitle(_displayMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: maxY,
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 5),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(Colors.green, 'Entrada'),
                  const SizedBox(width: 16),
                  _buildLegend(Colors.red, 'Saída'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
