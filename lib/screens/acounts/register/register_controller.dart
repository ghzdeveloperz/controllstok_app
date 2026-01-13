import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'utils/password_strength.dart';

class RegisterController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // ===== Email verification flow =====
  bool emailSent = false;
  bool emailVerified = false;
  bool awaitingVerification = false;

  User? _tempUser;
  String? _tempPassword;

  Timer? _verifyTimer;
  Timer? _verifyTimeoutTimer;

  // ===== cooldown do reenviar =====
  int resendCooldownSeconds = 0;
  Timer? _resendCooldownTimer;

  // ===== Password UX =====
  bool showPassword = false;
  bool showConfirmPassword = false;
  int passwordStrength = 0; // 0..3

  RegisterController() {
    emailController.addListener(_onEmailChanged);

    // ✅ tempo real: reconstruir quando senha/confirm mudar
    passwordController.addListener(_onPasswordFieldsChanged);
    confirmPasswordController.addListener(_onPasswordFieldsChanged);

    // força inicial (caso já tenha texto por algum motivo)
    _recomputePasswordStrength();
  }

  void _onEmailChanged() {
    notifyListeners();
  }

  void _onPasswordFieldsChanged() {
    _recomputePasswordStrength();
    // ✅ sempre notifica para atualizar canSubmit em tempo real
    notifyListeners();
  }

  void _recomputePasswordStrength() {
    final strength = calculatePasswordStrength(passwordController.text.trim());
    passwordStrength = strength; // pode atualizar direto (bar/label vai acompanhar)
  }

  void toggleShowPassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleShowConfirmPassword() {
    showConfirmPassword = !showConfirmPassword;
    notifyListeners();
  }

  bool get canSubmit {
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();
    final strongEnough = passwordStrength >= 3;

    return emailVerified &&
        !isLoading &&
        strongEnough &&
        password.isNotEmpty &&
        confirm.isNotEmpty &&
        password == confirm;
  }

  // ===== ALERT helper (usado pra erro E pra status) =====
  void setAlertWithTimeout(String message, {int seconds = 4}) {
    errorMessage = message;
    notifyListeners();

    Future.delayed(Duration(seconds: seconds), () {
      if (errorMessage == message) {
        clearError();
      }
    });
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // ===== cooldown =====
  void _startResendCooldown([int seconds = 30]) {
    _resendCooldownTimer?.cancel();
    resendCooldownSeconds = seconds;
    notifyListeners();

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      resendCooldownSeconds--;
      notifyListeners();

      if (resendCooldownSeconds <= 0) {
        resendCooldownSeconds = 0;
        t.cancel();
        notifyListeners();
      }
    });
  }

  void _resetResendCooldown() {
    _resendCooldownTimer?.cancel();
    resendCooldownSeconds = 0;
    notifyListeners();
  }

  // ===== 1) Enviar email de verificação =====
  Future<void> sendEmailVerification() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setAlertWithTimeout('Preencha o e-mail.');
      return;
    }
    if (!_looksLikeEmail(email)) {
      setAlertWithTimeout('E-mail inválido.');
      return;
    }

    _setLoading(true);

    try {
      final randomPass = _generateTempPassword();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: randomPass,
      );

      _tempUser = credential.user;
      _tempPassword = randomPass;

      await _tempUser?.sendEmailVerification();

      emailSent = true;
      emailVerified = false;
      awaitingVerification = true;

      setAlertWithTimeout(
        'E-mail de verificação enviado. Verifique sua caixa de entrada (e spam).',
      );

      _startVerificationPolling();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      setAlertWithTimeout(_mapFirebaseError(e.code));
    } catch (_) {
      setAlertWithTimeout('Erro inesperado ao enviar verificação.');
    } finally {
      _setLoading(false);
    }
  }

  // ===== Reenviar (com cooldown) =====
  Future<void> resendEmailVerification() async {
    if (isLoading) return;
    if (resendCooldownSeconds > 0) return;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      setAlertWithTimeout('Preencha o e-mail.');
      return;
    }
    if (!_changeableLooksLikeEmail(email)) {
      setAlertWithTimeout('E-mail inválido.');
      return;
    }

    _setLoading(true);

    try {
      await _deleteTempUserIfExists();

      final randomPass = _generateTempPassword();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: randomPass,
      );

      _tempUser = credential.user;
      _tempPassword = randomPass;

      await _tempUser?.sendEmailVerification();

      emailSent = true;
      emailVerified = false;
      awaitingVerification = true;

      setAlertWithTimeout('E-mail reenviado. Verifique a caixa de entrada (e spam).');

      _startResendCooldown(30);

      _startVerificationPolling();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      setAlertWithTimeout(_mapFirebaseError(e.code));
    } catch (_) {
      setAlertWithTimeout('Erro inesperado ao reenviar verificação.');
    } finally {
      _setLoading(false);
    }
  }

  // ===== “Não é esse e-mail?” =====
  Future<void> changeEmail() async {
    if (isLoading) return;

    _setLoading(true);

    try {
      await _deleteTempUserIfExists();

      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      emailSent = false;
      emailVerified = false;
      awaitingVerification = false;

      _resetResendCooldown();

      setAlertWithTimeout('Você pode alterar o e-mail e tentar novamente.', seconds: 3);
      notifyListeners();
    } catch (_) {
      setAlertWithTimeout('Não foi possível alterar agora. Tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _deleteTempUserIfExists() async {
    _verifyTimer?.cancel();
    _verifyTimeoutTimer?.cancel();

    try {
      await _tempUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final email = emailController.text.trim();
        if (_tempPassword != null && email.isNotEmpty) {
          final cred = EmailAuthProvider.credential(
            email: email,
            password: _tempPassword!,
          );
          await _auth.currentUser?.reauthenticateWithCredential(cred);
          await _auth.currentUser?.delete();
        }
      } else {
        rethrow;
      }
    } finally {
      await _auth.signOut();

      _tempUser = null;
      _tempPassword = null;

      awaitingVerification = false;
      emailSent = false;
      emailVerified = false;
      notifyListeners();
    }
  }

  void _startVerificationPolling() {
    _verifyTimer?.cancel();
    _verifyTimeoutTimer?.cancel();

    _verifyTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_tempUser == null) return;

      await _tempUser!.reload();
      final refreshed = _auth.currentUser;

      final verified = refreshed?.emailVerified == true;

      if (verified && !emailVerified) {
        emailVerified = true;
        awaitingVerification = false;

        _verifyTimer?.cancel();
        _verifyTimeoutTimer?.cancel();

        // ✅ você pediu: sem alert de "email verificado"
        notifyListeners();
      }
    });

    _verifyTimeoutTimer = Timer(const Duration(minutes: 2), () {
      _verifyTimer?.cancel();
      awaitingVerification = false;
      notifyListeners();
    });
  }

  // ===== 2) Finalizar registro =====
  Future<void> submit() async {
    if (!emailVerified) {
      setAlertWithTimeout('Verifique seu e-mail antes de continuar.');
      return;
    }

    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      setAlertWithTimeout('Preencha a senha e a confirmação.');
      return;
    }

    if (passwordStrength < 3) {
      setAlertWithTimeout('A senha precisa ser forte para criar a conta.');
      return;
    }

    if (password != confirm) {
      setAlertWithTimeout('As senhas não coincidem.');
      return;
    }

    if (_tempUser == null || _tempPassword == null) {
      setAlertWithTimeout('Sessão inválida. Refaça a verificação do e-mail.');
      return;
    }

    _setLoading(true);

    try {
      final email = emailController.text.trim();
      final cred = EmailAuthProvider.credential(
        email: email,
        password: _tempPassword!,
      );

      await _auth.currentUser?.reauthenticateWithCredential(cred);
      await _auth.currentUser?.updatePassword(password);

      _tempPassword = null;
      clearError();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      setAlertWithTimeout(_mapFirebaseError(e.code));
    } catch (_) {
      setAlertWithTimeout('Erro inesperado ao criar conta.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool _looksLikeEmail(String email) {
    return email.contains('@') && email.contains('.') && email.length >= 6;
  }

  // (igual ao seu _looksLikeEmail, só mantive pra não quebrar nada)
  bool _changeableLooksLikeEmail(String email) => _looksLikeEmail(email);

  String _generateTempPassword() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return 'Tmp@${millis}Aa1!';
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha fraca.';
      case 'network-request-failed':
        return 'Sem conexão. Tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco.';
      default:
        return 'Erro ao continuar o cadastro.';
    }
  }

  @override
  void dispose() {
    _verifyTimer?.cancel();
    _verifyTimeoutTimer?.cancel();
    _resendCooldownTimer?.cancel();

    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordFieldsChanged);
    confirmPasswordController.removeListener(_onPasswordFieldsChanged);

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
