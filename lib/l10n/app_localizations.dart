import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('de', 'CH'),
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'PT'),
  ];

  /// GERAL / APP — Título principal do aplicativo
  ///
  /// In pt, this message translates to:
  /// **'MyStoreDay'**
  String get appTitle;

  /// GERAL / APP — Saudação genérica
  ///
  /// In pt, this message translates to:
  /// **'Olá'**
  String get hello;

  /// GERAL / APP — Saudação com nome da empresa
  ///
  /// In pt, this message translates to:
  /// **'Olá, {company}.'**
  String helloCompany(Object company);

  /// TELA AUTH_CHOICE — Texto do botão Login
  ///
  /// In pt, this message translates to:
  /// **'Login'**
  String get authChoiceLogin;

  /// TELA AUTH_CHOICE — Texto do botão Cadastrar
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get authChoiceRegister;

  /// TELA ESTOQUE / HOME — Título do resumo do estoque
  ///
  /// In pt, this message translates to:
  /// **'Seu estoque hoje'**
  String get stockToday;

  /// TELA ESTOQUE / HOME — Placeholder do campo de busca de produtos
  ///
  /// In pt, this message translates to:
  /// **'Buscar produto...'**
  String get searchProductHint;

  /// TELA ESTOQUE / HOME — Filtro 'Todos' (categorias)
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get allCategory;

  /// TELA ESTOQUE / HOME — Mensagem quando não há produtos
  ///
  /// In pt, this message translates to:
  /// **'Nenhum produto encontrado'**
  String get noProductsFound;

  /// TELA IDIOMA — Título da tela de idioma
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

  /// TELA IDIOMA — Opção para usar idioma do sistema
  ///
  /// In pt, this message translates to:
  /// **'Idioma do sistema'**
  String get languageSystem;

  /// TELA IDIOMA — Descrição do idioma do sistema
  ///
  /// In pt, this message translates to:
  /// **'Usar o idioma do seu dispositivo automaticamente'**
  String get languageSystemDescription;

  /// TELA IDIOMA — Placeholder do campo de busca de idioma
  ///
  /// In pt, this message translates to:
  /// **'Buscar idioma...'**
  String get searchLanguageHint;

  /// TELA IDIOMA — Título da seção de preferências
  ///
  /// In pt, this message translates to:
  /// **'Preferências'**
  String get languageSectionPreferences;

  /// TELA IDIOMA — Título da seção de idiomas disponíveis
  ///
  /// In pt, this message translates to:
  /// **'Idiomas disponíveis'**
  String get languageSectionAvailable;

  /// TELA IDIOMA — Label exibido quando idioma está selecionado
  ///
  /// In pt, this message translates to:
  /// **'Selecionado'**
  String get selectedLabel;

  /// TELA IDIOMA — Mensagem quando a busca não encontra idiomas
  ///
  /// In pt, this message translates to:
  /// **'Nenhum idioma encontrado'**
  String get noLanguageFound;

  /// MODAL IDIOMA — Título do modal de confirmação
  ///
  /// In pt, this message translates to:
  /// **'Confirmar alteração'**
  String get languageConfirmTitle;

  /// MODAL IDIOMA — Mensagem do modal de confirmação
  ///
  /// In pt, this message translates to:
  /// **'Deseja aplicar este idioma agora? Você pode alterar novamente quando quiser.'**
  String get languageConfirmMessage;

  /// MODAL / BOTÕES — Ação de confirmar/aplicar
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// MODAL / BOTÕES — Ação de cancelar/voltar
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'de':
      {
        switch (locale.countryCode) {
          case 'CH':
            return AppLocalizationsDeCh();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
