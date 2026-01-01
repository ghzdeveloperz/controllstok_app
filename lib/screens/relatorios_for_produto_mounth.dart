// lib/screens/relatorios_for_produto_mounth.dart
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../firebase/firestore/movements_days.dart';
import '../screens/models/monthly_report_period_controller.dart';
import '../screens/models/salve_modal.dart';

class RelatoriosForProdutoMounth extends StatefulWidget {
  final String productId;
  final String uid;

  /// Mês selecionado na tela de relatórios mensais
  final DateTime displayMonth;

  const RelatoriosForProdutoMounth({
    super.key,
    required this.productId,
    required this.uid,
    required this.displayMonth,
  });

  @override
  State<RelatoriosForProdutoMounth> createState() =>
      _RelatoriosForProdutoMounthState();
}

class _RelatoriosForProdutoMounthState extends State<RelatoriosForProdutoMounth> {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;
  late DateTime _displayMonth;
  late String _uid;
  late String _productId;
  Timer? _timer;
  List<Movement> _currentMovements = []; // ✅ Adicionado para armazenar os movimentos atuais

  String get _selectedPeriod => MonthlyReportPeriodController.period.value;

  @override
  void initState() {
    super.initState();

    _uid = widget.uid;
    _productId = widget.productId;
    _displayMonth = DateTime(widget.displayMonth.year, widget.displayMonth.month);

    _initializeLocale();

    // Atualiza a UI se o período mudar em outra tela (sincronizado)
    MonthlyReportPeriodController.period.addListener(_onPeriodChanged);

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    MonthlyReportPeriodController.period.removeListener(_onPeriodChanged);
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

  DateTime _startDateForSelectedPeriod() {
    final monthStart = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final nextMonthStart = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);

    switch (_selectedPeriod) {
      case 'Últimos 7 dias':
        return nextMonthStart.subtract(const Duration(days: 7));
      case 'Últimos 14 dias':
        return nextMonthStart.subtract(const Duration(days: 14));
      case 'Últimos 21 dias':
        return nextMonthStart.subtract(const Duration(days: 21));
      case 'Últimos 28 dias':
        return nextMonthStart.subtract(const Duration(days: 28));
      case 'Mês inteiro':
      default:
        return monthStart;
    }
  }

  List<Movement> _filterBySelectedPeriod(List<Movement> movements) {
    final start = _startDateForSelectedPeriod();
    return movements
        .where((m) => m.date.isAtSameMomentAs(start) || m.date.isAfter(start))
        .toList();
  }

