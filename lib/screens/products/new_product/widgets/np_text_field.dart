// lib/screens/products/new_product/widgets/np_text_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NPTextField extends StatelessWidget {
  final TextEditingController controller;

  // ✅ l10n
  final String label;
  final String hint;

  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  /// Se você quiser usar validação padrão aqui dentro
  final String? requiredMessage;

  const NPTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.requiredMessage,
  });

  String? _defaultValidator(String? v) {
    if (requiredMessage == null) return null;
    if (v == null || v.trim().isEmpty) return requiredMessage;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveValidator = validator ?? _defaultValidator;

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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: effectiveValidator,
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
      ],
    );
  }
}
