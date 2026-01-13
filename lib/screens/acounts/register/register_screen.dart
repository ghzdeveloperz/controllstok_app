  import 'package:flutter/material.dart';
  import 'register_controller.dart';
  import 'widgets/register_form.dart';
  import 'widgets/register_alert.dart';
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

    late final AnimationController _animationController;
    late final Animation<double> _animation;

    String? _lastError;

    @override
    void initState() {
      super.initState();

      controller = RegisterController();

      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );

      _animation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );

      controller.addListener(_handleErrorAnimation);
    }

    void _handleErrorAnimation() {
      final error = controller.errorMessage;

      if (error != null && error.isNotEmpty && error != _lastError) {
        _lastError = error;
        _animationController
          ..reset()
          ..forward();
        return;
      }

      if ((error == null || error.isEmpty) && _lastError != null) {
        _lastError = null;
        _animationController.reverse();
      }

      setState(() {});
    }

    @override
    void dispose() {
      controller.removeListener(_handleErrorAnimation);
      controller.dispose();
      _animationController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final hideFooter = controller.awaitingVerification || controller.emailVerified;

      return WillPopScope(
        onWillPop: () async {
          // ✅ se o usuário tentar sair com cadastro pendente, cancela corretamente
          if (controller.hasPendingVerification) {
            await controller.cancelPendingRegistration();
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const RegisterHeader(),
                    const SizedBox(height: 20),

                    RegisterAlert(
                      animation: _animation,
                      message: controller.errorMessage,
                    ),

                    const SizedBox(height: 20),

                    RegisterForm(
                      controller: controller,
                      isLoading: controller.isLoading,
                      onSubmit: controller.submit,
                    ),

                    if (!hideFooter) ...[
                      const SizedBox(height: 28),
                      const RegisterFooter(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
