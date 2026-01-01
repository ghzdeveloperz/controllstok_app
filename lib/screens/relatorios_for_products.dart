import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/movements_days.dart';
import '../screens/models/salve_modal.dart';
import '../screens/models/report_period.dart';
import '../screens/models/month_reference.dart';

class RelatoriosForProducts extends StatefulWidget {
  final String productId;
  final String uid;
  final ReportPeriod
  period; // ✅ PERÍODO DO RELATÓRIO (não mais DateTime ambíguo)

  const RelatoriosForProducts({
    super.key,
    required this.productId,
    required this.uid,
    required this.period, // ✅ RECEBE O PERÍODO EXPLÍCITO
  });

  /// Construtor de compatibilidade para código legado que passa DateTime
  /// @deprecated Use o construtor principal com ReportPeriod
  factory RelatoriosForProducts.fromDate({
    required String productId,
    required String uid,
    required DateTime date,
  }) {
    // Tenta detectar se é um mês (dia 1) ou dia específico
    final period = date.day == 1
        ? ReportPeriod.month(MonthReference.fromDateTime(date))
        : ReportPeriod.day(date);

    return RelatoriosForProducts(
      productId: productId,
      uid: uid,
      period: period,
    );
  }

  @override
  State<RelatoriosForProducts> createState() => _RelatoriosForProductsState();
}

class _RelatoriosForProductsState extends State<RelatoriosForProducts> {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;
  late DateTime _displayDate;
  late String _uid;
  late String _productId;
  Timer? _timer;
  late ValueNotifier<List<Movement>> _movementsNotifier; // ValueNotifier para os movimentos

  @override
  void initState() {
    super.initState();

    _movementsNotifier = ValueNotifier<List<Movement>>([]);

    _uid = widget.uid;
    _productId = widget.productId;

    // ✅ USA O PERÍODO RECEBIDO
    // Se for um dia específico, usa esse dia
    // Se for um mês, usa o primeiro dia do mês para exibição
    _displayDate = widget.period.isDay
        ? widget.period.specificDay!
        : widget.period.monthReference!.firstDay;

    _initializeLocale();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _movementsNotifier.dispose();
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
    // ✅ Formata o título baseado no tipo de período
    if (widget.period.isMonth) {
      final month = DateFormat('MMMM', 'pt_BR').format(date);
      return '${month[0].toUpperCase()}${month.substring(1)} de ${date.year}';
    } else {
      final weekday = DateFormat('EEEE', 'pt_BR').format(date);
      final day = DateFormat('dd', 'pt_BR').format(date);
      final month = DateFormat('MMMM', 'pt_BR').format(date);

      return '${weekday[0].toUpperCase()}${weekday.substring(1)}, '
          '$day de ${month[0].toUpperCase()}${month.substring(1)} de ${date.year}';
    }
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
    return ValueListenableBuilder<List<Movement>>(
      valueListenable: _movementsNotifier,
      builder: (context, movements, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
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
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _displayDateText,
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
                  onPressed: movements.isNotEmpty
                      ? () => SalveModal.show(
                            context,
                            days: [_displayDate],
                            uid: _uid,
                            movements: movements,
                          )
                      : null, // ✅ Desabilita se movements estiver vazio
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
                      Text(
                        'Exportar Relatório',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= REPORT =================
  Widget _buildReport() {
    // ✅ AGORA USA A CONSULTA CORRETA BASEADA NO TIPO DE PERÍODO
    final Stream<List<Movement>> movementsStream;

    if (widget.period.isDay) {
      // Relatório de um dia específico
      movementsStream = _movementsService.getDailyMovementsStream(
        day: widget.period.specificDay!,
        uid: _uid,
      );
    } else if (widget.period.isMonth) {
      // Relatório de um mês completo
      final month = widget.period.monthReference!;
      movementsStream = _movementsService.getMonthlyMovementsStream(
        month: month.month,
        year: month.year,
        uid: _uid,
      );
    } else {
      // Período customizado - usa consulta diária do primeiro dia
      // (pode ser expandido no futuro para suportar ranges customizados)
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

        // Filtra por produto e pelo período (importante para períodos customizados)
        final movements = allMovements
            .where(
              (m) =>
                  m.productId == _productId &&
                  widget.period.contains(m.timestamp),
            )
            .toList();

        // Atualizar o notifier com os movimentos filtrados
        _movementsNotifier.value = List.from(movements);

        if (movements.isEmpty) {
          return _buildEmptyState();
        }

        return _buildProductReport(movements);
      },
    );
  }

  Widget _buildEmptyState() {
    final periodDescription = widget.period.getDescription();

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
                'Nenhuma movimentação em $periodDescription',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.period.isMonth
                    ? 'Selecione outro mês ou adicione novas movimentações.'
                    : 'Selecione outra data ou adicione novas movimentações.',
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

  Widget _buildProductReport(List<Movement> movements) {
    final product = movements.first;

    final totalAdd = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);
    final totalRemove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    final currentStock = totalAdd - totalRemove;
    final availability = currentStock > 0 ? 'Disponível' : 'Indisponível';

    // Preparar dados para o gráfico de linha (quantidade cumulativa ao longo do tempo)
    final sortedMovements = movements
      ..sort(
        (a, b) => a.timestamp.compareTo(b.timestamp),
      ); // Do antigo ao atual para o gráfico
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

    // Lista detalhada ordenada do mais recente ao antigo
    final detailedMovements = List<Movement>.from(movements)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Coletar valores X únicos
    final Set<double> allX = {};
    for (final spot in spotsAdd) {
      allX.add(spot.x);
    }
    for (final spot in spotsRemove) {
      allX.add(spot.x);
    }
    final List<double> sortedX = allX.toList()..sort();

    double minX = sortedX.isNotEmpty ? sortedX.first - 1 : 0;
    double maxX = sortedX.isNotEmpty ? sortedX.last + 1 : 24;
    minX = minX < 0 ? 0 : minX;
    maxX = maxX > 24 ? 24 : maxX;

    final maxCumulative = [
      cumulativeAdd,
      cumulativeRemove,
    ].reduce((a, b) => a > b ? a : b);
    final maxY = (maxCumulative + 10).toDouble();

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
      // Informações do Produto
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
              // Imagem do produto com efeito premium
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
                  child: _buildProductImage(product.image),
                ),
              ),

              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
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
                          'Estoque Atual: $currentStock',
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
      // Gráfico
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      widget.period.isMonth
                          ? 'Movimentações Cumulativas de ${product.productName} no Mês'
                          : 'Movimentações Cumulativas de ${product.productName}',
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
                                  if (value % 2 == 0 &&
                                      value >= 0 &&
                                      value <= 24) {
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
                                return touchedSpots.map((spot) {
                                  final isAdd = spot.barIndex == 0;
                                  final spotsList = isAdd
                                      ? spotsAdd
                                      : spotsRemove;
                                  final index = spotsList.indexOf(spot);
                                  if (index != -1) {
                                    final movementsForType = sortedMovements
                                        .where(
                                          (m) =>
                                              m.type ==
                                              (isAdd ? 'add' : 'remove'),
                                        )
                                        .toList();
                                    final movement = movementsForType[index];
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
                                (
                                  FlTouchEvent event,
                                  LineTouchResponse? touchResponse,
                                ) {
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
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      // Resumo Executivo do Produto
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
      // Lista de Movimentações Detalhadas
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
              ...detailedMovements.map((movement) {
                final timeStr = DateFormat('HH:mm').format(movement.timestamp);
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