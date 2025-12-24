import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../firebase/movements_days.dart';
import '../screens/models/salve_modal.dart';

class RelatoriosDays extends StatefulWidget {
  const RelatoriosDays({super.key});

  @override
  State<RelatoriosDays> createState() => _RelatoriosDaysState();
}

class _RelatoriosDaysState extends State<RelatoriosDays> {
  final MovementsDaysFirestore _movementsService =
      MovementsDaysFirestore();

  bool _localeReady = false;
  late DateTime _displayDate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _displayDate = DateTime.now();
    _initializeLocale();

    // mantém "Hoje" atualizado
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
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.white),
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
                side:
                    const BorderSide(color: Color(0xFF1A1A1A), width: 2),
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
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
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
        if (movements.isEmpty) {
          return _buildEmptyState();
        }

        return _buildGroupedList(movements);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhuma movimentação em ${DateFormat('dd/MM/yyyy').format(_displayDate)}',
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

  Widget _buildGroupedList(List<Movement> movements) {
    final Map<String, List<Movement>> grouped = {};

    for (final m in movements) {
      grouped.putIfAbsent(m.productId, () => []).add(m);
    }

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          _formatDateTitle(_displayDate),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
    ];

    for (final entry in grouped.values) {
      children.add(_buildProductCard(entry));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
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
              child:
                  _buildProductInfo(product.productName, add, remove),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? image) {
    if (image == null || image.isEmpty) {
      return _imagePlaceholder();
    }

    try {
      final base64 = image.contains(',')
          ? image.split(',').last
          : image;

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          base64Decode(base64),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return _imagePlaceholder();
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_not_supported,
          color: Colors.grey),
    );
  }

  Widget _buildProductInfo(String name, int add, int remove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (add > 0)
              _tag('Entrada: $add',
                  Colors.green.shade50, Colors.green.shade700),
            if (remove > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _tag('Saída: $remove',
                    Colors.red.shade50, Colors.red.shade700),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
