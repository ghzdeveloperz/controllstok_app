import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth_choice/auth_choice_screen.dart';
import '../register_controller.dart';

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

  String _strengthLabel(int strength) {
    if (strength <= 1) return 'Muito fraca';
    if (strength == 2) return 'Fraca';
    return 'Forte';
  }

  double _strengthValue(int strength) => (strength.clamp(0, 3)) / 3.0;

  Color _strengthColor(int strength) {
    if (strength <= 1) return Colors.red;
    if (strength == 2) return Colors.orange;
    return Colors.green;
  }

  Widget _passwordStrengthUI() {
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
          'Força da senha: ${_strengthLabel(strength)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Dica: 8+ chars, maiúscula, minúscula, número e símbolo.',
          style: TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _socialButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _dotsLoading({TextStyle? style}) => _DotsLoadingText(style: style);

  Widget _emailInlineStatus({
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
          children: const [
            Icon(Icons.verified_rounded, size: 18, color: Colors.green),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'E-mail verificado.',
                textAlign: TextAlign.left,
                style: TextStyle(
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
          const Text(
            'Aguardando verificação do usuário',
            textAlign: TextAlign.left,
            style: TextStyle(
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

  Widget _restoringHint() {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Restaurando seu cadastro...',
              style: TextStyle(
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

  Future<void> _deleteAndBackToAuthChoice(BuildContext context) async {
    await controller.cancelAndResetRegistration();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
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
                hint: "Email",
                icon: Icons.email_outlined,
              ),
            ),

            if (controller.isRestoring)
              _restoringHint()
            else
              _emailInlineStatus(
                emailSent: emailSent,
                emailVerified: emailVerified,
                awaiting: awaiting,
              ),

            const SizedBox(height: 14),

            if (!controller.isRestoring) ...[
              if (!emailVerified) ...[
                if (canShowSendButton)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : controller.sendEmailVerification,
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text(
                              "Enviar e-mail de verificação",
                              style: TextStyle(
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
                                ? controller.resendEmailVerification
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                              ),
                            )
                          : Text(
                              canResend
                                  ? "Reenviar e-mail de verificação"
                                  : "Reenviar em ${cooldown}s",
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
                      onPressed: isLoading ? null : controller.changeEmail,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text(
                        'Não é esse e-mail?',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],

                if (!isAwaitingVerification) ...[
                  const SizedBox(height: 26),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "ou continue com",
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _socialButton(
                          label: "Google",
                          icon: Icons.g_mobiledata,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _socialButton(
                          label: "Apple",
                          icon: Icons.apple,
                          onPressed: () {},
                        ),
                      ),
                    ],
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
                            hint: "Senha",
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              onPressed: isLoading
                                  ? null
                                  : controller.toggleShowPassword,
                              icon: Icon(
                                controller.showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        if (hasPasswordTyped) _passwordStrengthUI(),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.confirmPasswordController,
                          enabled: !isLoading,
                          obscureText: !controller.showConfirmPassword,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            hint: "Confirmar senha",
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
                                : const Text(
                                    "Criar conta",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                          ),
                        ),

                        // ✅ NOVO: textbutton discreto, sublinhado, abaixo do Criar conta
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: isLoading
                                ? null
                                : () => _deleteAndBackToAuthChoice(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                'Excluir cadastro',
                                style: TextStyle(
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
