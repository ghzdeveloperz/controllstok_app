import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../l10n/app_localizations.dart';

Future<String?> showAddCategoryDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      title: Text(
        l10n.categoriesAddTitle,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: l10n.categoriesAddHint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.6),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            l10n.actionCancel,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(dialogContext, name);
          },
          child: Text(
            l10n.actionSave,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
