import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para haptic feedback
import '../../export/export_pdf.dart';
import '../../export/export_excel.dart';
import '../../export/export_csv.dart';

class SalveModal extends StatefulWidget {
  const SalveModal({super.key});

  /// Abre o modal centralizado com animação suave e premium (ultra-rápida e premium)
  static Future<void> show(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black.withValues(alpha: 0.8), // Fundo ainda mais escuro para foco intenso
      transitionDuration: const Duration(milliseconds: 100), // Ultra-rápida para máxima fluidez
      pageBuilder: (context, _, _) => const SalveModal(),
      transitionBuilder: (context, anim, _, child) {
        final curvedAnim = CurvedAnimation(parent: anim, curve: Curves.fastOutSlowIn); // Curva premium e rápida
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnim), // Entrada mais dramática
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<SalveModal> createState() => _SalveModalState();
}

class _SalveModalState extends State<SalveModal> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconRotation;
  late Animation<double> _iconPulse;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true); // Rotação e pulso contínuos
    _iconRotation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    _iconPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Bordas arredondadas menores
      elevation: 30, // Elevação extrema para profundidade máxima
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0F4F8), Color(0xFFE2E8F0)], // Gradiente mais premium
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4), // Sombra mais escura
              blurRadius: 50, // Blur maior
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Sombra adicional escura
              blurRadius: 80, // Blur extremo
              offset: const Offset(0, 30),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.95), // Destaque mais intenso
              blurRadius: 40,
              offset: const Offset(-15, -15),
            ), // Efeito glassmorphism ultra-avançado
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24), // Padding reduzido para compacto
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone premium com animação de rotação e pulso
              AnimatedBuilder(
                animation: Listenable.merge([_iconRotation, _iconPulse]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconPulse.value,
                    child: Transform.rotate(
                      angle: _iconRotation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16), // Padding reduzido
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F0F0F), Color(0xFF2D2D2D), Color(0xFF5A5A5A)], // Gradiente metálico triplo
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.7), // Sombra mais escura
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4), // Destaque mais intenso
                              blurRadius: 20,
                              offset: const Offset(-8, -8),
                            ), // Destaque metálico ultra
                          ],
                        ),
                        child: const Icon(
                          Icons.save_alt,
                          color: Colors.white,
                          size: 28, // Tamanho reduzido
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20), // Espaçamento reduzido
              Text(
                'Salvar Relatório',
                style: TextStyle(
                  fontSize: 22, // Tamanho reduzido
                  fontWeight: FontWeight.w900, // Peso máximo
                  color: const Color(0xFF0D0D0D), // Preto ultra-premium
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Espaçamento reduzido
              Text(
                'Escolha o formato de exportação',
                style: TextStyle(
                  fontSize: 14, // Tamanho reduzido
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 24), // Espaçamento reduzido
              _UltraPremiumOptionButton(
                label: 'Exportar como PDF',
                icon: Icons.picture_as_pdf,
                gradientColors: const [Color(0xFFDC3545), Color(0xFFFF6B6B), Color(0xFFFFCDD2), Color(0xFFFFEBEE)], // Gradiente quádruplo vermelho
                onTap: () {
                  HapticFeedback.heavyImpact(); // Feedback tátil mais intenso
                  exportPDF();
                },
              ),
              const SizedBox(height: 16), // Espaçamento reduzido
              _UltraPremiumOptionButton(
                label: 'Exportar como Excel',
                icon: Icons.grid_on,
                gradientColors: const [Color(0xFF28A745), Color(0xFF20C997), Color(0xFF81C784), Color(0xFFB9F6CA)], // Gradiente quádruplo verde
                onTap: () {
                  HapticFeedback.heavyImpact();
                  exportExcel();
                },
              ),
              const SizedBox(height: 16), // Espaçamento reduzido
              _UltraPremiumOptionButton(
                label: 'Exportar como CSV',
                icon: Icons.insert_drive_file,
                gradientColors: const [Color(0xFF007BFF), Color(0xFF6610F2), Color(0xFFBA68C8), Color(0xFFE1BEE7)], // Gradiente quádruplo azul-roxo
                onTap: () {
                  HapticFeedback.heavyImpact();
                  exportCSV();
                },
              ),
              const SizedBox(height: 24), // Espaçamento reduzido
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact(); // Feedback leve no cancelar
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFA0AEC0), width: 3), // Borda mais grossa
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.95), // Fundo mais opaco
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(vertical: 16), // Padding reduzido
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Bordas menores
                    ),
                    elevation: 8,
                    shadowColor: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.2), // Sombra mais escura
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16, // Tamanho reduzido
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UltraPremiumOptionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _UltraPremiumOptionButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    this.onTap,
  });

  @override
  State<_UltraPremiumOptionButton> createState() => _UltraPremiumOptionButtonState();
}

class _UltraPremiumOptionButtonState extends State<_UltraPremiumOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shadowBlur;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250), // Mais rápido para premium
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowBlur = Tween<double>(begin: 15, end: 35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        Navigator.of(context).pop();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation, _shadowBlur]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), // Padding reduzido
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20), // Bordas menores
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withValues(alpha: 0.6 + _glowAnimation.value * 0.4),
                    blurRadius: _shadowBlur.value,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3 + _glowAnimation.value * 0.2), // Sombra mais escura
                    blurRadius: _shadowBlur.value + 10,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4 + _glowAnimation.value * 0.3),
                    blurRadius: 15,
                    offset: const Offset(-6, -6),
                  ), // Glow dinâmico ultra-premium
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24), // Ícone reduzido
                  const SizedBox(width: 16), // Espaçamento reduzido
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16, // Tamanho reduzido
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 20, // Tamanho reduzido
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}