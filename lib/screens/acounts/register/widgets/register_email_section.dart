// lib/screens/acounts/register/widgets/register_email_section.dart
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class RegisterEmailSection extends StatelessWidget {
  final TextEditingController emailController;

  const RegisterEmailSection({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(labelText: l10n.registerEmailLabel),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.registerEmailValidatorRequired;
        }
        return null;
      },
    );
  }
}
