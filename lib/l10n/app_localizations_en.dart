// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyStoreDay';

  @override
  String get hello => 'Hello';

  @override
  String helloCompany(Object company) {
    return 'Hello, $company.';
  }

  @override
  String get stockToday => 'Your stock today';

  @override
  String get searchProductHint => 'Search product...';

  @override
  String get allCategory => 'All';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageSystemDescription =>
      'Usar automáticamente el idioma de tu dispositivo';

  @override
  String get searchLanguageHint => 'Buscar idioma...';

  @override
  String get languageSectionPreferences => 'Preferencias';

  @override
  String get languageSectionAvailable => 'Idiomas disponibles';

  @override
  String get selectedLabel => 'Seleccionado';

  @override
  String get noLanguageFound => 'No se encontró ningún idioma';

  @override
  String get languageConfirmTitle => 'Confirmar cambio';

  @override
  String get languageConfirmMessage =>
      '¿Quieres aplicar este idioma ahora? Puedes cambiarlo cuando quieras.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';
}
