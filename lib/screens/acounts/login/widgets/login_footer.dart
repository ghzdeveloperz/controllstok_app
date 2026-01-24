// lib/screens/acounts/login/widgets/login_footer.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../register/register_screen.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: t.loginNoAccountPrefix,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
          children: [
            TextSpan(
              text: t.loginCreateNow,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
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
