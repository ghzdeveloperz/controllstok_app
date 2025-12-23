import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();

  String? error;
  bool isLoading = false;

  Future<void> handleRegister() async {
    if (isLoading) return;

    setState(() {
      error = null;
      isLoading = true;
    });

    final login = _loginController.text.trim();
    final password = _passwordController.text;
    final company = _companyController.text.trim();

    if (login.isEmpty || password.isEmpty || company.isEmpty) {
      setState(() {
        error = 'Preencha todos os campos';
        isLoading = false;
      });
      return;
    }

    final result = await _authService.register(
      login: login,
      password: password,
      company: company,
    );

    if (!mounted) return;

    // ❌ erro → retorna string
    if (result != null) {
      setState(() {
        error = result;
        isLoading = false;
      });
      return;
    }

    // ✅ sucesso
    Navigator.pop(context);
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
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    super.dispose();
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
                const Icon(Icons.person_add_alt_1,
                    size: 42, color: Colors.black),
                const SizedBox(height: 12),

                const Text(
                  "Criar Conta",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                const Text(
                  "Cadastro de novo usuário",
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
                  controller: _companyController,
                  enabled: !isLoading,
                  decoration: _inputDecoration(
                    hint: "Empresa",
                    icon: Icons.storefront_outlined,
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
                    onPressed: isLoading ? null : handleRegister,
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
                            "Criar conta",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
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
