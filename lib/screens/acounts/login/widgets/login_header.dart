// lib/screens/login/widgets/login_header.dart
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset(
            'assets/images/logo-controllstok-bac.png',
            width: 96,
            height: 96,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Bem-vindo de volta!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Entre, e gerencie seu estoque com facilidade.",
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
