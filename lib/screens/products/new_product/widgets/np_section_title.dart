// lib/screens/products/new_product/widgets/np_section_title.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NPSectionTitle extends StatelessWidget {
  final String title;
  const NPSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }
}
