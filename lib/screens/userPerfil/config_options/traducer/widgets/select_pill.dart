import 'package:flutter/material.dart';

class SelectPill extends StatelessWidget {
  final bool selected;
  const SelectPill({super.key, required this.selected});

  static const Color _ink = Color(0xFF0B0F14);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected ? _ink : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? _ink : _border, width: 1.2),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 18,
        color: selected ? Colors.white : Colors.transparent,
      ),
    );
  }
}
