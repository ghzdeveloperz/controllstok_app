// lib/screens/userPerfil/widgets/perfil_info_row.dart
import 'package:flutter/material.dart';

class PerfilInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  final bool isCopyable;
  final VoidCallback? onCopy;

  const PerfilInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isCopyable = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isCopyable)
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
            onPressed: onCopy,
          ),
      ],
    );
  }
}
