// lib/core/locale_store.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleStore {
  static const String _kLocaleOverrideKey = 'locale_override';

  /// Retorna o override salvo:
  /// - null => seguir idioma do sistema
  /// - 'pt' => pt (pt-BR no seu caso)
  /// - 'pt_PT' => pt-PT
  /// - 'en' => en
  /// - 'es' => es
  static Future<Locale?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleOverrideKey);

    if (code == null || code.trim().isEmpty) return null;

    // suporta padrões:
    // 'pt' / 'en' / 'es'
    // 'pt_PT' (underscore)
    final parts = code.split(RegExp('[_-]'));
    if (parts.isEmpty) return null;

    final languageCode = parts[0];
    final countryCode = parts.length > 1 ? parts[1] : null;

    return Locale(languageCode, countryCode);
  }

  static Future<void> save(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleOverrideKey);
      return;
    }

    // padroniza:
    // pt -> 'pt'
    // pt-PT -> 'pt_PT'
    final value = (locale.countryCode == null || locale.countryCode!.isEmpty)
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';

    await prefs.setString(_kLocaleOverrideKey, value);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLocaleOverrideKey);
  }
}
