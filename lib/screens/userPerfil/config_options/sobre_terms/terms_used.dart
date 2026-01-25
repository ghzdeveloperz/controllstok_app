import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class TermsUsedScreen extends StatelessWidget {
  const TermsUsedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.termsOfUseTitle),
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
            _TitleText(l10n.termsOfUseSection1Title),
            _BodyText(l10n.termsOfUseSection1Body),

            _TitleText(l10n.termsOfUseSection2Title),
            _BodyText(l10n.termsOfUseSection2Body),

            _TitleText(l10n.termsOfUseSection3Title),
            _BodyText(l10n.termsOfUseSection3Body),

            _TitleText(l10n.termsOfUseSection4Title),
            _BodyText(l10n.termsOfUseSection4Body),

            _TitleText(l10n.termsOfUseSection5Title),
            _BodyText(l10n.termsOfUseSection5Body),

            _TitleText(l10n.termsOfUseSection6Title),
            _BodyText(l10n.termsOfUseSection6Body),

            _TitleText(l10n.termsOfUseSection7Title),
            _BodyText(l10n.termsOfUseSection7Body),

            _TitleText(l10n.termsOfUseSection8Title),
            _BodyText(l10n.termsOfUseSection8Body),

            const SizedBox(height: 24),

            Text(
              l10n.termsOfUseLastUpdate,
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
