import 'dart:async';
import 'package:flutter/material.dart';

class ScanResultCard extends StatefulWidget {
  final String productName;
  final bool isError;
  final String scannedCode;
  final VoidCallback? onDismiss;

  const ScanResultCard({
    super.key,
    required this.productName,
    required this.scannedCode,
    required this.isError,
    this.onDismiss,
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
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // animação de entrada
    _controller.forward();

    // ⏱️ TIMER MENOR (antes 3s)
    _dismissTimer = Timer(const Duration(milliseconds: 1200), _dismissCard);
  }

  void _dismissCard() {
    _controller.duration = const Duration(milliseconds: 600);

    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.isError;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  if (isError) {
                    return Transform.scale(scale: value, child: child);
                  }
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: value * 2 * 3.14159,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  isError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color:
                      isError ? Colors.redAccent : Colors.greenAccent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.productName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      isError ? Colors.redAccent : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isError) ...[
                const SizedBox(height: 6),
                Text(
                  'Código: ${widget.scannedCode}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
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
