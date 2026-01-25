// lib/screens/widgets/relatorios/days/widgets/percentual_chip.dart
import 'package:flutter/material.dart';

class PercentualChip extends StatelessWidget {
  final String label;
  final String mode; // all | add | remove
  final String selectedMode;
  final ValueChanged<String> onSelect;

  const PercentualChip({
    super.key,
    required this.label,
    required this.mode,
    required this.selectedMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedMode == mode;

    Color selectedColor;
    if (mode == 'all') {
      selectedColor = Colors.black;
    } else if (mode == 'add') {
      selectedColor = isSelected ? Colors.green : Colors.black;
    } else {
      selectedColor = isSelected ? Colors.red : Colors.black;
    }

    return ChoiceChip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelect(mode),
      backgroundColor: Colors.black,
      selectedColor: selectedColor,
    );
  }
}
