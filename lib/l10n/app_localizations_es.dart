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
}
