import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../firebase/movements_days.dart';
import '../screens/models/salve_modal.dart';

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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1A1A), // Preto elegante
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _displayMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  String get _displayMonthText {
    final now = DateTime.now();
    if (_displayMonth.year == now.year && _displayMonth.month == now.month) {
      return 'Este mês';
    }
    return DateFormat('MM/yyyy').format(_displayMonth);
  }

  String _formatMonthTitle(DateTime date) {
    final monthName = DateFormat('MMMM', 'pt_BR').format(date);
    return '${monthName[0].toUpperCase()}${monthName.substring(1)} de ${date.year}';
  }

  // =====================================================
  // GRÁFICO MENSAL PREMIUM COM SCROLL E ANIMAÇÕES
  // =====================================================
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
    const double dayWidth = 50; // Aumentado para melhor visual
    final double chartWidth = daysInMonth * dayWidth;

    final barGroups = List.generate(daysInMonth, (index) {
      final day = index + 1;
      return BarChartGroupData(
        x: day,
        barsSpace: 8, // Espaço maior entre barras
        barRods: [
          BarChartRodData(
            toY: (addByDay[day] ?? 0).toDouble(),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF81C784),
              ], // Gradiente verde premium
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 12,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 0,
              color: Colors.grey.shade200,
            ),
          ),
          BarChartRodData(
            toY: (removeByDay[day] ?? 0).toDouble(),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF44336),
                Color(0xFFEF5350),
              ], // Gradiente vermelho premium
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 12,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 0,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      );
    });

    final maxY =
        barGroups
            .expand((e) => e.barRods)
            .map((e) => e.toY)
            .fold<double>(0, (p, c) => c > p ? c : p) +
        5; // Margem superior

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)], // Fundo sutil
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // Corrigido
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        elevation: 0, // Removido para usar o container
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.transparent, // Transparente para mostrar o gradiente
        child: SizedBox(
          height: 350, // Altura aumentada
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth < MediaQuery.of(context).size.width
                  ? MediaQuery.of(context).size.width
                  : chartWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barGroups: barGroups,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 211, 12, 12),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBorderRadius: BorderRadius.circular(
                          8,
                        ), // versão antiga usa tooltipBorderRadius
                        tooltipMargin: 8, // margem do tooltip
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final type = rodIndex == 0 ? 'Entrada' : 'Saída';
                          return BarTooltipItem(
                            '$type\n${rod.toY.toInt()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  duration: const Duration(milliseconds: 800), // Corrigido
                  curve: Curves.easeInOut, // Corrigido
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeReady) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF4CAF50),
          ), // Verde premium
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Fundo premium
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickMonth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1A1A1A),
                            Color(0xFF424242),
                          ], // Gradiente preto
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.2,
                            ), // Corrigido
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _displayMonthText,
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
                    onPressed: () {
                      // Aqui você chama o modal
                      SalveModal.show(context);
                    },
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
                      shadowColor: Colors.black.withValues(
                        alpha: 0.1,
                      ), // Corrigido
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Exportar Relatório',
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
            child: StreamBuilder<List<Movement>>(
              stream: _movementsService.getMonthlyMovementsStream(
                userId: widget.userId,
                month: _displayMonth.month,
                year: _displayMonth.year,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  );
                }

                final movements = snapshot.data!;
                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma movimentação em ${DateFormat('MM/yyyy').format(_displayMonth)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        _formatMonthTitle(_displayMonth),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    _buildBarChart(movements),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
