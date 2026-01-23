// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MyStoreDay';

  @override
  String get hello => 'Hola';

  @override
  String helloCompany(Object company) {
    return 'Hola, $company.';
  }

  @override
  String get stockToday => 'Tu inventario hoy';

  @override
  String get searchProductHint => 'Buscar producto...';

  @override
  String get allCategory => 'Todos';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageSystemDescription =>
      'Usar el idioma del dispositivo automáticamente';

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
  String get languageConfirmTitle => 'Confirmar alteração';

  @override
  String get languageConfirmMessage =>
      'Deseja aplicar este idioma agora? Você pode alterar novamente quando quiser.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';
}
