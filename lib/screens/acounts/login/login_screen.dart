// lib/screens/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';
import '../../home_screen.dart';
import 'login_controller.dart';
import 'widgets/login_error.dart';
import 'widgets/login_footer.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  String? _lastError;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleErrorAnimation(String? error) {
    // erro apareceu ou mudou
    if (error != null && error != _lastError) {
      _lastError = error;
      _animationController
        ..reset()
        ..forward();
      return;
    }

    // erro foi limpo
    if (error == null && _lastError != null) {
      _lastError = null;
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(AuthService()),
      child: Consumer<LoginController>(
        builder: (context, controller, _) {
          final state = controller.state;

          /// 🎯 Controle total da animação de erro
          _handleErrorAnimation(state.error);

          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F7),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: 20),

                    /// 🚨 Alerta animado (entra e sai suave)
                    LoginError(animation: _animation, message: state.error),

                    const SizedBox(height: 20),

                    LoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isLoading: state.isLoading,
                      onSubmit: () {
                        controller.handleLogin(
                          context: context,
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          onSuccess: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          },
                        );
                      },
                      onResetPassword: () {
                        controller.resetPassword(_emailController.text.trim());
                      },
                    ),

                    const SizedBox(height: 28),

                    const LoginFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
