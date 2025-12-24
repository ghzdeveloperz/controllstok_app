import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../firebase/movements_days.dart';
import '../screens/models/salve_modal.dart';

class RelatoriosMonths extends StatefulWidget {
  const RelatoriosMonths({super.key});

  @override
  State<RelatoriosMonths> createState() => _RelatoriosMonthsState();
}

class _RelatoriosMonthsState extends State<RelatoriosMonths> {
  final MovementsDaysFirestore _movementsService =
      MovementsDaysFirestore();

  bool _localeReady = false;
  late DateTime _displayMonth;
  late String _uid;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    // 🔒 Proteção: usuário não logado
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    _uid = user.uid;
    _displayMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );

    _initializeLocale();

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
    if (mounted) {
      setState(() => _localeReady = true);
    }
  }

  String _formatMonthTitle(DateTime date) {
    final monthName = DateFormat('MMMM', 'pt_BR').format(date);
    return '${monthName[0].toUpperCase()}${monthName.substring(1)} de ${date.year}';
  }

  Widget _buildBarChart(List<Movement> movements) {
    final Map<int, int> addByDay = {};
    final Map<int, int> removeByDay = {};

    for (final m in movements) {
      final day = m.date.day;
      if (m.type == 'add') {
        addByDay[day] = (addByDay[day] ?? 0) + m.quantity;
      } else {
        removeByDay[day] = (removeByDay[day] ?? 0) + m.quantity;
      }
    }

    final daysInMonth = DateUtils.getDaysInMonth(
      _displayMonth.year,
      _displayMonth.month,
    );

    const double dayWidth = 50;
    final double chartWidth = daysInMonth * dayWidth;

    final barGroups = List.generate(daysInMonth, (index) {
      final day = index + 1;
      return BarChartGroupData(
        x: day,
        barsSpace: 8,
        barRods: [
          BarChartRodData(
            toY: (addByDay[day] ?? 0).toDouble(),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          BarChartRodData(
            toY: (removeByDay[day] ?? 0).toDouble(),
            gradient: const LinearGradient(
              colors: [Color(0xFFF44336), Color(0xFFEF5350)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 12,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    final maxY = barGroups
            .expand((e) => e.barRods)
            .map((e) => e.toY)
            .fold<double>(0, (p, c) => c > p ? c : p) +
        5;

    return SizedBox(
      height: 350,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth < MediaQuery.of(context).size.width
              ? MediaQuery.of(context).size.width
              : chartWidth,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            ),
          ),
        ),
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
      body: StreamBuilder<List<Movement>>(
        stream: _movementsService.getMonthlyMovementsStream(
          uid: _uid, // ✅ UID do Firebase Auth
          month: _displayMonth.month,
          year: _displayMonth.year,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final movements = snapshot.data!;
          if (movements.isEmpty) {
            return const Center(
              child: Text('Nenhuma movimentação'),
            );
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _formatMonthTitle(_displayMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildBarChart(movements),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SalveModal.show(context),
        backgroundColor: const Color(0xFF1A1A1A),
        child: const Icon(Icons.save),
      ),
    );
  }
}
