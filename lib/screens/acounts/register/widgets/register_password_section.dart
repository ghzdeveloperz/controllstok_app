// lib/screens/acounts/register/widgets/register_password_section.dart
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class RegisterPasswordSection extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegisterPasswordSection({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.registerPasswordLabel),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.registerConfirmPasswordLabel),
        ),
      ],
    );
  }
}
