// lib/screens/userPerfil/config_options/configuracoes/config_items.dart
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'models/config_item.dart';

class ConfigItems {
  static const int count = 3;

  static List<ConfigItem> build({
    required AppLocalizations l10n,
    required VoidCallback onOpenLanguage,
    required VoidCallback onOpenCategories,
    required VoidCallback onOpenAbout,
  }) {
    return [
      ConfigItem(
        icon: Icons.language_outlined,
        title: l10n.settingsLanguageTitle,
        subtitle: l10n.settingsLanguageSubtitle,
        onTap: onOpenLanguage,
      ),
      ConfigItem(
        icon: Icons.category_outlined,
        title: l10n.settingsCategoriesTitle,
        subtitle: l10n.settingsCategoriesSubtitle,
        onTap: onOpenCategories,
      ),
      ConfigItem(
        icon: Icons.info_outline,
        title: l10n.settingsAboutTitle,
        subtitle: l10n.settingsAboutSubtitle,
        onTap: onOpenAbout,
      ),
    ];
  }
}
