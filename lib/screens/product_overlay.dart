// product_overlay.dart
import 'dart:async';
import 'dart:ui'; // Para BackdropFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductOverlay extends StatefulWidget {
  final bool isVisible;
  final String productName;

  const ProductOverlay({
    super.key,
    required this.isVisible,
    required this.productName,
  });

  @override
  State<ProductOverlay> createState() => _ProductOverlayState();
}

class _ProductOverlayState extends State<ProductOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _messageTimer;
  int _currentMessageIndex = 0;

  final List<String> _messages = [
    'Criando produto',
    'Validando informações',
    'Salvando no sistema',
    'Finalizando',
    'Pronto', // Nova mensagem para o final
  ];

  final List<IconData> _icons = [
    Icons.add_circle_outline, // Criando
    Icons.verified_outlined, // Validando
    Icons.cloud_upload_outlined, // Salvando
    Icons.check_circle_outline, // Finalizando
    Icons.done_all, // Pronto
  ];

  @override
  void initState() {
    super.initState();

    // Controlador para fade do overlay
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Controlador para scale do ícone
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Controlador para rotação sutil do ícone
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Controlador para progresso linear
    _progressController = AnimationController(
      duration: const Duration(seconds: 4), // Tempo total do fluxo
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Controlador para shimmer na barra
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Novo controlador para efeito de pulso no ícone
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressController.addListener(() {
      if (mounted) {
        setState(() {
          // Lógica ajustada: para progresso < 1.0, usa as primeiras 4 mensagens
          // No último milésimo (quando == 1.0), mostra "Pronto"
          if (_progressAnimation.value >= 1.0) {
            _currentMessageIndex = 4; // "Pronto"
          } else {
            _currentMessageIndex = (_progressAnimation.value * 4).floor().clamp(0, 3);
          }
        });
      }
    });

    if (widget.isVisible) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant ProductOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startAnimation();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    _fadeController.forward();
    _scaleController.forward();
    _rotationController.repeat(reverse: true); // Rotação contínua sutil
    _progressController.forward(from: 0.0);
    _shimmerController.repeat(reverse: true); // Shimmer contínuo
    _pulseController.repeat(reverse: true); // Pulso contínuo
  }

  void _stopAnimation() {
    _progressController.stop();
    _shimmerController.stop();
    _rotationController.stop();
    _pulseController.stop();
    _fadeController.reverse();
    _scaleController.reverse();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _shimmerAnimation, _pulseAnimation]),
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), // Blur ultra premium
          child: Container(
            color: Colors.black.withOpacity(0.7 * _fadeAnimation.value), // Fundo preto intenso com fade
            child: IgnorePointer( // Bloqueia interações
              child: Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9, // Largura quase total para imersão
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white, // Fundo branco sólido para contraste
                      borderRadius: BorderRadius.circular(32), // Bordas ultra arredondadas
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -10), // Glow superior
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withOpacity(0.8), // Borda preta forte
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícone animado com scale, rotação e pulso
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: RotationTransition(
                            turns: _rotationAnimation,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Icon(
                                    _icons[_currentMessageIndex],
                                    size: 64, // Ícone ainda maior
                                    color: Colors.black, // Preto para contraste
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Texto com AnimatedSwitcher premium
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _messages[_currentMessageIndex],
                            key: ValueKey<int>(_currentMessageIndex),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700, // Peso maior para elegância
                              color: Colors.black,
                              letterSpacing: 0.5, // Espaçamento para premium
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Subtítulo
                        Text(
                          widget.productName.isNotEmpty ? widget.productName : 'Produto',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        // Barra de progresso com shimmer
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black.withOpacity(0.8),
                                  ),
                                ),
                                // Shimmer effect
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.4),
                                          Colors.transparent,
                                        ],
                                        stops: [
                                          _shimmerAnimation.value - 0.3,
                                          _shimmerAnimation.value,
                                          _shimmerAnimation.value + 0.3,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}