import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/password_strength.dart';

class RegisterController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isRestoring = true;
  String? errorMessage;

  bool emailSent = false;
  bool emailVerified = false;
  bool awaitingVerification = false;

  User? _tempUser;
  String? _tempPassword;

  Timer? _verifyTimer;
  Timer? _verifyTimeoutTimer;

  int resendCooldownSeconds = 0;
  Timer? _resendCooldownTimer;

  bool showPassword = false;
  bool showConfirmPassword = false;
  int passwordStrength = 0;

  static const _kPendingEmail = 'register_pending_email';
  static const _kPendingTempPass = 'register_pending_temp_pass';
  static const _kPendingCreatedAt = 'register_pending_created_at';

  RegisterController() {
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordFieldsChanged);
    confirmPasswordController.addListener(_onPasswordFieldsChanged);

    _recomputePasswordStrength();
    Future.microtask(_restorePendingIfAny);
  }

  bool get hasPendingVerification => emailSent && !emailVerified;

  Future<void> cancelPendingRegistration() async {
    if (!emailSent || emailVerified) return;
    await _deleteTempUserIfExists();
    await _clearPendingStorage();
  }

  /// ✅ NOVO: cancela e volta pra tela inicial (AuthChoice)
  /// - funciona tanto se estiver "aguardando" quanto se já estiver verificado
  Future<void> cancelAndResetRegistration() async {
    if (isLoading) return;

    _setLoading(true);
    try {
      await _deleteTempUserIfExists();
      await _clearPendingStorage();

      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      emailSent = false;
      emailVerified = false;
      awaitingVerification = false;

      _resetResendCooldown();
      clearError();
    } catch (_) {
      // se falhar, mantém uma mensagem humana
      setAlertWithTimeout('Não foi possível cancelar agora. Tente novamente.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _onEmailChanged() => notifyListeners();

  void _onPasswordFieldsChanged() {
    _recomputePasswordStrength();
    notifyListeners();
  }

  void _recomputePasswordStrength() {
    passwordStrength = calculatePasswordStrength(passwordController.text.trim());
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

  void setAlertWithTimeout(String message, {int seconds = 4}) {
    errorMessage = message;
    notifyListeners();

    Future.delayed(Duration(seconds: seconds), () {
      if (errorMessage == message) clearError();
    });
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

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

      await _persistPending(email: email, tempPassword: randomPass);

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

  Future<void> resendEmailVerification() async {
    if (isLoading) return;
    if (resendCooldownSeconds > 0) return;

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
      await _deleteTempUserIfExists();

      final randomPass = _generateTempPassword();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: randomPass,
      );

      _tempUser = credential.user;
      _tempPassword = randomPass;

      await _persistPending(email: email, tempPassword: randomPass);

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

  Future<void> changeEmail() async {
    if (isLoading) return;

    _setLoading(true);

    try {
      await _deleteTempUserIfExists();
      await _clearPendingStorage();

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
      // se já estiver logado, garante que _tempUser aponta pro currentUser
      _tempUser ??= _auth.currentUser;

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

        notifyListeners();
      }
    });

    _verifyTimeoutTimer = Timer(const Duration(minutes: 2), () {
      _verifyTimer?.cancel();
      awaitingVerification = false;
      notifyListeners();
    });
  }

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

    if (_tempPassword == null) {
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
      await _clearPendingStorage();

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

  Future<void> _persistPending({
    required String email,
    required String tempPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPendingEmail, email);
    await prefs.setString(_kPendingTempPass, tempPassword);
    await prefs.setInt(_kPendingCreatedAt, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _clearPendingStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPendingEmail);
    await prefs.remove(_kPendingTempPass);
    await prefs.remove(_kPendingCreatedAt);
  }

  Future<void> _restorePendingIfAny() async {
    isRestoring = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_kPendingEmail);
      final pass = prefs.getString(_kPendingTempPass);

      if (email == null || pass == null) {
        isRestoring = false;
        notifyListeners();
        return;
      }

      emailController.text = email;
      _tempPassword = pass;

      try {
        await _auth.signInWithEmailAndPassword(email: email, password: pass);
      } catch (_) {
        await _clearPendingStorage();
        isRestoring = false;
        notifyListeners();
        return;
      }

      _tempUser = _auth.currentUser;
      if (_tempUser == null) {
        await _clearPendingStorage();
        isRestoring = false;
        notifyListeners();
        return;
      }

      await _tempUser!.reload();
      final refreshed = _auth.currentUser;
      final verified = refreshed?.emailVerified == true;

      emailSent = true;
      emailVerified = verified;
      awaitingVerification = !verified;

      if (!verified) {
        _startVerificationPolling();
      }

      isRestoring = false;
      notifyListeners();
    } catch (_) {
      isRestoring = false;
      notifyListeners();
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
