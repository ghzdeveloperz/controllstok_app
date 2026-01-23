// lib/screens/products/new_product/widgets/np_barcode_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NPBarcodeField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onScanTap;

  // ✅ l10n
  final String label;
  final String hint;
  final String requiredMessage;

  const NPBarcodeField({
    super.key,
    required this.controller,
    required this.onScanTap,

    this.label = 'Código de barras',
    this.hint = 'Ex: 7894900011517',
    this.requiredMessage = 'Campo obrigatório',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().isEmpty ? requiredMessage : null,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onScanTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
