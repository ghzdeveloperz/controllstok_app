// lib/screens/userPerfil/widgets/perfil_security_section.dart
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class PerfilSecuritySection extends StatelessWidget {
  final VoidCallback onSignOut;
  final VoidCallback onDeactivate;

  const PerfilSecuritySection({
    super.key,
    required this.onSignOut,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileSecurityTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          _SecurityButton(
            icon: Icons.logout,
            label: l10n.profileSignOutButton,
            color: const Color.fromARGB(255, 70, 70, 70),
            onTap: onSignOut,
          ),

          const SizedBox(height: 12),

          _SecurityButton(
            icon: Icons.delete_forever,
            label: l10n.profileDeactivateButton,
            color: Colors.red.shade800,
            onTap: onDeactivate,
          ),
        ],
      ),
    );
  }
}

class _SecurityButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SecurityButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withAlpha(51)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
