// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MyStoreDay';

  @override
  String get hello => 'Olá';

  @override
  String helloCompany(Object company) {
    return 'Olá, $company.';
  }

  @override
  String get authChoiceLogin => 'Login';

  @override
  String get authChoiceRegister => 'Cadastrar';

  @override
  String get stockToday => 'Seu estoque hoje';

  @override
  String get searchProductHint => 'Buscar produto...';

  @override
  String get allCategory => 'Todos';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get languageSystemDescription =>
      'Usar o idioma do seu dispositivo automaticamente';

  @override
  String get searchLanguageHint => 'Buscar idioma...';

  @override
  String get languageSectionPreferences => 'Preferências';

  @override
  String get languageSectionAvailable => 'Idiomas disponíveis';

  @override
  String get selectedLabel => 'Selecionado';

  @override
  String get noLanguageFound => 'Nenhum idioma encontrado';

  @override
  String get languageConfirmTitle => 'Confirmar alteração';

  @override
  String get languageConfirmMessage =>
      'Deseja aplicar este idioma agora? Você pode alterar novamente quando quiser.';

  @override
  String get apply => 'Aplicar';

  @override
  String get cancel => 'Cancelar';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appTitle => 'MyStoreDay';

  @override
  String get hello => 'Olá';

  @override
  String helloCompany(Object company) {
    return 'Olá, $company.';
  }

  @override
  String get authChoiceLogin => 'Iniciar sessão';

  @override
  String get authChoiceRegister => 'Registar';

  @override
  String get stockToday => 'O seu stock hoje';

  @override
  String get searchProductHint => 'Pesquisar produto...';

  @override
  String get allCategory => 'Todos';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get languageSystemDescription =>
      'Usar automaticamente o idioma do seu dispositivo';

  @override
  String get searchLanguageHint => 'Pesquisar idioma...';

  @override
  String get languageSectionPreferences => 'Preferências';

  @override
  String get languageSectionAvailable => 'Idiomas disponíveis';

  @override
  String get selectedLabel => 'Selecionado';

  @override
  String get noLanguageFound => 'Nenhum idioma encontrado';

  @override
  String get languageConfirmTitle => 'Confirmar alteração';

  @override
  String get languageConfirmMessage =>
      'Pretende aplicar este idioma agora? Pode alterá-lo novamente quando quiser.';

  @override
  String get apply => 'Aplicar';

  @override
  String get cancel => 'Cancelar';
}
