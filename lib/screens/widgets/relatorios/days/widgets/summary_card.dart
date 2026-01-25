// lib/screens/widgets/relatorios/days/widgets/summary_card.dart
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class SummaryCard extends StatelessWidget {
  final int totalAdd;
  final int totalRemove;
  final int net;

  const SummaryCard({
    super.key,
    required this.totalAdd,
    required this.totalRemove,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget divider() {
      return Container(
        height: 42,
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFBDC3C7).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    Widget item(String label, int value, Color color) {
      return Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 12,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              l10n.relatoriosExecutiveSummaryTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: item(l10n.relatoriosEntries, totalAdd, const Color(0xFF27AE60))),
                divider(),
                Expanded(child: item(l10n.relatoriosExits, totalRemove, const Color(0xFFE74C3C))),
                divider(),
                Expanded(child: item(l10n.relatoriosNetBalance, net, const Color(0xFF2C3E50))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
