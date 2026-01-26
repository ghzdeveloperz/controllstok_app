// lib/screens/userPerfil/config_options/configuracoes/widgets/animated_config_option_card.dart
import 'package:flutter/material.dart';

import 'config_option_card.dart';

class AnimatedConfigOptionCard extends StatelessWidget {
  final Animation<double> animation;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const AnimatedConfigOptionCard({
    super.key,
    required this.animation,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        return Transform.translate(
          offset: Offset(0, 26 * (1 - t)),
          child: Opacity(
            opacity: t,
            child: ConfigOptionCard(
              icon: icon,
              title: title,
              subtitle: subtitle,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}
