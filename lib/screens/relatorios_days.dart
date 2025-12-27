import 'dart:async';
// import 'dart:convert'; // Removido, pois não é mais necessário para Base64

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart'; // Adicione esta dependência ao pubspec.yaml
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/movements_days.dart';
import '../screens/models/salve_modal.dart';

class RelatoriosDays extends StatefulWidget {
  const RelatoriosDays({super.key});

  @override
  State<RelatoriosDays> createState() => _RelatoriosDaysState();
}

class _RelatoriosDaysState extends State<RelatoriosDays> {
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();

  bool _localeReady = false;
  late DateTime _displayDate;
  late String _uid;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _uid = FirebaseAuth.instance.currentUser!.uid;
    _displayDate = DateTime.now();

    _initializeLocale();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
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

  // ================= TOP ACTIONS =================
  Widget _buildTopActions() {
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

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          _formatDateTitle(_displayDate),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalAdd + totalRemove).toDouble() + 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = rodIndex == 0 ? 'Entrada' : 'Saída';
                      return BarTooltipItem(
                        '$label: ${rod.toY.toInt()}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text(
                              'Entrada',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          case 1:
                            return const Text(
                              'Saída',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
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
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalAdd.toDouble(),
                        color: Colors.green.shade600,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (totalAdd + totalRemove).toDouble() + 10,
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: totalRemove.toDouble(),
                        color: Colors.red.shade600,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (totalAdd + totalRemove).toDouble() + 10,
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                'Resumo do Dia',
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

    for (final entry in grouped.values) {
      children.add(_buildProductCard(entry));
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