  String _formatMonthTitle(DateTime date) {
    final month = DateFormat('MMMM', 'pt_BR').format(date);
    final monthCap = '${month[0].toUpperCase()}${month.substring(1)}';
    return '$monthCap de ${date.year} ($_selectedPeriod)';
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

  // ================= TOP ACTIONS =================
  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // ✅ SEM DATEPICKER: seletor de período (sincronizado)
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
                valueListenable: MonthlyReportPeriodController.period,
                builder: (context, value, _) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xFF1A1A1A),
                      value: value,
                      isExpanded: true,
                      iconEnabledColor: Colors.white,
                      items: MonthlyReportPeriodController.options.map((opt) {
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
                        MonthlyReportPeriodController.period.value = newValue;
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
                        days: [_displayMonth], // ✅ Ajustado para passar o mês como lista de dias (ou ajustar conforme necessidade)
                        uid: _uid,
                        movements: _currentMovements,
                      )
                  : null, // ✅ Desabilita se _currentMovements estiver vazio
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
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
    return StreamBuilder<List<Movement>>(
      stream: _movementsService.getMonthlyMovementsStream(
        month: _displayMonth.month,
        year: _displayMonth.year,
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

        final allMonthMovements = snapshot.data!;

        // 1) Filtra somente do produto
        final productAll = allMonthMovements.where((m) => m.productId == _productId).toList();

        // Pega dados do produto mesmo se o período filtrar tudo
        final productName = productAll.isNotEmpty ? productAll.first.productName : 'Produto';
        final productImage = productAll.isNotEmpty ? productAll.first.image : null;

        // 2) Filtra pelo período selecionado (últimos 7/14/21/28 ou mês inteiro)
        final productMovements = _filterBySelectedPeriod(productAll);

        // ✅ Atualiza _currentMovements com a lista filtrada
        if (mounted) {
          setState(() {
            _currentMovements = productMovements;
          });
        }

        if (productMovements.isEmpty) {
          return _buildEmptyState(productName: productName);
        }

        return _buildProductMonthReport(
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
                'Nenhuma movimentação de $productName\nem ${_formatMonthTitle(_displayMonth)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione outro período ou verifique as movimentações deste mês.',
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

  Widget _buildProductMonthReport({
    required List<Movement> movements,
    required String productName,
    required String? productImage,
  }) {
    // Totais no período selecionado
    final totalAdd =
        movements.where((e) => e.type == 'add').fold<int>(0, (p, e) => p + e.quantity);
    final totalRemove =
        movements.where((e) => e.type == 'remove').fold<int>(0, (p, e) => p + e.quantity);

    final currentStock = totalAdd - totalRemove;
    final availability = currentStock > 0 ? 'Disponível' : 'Indisponível';

    // ======== Gráfico de linha (cumulativo ao longo dos DIAS do mês) ========
    final sortedForChart = List<Movement>.from(movements)
      ..sort((a, b) => a.date.compareTo(b.date));

    int cumulativeAdd = 0;
    int cumulativeRemove = 0;
    final List<FlSpot> spotsAdd = [];
    final List<FlSpot> spotsRemove = [];

    for (final m in sortedForChart) {
      final x = m.date.day.toDouble();
      if (m.type == 'add') {
        cumulativeAdd += m.quantity;
        spotsAdd.add(FlSpot(x, cumulativeAdd.toDouble()));
      } else {
        cumulativeRemove += m.quantity;
        spotsRemove.add(FlSpot(x, cumulativeRemove.toDouble()));
      }
    }

    // minX/maxX
    final Set<double> allX = {...spotsAdd.map((e) => e.x), ...spotsRemove.map((e) => e.x)};
    final sortedX = allX.toList()..sort();
    final daysInMonth = DateUtils.getDaysInMonth(_displayMonth.year, _displayMonth.month).toDouble();

    double minX = sortedX.isNotEmpty ? (sortedX.first - 1) : 1;
    double maxX = sortedX.isNotEmpty ? (sortedX.last + 1) : daysInMonth;

        minX = minX < 1 ? 1 : minX;
    maxX = maxX > daysInMonth ? daysInMonth : maxX;

    final maxCumulative =
        [cumulativeAdd, cumulativeRemove].reduce((a, b) => a > b ? a : b);
    final maxY = (maxCumulative + 10).toDouble();

    // ======== Movimentações detalhadas (AGRUPADAS POR DIA) ========
    final Map<DateTime, List<Movement>> groupedByDay = {};
    for (final m in movements) {
      final dayKey = DateTime(m.date.year, m.date.month, m.date.day);
      groupedByDay.putIfAbsent(dayKey, () => []).add(m);
    }

    final daysSorted = groupedByDay.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final day in daysSorted) {
      groupedByDay[day]!.sort((a, b) => b.date.compareTo(a.date)); // mais recente primeiro
    }

    final children = <Widget>[
      // Título do mês/período
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          _formatMonthTitle(_displayMonth),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
      ),

      // Informações do Produto (mesma cara do seu RelatoriosForProducts)
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

      // Gráfico (cumulativo por dia)
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
                      'Movimentações Cumulativas de $productName no $_selectedPeriod',
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
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
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
                                    const Color(0xFF27AE60).withValues(alpha: 0.2),
                                    const Color(0xFF2ECC71).withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) =>
                                    FlDotCirclePainter(
                                  radius: 6,
                                  color: const Color(0xFF27AE60),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                            ),
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
                                    const Color(0xFFE74C3C).withValues(alpha: 0.2),
                                    const Color(0xFFE74C3C).withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) =>
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
                                'Dia',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7F8C8D),
                                ),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: 5,
                                getTitlesWidget: (value, meta) {
                                  if (value >= 1 &&
                                      value <= daysInMonth &&
                                      value % 5 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF7F8C8D),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: maxY / 10,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF7F8C8D),
                                    ),
                                  );
                                },
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
                            verticalInterval: 5,
                            horizontalInterval: maxY / 10,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: const Color(0xFFECF0F1),
                                strokeWidth: 0.5,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: const Color(0xFFECF0F1),
                                strokeWidth: 0.5,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: const Color(0xFFBDC3C7), width: 1),
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

      // Resumo Executivo
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

      // Movimentações Detalhadas (com TÍTULO DO DIA)
      ...daysSorted.expand((day) {
        final dayTitleRaw = DateFormat('EEEE, dd/MM', 'pt_BR').format(day);
        final dayTitle = '${dayTitleRaw[0].toUpperCase()}${dayTitleRaw.substring(1)}';

        final dayMovements = groupedByDay[day]!;

        return [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Movimentações Detalhadas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...dayMovements.map((movement) {
                    final timeStr = DateFormat('HH:mm').format(movement.date);
                    final type = movement.type == 'add' ? 'Entrada' : 'Saída';
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

      const SizedBox(height: 16),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
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

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _imagePlaceholder();
    }

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
}

Widget _premiumTag(String text, Color bg, Color fg, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: fg.withValues(alpha: 0.2), width: 1),
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
            fontSize: 12,
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}