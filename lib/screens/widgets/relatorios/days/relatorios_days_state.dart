// lib/screens/widgets/relatorios/days/relatorios_days_state.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../../l10n/app_localizations.dart';

import '../../../../firebase/firestore/movements_days.dart';
import '../../../models/report_period.dart';
import '../../../models/salve_modal.dart';
import '../days/for_product/relatorios_for_products_days.dart';

import 'relatorios_days.dart'; // ✅ IMPORTA O WIDGET DO MESMO MÓDULO

import 'utils/relatorios_days_date.dart';

import 'widgets/top_actions.dart';
import 'widgets/empty_state.dart';
import 'widgets/chart_type_selector.dart';
import 'widgets/percentual_chip.dart';
import 'widgets/summary_card.dart';
import 'widgets/products_moved_card.dart';
import 'widgets/product_detail_card.dart';

import 'charts/line_chart_section.dart';
import 'charts/pie_chart_section.dart';



class RelatoriosDaysState extends State<RelatoriosDays>
    with TickerProviderStateMixin {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;
  late DateTime _displayDate;
  late String _uid;
  Timer? _timer;

  String? _selectedProductId;
  String _selectedChartType = 'Linha'; // Linha | Pizza
  String _percentualMode = 'all'; // all | add | remove

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _pieTouchedIndex = -1;
 
  String? _pieTouchedImageUrl;

  late ValueNotifier<List<Movement>> _movementsNotifier;

  @override
  void initState() {
    super.initState();

    _movementsNotifier = ValueNotifier<List<Movement>>([]);
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
    _movementsNotifier.dispose();
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    // Mantendo pt_BR para formatação de data (títulos e etc.)
    await initializeDateFormatting('pt_BR', null);
    if (!mounted) return;
    setState(() => _localeReady = true);
  }

  void _openSaveModal(List<Movement> movements) {
    SalveModal.show(
      context,
      days: [_displayDate],
      uid: _uid,
      movements: movements,
    );
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
      setState(() {
        _displayDate = picked;
        _selectedProductId = null;

        _pieTouchedIndex = -1;
       
        _pieTouchedImageUrl = null;
      });
    }
  }

  void _onSelectProductFromChart(String productId) {
    if (!mounted) return;
    setState(() => _selectedProductId = productId);
  }

  void _onPieTouch({
    required int touchedIndex,
    required String? label,
    required String? imageUrl,
  }) {
    setState(() {
      _pieTouchedIndex = touchedIndex;
      
      _pieTouchedImageUrl = imageUrl;
    });
  }

  void _clearPieTouch() {
    if (!mounted) return;
    setState(() {
      _pieTouchedIndex = -1;

      _pieTouchedImageUrl = null;
    });
  }

  void _goToProductDetails({
    required String productId,
  }) {
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
  }

  /// ✅ Substitui o buildPieChartModel inexistente
  /// Gera PieChartSectionData numa ordem estável (mesma ordem usada por grouped.keys)
  List<PieChartSectionData> _buildPieSections({
    required Map<String, int> productTotals,
    required int totalMovements,
    required int touchedIndex,
  }) {
    if (totalMovements <= 0 || productTotals.isEmpty) return const [];

    final keys = productTotals.keys.toList(); // ordem estável
    final sections = <PieChartSectionData>[];

    for (var i = 0; i < keys.length; i++) {
      final productId = keys[i];
      final value = productTotals[productId] ?? 0;
      if (value <= 0) continue;

      final percent = (value / totalMovements) * 100;
      final isTouched = i == touchedIndex;

      // cor determinística por índice (sem depender de random)
      final color = Colors.primaries[i % Colors.primaries.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: value.toDouble(),
          title: '${percent.toStringAsFixed(0)}%',
          radius: isTouched ? 68 : 56,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_localeReady) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      );
    }

    final displayDateText = relatoriosDisplayDateText(
      displayDate: _displayDate,
      now: DateTime.now(),
      l10n: l10n,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          TopActions(
            movementsNotifier: _movementsNotifier,
            displayDateText: displayDateText,
            onPickDate: _pickDate,
            onExport: _openSaveModal,
          ),
          Expanded(
            child: StreamBuilder<List<Movement>>(
              stream: _movementsService.getDailyMovementsStream(
                day: _displayDate,
                uid: _uid,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  );
                }

                final movements = snapshot.data!;
                _movementsNotifier.value = List.from(movements);

                if (movements.isEmpty) {
                  return EmptyState(displayDateText: displayDateText);
                }

                // ================== AGRUPAMENTO ==================
                final Map<String, List<Movement>> grouped = {};
                for (final m in movements) {
                  grouped.putIfAbsent(m.productId, () => []).add(m);
                }

                // ================== TOTAIS ==================
                final totalAdd = movements
                    .where((e) => e.type == 'add')
                    .fold<int>(0, (p, e) => p + e.quantity);

                final totalRemove = movements
                    .where((e) => e.type == 'remove')
                    .fold<int>(0, (p, e) => p + e.quantity);

                // ================== LINHA (spots + refs) ==================
                final sortedMovements = List<Movement>.from(movements)
                  ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                int cumulativeAdd = 0;
                int cumulativeRemove = 0;

                final List<FlSpot> spotsAdd = [];
                final List<FlSpot> spotsRemove = [];
                final List<Movement> refsAdd = [];
                final List<Movement> refsRemove = [];

                for (final m in sortedMovements) {
                  final x = m.timestamp.hour + m.timestamp.minute / 60.0;
                  if (m.type == 'add') {
                    cumulativeAdd += m.quantity;
                    spotsAdd.add(FlSpot(x, cumulativeAdd.toDouble()));
                    refsAdd.add(m);
                  } else {
                    cumulativeRemove += m.quantity;
                    spotsRemove.add(FlSpot(x, cumulativeRemove.toDouble()));
                    refsRemove.add(m);
                  }
                }

                // zoom minX/maxX
                final allX = <double>{
                  ...spotsAdd.map((e) => e.x),
                  ...spotsRemove.map((e) => e.x),
                };
                final sortedX = allX.toList()..sort();

                double minX = sortedX.isNotEmpty ? sortedX.first - 1 : 0;
                double maxX = sortedX.isNotEmpty ? sortedX.last + 1 : 24;
                if (minX < 0) minX = 0;
                if (maxX > 24) maxX = 24;

                final maxCumulative =
                    [cumulativeAdd, cumulativeRemove].reduce(
                  (a, b) => a > b ? a : b,
                );
                final maxY = (maxCumulative + 10).toDouble();

                // ================== PIE (percentual) ==================
                final Map<String, int> productTotals = {};
                for (final entry in grouped.entries) {
                  final productId = entry.key;

                  final filtered = entry.value.where((m) {
                    if (_percentualMode == 'add') return m.type == 'add';
                    if (_percentualMode == 'remove') return m.type == 'remove';
                    return true;
                  });

                  final total =
                      filtered.fold<int>(0, (p, e) => p + e.quantity);
                  if (total > 0) productTotals[productId] = total;
                }

                final totalMovements =
                    productTotals.values.fold<int>(0, (p, e) => p + e);

                // ✅ gera sections aqui (sem buildPieChartModel)
                final pieSections = _buildPieSections(
                  productTotals: productTotals,
                  totalMovements: totalMovements,
                  touchedIndex: _pieTouchedIndex,
                );

                final title = relatoriosFormatDateTitle(_displayDate);

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ChartTypeSelector(
                        selectedChartType: _selectedChartType,
                        onSelect: (value) =>
                            setState(() => _selectedChartType = value),
                      ),
                    ),

                    if (_selectedChartType == 'Pizza')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            PercentualChip(
                              // ✅ precisa existir no .arb: relatoriosPercentAll
                              label: l10n.relatoriosPercentAll,
                              mode: 'all',
                              selectedMode: _percentualMode,
                              onSelect: (m) =>
                                  setState(() => _percentualMode = m),
                            ),
                            PercentualChip(
                              label: l10n.relatoriosEntries,
                              mode: 'add',
                              selectedMode: _percentualMode,
                              onSelect: (m) =>
                                  setState(() => _percentualMode = m),
                            ),
                            PercentualChip(
                              label: l10n.relatoriosExits,
                              mode: 'remove',
                              selectedMode: _percentualMode,
                              onSelect: (m) =>
                                  setState(() => _percentualMode = m),
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenHeight =
                              MediaQuery.of(context).size.height;
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
                              border: Border.all(
                                  color: const Color(0xFFE0E0E0), width: 1.5),
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
                                    ? LineChartSection(
                                        spotsAdd: spotsAdd,
                                        spotsRemove: spotsRemove,
                                        minX: minX,
                                        maxX: maxX,
                                        maxY: maxY,
                                        refsAdd: refsAdd,
                                        refsRemove: refsRemove,
                                        onSelectProductId:
                                            _onSelectProductFromChart,
                                      )
                                    : PieChartSection(
                                        sections: pieSections,
                                        grouped: grouped,
                                        percentualMode: _percentualMode,
                                        touchedIndex: _pieTouchedIndex,
                                        touchedImageUrl: _pieTouchedImageUrl,
                                        onClearTouch: _clearPieTouch,
                                        onTouch: (payload) {
                                          _onPieTouch(
                                            touchedIndex: payload.index,
                                            label: payload.label,
                                            imageUrl: payload.imageUrl,
                                          );
                                        },
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    SummaryCard(
                      totalAdd: totalAdd,
                      totalRemove: totalRemove,
                      net: totalAdd - totalRemove,
                    ),

                    const SizedBox(height: 16),

                    ProductsMovedCard(
                      grouped: grouped,
                      onGoToProduct: (productId) =>
                          _goToProductDetails(productId: productId),
                    ),

                    const SizedBox(height: 16),

                    if (_selectedProductId != null &&
                        grouped[_selectedProductId] != null)
                      ProductDetailCard(
                        movements: grouped[_selectedProductId!]!,
                      ),
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
