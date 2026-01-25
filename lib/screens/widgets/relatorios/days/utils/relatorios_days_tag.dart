// lib/screens/widgets/relatorios/days/utils/relatorios_days_tag.dart
import 'package:flutter/material.dart';

class RelatoriosTag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const RelatoriosTag({
    super.key,
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
