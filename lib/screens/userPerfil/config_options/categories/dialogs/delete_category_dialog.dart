import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../l10n/app_localizations.dart';

Future<bool?> showDeleteCategoryDialog(
  BuildContext context, {
  required String categoryName,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      title: Text(
        l10n.categoriesDeleteTitle,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      content: Text(
        l10n.categoriesDeleteConfirmWithValue(categoryName),
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
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
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            l10n.categoriesDeleteButton,
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
