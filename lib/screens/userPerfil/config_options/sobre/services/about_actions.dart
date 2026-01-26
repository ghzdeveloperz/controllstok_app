import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../l10n/app_localizations.dart';

class AboutActions {
  static const String supportEmail = 'contact@mystoreday.com';
  static const String developerName = 'Gabriel Henrique de Lima Maia';

  /// ✅ Ano automático
  static int get currentYear => DateTime.now().year;

  /// ✅ Versão do app (placeholder simples).
  /// Se quiser ficar 100% automático via pubspec, dá pra trocar por package_info_plus.
  static const String appVersion = '1.0.1';

  static Future<void> openHelpEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final subject = Uri.encodeComponent(l10n.aboutHelpEmailSubject);
    final Uri emailUri = Uri.parse('mailto:$supportEmail?subject=$subject');

    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  }
}
