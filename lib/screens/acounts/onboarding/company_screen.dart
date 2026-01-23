// lib/screens/acounts/onboarding/company_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home_screen.dart';
import 'company_controller.dart';
import 'widgets/company_header.dart';
import 'widgets/company_form.dart';

class CompanyScreen extends StatefulWidget {
  final User user;
  const CompanyScreen({super.key, required this.user});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen>
    with SingleTickerProviderStateMixin {
  late final CompanyController controller;

  late final AnimationController _animationController;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    controller = CompanyController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _finish() async {
    final ok = await controller.finish(user: widget.user);
    if (!mounted) return;

    if (!ok) {
      _animationController.forward();
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _animationController.reverse();
      });
      return;
    }

    // ✅ sucesso → vai pra Home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F7F7),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ header premium (você disse que quer no estilo do RegisterHeader)
                      // Se seu CompanyHeader já está pronto, ele entra aqui.
                      // Dica: passe o email pra mostrar qual conta está sendo configurada.
                      CompanyHeader(email: widget.user.email ?? ''),

                      const SizedBox(height: 16),

                      CompanyForm(
                        controller: controller,
                        isLoading: controller.isLoading,
                        error: controller.error,
                        animation: _offsetAnimation,
                        onFinish: _finish,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
