// lib/screens/login/login_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/auth_service.dart';
import '../../widgets/desactive_acount.dart';
import 'login_state.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService;

  LoginState _state = const LoginState();
  LoginState get state => _state;

  Timer? _errorTimer;

  LoginController(this._authService);

  void _setState(LoginState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setTemporaryError(String message, {Duration duration = const Duration(seconds: 3)}) {
    _errorTimer?.cancel();

    _setState(
      _state.copyWith(
        isLoading: false,
        error: message,
      ),
    );

    _errorTimer = Timer(duration, () {
      clearError();
    });
  }

  Future<void> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    if (_state.isLoading) return;

    _errorTimer?.cancel();
    _setState(_state.copyWith(isLoading: true, error: null));

    if (email.isEmpty || password.isEmpty) {
      _setTemporaryError("Preencha email e senha");
      return;
    }

    final message = await _authService.login(
      email: email,
      password: password,
    );

    if (message != null) {
      _setTemporaryError(message);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _setTemporaryError("Erro ao obter usuário");
      return;
    }

    final activeMessage = await _checkUserActive(
      context: context,
      user: user,
    );

    if (activeMessage != null) {
      _setState(_state.copyWith(isLoading: false, error: activeMessage));
      return;
    }

    _setState(_state.copyWith(isLoading: false));
    onSuccess();
  }

  Future<String?> _checkUserActive({
    required BuildContext context,
    required User user,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return "Usuário não encontrado";

      final data = doc.data()!;
      if (data['active'] == false) {
        await FirebaseAuth.instance.signOut();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomAlertDialog(
            title: "Conta desativada",
            message:
                "Sua conta está desativada. Entre em contato com o suporte.",
            buttonText: "OK",
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        );

        return "Sua conta está desativada.";
      }

      return null;
    } catch (_) {
      return "Erro ao verificar usuário";
    }
  }

  Future<void> resetPassword(String email) async {
    _errorTimer?.cancel();

    if (email.isEmpty) {
      _setTemporaryError("Informe seu email para redefinir a senha");
      return;
    }

    final message = await _authService.resetPassword(email: email);

    if (message != null) {
      _setTemporaryError(message);
    }
  }

  void clearError() {
    _errorTimer?.cancel();
    _setState(_state.copyWith(error: null));
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }
}
