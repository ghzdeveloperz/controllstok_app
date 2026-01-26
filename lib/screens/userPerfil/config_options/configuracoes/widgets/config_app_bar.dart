// lib/screens/userPerfil/config_options/configuracoes/widgets/config_app_bar.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../l10n/app_localizations.dart';
import '../theme/config_palette.dart';

class ConfigAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ConfigAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.78),
          foregroundColor: ConfigPalette.ink,
          centerTitle: false,
          titleSpacing: 20,
          title: Text(
            l10n.settingsTitle,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: ConfigPalette.ink,
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
                    ConfigPalette.accent.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
