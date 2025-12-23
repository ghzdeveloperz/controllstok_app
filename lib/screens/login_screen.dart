// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? error;
  bool isLoading = false;

  Future<void> handleLogin() async {
    if (isLoading) return;

    setState(() {
      error = null;
      isLoading = true;
    });

    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        error = "Preencha login e senha";
        isLoading = false;
      });
      return;
    }

    final loginError = await _authService.login(
      login: login,
      password: password,
    );

    if (!mounted) return;

    if (loginError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userLogin: login)),
      );
    } else {
      setState(() {
        error = loginError;
        isLoading = false;
      });
    }
  }

  Future<void> _openSupportEmail() async {
    final login = _loginController.text.trim().isEmpty
        ? '(INFORME SEU LOGIN)'
        : _loginController.text.trim();

    final subject = Uri.encodeComponent(
      'Redefinição de senha - usuário: $login',
    );

    final emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@mystoreday.com', // <-- troque aqui
      query: 'subject=$subject',
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o app de e-mail');
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.black12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(25, 0, 0, 0),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 42, color: Colors.black),
                const SizedBox(height: 12),
                const Text(
                  "Painel de Controle",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Acesse seu estoque",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 28),

                if (error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                if (error != null) const SizedBox(height: 18),

                TextField(
                  controller: _loginController,
                  enabled: !isLoading,
                  decoration: _inputDecoration(
                    hint: "Login",
                    icon: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: true,
                  decoration: _inputDecoration(
                    hint: "Senha",
                    icon: Icons.lock_outline,
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.black38,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                GestureDetector(
                  onTap: _openSupportEmail,
                  child: const Text(
                    "Esqueceu a senha? Consulte o administrador.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
