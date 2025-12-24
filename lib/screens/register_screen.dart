// lib/screens/register_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_additional_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool emailSent = false;
  bool emailVerified = false;
  String? error;

  late AnimationController _animationController;
  late Animation<double> _offsetAnimation;

  int _passwordStrength = 0;
  User? _tempUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password)) strength++;
    if (RegExp(r'(?=.*\d)').hasMatch(password)) strength++;
    if (RegExp(r'(?=.*[!@#\$&*~]).').hasMatch(password)) strength++;

    setState(() {
      _passwordStrength = min(strength, 3);
    });
  }

  bool get _isEmailValid {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim());
  }

  bool get _isPasswordValid {
    return _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.isNotEmpty &&
        _passwordStrength >= 2;
  }

  bool get _canContinue {
    return _isPasswordValid && emailVerified;
  }

  Future<void> _sendVerificationEmail() async {
    if (!_isEmailValid) {
      setState(() {
        error = 'Email inválido';
      });
      _showError();
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: 'Temporary123!',
      );

      _tempUser = userCredential.user;
      await _tempUser?.sendEmailVerification();

      setState(() {
        emailSent = true;
      });

      debugPrint('Email de verificação enviado para ${_emailController.text}');
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Erro ao enviar email';
      });
      _showError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkEmailVerified() async {
    if (_tempUser == null) return;

    await _tempUser!.reload();
    _tempUser = FirebaseAuth.instance.currentUser;

    if (_tempUser!.emailVerified) {
      setState(() {
        emailVerified = true;
        error = null;
      });
    } else {
      setState(() {
        error = 'Email ainda não verificado. Verifique sua caixa de entrada.';
      });
      _showError();
    }
  }

  Future<void> handleContinue() async {
    if (!_canContinue) {
      setState(() {
        error = 'Preencha todos os campos corretamente e verifique seu email';
      });
      _showError();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _tempUser!.updatePassword(_passwordController.text);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterAdditionalScreen(user: _tempUser!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Erro ao registrar usuário';
      });
      _showError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError() {
    _animationController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black87),
      suffixIcon: suffixIcon,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1,
                child: Image.asset(
                  'lib/assets/images/logo-controllstok.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1,
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 32),
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
                      const Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 42,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Registrar Conta",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Crie seu acesso ao estoque",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      SizeTransition(
                        sizeFactor: _offsetAnimation,
                        axisAlignment: -1.0,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            error ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !isLoading && !emailSent,
                              decoration: _inputDecoration(
                                hint: "Email",
                                icon: Icons.email_outlined,
                              ),
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_isEmailValid && !emailSent)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : _sendVerificationEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                      "Enviar email de verificação"),
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (emailSent && !emailVerified)
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _checkEmailVerified,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                        "Já verifiquei meu email"),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Verifique seu email antes de continuar",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: [
                            if (emailVerified) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: !showPassword,
                                decoration: _inputDecoration(
                                  hint: "Senha",
                                  icon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_passwordController.text.isNotEmpty)
                                Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value: (_passwordStrength + 1) / 4,
                                      color: _passwordStrengthColor,
                                      backgroundColor: Colors.black12,
                                      minHeight: 6,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _passwordStrengthLabel,
                                        style: TextStyle(
                                          color: _passwordStrengthColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: !showConfirmPassword,
                                decoration: _inputDecoration(
                                  hint: "Confirmar senha",
                                  icon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showConfirmPassword =
                                            !showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _canContinue && !isLoading
                                      ? handleContinue
                                      : null,
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
                                          "Continuar",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Botão para voltar pro login
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Já possui conta? Fazer login",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _passwordStrengthColor {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get _passwordStrengthLabel {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return 'Fraca';
      case 2:
        return 'Média';
      case 3:
        return 'Forte';
      default:
        return '';
    }
  }
}
