// lib/screens/relatorios_days.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../firebase/movements_days.dart';

class RelatoriosDays extends StatefulWidget {
  final String userId;
  final DateTime? selectedDate;

  const RelatoriosDays({super.key, required this.userId, this.selectedDate});

  @override
  State<RelatoriosDays> createState() => _RelatoriosDaysState();
}

class _RelatoriosDaysState extends State<RelatoriosDays> {
  bool _localeReady = false;
  final MovementsDaysFirestore _movementsService = MovementsDaysFirestore();
  late DateTime _displayDate;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _displayDate = widget.selectedDate ?? DateTime.now();
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
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800, //largura do modal
              maxHeight: 600, // altura do modal
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _displayDate = picked);
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
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Botão compacto de seleção de data
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity, // botão ocupa toda a largura disponível
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ), // padding vertical
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // conteúdo centralizado
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_displayDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Conteúdo principal
        Expanded(
          child: StreamBuilder<List<Movement>>(
            stream: _movementsService.getDailyMovementsStream(
              userId: widget.userId,
              day: _displayDate,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final movements = snapshot.data!;
              if (movements.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhuma movimentação em ${DateFormat('dd/MM/yyyy').format(_displayDate)}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
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
                                productImage != null && productImage.isNotEmpty
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
                                        margin: const EdgeInsets.only(left: 8),
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                children: children,
              );
            },
          ),
        ),
      ],
    );
  }
}
