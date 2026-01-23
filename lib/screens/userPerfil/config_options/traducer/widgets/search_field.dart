import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  static const Color _surface = Colors.white;
  static const Color _ink = Color(0xFF0B0F14);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14.5,
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: _muted.withValues(alpha: 0.9)),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: controller.clear,
                icon: Icon(Icons.close_rounded, color: _muted.withValues(alpha: 0.9)),
                tooltip: 'Limpar',
              );
            },
          ),
          filled: true,
          fillColor: _surface,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
