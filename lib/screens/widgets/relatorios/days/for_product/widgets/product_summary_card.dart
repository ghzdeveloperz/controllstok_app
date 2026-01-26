// lib/screens/widgets/relatorios/days/for_product/widgets/product_summary_card.dart
import 'package:flutter/material.dart';

class RelatoriosForProductSummaryCard extends StatelessWidget {
  final String title;

  final String entriesLabel;
  final String exitsLabel;
  final String netLabel;

  final int totalAdd;
  final int totalRemove;

  const RelatoriosForProductSummaryCard({
    super.key,
    required this.title,
    required this.entriesLabel,
    required this.exitsLabel,
    required this.netLabel,
    required this.totalAdd,
    required this.totalRemove,
  });

  @override
  Widget build(BuildContext context) {
    final net = totalAdd - totalRemove;

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
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _item(entriesLabel, totalAdd, const Color(0xFF27AE60))),
                _divider(),
                Expanded(child: _item(exitsLabel, totalRemove, const Color(0xFFE74C3C))),
                _divider(),
                Expanded(child: _item(netLabel, net, const Color(0xFF2C3E50))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
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

  Widget _item(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
