import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Para BackdropFilter

import '../screens/login_screen.dart';
import 'conf_options/perfil_screen.dart';
import 'conf_options/categorias_screen.dart';
import 'conf_options/sobre_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animações stagger para entrada dos cards
    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.15, 1.0, curve: Curves.elasticOut),
        ),
      );
    });

    // Animação de fundo pulsante
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.grey.shade50.withValues(alpha: 0.2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              foregroundColor: Colors.black,
              centerTitle: false,
              title: Padding(
                padding: EdgeInsets.zero, // sem padding
                child: Text(
                  'Configurações',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Colors.black87,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
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
                        Colors.grey.shade400.withValues(alpha: 0.6),
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
                  _backgroundColorAnimation.value ?? Colors.white,
                  Colors.grey.shade50.withValues(alpha: 0.4),
                  Colors.grey.shade100.withValues(alpha: 0.2),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _animations[0],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 60 * (1 - _animations[0].value)),
                        child: Opacity(
                          opacity: _animations[0].value,
                          child: _buildOption(
                            context,
                            icon: Icons.person_outline,
                            title: 'Perfil',
                            subtitle: 'Informações pessoais',
                            page: const PerfilScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: _animations[1],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 60 * (1 - _animations[1].value)),
                        child: Opacity(
                          opacity: _animations[1].value,
                          child: _buildOption(
                            context,
                            icon: Icons.category_outlined,
                            title: 'Categorias',
                            subtitle: 'Categorias do estoque',
                            page: const CategoriasScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: _animations[2],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 60 * (1 - _animations[2].value)),
                        child: Opacity(
                          opacity: _animations[2].value,
                          child: _buildOption(
                            context,
                            icon: Icons.info_outline,
                            title: 'Sobre',
                            subtitle: 'Informações do app',
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
    required Widget page,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22), // um pouco menor
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Stack(
        children: [
          // Glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.85),
                      Colors.grey.shade50.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Conteúdo
          InkWell(
            borderRadius: BorderRadius.circular(22),
            splashColor: Colors.blue.shade200.withValues(alpha: 0.25),
            highlightColor: Colors.blue.shade100.withValues(alpha: 0.15),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => page));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ), // menor
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14), // menor
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade200,
                          Colors.grey.shade300.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 5,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.black87, size: 28), // menor
                  ),
                  const SizedBox(width: 20), // menor espaçamento
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
