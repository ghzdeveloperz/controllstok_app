import 'dart:async';
import 'dart:convert';
import 'package:controllstok_app/screens/models/salve_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../firebase/movements_days.dart';

class RelatoriosDays extends StatefulWidget {
  final String userId;

  const RelatoriosDays({super.key, required this.userId});

  @override
  State<RelatoriosDays> createState() => _RelatoriosDaysState();
}

class _RelatoriosDaysState extends State<RelatoriosDays> {
  bool _localeReady = false;
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();
  late DateTime _displayDate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _displayDate = DateTime.now();

    // Atualiza a tela a cada minuto para refletir "Hoje" em tempo real
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
    } else {
      return DateFormat('dd/MM/yyyy').format(_displayDate);
    }
  }

  String _formatDateTitle(DateTime date) {
    final weekdayName = DateFormat('EEEE', 'pt_BR').format(date);
    final day = DateFormat('dd', 'pt_BR').format(date);
    final monthName = DateFormat('MMMM', 'pt_BR').format(date);
    final year = date.year;
    return '${weekdayName[0].toUpperCase()}${weekdayName.substring(1)}, $day de ${monthName[0].toUpperCase()}${monthName.substring(1)} de $year';
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
          Padding(
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
                            color: Colors.black.withValues(
                              alpha: 0.2,
                            ), // Linha 140
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
                    onPressed: () {
                      // Aqui você chama o modal
                      SalveModal.show(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF1A1A1A),
                        width: 2,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(
                        alpha: 0.1,
                      ), // Linha 177
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Exportar Relatório',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Movement>>(
              stream: _movementsService.getDailyMovementsStream(
                userId: widget.userId,
                day: _displayDate,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  );
                }

                final movements = snapshot.data!;
                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
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

                Map<String, List<Movement>> groupedByProduct = {};
                for (var m in movements) {
                  groupedByProduct.putIfAbsent(m.productId, () => []).add(m);
                }

                final List<Widget> children = [];

                children.add(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      _formatDateTitle(_displayDate),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );

                for (var entry in groupedByProduct.entries) {
                  final productMovements = entry.value;
                  final productName = productMovements.first.productName;
                  final productImage = productMovements.first.image;

                  final totalAdd = productMovements
                      .where((e) => e.type == 'add')
                      .fold<int>(0, (p, e) => p + e.quantity);
                  final totalRemove = productMovements
                      .where((e) => e.type == 'remove')
                      .fold<int>(0, (p, e) => p + e.quantity);

                  children.add(
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  productImage != null &&
                                      productImage.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(
                                        productImage.contains(',')
                                            ? productImage.split(',')[1]
                                            : productImage,
                                      ),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (totalAdd > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Entrada: $totalAdd',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      if (totalRemove > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Saída: $totalRemove',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (totalAdd > 0)
                                        Expanded(
                                          flex: totalAdd,
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      if (totalRemove > 0)
                                        Expanded(
                                          flex: totalRemove,
                                          child: Container(
                                            height: 8,
                                            margin: const EdgeInsets.only(
                                              left: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
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
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  children: children,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
