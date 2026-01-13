import 'package:flutter/material.dart';

class RegisterEmailSection extends StatelessWidget {
  final TextEditingController emailController;

  const RegisterEmailSection({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe o email';
        }
        return null;
      },
    );
  }
}
