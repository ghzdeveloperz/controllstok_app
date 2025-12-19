import 'dart:async'; // Adicione esta importação para usar Timer
import 'package:flutter/material.dart';

class ScanResultCard extends StatefulWidget {
  final String productName;
  final String scannedCode;
  final VoidCallback? onDismiss; // Callback opcional para quando o card for dispensado (útil se o pai quiser controlar)

  const ScanResultCard({
    super.key,
    required this.productName,
    required this.scannedCode,
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
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Inicia a animação de entrada
    _controller.forward();

    // Após 3 segundos (ajuste conforme necessário), inicia a animação de saída
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      _dismissCard();
    });
  }

  void _dismissCard() {
    // Anima a saída com fade-out mais suave: duração maior para o fade-out
    _controller.duration = const Duration(milliseconds: 800); // Duração maior para saída (fade-out mais lento)
    _controller.reverse().then((_) {
      widget.onDismiss?.call(); // Chama o callback se fornecido
      // Ou, se não houver callback, você pode simplesmente deixar o widget ser removido pelo pai
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel(); // Cancela o timer se o widget for descartado
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isError = widget.productName == 'Produto não encontrado' ||
        widget.productName == 'Erro ao buscar produto';

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
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  if (isError) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  } else {
                    return Transform.scale(
                      scale: value,
                      child: Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: child,
                      ),
                    );
                  }
                },
                child: Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: isError ? Colors.redAccent : Colors.greenAccent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.productName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isError ? Colors.redAccent : Colors.black87,
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