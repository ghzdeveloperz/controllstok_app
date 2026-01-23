// lib/screens/products/new_product/widgets/np_product_name_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/product_name_utils.dart';

class NPProductNameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  final bool isDuplicate;
  final String duplicateMessage;
  final ValueChanged<String> onChanged;

  // ✅ textos configuráveis (l10n)
  final String label;
  final String hint;

  final String requiredMessage;
  final String minLengthMessage;
  final String maxLengthMessage;
  final String duplicateValidatorMessage;

  /// Ex: (count) => "{count}/50 caracteres"
  final String Function(int count) helperChars;
  final String helperNearLimit;
  final String helperLimitReached;

  // ✅ fallback constante (tear-off permitido)
  static String _defaultHelperChars(int count) => '$count/50 caracteres';

  const NPProductNameField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isDuplicate,
    required this.duplicateMessage,
    required this.onChanged,

    this.label = 'Nome do produto',
    this.hint = 'Ex: Arroz 5kg',

    this.requiredMessage = 'Campo obrigatório',
    this.minLengthMessage = 'Nome deve ter pelo menos 2 caracteres',
    this.maxLengthMessage = 'Nome deve ter no máximo 50 caracteres',
    this.duplicateValidatorMessage = 'Nome já existe. Escolha outro.',

    String Function(int count)? helperChars,
    this.helperNearLimit = '(Quase perto do limite)',
    this.helperLimitReached = '(limite atingido)',
  }) : helperChars = helperChars ?? _defaultHelperChars;

  String _helperText() {
    final length = normalizeProductName(controller.text).length;
    final remaining = 50 - length;

    var text = helperChars(length);

    if (remaining < 3 && remaining >= 1) {
      text += ' $helperNearLimit';
    }
    if (remaining == 0) {
      text += ' $helperLimitReached';
    }
    if (isDuplicate && duplicateMessage.isNotEmpty) {
      text += '\n$duplicateMessage';
    }

    return text;
  }

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
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.text,
          maxLength: 50,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ0-9\s\-_.,]")),
          ],
          onChanged: onChanged,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return requiredMessage;

            final normalized = normalizeProductName(v);
            if (normalized.length < 2) return minLengthMessage;
            if (normalized.length > 50) return maxLengthMessage;
            if (isDuplicate) return duplicateValidatorMessage;

            return null;
          },
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
            counterText: '',
            helperText: _helperText(),
            helperStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            suffixIcon: isDuplicate ? Icon(Icons.warning, color: Colors.grey.shade600) : null,
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
