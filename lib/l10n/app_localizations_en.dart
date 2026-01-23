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
  String get authChoiceLogin => 'Login';

  @override
  String get authChoiceRegister => 'Sign up';

  @override
  String get stockToday => 'Your stock today';

  @override
  String get searchProductHint => 'Search product...';

  @override
  String get allCategory => 'All';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageSystemDescription =>
      'Automatically use your device language';

  @override
  String get searchLanguageHint => 'Search language...';

  @override
  String get languageSectionPreferences => 'Preferences';

  @override
  String get languageSectionAvailable => 'Available languages';

  @override
  String get selectedLabel => 'Selected';

  @override
  String get noLanguageFound => 'No language found';

  @override
  String get languageConfirmTitle => 'Confirm change';

  @override
  String get languageConfirmMessage =>
      'Do you want to apply this language now? You can change it again anytime.';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';
}
