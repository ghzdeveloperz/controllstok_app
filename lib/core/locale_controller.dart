// lib/core/locale_controller.dart
import 'package:flutter/material.dart';
import 'locale_store.dart';

class LocaleController {
  LocaleController._();

  /// Notifica o app inteiro quando o locale muda
  static final ValueNotifier<Locale?> notifier = ValueNotifier<Locale?>(null);

  /// Carrega o locale salvo antes do app iniciar
  static Future<void> init() async {
    notifier.value = await LocaleStore.load();
  }

  /// Salva e aplica imediatamente
  static Future<void> set(Locale? locale) async {
    await LocaleStore.save(locale);
    notifier.value = locale; // ✅ troca instantânea
  }

  static Future<void> clear() async {
    await LocaleStore.clear();
    notifier.value = null;
  }
}
