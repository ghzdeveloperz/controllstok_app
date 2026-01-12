// lib/screens/login/widgets/login_footer.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../register/register_screen.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "Ainda não tem conta? ",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
          children: [
            TextSpan(
              text: "Criar agora",
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
