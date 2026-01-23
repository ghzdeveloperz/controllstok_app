import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool?> showConfirmLocaleDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelText,
  required String confirmText,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF0B0F14),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFF374151),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0B0F14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}
