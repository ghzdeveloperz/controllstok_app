// lib/screens/acounts/register/widgets/register_footer.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../login/login_screen.dart';

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: RichText(
        text: TextSpan(
          text: l10n.registerFooterHaveAccount,
          style: const TextStyle(color: Colors.black54),
          children: [
            TextSpan(
              text: l10n.registerFooterLogin,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
