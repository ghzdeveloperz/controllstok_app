  import 'package:flutter/material.dart';
  import '../../../../l10n/app_localizations.dart';

  class PoliticPrivacityScreen extends StatelessWidget {
    const PoliticPrivacityScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;

      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(l10n.privacyPolicyTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleText(l10n.privacyPolicySection1Title),
              _BodyText(l10n.privacyPolicySection1Body),

              _TitleText(l10n.privacyPolicySection2Title),
              _BodyText(l10n.privacyPolicySection2Body),

              _TitleText(l10n.privacyPolicySection3Title),
              _BodyText(l10n.privacyPolicySection3Body),

              _TitleText(l10n.privacyPolicySection4Title),
              _BodyText(l10n.privacyPolicySection4Body),

              _TitleText(l10n.privacyPolicySection5Title),
              _BodyText(l10n.privacyPolicySection5Body),

              _TitleText(l10n.privacyPolicySection6Title),
              _BodyText(l10n.privacyPolicySection6Body),

              _TitleText(l10n.privacyPolicySection7Title),
              _BodyText(l10n.privacyPolicySection7Body),

              _TitleText(l10n.privacyPolicySection8Title),
              _BodyText(l10n.privacyPolicySection8Body),

              const SizedBox(height: 24),

              Text(
                l10n.privacyPolicyLastUpdate,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
  }

  class _TitleText extends StatelessWidget {
    final String text;

    const _TitleText(this.text);

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 20),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  class _BodyText extends StatelessWidget {
    final String text;

    const _BodyText(this.text);

    @override
    Widget build(BuildContext context) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.black87,
        ),
      );
    }
  }
