// lib/screens/widgets/relatorios/days/for_product/widgets/top_actions.dart
import 'package:flutter/material.dart';

import '../../../../../../firebase/firestore/movements_days.dart';

class RelatoriosForProductTopActions extends StatelessWidget {
  final ValueNotifier<List<Movement>> movementsNotifier;
  final String displayDateText;
  final VoidCallback onPickDate;
  final void Function(List<Movement> movements) onExport;
  final String exportLabel;

  const RelatoriosForProductTopActions({
    super.key,
    required this.movementsNotifier,
    required this.displayDateText,
    required this.onPickDate,
    required this.onExport,
    required this.exportLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Movement>>(
      valueListenable: movementsNotifier,
      builder: (context, movements, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPickDate,
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
                        const Icon(Icons.calendar_today, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          displayDateText,
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
                  onPressed: movements.isNotEmpty ? () => onExport(movements) : null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A1A1A), width: 2),
                    foregroundColor: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        exportLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
}
