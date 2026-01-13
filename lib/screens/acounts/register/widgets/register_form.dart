// lib/screens/acounts/register/widgets/register_form.dart
import 'package:flutter/material.dart';
import '../register_controller.dart';

class RegisterForm extends StatelessWidget {
  final RegisterController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const RegisterForm({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  InputDecoration _inputDecoration({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _socialButton({required String label, required IconData icon, required VoidCallback onPressed}) =>
      SizedBox(
        height: 54,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.black12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller.emailController,
          enabled: !isLoading,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hint: "Email", icon: Icons.email_outlined),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller.passwordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: _inputDecoration(hint: "Senha", icon: Icons.lock_outline),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller.confirmPasswordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: _inputDecoration(hint: "Confirmar senha", icon: Icons.lock_outline),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                  )
                : const Text(
                    "Criar conta",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _socialButton(label: "Google", icon: Icons.g_mobiledata, onPressed: () {}),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _socialButton(label: "Apple", icon: Icons.apple, onPressed: () {}),
            ),
          ],
        ),
      ],
    );
  }
}
