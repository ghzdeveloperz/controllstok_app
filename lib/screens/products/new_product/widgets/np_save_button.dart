// lib/screens/products/new_product/widgets/np_save_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NPSaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  // ✅ l10n
  final String label;

  const NPSaveButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
    this.label = 'Salvar Produto',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
