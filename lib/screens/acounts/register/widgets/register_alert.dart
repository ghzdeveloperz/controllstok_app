// lib/screens/acounts/register/widgets/register_alert.dart
import 'package:flutter/material.dart';

class RegisterAlert extends StatelessWidget {
  final Animation<double> animation;
  final String? message;

  const RegisterAlert({
    super.key,
    required this.animation,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        if ((message == null || message!.isEmpty) && animation.value == 0) {
          return const SizedBox.shrink();
        }

        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0,
          child: Opacity(
            opacity: animation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0), // igual login
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                message ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
