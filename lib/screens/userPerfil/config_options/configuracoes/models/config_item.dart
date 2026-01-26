// lib/screens/userPerfil/config_options/configuracoes/models/config_item.dart
import 'package:flutter/material.dart';

class ConfigItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ConfigItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });
}
