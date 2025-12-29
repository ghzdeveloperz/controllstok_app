import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../firebase/firestore/movements_days.dart';
import '../screens/models/annual_report_period_controller.dart';
import '../screens/models/salve_modal.dart';
import 'relatorios_for_product_years.dart';

class RelatoriosYears extends StatefulWidget {
  const RelatoriosYears({super.key});

  @override
  State<RelatoriosYears> createState() => _RelatoriosYearsState();
}

class _RelatoriosYearsState extends State<RelatoriosYears>
    with TickerProviderStateMixin {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;

  late int _displayYear;
  late String _uid;

  Timer? _timer;

  // "Barras" (stacked por mês) ou "Pizza" (distribuição por produto no ano)
  String _selectedChartType = 'Barras';

  // ✅ Período anual sincronizado (controller global)
  String _selectedPeriod = AnnualReportPeriodController.period.value;
  final List<String> _periodOptions = AnnualReportPeriodController.options;

  late Future<List<Movement>> _movementsFuture;

  // Pie touch
  int _touchedIndex = -1;
  String? _touchedLabel;
  String? _touchedImageUrl;

  // Animação
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    _uid = user.uid;
    _displayYear = DateTime.now().year;

    _movementsFuture = _movementsService.getYearlyMovements(
      year: _displayYear,
      uid: _uid,
    );

    _initializeLocale();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    // ✅ Listener para refletir mudanças vindas da tela do produto (sincronizado)
    AnnualReportPeriodController.period.addListener(_syncSelectedPeriod);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  void _syncSelectedPeriod() {
    final newValue = AnnualReportPeriodController.period.value;
    if (!mounted) return;
    if (_selectedPeriod == newValue) return;
    setState(() => _selectedPeriod = newValue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    AnnualReportPeriodController.period.removeListener(_syncSelectedPeriod);
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    if (!mounted) return;
    setState(() => _localeReady = true);
  }

  Future<void> _pickYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_displayYear),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1A1A),
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

    if (picked != null && picked.year != _displayYear) {
      setState(() {
        _displayYear = picked.year;
        _movementsFuture = _movementsService.getYearlyMovements(
          year: _displayYear,
          uid: _uid,
        );
      });
    }
  }

  String get _displayYearText {
    final now = DateTime.now();
    return _displayYear == now.year ? 'Este ano' : _displayYear.toString();
  }

  String _formatYearTitle(int year) => 'Relatório de $year ($_selectedPeriod)';

  ({int startMonth, int endMonth}) _periodMonthRange() {
    switch (_selectedPeriod) {
      case '1º Trimestre (Jan–Mar)':
        return (startMonth: 1, endMonth: 3);
      case '2º Trimestre (Abr–Jun)':
        return (startMonth: 4, endMonth: 6);
      case '3º Trimestre (Jul–Set)':
        return (startMonth: 7, endMonth: 9);
      case '4º Trimestre (Out–Dez)':
        return (startMonth: 10, endMonth: 12);

      case '1º Semestre (Jan–Jun)':
        return (startMonth: 1, endMonth: 6);
      case '2º Semestre (Jul–Dez)':
        return (startMonth: 7, endMonth: 12);

      case 'Últimos 3 meses (Out–Dez)':
        return (startMonth: 10, endMonth: 12);
      case 'Últimos 6 meses (Jul–Dez)':
        return (startMonth: 7, endMonth: 12);

      case 'Ano inteiro':
      default:
        return (startMonth: 1, endMonth: 12);
    }
  }

  List<Movement> _filterMovementsByPeriod(List<Movement> movements) {
    final range = _periodMonthRange();
    return movements.where((m) {
      return m.date.year == _displayYear &&
          m.date.month >= range.startMonth &&
          m.date.month <= range.endMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeReady) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildTopActions(),
          Expanded(child: _buildReport()),
        ],
      ),
    );
  }

  // ================= TOP ACTIONS =================
  Widget _buildTopActions() {
    return Column(
      children: [
        // ✅ Select do período anual (igual ao Months: branco, premium, em cima)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              underline: const SizedBox(),
              items: _periodOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2C3E50),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == null) return;
                setState(() => _selectedPeriod = newValue);
                AnnualReportPeriodController.period.value = newValue;
              },
            ),
          ),
        ),

        // Ano + Exportar (mantém)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickYear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)],
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _displayYearText,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
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
                  onPressed: () => SalveModal.show(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    side: const BorderSide(color: Color(0xFF1A1A1A), width: 2),
                    foregroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.save, size: 18),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Exportar Relatório',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= REPORT =================
  Widget _buildReport() {
    return FutureBuilder<List<Movement>>(
      future: _movementsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }

        final allMovements = snapshot.data!;
        final movements = _filterMovementsByPeriod(allMovements);

        if (movements.isEmpty) {
          return _buildEmptyState();
        }

        return _buildGroupedList(movements);
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 12,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              Text(
                'Nenhuma movimentação em $_displayYearText ($_selectedPeriod)',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione outro ano, período ou adicione novas movimentações.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 42,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBDC3C7).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ================= LIST / GROUPING =================
  Widget _buildGroupedList(List<Movement> movements) {
    // Agrupar por mês -> produto
    final Map<int, List<Movement>> groupedByMonth = {};
    for (final m in movements) {
      groupedByMonth.putIfAbsent(m.date.month, () => []).add(m);
    }

    // ordenar meses (mais recente primeiro)
    final sortedMonthsDesc = groupedByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Totais do período selecionado
    final totalAdd = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);

    final totalRemove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    // ===== Dados para gráficos =====
    final addByMonth = <int, int>{};
    final removeByMonth = <int, int>{};

    // Distribuição por produto (pizza) -> soma de (add + remove)
    final productTotals = <String, int>{};

    for (final m in movements) {
      final month = m.date.month;

      if (m.type == 'add') {
        addByMonth[month] = (addByMonth[month] ?? 0) + m.quantity;
      } else {
        removeByMonth[month] = (removeByMonth[month] ?? 0) + m.quantity;
      }

      productTotals[m.productId] =
          (productTotals[m.productId] ?? 0) + m.quantity;
    }

    // ===== Pie sections =====
    final totalMovementsQty = productTotals.values.fold<int>(
      0,
      (p, e) => p + e,
    );

    final List<PieChartSectionData> pieSections = [];
    int index = 0;

    for (final entry in productTotals.entries) {
      final qty = entry.value;
      final percentage = totalMovementsQty == 0
          ? 0.0
          : (qty / totalMovementsQty) * 100;

      pieSections.add(
        PieChartSectionData(
          titlePositionPercentageOffset: 0.55,
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          showTitle: true,
          color: generateDistinctColor(index),
          radius: _touchedIndex == index ? 68 : 56,
          titleStyle: GoogleFonts.poppins(
            fontSize: _touchedIndex == index ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
          ),
        ),
      );

      index++;
    }

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          _formatYearTitle(_displayYear),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
      ),

      // ✅ AGORA IGUAL AO MONTHS: seletor do tipo de gráfico fica AQUI (dentro do relatório)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildChartTypeSelector(),
      ),

      // ===== Chart container (premium) =====
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final chartHeight = screenHeight * 0.4;

            return Container(
              height: chartHeight,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 15,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _selectedChartType == 'Barras'
                      ? _buildYearBarChart(addByMonth, removeByMonth)
                      : _buildYearPieChart(
                          sections: pieSections,
                          productTotals: productTotals,
                          movements: movements,
                        ),
                ),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 16),

      // ===== Resumo Executivo =====
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF8F9FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                blurRadius: 12,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Resumo Executivo do $_selectedPeriod',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Entradas',
                      totalAdd,
                      const Color(0xFF27AE60),
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildSummaryItem(
                      'Saídas',
                      totalRemove,
                      const Color(0xFFE74C3C),
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildSummaryItem(
                      'Saldo Líquido',
                      totalAdd - totalRemove,
                      const Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 16),

      // ===== Meses (mais recente primeiro) =====
      ...sortedMonthsDesc.map((month) {
        final monthMovements = groupedByMonth[month]!;
        return _buildMonthSection(month, monthMovements);
      }),

      const SizedBox(height: 16),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
    );
  }

  // =======================
  // CHART TYPE SELECTOR (igual ao Months)
  // =======================
  Widget _buildChartTypeSelector() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _chartTypeItem(
                label: 'Barras',
                icon: Icons.bar_chart,
                isSelected: _selectedChartType == 'Barras',
                onTap: () => setState(() => _selectedChartType = 'Barras'),
              ),
            ),
            Expanded(
              child: _chartTypeItem(
                label: 'Pizza',
                icon: Icons.pie_chart,
                isSelected: _selectedChartType == 'Pizza',
                onTap: () => setState(() => _selectedChartType = 'Pizza'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartTypeItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF2C3E50),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =======================
  // CHARTS
  // =======================
  Widget _buildYearBarChart(
    Map<int, int> addByMonth,
    Map<int, int> removeByMonth,
  ) {
    // ✅ opcional (recomendado): mostra somente meses do período selecionado
    final range = _periodMonthRange();
    final monthsInRange = List<int>.generate(
      range.endMonth - range.startMonth + 1,
      (i) => range.startMonth + i,
    );

    final barGroups = monthsInRange.map((month) {
      final add = (addByMonth[month] ?? 0).toDouble();
      final remove = (removeByMonth[month] ?? 0).toDouble();

      // x = mês (1..12) para facilitar labels
      return BarChartGroupData(
        x: month,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: add,
            width: 14,
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
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
              colors: [Color(0xFFE74C3C), Color(0xFFEF5350)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    }).toList();

    final maxY =
        barGroups
            .expand((g) => g.barRods)
            .map((r) => r.toY)
            .fold<double>(0, (p, c) => c > p ? c : p) +
        10;

    const monthsShort = [
      '',
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

    return Column(
      children: [
        Text(
          'Movimentações Mensais ($_selectedPeriod)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF34495E),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Entradas', const Color(0xFF27AE60)),
            const SizedBox(width: 20),
            _buildLegendItem('Saídas', const Color(0xFFE74C3C)),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: barGroups,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 10,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: const Color(0xFFECF0F1), strokeWidth: 0.6),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xFFBDC3C7), width: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    interval: maxY / 10,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final month = value.toInt();
                      if (!monthsInRange.contains(month)) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          monthsShort[month],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7F8C8D),
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
                  tooltipPadding: const EdgeInsets.all(12),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final month = group.x; // 1..12
                    final monthLabel = monthsShort[month];

                    final add = (addByMonth[month] ?? 0);
                    final remove = (removeByMonth[month] ?? 0);

                    if (rodIndex == 0) {
                      return BarTooltipItem(
                        '$monthLabel\nEntrada: $add',
                        GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }

                    return BarTooltipItem(
                      '$monthLabel\nSaída: $remove',
                      GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _buildYearPieChart({
    required List<PieChartSectionData> sections,
    required Map<String, int> productTotals,
    required List<Movement> movements,
  }) {
    return Column(
      children: [
        Text(
          'Distribuição de Produtos Movimentados no $_selectedPeriod',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 48,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          _touchedLabel = null;
                          _touchedImageUrl = null;
                          return;
                        }

                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;

                        final productId = productTotals.keys.elementAt(
                          _touchedIndex,
                        );

                        final product = movements.firstWhere(
                          (m) => m.productId == productId,
                        );

                        _touchedLabel = product.productName;
                        _touchedImageUrl = product.image;
                      });
                    },
                  ),
                  sections: sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;
                    final isTouched = index == _touchedIndex;

                    return section.copyWith(
                      radius: isTouched ? 68 : 56,
                      titleStyle: section.titleStyle?.copyWith(
                        fontSize: isTouched ? 14 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_touchedLabel != null && _touchedImageUrl != null)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(_touchedImageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: sections.asMap().entries.map((entry) {
            final idx = entry.key;
            final section = entry.value;

            final productId = productTotals.keys.elementAt(idx);
            final product = movements.firstWhere(
              (m) => m.productId == productId,
            );

            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // ✅ garante sincronização no detalhe
                AnnualReportPeriodController.period.value = _selectedPeriod;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RelatoriosForProductYears(
                      productId: productId,
                      uid: _uid,
                      displayYear: _displayYear,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: section.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 170),
                    child: Text(
                      product.productName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2C3E50),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // =======================
  // MONTH SECTION + PRODUCT CARD (igual ao que você já tinha)
  // =======================
  Widget _buildMonthSection(int month, List<Movement> movements) {
    final monthDate = DateTime(_displayYear, month, 1);
    final monthTitleRaw = DateFormat('MMMM/yyyy', 'pt_BR').format(monthDate);
    final monthTitle =
        '${monthTitleRaw[0].toUpperCase()}${monthTitleRaw.substring(1)}';

    final Map<String, List<Movement>> groupedByProduct = {};
    for (final m in movements) {
      groupedByProduct.putIfAbsent(m.productId, () => []).add(m);
    }

    final productGroups = groupedByProduct.values.toList()
      ..sort((a, b) {
        final totalA = a.fold<int>(0, (p, e) => p + e.quantity);
        final totalB = b.fold<int>(0, (p, e) => p + e.quantity);
        return totalB.compareTo(totalA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            monthTitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...productGroups.map(_buildProductCard),
      ],
    );
  }

  Widget _buildProductCard(List<Movement> movements) {
    final product = movements.first;

    final add = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);

    final remove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildProductImage(product.image),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProductInfo(product.productName, add, remove),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF424242)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  // ✅ garante sincronização no detalhe
                  AnnualReportPeriodController.period.value = _selectedPeriod;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatoriosForProductYears(
                        productId: product.productId,
                        uid: _uid,
                        displayYear: _displayYear,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return _imagePlaceholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Color(0xFFBDC3C7),
        size: 24,
      ),
    );
  }

  Widget _buildProductInfo(String name, int add, int remove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (add > 0)
              _tag(
                'Entradas: $add',
                const Color(0xFFD5F4E6),
                const Color(0xFF27AE60),
              ),
            if (remove > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _tag(
                  'Saídas: $remove',
                  const Color(0xFFFADBD8),
                  const Color(0xFFE74C3C),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF34495E),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color generateDistinctColor(int index) {
    final double hue = (index * 137.508) % 360;
    return HSVColor.fromAHSV(1.0, hue, 0.65, 0.85).toColor();
  }
}
