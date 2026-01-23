import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlagCircle extends StatelessWidget {
  final String text;
  const FlagCircle({super.key, required this.text});

  static const Color _ink = Color(0xFF0B0F14);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
      ),
    );
  }
}
