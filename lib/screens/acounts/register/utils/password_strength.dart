// lib/screens/register/utils/password_strength.dart
import 'dart:math';

int calculatePasswordStrength(String password) {
  int strength = 0;

  if (password.length >= 8) strength++;
  if (RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password)) strength++;
  if (RegExp(r'(?=.*\d)').hasMatch(password)) strength++;
  if (RegExp(r'(?=.*[!@#\$&*~])').hasMatch(password)) strength++;

  return min(strength, 3);
}
