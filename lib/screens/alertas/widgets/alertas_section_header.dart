// lib/screens/alertas/widgets/alertas_section_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertasSectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const AlertasSectionHeader({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 24,
          decoration: BoxDecoration(
            color: color.withAlpha(204),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
