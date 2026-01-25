// lib/screens/widgets/relatorios/days/widgets/legend_item.dart
import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const LegendItem({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF34495E),
          ),
        ),
      ],
    );
  }
}
