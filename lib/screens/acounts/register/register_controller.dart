// lib/screens/acounts/register/register_controller.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';
import 'utils/password_strength.dart';
import 'package:mystoreday/services/auth/google_auth_service.dart';

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

  /// ✅ Google sign-in
  /// Retorna:
  /// - true  => ir para Company (novo usuário ou onboarding incompleto)
  /// - false => ir para Home (onboarding completo)
  /// - null  => cancelado/erro (não navegar)
  Future<bool?> registerWithGoogle(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) return null;

    _setLoading(true);
    clearError();

    try {
      // 🔹 Reseta qualquer fluxo pendente de email/senha
      _verifyTimer?.cancel();
      _verifyTimeoutTimer?.cancel();
      _resetResendCooldown();

      awaitingVerification = false;
      emailSent = false;
      emailVerified = false;

      _tempUser = null;
      _tempPassword = null;

      await _clearPendingStorage();

      final cred = await GoogleAuthService.instance.signInWithGoogle();

      if (cred == null) {
        setAlertWithTimeout(l10n.registerGoogleCancelled);
        return null;
      }

      final user = cred.user ?? _auth.currentUser;
      if (user == null) {
        setAlertWithTimeout(l10n.registerGoogleUserNotFound);
        return null;
      }

      final isNewUser = cred.additionalUserInfo?.isNewUser == true;

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // 🔹 Se doc já existe, respeita o estado atual do onboarding
      final existingDoc = await userRef.get();
      final existedBefore = existingDoc.exists;
      final onboardingCompleted =
          existedBefore && (existingDoc.data()?['onboardingCompleted'] == true);

      // 🔹 Garante doc mínimo (sem sobrescrever dados)
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'provider': 'google',
        'emailVerified': user.emailVerified,
        'active': true,
        'plan': 'Grátis',
        'updatedAt': FieldValue.serverTimestamp(),

        // Só define createdAt e onboarding inicial quando é novo/primeira vez
        if (isNewUser || !existedBefore) 'createdAt': FieldValue.serverTimestamp(),
        if (isNewUser || !existedBefore) 'onboardingCompleted': false,
      }, SetOptions(merge: true));

      clearError();
      notifyListeners();

      // ✅ Decide destino
      if (isNewUser) return true;
      if (onboardingCompleted) return false;
      return true;
    } on FirebaseAuthException catch (e) {
      setAlertWithTimeout(_mapFirebaseError(context, e.code));
      return null;
    } catch (_) {
      setAlertWithTimeout(l10n.registerGoogleGenericFail);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelPendingRegistration() async {
    if (!emailSent || emailVerified) return;
    await _deleteTempUserIfExists();
    await _clearPendingStorage();
  }

  Future<void> cancelAndResetRegistration(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

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
      setAlertWithTimeout(l10n.registerCancelFail);
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

  Future<void> sendEmailVerification(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setAlertWithTimeout(l10n.registerEmailRequired);
      return;
    }
    if (!_looksLikeEmail(email)) {
      setAlertWithTimeout(l10n.registerInvalidEmail);
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

      setAlertWithTimeout(l10n.registerVerificationEmailSent);

      _startVerificationPolling();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      setAlertWithTimeout(_mapFirebaseError(context, e.code));
    } catch (_) {
      setAlertWithTimeout(l10n.registerSendVerificationUnexpectedError);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendEmailVerification(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) return;
    if (resendCooldownSeconds > 0) return;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      setAlertWithTimeout(l10n.registerEmailRequired);
      return;
    }
    if (!_looksLikeEmail(email)) {
      setAlertWithTimeout(l10n.registerInvalidEmail);
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

      setAlertWithTimeout(l10n.registerVerificationEmailResent);

      _startResendCooldown(30);

      _startVerificationPolling();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      setAlertWithTimeout(_mapFirebaseError(context, e.code));
    } catch (_) {
      setAlertWithTimeout(l10n.registerResendVerificationUnexpectedError);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

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

      setAlertWithTimeout(l10n.registerChangeEmailHint, seconds: 3);
      notifyListeners();
    } catch (_) {
      setAlertWithTimeout(l10n.registerChangeEmailFail);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _deleteTempUserIfExists() async {
    _verifyTimer?.cancel();
    _verifyTimeoutTimer?.cancel();

    final User? userToDelete = _tempUser ?? _auth.currentUser;

    try {
      if (userToDelete != null) {
        await userToDelete.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final email = emailController.text.trim();
        final pass = _tempPassword;

        if (pass != null && email.isNotEmpty && _auth.currentUser != null) {
          final cred = EmailAuthProvider.credential(email: email, password: pass);
          await _auth.currentUser!.reauthenticateWithCredential(cred);
          await _auth.currentUser!.delete();
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
      _tempUser ??= _auth.currentUser;
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

  Future<void> submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (!emailVerified) {
      setAlertWithTimeout(l10n.registerVerifyEmailBeforeContinue);
      return;
    }

    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      setAlertWithTimeout(l10n.registerPasswordAndConfirmRequired);
      return;
    }

    if (passwordStrength < 3) {
      setAlertWithTimeout(l10n.registerPasswordMustBeStrong);
      return;
    }

    if (password != confirm) {
      setAlertWithTimeout(l10n.registerPasswordsDoNotMatch);
      return;
    }

    if (_tempPassword == null) {
      setAlertWithTimeout(l10n.registerInvalidSessionRedoEmailVerification);
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
      setAlertWithTimeout(_mapFirebaseError(context, e.code));
    } catch (_) {
      setAlertWithTimeout(l10n.registerCreateAccountUnexpectedError);
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

  String _mapFirebaseError(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;

    switch (code) {
      case 'email-already-in-use':
        return l10n.registerErrorEmailAlreadyInUse;
      case 'invalid-email':
        return l10n.registerInvalidEmail;
      case 'weak-password':
        return l10n.registerErrorWeakPassword;
      case 'network-request-failed':
        return l10n.registerErrorNoConnection;
      case 'too-many-requests':
        return l10n.registerErrorTooManyRequests;
      default:
        return l10n.registerErrorGeneric;
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
