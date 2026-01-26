// lib/screens/widgets/relatorios/days/for_product/widgets/movements_list_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../firebase/firestore/movements_days.dart';

class RelatoriosForProductMovementsListCard extends StatelessWidget {
  final String title;
  final String timeLabel;

  final String entryLabel;
  final String exitLabel;

  final List<Movement> movements;

  const RelatoriosForProductMovementsListCard({
    super.key,
    required this.title,
    required this.timeLabel,
    required this.entryLabel,
    required this.exitLabel,
    required this.movements,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            ...movements.map((movement) {
              final timeStr = DateFormat('HH:mm').format(movement.timestamp);
              final isAdd = movement.type == 'add';

              final typeLabel = isAdd ? entryLabel : exitLabel;
              final color = isAdd ? const Color(0xFF27AE60) : const Color(0xFFE74C3C);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$typeLabel: ${movement.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            '$timeLabel: $timeStr',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
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
    );
  }
}
