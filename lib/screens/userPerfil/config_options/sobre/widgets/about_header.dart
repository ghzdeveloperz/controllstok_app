import 'package:flutter/material.dart';

class AboutHeader extends StatelessWidget {
  final String appName;
  final String versionLabel;
  final String yearLabel;

  const AboutHeader({
    super.key,
    required this.appName,
    required this.versionLabel,
    required this.yearLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$versionLabel • $yearLabel',
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
