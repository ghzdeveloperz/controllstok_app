import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';

class ScanResultCard extends StatefulWidget {
  /// Mantido por compatibilidade com o código atual.
  /// Agora ele funciona como "título" do resultado.
  final String productName;

  final bool isError;
  final String scannedCode;
  final VoidCallback? onDismiss;

  /// Opcional (mantém UX premium)
  final Duration autoDismissDuration;

  const ScanResultCard({
    super.key,
    required this.productName,
    required this.scannedCode,
    required this.isError,
    this.onDismiss,
    this.autoDismissDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<ScanResultCard> createState() => _ScanResultCardState();
}

class _ScanResultCardState extends State<ScanResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _dismissTimer = Timer(widget.autoDismissDuration, _dismissCard);
  }

  void _dismissCard() {
    _controller.duration = const Duration(milliseconds: 500);
    _controller.reverse().then((_) => widget.onDismiss?.call());
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isError = widget.isError;

    // ✅ i18n: se você passou "Código escaneado" no modal, dá pra deixar automático:
    // - se vier vazio, usamos um título padrão traduzível.
    final fallbackTitle =
        isError ? l10n.scannerResultErrorTitle : l10n.scannerResultSuccessTitle;

    final title =
        widget.productName.trim().isEmpty ? fallbackTitle : widget.productName;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isError
                  ? [Colors.red.shade50, Colors.white.withAlpha(220)]
                  : [Colors.green.shade50, Colors.white.withAlpha(220)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    isError ? Colors.red.withAlpha(100) : Colors.green.withAlpha(100),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
            border: Border.all(
              color: isError ? Colors.red.shade200 : Colors.green.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  if (isError) return Transform.scale(scale: value, child: child);

                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: value * 2 * 3.14159,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isError
                          ? [Colors.redAccent, Colors.red.shade300]
                          : [Colors.greenAccent, Colors.green.shade300],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isError
                            ? Colors.red.withAlpha(150)
                            : Colors.green.withAlpha(150),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isError ? Colors.red.shade800 : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),

              if (isError) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.scannerResultCode(widget.scannedCode),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
