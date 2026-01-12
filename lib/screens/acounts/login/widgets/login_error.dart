// lib/screens/login/widgets/login_error.dart
import 'package:flutter/material.dart';

class LoginError extends StatelessWidget {
  final Animation<double> animation;
  final String? message;

  const LoginError({
    super.key,
    required this.animation,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        // Quando não tem mensagem E animação terminou → não ocupa espaço
        if ((message == null || message!.isEmpty) &&
            animation.value == 0) {
          return const SizedBox.shrink();
        }

        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0,
          child: Opacity(
            opacity: animation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                message ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
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
