import 'package:flutter/material.dart';

class CustomAlert {
  // Alerta tipo SnackBar flutuante
  static void showSnack({
    required BuildContext context,
    required String message,
    IconData icon = Icons.error_outline,
    Color backgroundColor = Colors.black,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}
