import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../l10n/app_localizations.dart';

Future<void> showCategoryInUseDialog(
  BuildContext context, {
  required String categoryName,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      title: Text(
        l10n.categoriesInUseTitle,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      content: Text(
        l10n.categoriesInUseMessageWithValue(categoryName),
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            l10n.actionOk,
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
