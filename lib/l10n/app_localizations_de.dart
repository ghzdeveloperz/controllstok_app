// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MyStoreDay';

  @override
  String get hello => 'Olá';

  @override
  String helloCompany(Object company) {
    return 'Olá, $company.';
  }

  @override
  String get stockToday => 'Seu estoque hoje';

  @override
  String get searchProductHint => 'Buscar produto...';

  @override
  String get allCategory => 'Todos';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get languageSystemDescription =>
      'Automatisch die Gerätesprache verwenden';

  @override
  String get searchLanguageHint => 'Sprache suchen...';

  @override
  String get languageSectionPreferences => 'Einstellungen';

  @override
  String get languageSectionAvailable => 'Verfügbare Sprachen';

  @override
  String get selectedLabel => 'Ausgewählt';

  @override
  String get noLanguageFound => 'Keine Sprache gefunden';

  @override
  String get languageConfirmTitle => 'Sprache ändern';

  @override
  String get languageConfirmMessage =>
      'Möchten Sie diese Sprache jetzt anwenden?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get apply => 'Anwenden';
}

/// The translations for German, as used in Switzerland (`de_CH`).
class AppLocalizationsDeCh extends AppLocalizationsDe {
  AppLocalizationsDeCh() : super('de_CH');

  @override
  String get appTitle => 'MyStoreDay';

  @override
  String get hello => 'Hallo';

  @override
  String helloCompany(Object company) {
    return 'Hallo, $company.';
  }

  @override
  String get stockToday => 'Ihr Lagerbestand heute';

  @override
  String get searchProductHint => 'Produkt suchen...';

  @override
  String get allCategory => 'Alle';

  @override
  String get noProductsFound => 'Keine Produkte gefunden';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get languageSystemDescription =>
      'Automatisch die Gerätesprache verwenden';

  @override
  String get searchLanguageHint => 'Sprache suchen...';

  @override
  String get languageSectionPreferences => 'Einstellungen';

  @override
  String get languageSectionAvailable => 'Verfügbare Sprachen';

  @override
  String get selectedLabel => 'Ausgewählt';

  @override
  String get noLanguageFound => 'Keine Sprache gefunden';

  @override
  String get languageConfirmTitle => 'Sprache ändern';

  @override
  String get languageConfirmMessage =>
      'Möchten Sie diese Sprache jetzt anwenden? Sie können sie jederzeit erneut ändern.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get apply => 'Anwenden';
}
