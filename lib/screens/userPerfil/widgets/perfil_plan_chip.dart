// lib/screens/userPerfil/widgets/perfil_plan_chip.dart
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class PerfilPlanChip extends StatelessWidget {
  final String? planRaw;

  const PerfilPlanChip({super.key, required this.planRaw});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final normalized = _normalizedPlan(planRaw);
    final label = _labelFor(l10n, normalized);
    final color = _colorFor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(64)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static String _normalizedPlan(String? plan) {
    final p = (plan ?? '').trim().toLowerCase();
    if (p == 'pro' || p == 'pró') return 'pro';
    if (p == 'max') return 'max';
    return 'free';
  }

  static String _labelFor(AppLocalizations l10n, String plan) {
    switch (plan) {
      case 'pro':
        return l10n.profilePlanPro;
      case 'max':
        return l10n.profilePlanMax;
      default:
        return l10n.profilePlanFree;
    }
  }

  static Color _colorFor(String plan) {
    switch (plan) {
      case 'pro':
        return const Color(0xFF1565C0);
      case 'max':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF2E7D32);
    }
  }
}
