// lib/screens/widgets/relatorios/days/utils/relatorios_days_colors.dart
import 'package:flutter/material.dart';

Color generateDistinctColor(int index) {
  final double hue = (index * 137.508) % 360;
  return HSVColor.fromAHSV(
    1.0,
    hue,
    0.65,
    0.85,
  ).toColor();
}
