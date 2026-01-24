// lib/screens/acounts/login/widgets/login_header.dart
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
        Text(
          t.loginWelcomeBackTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t.loginWelcomeBackSubtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
