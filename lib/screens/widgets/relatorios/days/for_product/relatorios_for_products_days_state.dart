// lib/screens/widgets/relatorios/days/for_product/relatorios_for_products_days_state.dart
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../firebase/firestore/movements_days.dart';

import '../../../../models/salve_modal.dart';


import 'relatorios_for_products_days.dart';

import 'utils/relatorios_for_products_date.dart';

import 'widgets/top_actions.dart';
import 'widgets/empty_state.dart';
import 'widgets/product_header_card.dart';
import 'widgets/product_line_chart_card.dart';
import 'widgets/product_summary_card.dart';
import 'widgets/movements_list_card.dart';

class RelatoriosForProductsState extends State<RelatoriosForProducts> {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;

  late DateTime _displayDate;
  late String _uid;
  late String _productId;

  Timer? _timer;

  late ValueNotifier<List<Movement>> _movementsNotifier;

  @override
  void initState() {
    super.initState();

    _movementsNotifier = ValueNotifier<List<Movement>>([]);

    _uid = widget.uid;
    _productId = widget.productId;

    // ✅ usa período recebido
    _displayDate = widget.period.isDay
        ? widget.period.specificDay!
        : widget.period.monthReference!.firstDay;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ i18n: formatação de datas com base no locale atual
    // Obs: initializeDateFormatting é async, então controlamos com flag.
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    if (_localeReady) return;

    final locale = Localizations.localeOf(context);
    final tag = locale.toLanguageTag(); // ex: pt-BR, de-CH
    await initializeDateFormatting(tag, null);

    if (!mounted) return;
    setState(() => _localeReady = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _movementsNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // ⚠️ aqui mantém seleção de DIA (igual seu original)
    final picked = await showDatePicker(
      context: context,
      initialDate: _displayDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Localizations.localeOf(context),
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

  void _openSaveModal(List<Movement> movements) {
    SalveModal.show(
      context,
      days: [_displayDate],
      uid: _uid,
      movements: movements,
    );
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

    final displayDateText = relatoriosForProductDisplayDateText(
      displayDate: _displayDate,
      now: DateTime.now(),
      l10n: l10n,
      context: context,
    );

    final title = relatoriosForProductFormatDateTitle(
      date: _displayDate,
      period: widget.period,
      context: context,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          l10n.relatoriosProductReportTitle, // ✅ i18n
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          RelatoriosForProductTopActions(
            movementsNotifier: _movementsNotifier,
            displayDateText: displayDateText,
            onPickDate: _pickDate,
            onExport: _openSaveModal,
            exportLabel: l10n.relatoriosExportReport, // ✅ reaproveita a chave
          ),
          Expanded(
            child: _buildReport(
              l10n: l10n,
              title: title,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReport({
    required AppLocalizations l10n,
    required String title,
  }) {
    final Stream<List<Movement>> movementsStream;

    if (widget.period.isDay) {
      movementsStream = _movementsService.getDailyMovementsStream(
        day: widget.period.specificDay!,
        uid: _uid,
      );
    } else if (widget.period.isMonth) {
      final month = widget.period.monthReference!;
      movementsStream = _movementsService.getMonthlyMovementsStream(
        month: month.month,
        year: month.year,
        uid: _uid,
      );
    } else {
      movementsStream = _movementsService.getDailyMovementsStream(
        day: widget.period.startDate,
        uid: _uid,
      );
    }

    return StreamBuilder<List<Movement>>(
      stream: movementsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }

        final allMovements = snapshot.data!;

        // filtra por produto e período
        final movements = allMovements
            .where(
              (m) => m.productId == _productId && widget.period.contains(m.timestamp),
            )
            .toList();

        _movementsNotifier.value = List.from(movements);

        if (movements.isEmpty) {
          final periodDescription = widget.period.getDescription();
          return RelatoriosForProductEmptyState(
            title: l10n.relatoriosNoMovementsForPeriod(periodDescription),
            subtitle: widget.period.isMonth
                ? l10n.relatoriosSelectAnotherMonthHint
                : l10n.relatoriosSelectAnotherDateHint,
          );
        }

        return _buildProductReport(
          l10n: l10n,
          title: title,
          movements: movements,
        );
      },
    );
  }

  Widget _buildProductReport({
    required AppLocalizations l10n,
    required String title,
    required List<Movement> movements,
  }) {
    final product = movements.first;

    final totalAdd = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);

    final totalRemove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    final currentStock = totalAdd - totalRemove;

    final availabilityLabel = currentStock > 0
        ? l10n.relatoriosAvailabilityAvailable
        : l10n.relatoriosAvailabilityUnavailable;

    // ---- chart data (cumulativo) ----
    final sortedMovements = List<Movement>.from(movements)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int cumulativeAdd = 0;
    int cumulativeRemove = 0;

    final List<FlSpot> spotsAdd = [];
    final List<FlSpot> spotsRemove = [];

    // refs pra tooltip bater corretamente por tipo
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

    final allX = <double>{...spotsAdd.map((e) => e.x), ...spotsRemove.map((e) => e.x)};
    final sortedX = allX.toList()..sort();

    double minX = sortedX.isNotEmpty ? sortedX.first - 1 : 0;
    double maxX = sortedX.isNotEmpty ? sortedX.last + 1 : 24;
    if (minX < 0) minX = 0;
    if (maxX > 24) maxX = 24;

    final maxCumulative = [cumulativeAdd, cumulativeRemove].reduce((a, b) => a > b ? a : b);
    final maxY = (maxCumulative + 10).toDouble();

    // lista detalhada: mais recente primeiro
    final detailedMovements = List<Movement>.from(movements)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

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

        // header do produto
        RelatoriosForProductHeaderCard(
          productName: product.productName,
          imageUrl: product.image,
          currentStock: currentStock,
          availabilityLabel: availabilityLabel,
          currentStockLabel: l10n.relatoriosCurrentStockWithValue(currentStock),
        ),

        // gráfico
        RelatoriosForProductLineChartCard(
          period: widget.period,
          productName: product.productName,
          titleDay: l10n.relatoriosCumulativeMovementsOfProduct(product.productName),
          titleMonth: l10n.relatoriosCumulativeMovementsOfProductInMonth(product.productName),
          spotsAdd: spotsAdd,
          spotsRemove: spotsRemove,
          refsAdd: refsAdd,
          refsRemove: refsRemove,
          minX: minX,
          maxX: maxX,
          maxY: maxY,
        ),

        const SizedBox(height: 16),

        // resumo executivo
        RelatoriosForProductSummaryCard(
          title: l10n.relatoriosExecutiveSummaryProductTitle,
          entriesLabel: l10n.relatoriosEntries,
          exitsLabel: l10n.relatoriosExits,
          netLabel: l10n.relatoriosNetBalance,
          totalAdd: totalAdd,
          totalRemove: totalRemove,
        ),

        const SizedBox(height: 16),

        // lista detalhada
        RelatoriosForProductMovementsListCard(
          title: l10n.relatoriosDetailedMovementsTitle,
          timeLabel: l10n.relatoriosTimeLabel,
          entryLabel: l10n.relatoriosEntry,
          exitLabel: l10n.relatoriosExit,
          movements: detailedMovements,
        ),
      ],
    );
  }
}
