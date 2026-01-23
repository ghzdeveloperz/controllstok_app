import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';
import '../../../services/auth/google_auth_service.dart';
import '../../../services/bootstrap/auth_bootstrap_service.dart';
import '../../../screens/widgets/blocking_loader.dart';

import '../../home_screen.dart';
import '../onboarding/company_screen.dart';

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
    if (error != null && error != _lastError) {
      _lastError = error;
      _animationController
        ..reset()
        ..forward();
      return;
    }

    if (error == null && _lastError != null) {
      _lastError = null;
      _animationController.reverse();
    }
  }

  Future<void> _routeAfterLogin(NavigatorState nav) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final onboardingCompleted = data?['onboardingCompleted'] == true;

      if (!mounted) return;

      if (!onboardingCompleted) {
        nav.pushReplacement(
          MaterialPageRoute(builder: (_) => CompanyScreen(user: user)),
        );
        return;
      }

      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    } catch (_) {
      if (!mounted) return;

      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }
  }

  Future<void> _handleGoogleLoginFlow() async {
    final nav = Navigator.of(context);

    final credential = await BlockingLoader.run<UserCredential?>(
      context: context,
      message: 'Entrando com Google...',
      action: () async {
        try {
          return await GoogleAuthService.instance.signInWithGoogle();
        } catch (_) {
          return null;
        }
      },
    );

    if (!mounted) return;
    if (credential == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await BlockingLoader.run<void>(
      context: context,
      message: 'Preparando sua conta...',
      action: () async {
        try {
          await AuthBootstrapService.warmUp(context: context, user: user);
        } catch (_) {}
      },
    );

    if (!mounted) return;

    await _routeAfterLogin(nav);
    return;
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(AuthService()),
      child: Consumer<LoginController>(
        builder: (context, controller, _) {
          final state = controller.state;

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

                    LoginError(animation: _animation, message: state.error),
                    const SizedBox(height: 20),

                    LoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isLoading: state.isLoading,

                      onSubmit: () async {
                        final nav = Navigator.of(context);

                        controller.handleLogin(
                          context: context,
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          onSuccess: () {
                            // você quer roteamento async depois:
                            // ignore: discarded_futures
                            _routeAfterLogin(nav);
                          },
                        );
                      },

                      onGoogleTap: () async {
                        if (state.isLoading) return;
                        await _handleGoogleLoginFlow();
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
