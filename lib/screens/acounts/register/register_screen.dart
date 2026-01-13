// lib/screens/acounts/register/register_screen.dart
import 'package:flutter/material.dart';
import 'widgets/register_form.dart';
import 'widgets/register_alert.dart';
import 'register_controller.dart';
import 'widgets/register_header.dart';
import 'widgets/register_footer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final RegisterController controller;
  late final AnimationController _alertAnimationController;

  @override
  void initState() {
    super.initState();
    controller = RegisterController();

    _alertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _handleSubmit() {
    controller.submit();

    if (controller.errorMessage != null && controller.errorMessage!.isNotEmpty) {
      _alertAnimationController.forward();

      Future.delayed(const Duration(seconds: 3), () {
        controller.clearError();
        _alertAnimationController.reverse();
      });
    }

    setState(() {}); // atualiza loading e erro
  }

  @override
  void dispose() {
    controller.dispose();
    _alertAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center( // <--- centraliza verticalmente igual ao LoginScreen
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // <--- evita ocupar todo o espaço vertical
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RegisterHeader(),
                const SizedBox(height: 28),

                // ALERTA ANIMADO
                RegisterAlert(
                  animation: _alertAnimationController,
                  message: controller.errorMessage,
                ),
                if (controller.errorMessage != null &&
                    controller.errorMessage!.isNotEmpty)
                  const SizedBox(height: 16),

                // FORMULÁRIO
                RegisterForm(
                  controller: controller,
                  isLoading: controller.isLoading,
                  onSubmit: _handleSubmit,
                ),

                const SizedBox(height: 20),

                // FOOTER
                const RegisterFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
