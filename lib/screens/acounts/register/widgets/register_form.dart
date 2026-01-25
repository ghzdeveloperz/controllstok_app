// lib/screens/acounts/register/widgets/register_form.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../home_screen.dart';
import '../../auth_choice/auth_choice_screen.dart';
import '../../onboarding/company_screen.dart';

import '../register_controller.dart';
import 'social_register_buttons.dart';

import '../../../widgets/blocking_loader.dart';
import '../../../../services/bootstrap/auth_bootstrap_service.dart';

class RegisterForm extends StatelessWidget {
  final RegisterController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const RegisterForm({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  Future<void> _deleteAndBackToAuthChoice(BuildContext context) async {
    await controller.cancelAndResetRegistration(context);

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      (route) => false,
    );
  }

  Future<void> _handleGoogleTap(BuildContext context) async {
    if (controller.isLoading || isLoading) return;

    final l10n = AppLocalizations.of(context)!;

    final goToCompany = await BlockingLoader.run<bool?>(
      context: context,
      message: l10n.registerEnteringWithGoogleLoading,
      action: () async {
        try {
          return await controller.registerWithGoogle(context);
        } catch (_) {
          controller.setAlertWithTimeout(l10n.registerGoogleGenericFail);
          return null;
        }
      },
    );

    if (!context.mounted || goToCompany == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      controller.setAlertWithTimeout(l10n.registerLoginNotCompleted);
      return;
    }

    await BlockingLoader.run<void>(
      context: context,
      message: l10n.registerPreparingAccountLoading,
      action: () async {
        await AuthBootstrapService.warmUp(
          context: context,
          user: user,
        );
      },
    );

    if (!context.mounted) return;

    if (goToCompany) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CompanyScreen(user: user)),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final emailSent = controller.emailSent;
        final emailVerified = controller.emailVerified;
        final awaiting = controller.awaitingVerification;

        final hasPasswordTyped = controller.passwordController.text.isNotEmpty;
        final isAwaitingVerification = emailSent && !emailVerified && awaiting;

        final cooldown = controller.resendCooldownSeconds;
        final canResend = cooldown == 0;

        final emailEnabled = !isLoading && !emailSent && !emailVerified;
        final currentEmail = controller.emailController.text;
        final canShowSendButton = !emailSent && _looksLikeEmail(currentEmail);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.emailController,
              enabled: emailEnabled,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(
                hint: l10n.registerEmailHint,
                icon: Icons.email_outlined,
              ),
            ),

            if (controller.isRestoring)
              _restoringHint(l10n)
            else
              _emailInlineStatus(
                l10n: l10n,
                emailSent: emailSent,
                emailVerified: emailVerified,
                awaiting: awaiting,
              ),

            if (!controller.isRestoring) ...[
              if (!emailVerified) ...[
                if (canShowSendButton)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => controller.sendEmailVerification(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : Text(
                              l10n.registerSendVerificationButton,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                if (emailSent) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : (canResend
                              ? () => controller.resendEmailVerification(context)
                              : null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : Text(
                              canResend
                                  ? l10n.registerResendVerificationButton
                                  : l10n.registerResendInSeconds(cooldown),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed:
                          isLoading ? null : () => controller.changeEmail(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.black87,
                      ),
                      child: Text(
                        l10n.registerNotThisEmail,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],

                if (!isAwaitingVerification) ...[
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          l10n.registerOrContinueWith,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SocialLoginButtons(
                    isDisabled: isLoading,
                    onGoogleTap: () => _handleGoogleTap(context),
                    onAppleTap: () {
                      controller.setAlertWithTimeout(
                        l10n.registerAppleNotImplemented,
                      );
                    },
                  ),
                ],
              ],
            ],

            const SizedBox(height: 18),

            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: emailVerified
                  ? Column(
                      children: [
                        TextField(
                          controller: controller.passwordController,
                          enabled: !isLoading,
                          obscureText: !controller.showPassword,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            hint: l10n.registerPasswordHint,
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              onPressed:
                                  isLoading ? null : controller.toggleShowPassword,
                              icon: Icon(
                                controller.showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        if (hasPasswordTyped) _passwordStrengthUI(l10n),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.confirmPasswordController,
                          enabled: !isLoading,
                          obscureText: !controller.showConfirmPassword,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            hint: l10n.registerConfirmPasswordHint,
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              onPressed: isLoading
                                  ? null
                                  : controller.toggleShowConfirmPassword,
                              icon: Icon(
                                controller.showConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.canSubmit ? onSubmit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.registerCreateAccountButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: isLoading
                                ? null
                                : () => _deleteAndBackToAuthChoice(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                l10n.registerDeleteRegistration,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  bool _looksLikeEmail(String email) {
    final e = email.trim();
    if (e.isEmpty) return false;
    if (e.contains(' ')) return false;
    if (!e.contains('@')) return false;
    if (!e.contains('.')) return false;
    if (e.length < 6) return false;
    final at = e.indexOf('@');
    if (at <= 0) return false;
    if (at >= e.length - 3) return false;
    return true;
  }

  String _strengthLabel(AppLocalizations l10n, int strength) {
    if (strength <= 1) return l10n.registerPasswordStrengthVeryWeak;
    if (strength == 2) return l10n.registerPasswordStrengthWeak;
    return l10n.registerPasswordStrengthStrong;
  }

  double _strengthValue(int strength) => (strength.clamp(0, 3)) / 3.0;

  Color _strengthColor(int strength) {
    if (strength <= 1) return Colors.red;
    if (strength == 2) return Colors.orange;
    return Colors.green;
  }

  Widget _passwordStrengthUI(AppLocalizations l10n) {
    final strength = controller.passwordStrength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: _strengthValue(strength),
            backgroundColor: Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(_strengthColor(strength)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.registerPasswordStrengthLine(_strengthLabel(l10n, strength)),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.registerPasswordTip,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _dotsLoading({TextStyle? style}) => _DotsLoadingText(style: style);

  Widget _emailInlineStatus({
    required AppLocalizations l10n,
    required bool emailSent,
    required bool emailVerified,
    required bool awaiting,
  }) {
    if (!emailSent && !emailVerified) return const SizedBox.shrink();

    if (emailVerified) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.verified_rounded, size: 18, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.registerEmailVerifiedStatus,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.schedule_rounded, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            l10n.registerAwaitingUserVerification,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (awaiting)
            _dotsLoading(
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _restoringHint(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.registerRestoringRegistration,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsLoadingText extends StatefulWidget {
  final TextStyle? style;
  const _DotsLoadingText({this.style});

  @override
  State<_DotsLoadingText> createState() => _DotsLoadingTextState();
}

class _DotsLoadingTextState extends State<_DotsLoadingText> {
  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) return;
      setState(() => _step = (_step + 1) % 3);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = _step == 0
        ? '.'
        : _step == 1
            ? '..'
            : '...';
    return Text(dots, style: widget.style);
  }
}
