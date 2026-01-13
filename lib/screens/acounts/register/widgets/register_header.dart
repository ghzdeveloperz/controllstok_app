// lib/screens/acounts/register/widgets/register_header.dart
import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // alinhamento igual ao LoginHeader
      children: [
        Center(
          child: Image.asset(
            'assets/images/logo-controllstok-bac.png',
            width: 96,
            height: 96,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32), // mais espaçamento para jogar o header pra baixo
        const Text(
          "Crie sua conta",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Tenha controle total do seu estoque desde o primeiro dia.",
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
