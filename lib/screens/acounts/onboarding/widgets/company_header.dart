// lib/screens/acounts/onboarding/widgets/company_header.dart
import 'package:flutter/material.dart';

class CompanyHeader extends StatelessWidget {
  final String email;

  const CompanyHeader({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final safeEmail = email.trim().isEmpty ? '—' : email.trim();

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
          "Configure sua empresa",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Conta: $safeEmail",
          style: const TextStyle(
            fontSize: 13.5,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Essas informações ajudam a personalizar seu sistema e organizar seus relatórios.",
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
