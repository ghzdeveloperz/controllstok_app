import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  static const Color _muted = Color(0xFF6B7280);
  static const Color _ink = Color(0xFF0B0F14);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _ink.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _muted,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
