import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../sobre_terms/politic_privacity.dart';
import '../sobre_terms/terms_used.dart';

import 'services/about_actions.dart';
import 'widgets/about_header.dart';
import 'widgets/about_tile.dart';

class SobreScreen extends StatelessWidget {
  final VoidCallback logoutCallback;

  const SobreScreen({super.key, required this.logoutCallback});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
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
            AboutHeader(
              appName: l10n.appTitle, // já existe no seu app_pt
              versionLabel: l10n.aboutVersionWithValue(AboutActions.appVersion),
              yearLabel: l10n.aboutYearWithValue(AboutActions.currentYear),
            ),
            const SizedBox(height: 24),

            AboutTile(
              icon: Icons.person_outline,
              title: l10n.aboutDeveloperTitle,
              subtitle: AboutActions.developerName,
            ),

            AboutTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.aboutPrivacyPolicyTitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PoliticPrivacityScreen()),
                );
              },
            ),

            AboutTile(
              icon: Icons.description_outlined,
              title: l10n.aboutTermsTitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsUsedScreen()),
                );
              },
            ),

            AboutTile(
              icon: Icons.support_agent_outlined,
              title: l10n.aboutSupportTitle,
              subtitle: AboutActions.supportEmail,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => AboutActions.openHelpEmail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 3,
                ),
                child: Text(
                  l10n.aboutHelpButton,
                  style: const TextStyle(
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
}
