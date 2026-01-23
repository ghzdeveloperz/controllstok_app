import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../acounts/login/login_screen.dart';
import 'categorias_screen.dart';
import 'sobre_screen.dart';
import 'traducer/traducer_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  late AnimationController _backgroundAnimationController;
  late Animation<Color?> _backgroundColorAnimation;

  // Paleta “premium”
  static const Color _accent = Color(0xFF2D6CDF);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _surface = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Agora são 3 opções
    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.12, 1.0, curve: Curves.easeOutBack),
        ),
      );
    });

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundColorAnimation = ColorTween(
      begin: _surface,
      end: _surface.withValues(alpha: 0.92),
    ).animate(_backgroundAnimationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _openLanguage(BuildContext context) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TraducerScreen()),
    );

    // 🔮 Hook pronto para futuro (reiniciar árvore se quiser)
    if (changed == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(84),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withValues(alpha: 0.78),
              foregroundColor: _ink,
              centerTitle: false,
              titleSpacing: 20,
              title: Text(
                'Configurações',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: _ink,
                  letterSpacing: -0.3,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _accent.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _backgroundColorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColorAnimation.value ?? _surface,
                  const Color(0xFFF4F7FF),
                  const Color(0xFFF8FAFC),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Idioma
                  AnimatedBuilder(
                    animation: _animations[0],
                    builder: (context, child) {
                      final t = _animations[0].value;
                      return Transform.translate(
                        offset: Offset(0, 26 * (1 - t)),
                        child: Opacity(
                          opacity: t,
                          child: _buildOption(
                            context,
                            icon: Icons.language_outlined,
                            title: 'Idioma',
                            subtitle: 'Idioma e região',
                            onTap: () => _openLanguage(context),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Categorias
                  AnimatedBuilder(
                    animation: _animations[1],
                    builder: (context, child) {
                      final t = _animations[1].value;
                      return Transform.translate(
                        offset: Offset(0, 26 * (1 - t)),
                        child: Opacity(
                          opacity: t,
                          child: _buildOption(
                            context,
                            icon: Icons.category_outlined,
                            title: 'Categorias',
                            subtitle: 'Organize seu estoque',
                            page: const CategoriasScreen(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sobre
                  AnimatedBuilder(
                    animation: _animations[2],
                    builder: (context, child) {
                      final t = _animations[2].value;
                      return Transform.translate(
                        offset: Offset(0, 26 * (1 - t)),
                        child: Opacity(
                          opacity: t,
                          child: _buildOption(
                            context,
                            icon: Icons.info_outline,
                            title: 'Sobre',
                            subtitle: 'Versão e informações do app',
                            page: SobreScreen(
                              logoutCallback: () => _logout(context),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? page,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: _accent.withValues(alpha: 0.10),
        highlightColor: _accent.withValues(alpha: 0.06),
        onTap: onTap ??
            () {
              if (page != null) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => page));
              }
            },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.92),
                Colors.white.withValues(alpha: 0.82),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFE7ECF5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B1220).withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accent.withValues(alpha: 0.18),
                        _accent.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.22),
                      width: 1.0,
                    ),
                  ),
                  child:
                      Icon(icon, color: _ink.withValues(alpha: 0.88), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
