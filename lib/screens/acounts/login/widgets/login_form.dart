import 'package:flutter/material.dart';
import 'social_login_buttons.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onResetPassword;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
    required this.onResetPassword,
  });

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          enabled: !isLoading,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hint: "Email",
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: passwordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: _inputDecoration(
            hint: "Senha",
            icon: Icons.lock_outline,
          ),
        ),
        const SizedBox(height: 6),

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onResetPassword,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Esqueceu a senha?",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Entrar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 26),

        Row(
          children: const [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "ou continue com",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 18),

        SocialLoginButtons(
          onGoogleTap: () {
            // Aqui você vai chamar seu método real depois
          },
          onAppleTap: () {
            // Aqui você vai chamar seu método real depois
          },
        ),
      ],
    );
  }
}
