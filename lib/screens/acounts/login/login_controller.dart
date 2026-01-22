import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/auth_service.dart';
import '../../../services/bootstrap/auth_bootstrap_service.dart';
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

  void _setTemporaryError(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
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

  /// ✅ LOGIN (email/senha) com:
  /// - validações
  /// - AuthService.login
  /// - checagem de conta ativa
  /// - warmup/bootstrap (Firestore + precache) antes de navegar
  Future<void> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    if (_state.isLoading) return;

    _errorTimer?.cancel();
    _setState(_state.copyWith(isLoading: true, error: null));

    final safeEmail = email.trim();

    if (safeEmail.isEmpty || password.isEmpty) {
      _setTemporaryError("Preencha email e senha");
      return;
    }

    // 1) autentica
    final message = await _authService.login(
      email: safeEmail,
      password: password,
    );

    if (message != null) {
      _setTemporaryError(message);
      return;
    }

    // 2) valida user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _setTemporaryError("Erro ao obter usuário");
      return;
    }

    // 3) checa se está ativo (mantido)
    final activeMessage = await _checkUserActive(
      context: context,
      user: user,
    );

    if (activeMessage != null) {
      _setState(_state.copyWith(isLoading: false, error: activeMessage));
      return;
    }

    // 4) ✅ warmup/bootstrap antes de navegar (aqui o loading fica "funcional")
    try {
      await AuthBootstrapService.warmUp(
        context: context,
        user: user,
      );
    } catch (_) {
      // Não travar login por causa do warmup.
      // Se der erro, ainda assim deixa entrar.
    }

    // 5) sucesso
    _setState(_state.copyWith(isLoading: false));
    onSuccess();
  }

  /// Mantido: garante que o usuário não está desativado.
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

        if (!context.mounted) return "Sua conta está desativada.";

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomAlertDialog(
            title: "Conta desativada",
            message: "Sua conta está desativada. Entre em contato com o suporte.",
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

    final safeEmail = email.trim();

    if (safeEmail.isEmpty) {
      _setTemporaryError("Informe seu email para redefinir a senha");
      return;
    }

    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      final message = await _authService.resetPassword(email: safeEmail);

      if (message != null) {
        _setTemporaryError(message);
        return;
      }

      // Se seu AuthService retorna mensagem de sucesso (string),
      // você já exibe via _setTemporaryError. Se ele retornar null no sucesso,
      // pode mostrar algo aqui:
      _setTemporaryError("Enviamos um link de redefinição para seu e-mail.");
    } catch (_) {
      _setTemporaryError("Erro inesperado ao redefinir senha");
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
