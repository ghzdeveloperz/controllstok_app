import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sobre_terms/politic_privacity.dart';
import 'sobre_terms/terms_used.dart';

class SobreScreen extends StatelessWidget {
  final VoidCallback logoutCallback;

  const SobreScreen({super.key, required this.logoutCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sobre'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ControllStok',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versão 1.0.0 • 2025',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            _infoTile(
              icon: Icons.person_outline,
              title: 'Desenvolvedor',
              subtitle: 'Gabriel Henrique de Lima Maia',
            ),

            _infoTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de Privacidade',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PoliticPrivacityScreen(),
                  ),
                );
              },
            ),

            _infoTile(
              icon: Icons.description_outlined,
              title: 'Termos de Uso',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsUsedScreen()),
                );
              },
            ),

            _infoTile(
              icon: Icons.support_agent_outlined,
              title: 'Suporte',
              subtitle: 'contact@mystoreday.com',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openHelpEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 3,
                ),
                child: const Text(
                  'Ajuda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openHelpEmail() async {
    final Uri emailUri = Uri.parse(
      'mailto:contact@mystoreday.com?subject=Ajuda%20com%20o%20ControllStok',
    );

    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.black38)
            : null,
      ),
    );
  }
}
