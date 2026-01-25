// lib/screens/widgets/relatorios/days/widgets/chart_type_selector.dart
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class ChartTypeSelector extends StatelessWidget {
  final String selectedChartType; // Linha | Pizza
  final ValueChanged<String> onSelect;

  const ChartTypeSelector({
    super.key,
    required this.selectedChartType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _Item(
                label: l10n.relatoriosChartLine,
                icon: Icons.show_chart,
                isSelected: selectedChartType == 'Linha',
                onTap: () => onSelect('Linha'),
              ),
            ),
            Expanded(
              child: _Item(
                label: l10n.relatoriosChartPercent,
                icon: Icons.pie_chart,
                isSelected: selectedChartType == 'Pizza',
                onTap: () => onSelect('Pizza'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _Item({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : const Color(0xFF2C3E50)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
