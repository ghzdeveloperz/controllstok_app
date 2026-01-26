// lib/screens/userPerfil/config_options/configuracoes/config_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

import '../../../acounts/login/login_screen.dart';
import '../categories/categorias_screen.dart';
import '../sobre_screen.dart';
import '../traducer/traducer_screen.dart';

import 'config_items.dart';
import 'theme/config_palette.dart';
import 'widgets/config_app_bar.dart';
import 'widgets/animated_config_option_card.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> with TickerProviderStateMixin {
  late final AnimationController _cardsController;
  late final List<Animation<double>> _cardAnimations;

  late final AnimationController _bgController;
  late final Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _cardAnimations = List.generate(ConfigItems.count, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(index * 0.12, 1.0, curve: Curves.easeOutBack),
        ),
      );
    });

    _bgController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _bgColor = ColorTween(
      begin: ConfigPalette.surface,
      end: ConfigPalette.surface.withValues(alpha: 0.92),
    ).animate(_bgController);

    _cardsController.forward();
  }

  @override
  void dispose() {
    _cardsController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _openLanguage() async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TraducerScreen()),
    );

    if (changed == true && mounted) {
      setState(() {});
    }
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = ConfigItems.build(
      l10n: l10n,
      onOpenLanguage: _openLanguage,
      onOpenCategories: () => _openPage(const CategoriasScreen()),
      onOpenAbout: () => _openPage(SobreScreen(logoutCallback: _logout)),
    );

    return Scaffold(
      backgroundColor: ConfigPalette.surface,
      appBar: const ConfigAppBar(),
      body: AnimatedBuilder(
        animation: _bgColor,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _bgColor.value ?? ConfigPalette.surface,
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
                  for (int i = 0; i < items.length; i++) ...[
                    AnimatedConfigOptionCard(
                      animation: _cardAnimations[i],
                      icon: items[i].icon,
                      title: items[i].title,
                      subtitle: items[i].subtitle,
                      onTap: items[i].onTap,
                    ),
                    if (i != items.length - 1) const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
