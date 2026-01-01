import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../firebase/firestore/movements_days.dart';
import 'models/annual_report_period_controller.dart';
import 'models/salve_modal.dart';

class RelatoriosForProductYears extends StatefulWidget {
  final String productId;
  final String uid;

  /// Ano selecionado na tela de relatórios anuais
  final int displayYear;

  const RelatoriosForProductYears({
    super.key,
    required this.productId,
    required this.uid,
    required this.displayYear,
  });

  @override
  State<RelatoriosForProductYears> createState() =>
      _RelatoriosForProductYearsState();
}

class _RelatoriosForProductYearsState extends State<RelatoriosForProductYears> {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;

  late int _displayYear;
  late String _uid;
  late String _productId;

  Timer? _timer;

  String get _selectedPeriod => AnnualReportPeriodController.period.value;

  List<Movement> _currentMovements = []; // Adicionado para armazenar os movimentos atuais

  @override
  void initState() {
    super.initState();

    _uid = widget.uid;
    _productId = widget.productId;
    _displayYear = widget.displayYear;

    _initializeLocale();

    // ✅ sincroniza UI com controller global (RelatoriosYears <-> RelatoriosForProductYears)
    AnnualReportPeriodController.period.addListener(_onPeriodChanged);

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    AnnualReportPeriodController.period.removeListener(_onPeriodChanged);
    super.dispose();
  }

