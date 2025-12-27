import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/movements_days.dart';
import '../screens/models/salve_modal.dart';

/// =======================
/// LEGEND WIDGET
/// =======================
class Legend {
  final String name;
  final Color color;
  Legend(this.name, this.color);
}

class LegendsListWidget extends StatelessWidget {
  final List<Legend> legends;

  const LegendsListWidget({
    super.key,
    required this.legends,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: legends
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: e.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

/// =======================
/// RELATÓRIO ANUAL
/// =======================
class RelatoriosYears extends StatefulWidget {
  const RelatoriosYears({super.key});

  @override
  State<RelatoriosYears> createState() => _RelatoriosYearsState();
}

class _RelatoriosYearsState extends State<RelatoriosYears> {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;
  late int _displayYear;
  late String _uid;
  Timer? _timer;
  List<Movement> _movements = [];

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
    _displayYear = DateTime.now().year;

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
      await _fetchMovements();
    }
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
      setState(() => _displayYear = picked.year);
      await _fetchMovements();
    }
  }

  Future<void> _fetchMovements() async {
    final data = await _movementsService.getYearlyMovements(
      year: _displayYear,
      uid: _uid,
    );

    if (!mounted) return;
    setState(() => _movements = data);
  }

  String get _displayYearText {
    final now = DateTime.now();
    if (_displayYear == now.year) {
      return 'Este ano';
    }
    return _displayYear.toString();
  }

  String _formatYearTitle(int year) {
    return 'Relatório de $year';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickYear,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF424242)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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
                      _displayYearText,
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
              onPressed: () => SalveModal.show(context),
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
                    'Exportar',  // Texto encurtado para evitar overflow
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
    if (_movements.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGroupedList(_movements);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                'Nenhuma movimentação $_displayYearText',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione outro ano ou adicione novas movimentações.',
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

  Widget _buildGroupedList(List<Movement> movements) {
    // Agrupar por mês
    final Map<int, List<Movement>> groupedByMonth = {};
    for (final m in movements) {
      groupedByMonth.putIfAbsent(m.date.month, () => []).add(m);
    }

    // Calcular totais para o gráfico e resumo
    final totalAdd = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);
    final totalRemove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          _formatYearTitle(_displayYear),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      // Gráfico profissional de barras com estilo premium
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 300,
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
          child: _buildBarChart(),
        ),
      ),
      const SizedBox(height: 20),
      // Legenda ou resumo
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Resumo do Ano',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Entradas', totalAdd, Colors.green),
                  _buildSummaryItem('Saídas', totalRemove, Colors.red),
                  _buildSummaryItem(
                    'Saldo',
                    totalAdd - totalRemove,
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
    ];

    // Adicionar seções por mês
    final sortedMonths = groupedByMonth.keys.toList()..sort();
    for (final month in sortedMonths) {
      final monthMovements = groupedByMonth[month]!;
      children.add(_buildMonthSection(month, monthMovements));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
    );
  }

  Widget _buildSummaryItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  /// =======================
  /// CHART
  /// =======================
  Widget _buildBarChart() {
    final Map<int, int> addByMonth = {};
    final Map<int, int> removeByMonth = {};

    for (final m in _movements) {
      final month = m.date.month;
      if (m.type == 'add') {
        addByMonth[month] = (addByMonth[month] ?? 0) + m.quantity;
      } else {
        removeByMonth[month] = (removeByMonth[month] ?? 0) + m.quantity;
      }
    }

    final barGroups = List.generate(12, (i) {
      final month = i + 1;
      final add = addByMonth[month]?.toDouble() ?? 0;
      final remove = removeByMonth[month]?.toDouble() ?? 0;

      return BarChartGroupData(
        x: i,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: add,
            width: 14,
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
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
              colors: [Color(0xFFF44336), Color(0xFFEF5350)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });

    final maxY = barGroups
            .expand((e) => e.barRods)
            .map((e) => e.toY)
            .fold<double>(0, (p, c) => c > p ? c : p) +
        5;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movimentações Anuais',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          LegendsListWidget(
            legends: [
              Legend('Entradas', const Color(0xFF4CAF50)),
              Legend('Saídas', const Color(0xFFF44336)),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 2.2,  // Ajustado para expandir ligeiramente a largura
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 5,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const months = [
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = rodIndex == 0 ? 'Entrada' : 'Saída';
                      return BarTooltipItem(
                        '$label: ${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildMonthSection(int month, List<Movement> movements) {
    final monthDate = DateTime(_displayYear, month);
    final monthTitle = DateFormat('MMMM/yyyy', 'pt_BR').format(monthDate);

    // Agrupar produtos por productId dentro do mês
        final Map<String, List<Movement>> groupedByProduct = {};
    for (final m in movements) {
      groupedByProduct.putIfAbsent(m.productId, () => []).add(m);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            monthTitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...groupedByProduct.values.map((productMovements) => _buildProductCard(productMovements)),
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

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildProductImage(product.image),
            const SizedBox(width: 12),
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
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _buildProductInfo(String name, int add, int remove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (add > 0)
              _tag(
                'Entrada: $add',
                Colors.green.shade50,
                Colors.green.shade700,
              ),
            if (remove > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _tag(
                  'Saída: $remove',
                  Colors.red.shade50,
                  Colors.red.shade700,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}