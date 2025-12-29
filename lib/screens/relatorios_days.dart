import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/movements_days.dart';
import '../screens/models/salve_modal.dart';
import '../screens/models/report_period.dart';
import 'relatorios_for_products.dart';

class RelatoriosDays extends StatefulWidget {
  const RelatoriosDays({super.key});

  @override
  State<RelatoriosDays> createState() => _RelatoriosDaysState();
}

class _RelatoriosDaysState extends State<RelatoriosDays>
    with TickerProviderStateMixin {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;
  late DateTime _displayDate;
  late String _uid;
  Timer? _timer;
  String?
  _selectedProductId; // Para controlar qual card mostrar ao pressionar um ponto
  String _selectedChartType =
      'Linha'; // Novo estado para o tipo de gráfico selecionado
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _touchedIndex = -1;
  String? _touchedLabel;
  String? _touchedImageUrl;

  @override
  void initState() {
    super.initState();

    _uid = FirebaseAuth.instance.currentUser!.uid;
    _displayDate = DateTime.now();

    _initializeLocale();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    if (!mounted) return;
    setState(() => _localeReady = true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _displayDate,
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

    if (picked != null) {
      setState(() => _displayDate = picked);
    }
  }

  String get _displayDateText {
    final now = DateTime.now();
    if (_displayDate.year == now.year &&
        _displayDate.month == now.month &&
        _displayDate.day == now.day) {
      return 'Hoje';
    }
    return DateFormat('dd/MM/yyyy').format(_displayDate);
  }

  String _formatDateTitle(DateTime date) {
    final weekday = DateFormat('EEEE', 'pt_BR').format(date);
    final day = DateFormat('dd', 'pt_BR').format(date);
    final month = DateFormat('MMMM', 'pt_BR').format(date);

    return '${weekday[0].toUpperCase()}${weekday.substring(1)}, '
        '$day de ${month[0].toUpperCase()}${month.substring(1)} de ${date.year}';
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
                label: 'Linha',
                icon: Icons.show_chart,
                isSelected: _selectedChartType == 'Linha',
                onTap: () {
                  setState(() => _selectedChartType = 'Linha');
                },
              ),
            ),
            Expanded(
              child: _chartTypeItem(
                label: 'Pizza',
                icon: Icons.pie_chart,
                isSelected: _selectedChartType == 'Pizza',
                onTap: () {
                  setState(() => _selectedChartType = 'Pizza');
                },
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

  // ================= TOP ACTIONS =================
  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // 📅 SELETOR DE DATA
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickDate,
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
                        _displayDateText,
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

          // 💾 EXPORTAR RELATÓRIO
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
    );
  }

  // ================= REPORT =================
  Widget _buildReport() {
    return StreamBuilder<List<Movement>>(
      stream: _movementsService.getDailyMovementsStream(
        day: _displayDate,
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

        final movements = snapshot.data!;
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
                'Nenhuma movimentação $_displayDateText',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione outra data ou adicione novas movimentações.',
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

  Widget _buildGroupedList(List<Movement> movements) {
    final Map<String, List<Movement>> grouped = {};

    for (final m in movements) {
      grouped.putIfAbsent(m.productId, () => []).add(m);
    }

    // Calcular totais para o gráfico
    final totalAdd = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);
    final totalRemove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    // Preparar dados para o gráfico de linha (quantidade cumulativa ao longo do tempo para Entrada e Saída separadamente)
    final sortedMovements = movements
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    int cumulativeAdd = 0;
    int cumulativeRemove = 0;
    final List<FlSpot> spotsAdd = [];
    final List<FlSpot> spotsRemove = [];

    for (final m in sortedMovements) {
      final x = m.timestamp.hour + m.timestamp.minute / 60.0;
      if (m.type == 'add') {
        cumulativeAdd += m.quantity;
        spotsAdd.add(FlSpot(x, cumulativeAdd.toDouble()));
      } else {
        cumulativeRemove += m.quantity;
        spotsRemove.add(FlSpot(x, cumulativeRemove.toDouble()));
      }
    }

    // Coletar todos os valores X únicos para ajustar o zoom e os títulos
    final Set<double> allX = {};
    for (final spot in spotsAdd) {
      allX.add(spot.x);
    }
    for (final spot in spotsRemove) {
      allX.add(spot.x);
    }
    final List<double> sortedX = allX.toList()..sort();

    // Determinar minX e maxX para zoom nos dados (com padding de 1 hora)
    double minX = sortedX.isNotEmpty ? sortedX.first - 1 : 0;
    double maxX = sortedX.isNotEmpty ? sortedX.last + 1 : 24;
    minX = minX < 0 ? 0 : minX;
    maxX = maxX > 24 ? 24 : maxX;

    // Determinar maxY automaticamente baseado no maior valor cumulativo
    final maxCumulative = [
      cumulativeAdd,
      cumulativeRemove,
    ].reduce((a, b) => a > b ? a : b);
    final maxY = (maxCumulative + 10).toDouble();

    // Preparar dados para o gráfico percentual (pie chart)
    final Map<String, int> productTotals = {};
    for (final entry in grouped.entries) {
      final productId = entry.key;
      final productMovements = entry.value;
      final total = productMovements.fold<int>(0, (p, e) => p + e.quantity);
      productTotals[productId] = total;
    }
    final totalMovements = productTotals.values.fold<int>(0, (p, e) => p + e);
    final List<PieChartSectionData> pieSections = [];

    int index = 0;

    for (final entry in productTotals.entries) {
      final total = entry.value;
      final percentage = (total / totalMovements) * 100;

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
          _formatDateTitle(_displayDate),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      // Seletor premium para tipo de gráfico
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildChartTypeSelector(),
      ),

      // Gráfico baseado na seleção
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
                  child: _selectedChartType == 'Linha'
                      ? _buildLineChart(
                          spotsAdd,
                          spotsRemove,
                          minX,
                          maxX,
                          maxY,
                          sortedMovements,
                        )
                      : _buildPieChart(pieSections, grouped),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      // Resumo aprimorado
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
                'Resumo Executivo do Dia',
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
      // Lista de produtos que entraram e saíram
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
                'Produtos Movimentados',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),

              ...grouped.entries.map((entry) {
                final productId = entry.key;
                final productMovements = entry.value;
                final product = productMovements.first;

                final add = productMovements
                    .where((e) => e.type == 'add')
                    .fold<int>(0, (p, e) => p + e.quantity);

                final remove = productMovements
                    .where((e) => e.type == 'remove')
                    .fold<int>(0, (p, e) => p + e.quantity);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(product.image),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
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
                        ),
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
                            // ✅ AGORA PASSA UM PERÍODO EXPLÍCITO (DIA ESPECÍFICO)
                            final period = ReportPeriod.day(_displayDate);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RelatoriosForProducts(
                                  productId: productId,
                                  uid: _uid,
                                  period: period,
                                ),
                              ),
                            );
                          },
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

      const SizedBox(height: 16),
    ];

    // Adicionar card apenas se um produto estiver selecionado
    if (_selectedProductId != null) {
      final selectedMovements = grouped[_selectedProductId];
      if (selectedMovements != null) {
        children.add(_buildProductCard(selectedMovements));
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
    );
  }

  Widget _buildLineChart(
    List<FlSpot> spotsAdd,
    List<FlSpot> spotsRemove,
    double minX,
    double maxX,
    double maxY,
    List<Movement> sortedMovements,
  ) {
    return Column(
      children: [
        // Título do gráfico
        Text(
          'Movimentações Cumulativas ao Longo do Dia',
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
                // Linha para Entrada (verde sofisticado)
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
                // Linha para Saída (vermelho sofisticado)
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
                    'Horário',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      if (value % 2 == 0 && value >= 0 && value <= 24) {
                        return Text(
                          '${value.toInt().toString().padLeft(2, '0')}:00',
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
                verticalInterval: 2,
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
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(12),
                  tooltipMargin: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isAdd = spot.barIndex == 0;
                      final spotsList = isAdd ? spotsAdd : spotsRemove;
                      final index = spotsList.indexOf(spot);
                      if (index != -1) {
                        final movementsForType = sortedMovements
                            .where((m) => m.type == (isAdd ? 'add' : 'remove'))
                            .toList();
                        final movement = movementsForType[index];
                        setState(() {
                          _selectedProductId = movement.productId;
                        });
                        final timeStr = DateFormat(
                          'HH:mm',
                        ).format(movement.timestamp);
                        final type = isAdd ? 'Entrada' : 'Saída';
                        return LineTooltipItem(
                          '$timeStr\n$type: ${movement.quantity}\nCumulativo: ${spot.y.toInt()}',
                          GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      // Lógica extra ao tocar, se necessário
                    },
              ),
              minX: minX,
              maxX: maxX,
              minY: 0,
              maxY: maxY,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(
    List<PieChartSectionData> sections,
    Map<String, List<Movement>> grouped,
  ) {
    return Column(
      children: [
        Text(
          'Distribuição de Produtos Movimentados',
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

                        final productId = grouped.keys.elementAt(_touchedIndex);
                        final product = grouped[productId]!.first;

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

              // 🖼️ IMAGEM — APENAS NO CANTO INFERIOR ESQUERDO
              if (_touchedLabel != null)
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
                          color: Colors.black.withOpacity(0.2),
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

        // Legenda
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            final productId = grouped.keys.elementAt(index);
            final product = grouped[productId]!.first;

            return Row(
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
                Text(
                  product.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
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

  Widget _buildProductCard(List<Movement> movements) {
    final product = movements.first;

    final add = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);

    final remove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ],
        ),
      ),
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
                'Entrada: $add',
                const Color(0xFFD5F4E6),
                const Color(0xFF27AE60),
              ),
            if (remove > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _tag(
                  'Saída: $remove',
                  const Color(0xFFFADBD8),
                  const Color(0xFFE74C3C),
                ),
              ),
          ],
        ),
      ],
    );
  }
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

Color generateDistinctColor(int index) {
  // Espaça o matiz (hue) em saltos grandes
  final double hue = (index * 137.508) % 360;
  // 137.508 = ângulo dourado → evita cores parecidas

  return HSVColor.fromAHSV(
    1.0, // alpha
    hue, // matiz
    0.65, // saturação (viva, mas não neon exagerado)
    0.85, // brilho (ótimo pra texto branco)
  ).toColor();
}