  void _onPeriodChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    if (!mounted) return;
    setState(() => _localeReady = true);
  }

  /// Range de meses do período anual selecionado (inclusive)
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

  List<Movement> _filterBySelectedPeriod(List<Movement> movements) {
    final range = _periodMonthRange();

    return movements.where((m) {
      if (m.date.year != _displayYear) return false;
      return m.date.month >= range.startMonth && m.date.month <= range.endMonth;
    }).toList();
  }

  String _formatYearTitle() => '$_displayYear ($_selectedPeriod)';

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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'Relatório do Produto',
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildTopActions(),
          Expanded(child: _buildReport()),
        ],
      ),
    );
  }

  // ================= TOP ACTIONS (mesma cara do mensal detalhado) =================
  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // ✅ SEM YEAR PICKER AQUI: só período anual (sincronizado)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
              child: ValueListenableBuilder<String>(
                valueListenable: AnnualReportPeriodController.period,
                builder: (context, value, _) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xFF1A1A1A),
                      value: value,
                      isExpanded: true,
                      iconEnabledColor: Colors.white,
                      items: AnnualReportPeriodController.options.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt,
                          child: Text(
                            opt,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        AnnualReportPeriodController.period.value = newValue;
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: OutlinedButton(
              onPressed: _currentMovements.isNotEmpty
                  ? () => SalveModal.show(
                        context,
                        days: List.generate(
                          _periodMonthRange().endMonth -
                              _periodMonthRange().startMonth +
                              1,
                          (i) => DateTime(
                            _displayYear,
                            _periodMonthRange().startMonth + i,
                            1,
                          ),
                        ),
                        uid: _uid,
                        movements: _currentMovements,
                      )
                  : null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1A1A1A), width: 2),
                foregroundColor: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Exportar Relatório',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

  // ================= REPORT =================
  Widget _buildReport() {
    return FutureBuilder<List<Movement>>(
      future: _movementsService.getYearlyMovements(
        year: _displayYear,
        uid: _uid,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }

        final allYearMovements = snapshot.data!;
        // Atualizado: _currentMovements agora armazena os movimentos filtrados para o produto e período
        final productAll = allYearMovements
            .where((m) => m.productId == _productId)
            .toList();
        final productMovements = _filterBySelectedPeriod(productAll);
        _currentMovements = productMovements; // Atualizado para manter o estado sincronizado com os movimentos filtrados

        // dados base do produto
        final productName = productAll.isNotEmpty
            ? productAll.first.productName
            : 'Produto';
        final productImage = productAll.isNotEmpty
            ? productAll.first.image
            : null;

        if (productMovements.isEmpty) {
          return _buildEmptyState(productName: productName);
        }

        return _buildProductYearReport(
          movements: productMovements,
          productName: productName,
          productImage: productImage,
        );
      },
    );
  }

  Widget _buildEmptyState({required String productName}) {
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
                'Nenhuma movimentação de $productName\nem ${_formatYearTitle()}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione outro período anual ou verifique as movimentações desse ano.',
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

  // =======================
  // REPORT UI (mesma "cara" do mensal detalhado, só que por mês)
  // =======================
  Widget _buildProductYearReport({
    required List<Movement> movements,
    required String productName,
    required String? productImage,
  }) {
    // Totais no período selecionado
    final totalAdd = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);

    final totalRemove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    final currentStock = totalAdd - totalRemove;
    final availability = currentStock > 0 ? 'Disponível' : 'Indisponível';

    // ======== Gráfico de linha (cumulativo ao longo dos MESES do período) ========
    final addByMonth = <int, int>{};
    final removeByMonth = <int, int>{};

    for (final m in movements) {
      final month = m.date.month;
      if (m.type == 'add') {
        addByMonth[month] = (addByMonth[month] ?? 0) + m.quantity;
      } else {
        removeByMonth[month] = (removeByMonth[month] ?? 0) + m.quantity;
      }
    }

    final range = _periodMonthRange();
    final monthsInRange = List<int>.generate(
      range.endMonth - range.startMonth + 1,
      (i) => range.startMonth + i,
    );

    int cumulativeAdd = 0;
    int cumulativeRemove = 0;

    final spotsAdd = <FlSpot>[];
    final spotsRemove = <FlSpot>[];

    for (final month in monthsInRange) {
      cumulativeAdd += (addByMonth[month] ?? 0);
      cumulativeRemove += (removeByMonth[month] ?? 0);

      spotsAdd.add(FlSpot(month.toDouble(), cumulativeAdd.toDouble()));
      spotsRemove.add(FlSpot(month.toDouble(), cumulativeRemove.toDouble()));
    }

    final minX = monthsInRange.first.toDouble();
    final maxX = monthsInRange.last.toDouble();

    final maxCumulative = [
      cumulativeAdd,
      cumulativeRemove,
    ].reduce((a, b) => a > b ? a : b);
    final maxY = (maxCumulative + 10).toDouble();

    // ======== Detalhamento (AGRUPADO: MÊS -> DIA) ========
    final Map<int, List<Movement>> groupedByMonth = {};
    for (final m in movements) {
      groupedByMonth.putIfAbsent(m.date.month, () => []).add(m);
    }

    final monthsSortedDesc = groupedByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final Map<int, Map<DateTime, List<Movement>>> byMonthByDay = {};
    for (final month in monthsSortedDesc) {
      final monthMovements = groupedByMonth[month]!;
      final Map<DateTime, List<Movement>> groupedDays = {};

      for (final mv in monthMovements) {
        final dayKey = DateTime(mv.date.year, mv.date.month, mv.date.day);
        groupedDays.putIfAbsent(dayKey, () => []).add(mv);
      }

      final dayKeysDesc = groupedDays.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      final ordered = <DateTime, List<Movement>>{};
      for (final day in dayKeysDesc) {
        final list = groupedDays[day]!
          ..sort((a, b) => b.date.compareTo(a.date));
        ordered[day] = list;
      }
      byMonthByDay[month] = ordered;
    }

    const monthLabels = [
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

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          _formatYearTitle(),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
      ),

      // Card do produto (igual ao mensal detalhado)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF0F4F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE8ECF2).withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                blurRadius: 15,
                offset: const Offset(-4, -4),
              ),
              BoxShadow(
                color: const Color(0xFF4A90E2).withValues(alpha: 0.05),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              // Imagem do produto
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildProductImage(productImage),
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                                                fontSize: 20,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _premiumTag(
                          'Estoque: $currentStock',
                          const Color(0xFFE8F5E8),
                          const Color(0xFF2E7D32),
                          Icons.inventory,
                        ),
                        const SizedBox(width: 12),
                        _premiumTag(
                          availability,
                          availability == 'Disponível'
                              ? const Color(0xFFE8F5E8)
                              : const Color(0xFFFCE4EC),
                          availability == 'Disponível'
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD32F2F),
                          availability == 'Disponível'
                              ? Icons.check_circle
                              : Icons.cancel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Gráfico (cumulativo por mês)
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
                child: Column(
                  children: [
                    Text(
                      'Movimentações Cumulativas de $productName em $_selectedPeriod',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF34495E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Legenda
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
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            // Entradas (cumulativo)
                            LineChartBarData(
                              spots: spotsAdd,
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                              ),
                              barWidth: 5,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF27AE60,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFF2ECC71,
                                    ).withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 6,
                                          color: const Color(0xFF27AE60),
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                              ),
                            ),

                            // Saídas (cumulativo)
                            LineChartBarData(
                              spots: spotsRemove,
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE74C3C), Color(0xFFE74C3C)],
                              ),
                              barWidth: 5,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFFE74C3C,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFFE74C3C,
                                    ).withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 6,
                                          color: const Color(0xFFE74C3C),
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                              ),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Mês',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7F8C8D),
                                ),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final v = value.toInt();
                                  if (v < minX || v > maxX)
                                    return const Text('');

                                  // evita poluição em ranges grandes
                                  final showLabel =
                                      monthsInRange.contains(v) &&
                                      (monthsInRange.length <= 6 || v % 2 == 0);

                                  if (!showLabel) return const Text('');

                                  return Text(
                                    monthLabels[v],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7F8C8D),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: maxY / 10,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7F8C8D),
                                  ),
                                ),
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: true,
                            verticalInterval: 1,
                            horizontalInterval: maxY / 10,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: const Color(0xFFECF0F1),
                              strokeWidth: 0.5,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: const Color(0xFFECF0F1),
                              strokeWidth: 0.5,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xFFBDC3C7),
                              width: 1,
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipPadding: const EdgeInsets.all(12),
                              tooltipMargin: 8,
                              getTooltipItems: (touchedSpots) {
                                const monthNames = [
                                  '',
                                  'Jan',
                                  'Fev',
                                  'Mar',
                                  'Abr',
                                  'Mai',
                                  'Jun',
                                  'Jul',
                                  'Ago',
                                  'Set',
                                  'Out',
                                  'Nov',
                                  'Dez',
                                ];

                                return touchedSpots.map((spot) {
                                  final isAdd = spot.barIndex == 0;
                                  final month = spot.x.toInt();

                                  final monthAdd = addByMonth[month] ?? 0;
                                  final monthRemove = removeByMonth[month] ?? 0;

                                  final type = isAdd ? 'Entrada' : 'Saída';

                                  return LineTooltipItem(
                                    '${monthNames[month]}/$_displayYear\n'
                                    '$type (no mês): ${isAdd ? monthAdd : monthRemove}\n'
                                    'Cumulativo: ${spot.y.toInt()}',
                                    GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          minX: minX,
                          maxX: maxX,
                          minY: 0,
                          maxY: maxY,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 16),

      // Resumo Executivo (mesma cara do mensal)
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
          child: Column(
            children: [
              Text(
                'Resumo Executivo do Produto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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

      // =======================
      // DETALHAMENTO (MÊS -> DIA -> MOVIMENTAÇÕES) — igual ao mensal, só que com seção do mês
      // =======================
      ...monthsSortedDesc.expand((month) {
        final monthDate = DateTime(_displayYear, month, 1);
        final monthTitleRaw = DateFormat(
          'MMMM/yyyy',
          'pt_BR',
        ).format(monthDate);
        final monthTitle =
            '${monthTitleRaw[0].toUpperCase()}${monthTitleRaw.substring(1)}';

        final daysMap = byMonthByDay[month]!;
        final dayKeysDesc = daysMap.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return <Widget>[
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

          ...dayKeysDesc.expand((day) {
            final dayTitleRaw = DateFormat('EEEE, dd/MM', 'pt_BR').format(day);
            final dayTitle =
                '${dayTitleRaw[0].toUpperCase()}${dayTitleRaw.substring(1)}';

            final dayMovements = daysMap[day]!;

            final dayAdd = dayMovements
                .where((e) => e.type == 'add')
                .fold<int>(0, (p, e) => p + e.quantity);
            final dayRemove = dayMovements
                .where((e) => e.type == 'remove')
                .fold<int>(0, (p, e) => p + e.quantity);

            return <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  dayTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Movimentações Detalhadas',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          if (dayAdd > 0)
                            _miniTag(
                              'Entradas: $dayAdd',
                              const Color(0xFFD5F4E6),
                              const Color(0xFF27AE60),
                            ),
                          if (dayRemove > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _miniTag(
                                'Saídas: $dayRemove',
                                const Color(0xFFFADBD8),
                                const Color(0xFFE74C3C),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...dayMovements.map((movement) {
                        final timeStr = DateFormat(
                          'HH:mm',
                        ).format(movement.date);
                        final type = movement.type == 'add'
                            ? 'Entrada'
                            : 'Saída';
                        final color = movement.type == 'add'
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFE74C3C);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$type: ${movement.quantity}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: const Color(0xFF2C3E50),
                                      ),
                                    ),
                                    Text(
                                      'Horário: $timeStr',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF7F8C8D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ];
          }),

          const SizedBox(height: 8),
        ];
      }),

      const SizedBox(height: 16),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
    );
  }

  // =======================
  // UI HELPERS (mesma pegada do mensal)
  // =======================
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

  Widget _miniTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: fg.withValues(alpha: 0.25),
        ),
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

  Widget _imagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Color(0xFFBDC3C7),
        size: 24,
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      );
    } else {
      return _imagePlaceholder();
    }
  }

  Widget _premiumTag(
    String text,
    Color bg,
    Color fg,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: fg.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: fg.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}