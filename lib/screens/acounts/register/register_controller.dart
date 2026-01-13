import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // SUBMIT
  void submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validações
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return setErrorWithTimeout('Preencha todos os campos.');
    }
    if (password.length < 6) {
      return setErrorWithTimeout('A senha deve ter no mínimo 6 caracteres.');
    }
    if (password != confirmPassword) {
      return setErrorWithTimeout('As senhas não coincidem.');
    }

    _setLoading(true);

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      clearError();
    } on FirebaseAuthException catch (e) {
      setErrorWithTimeout(_mapFirebaseError(e.code));
    } catch (_) {
      setErrorWithTimeout('Erro inesperado ao criar conta.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setErrorWithTimeout(String message, {int seconds = 3}) {
    errorMessage = message;
    notifyListeners();

    Future.delayed(Duration(seconds: seconds), () {
      clearError();
    });
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha muito fraca.';
      default:
        return 'Erro ao criar conta.';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
