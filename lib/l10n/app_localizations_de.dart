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
  String get hello => 'Hallo';

  @override
  String helloCompany(Object company) {
    return 'Hallo, $company.';
  }

  @override
  String get authChoiceLogin => 'Anmelden';

  @override
  String get authChoiceRegister => 'Registrieren';

  @override
  String get stockToday => 'Ihr Bestand heute';

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
      'Möchten Sie diese Sprache jetzt anwenden? Sie können sie später jederzeit ändern.';

  @override
  String get apply => 'Anwenden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get fieldRequired => 'Pflichtfeld';

  @override
  String get newProductTitle => 'Neues Produkt';

  @override
  String get newProductSectionInfo => 'Produktinformationen';

  @override
  String get newProductNameLabel => 'Produktname';

  @override
  String get newProductNameHint => 'z. B. Reis 5kg';

  @override
  String get newProductNameMin => 'Der Name muss mindestens 2 Zeichen haben';

  @override
  String get newProductNameMax => 'Der Name darf höchstens 50 Zeichen haben';

  @override
  String get newProductNameDuplicateValidator =>
      'Name existiert bereits. Bitte einen anderen wählen.';

  @override
  String get newProductDuplicateNameMessage =>
      'Dieser Name existiert bereits. Sie können ihn bearbeiten.';

  @override
  String newProductNameHelperChars(int count) {
    return '$count/50 Zeichen';
  }

  @override
  String get newProductNameHelperNearLimit => '(Fast am Limit)';

  @override
  String get newProductNameHelperLimitReached => '(Limit erreicht)';

  @override
  String get newProductQuantityLabel => 'Menge';

  @override
  String get newProductPriceLabel => 'Preis (R\$)';

  @override
  String get newProductFillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get newProductNameAlreadyExists =>
      'Es gibt bereits ein Produkt mit diesem Namen';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'Dieser Barcode ist bereits mit dem Produkt $name verknüpft.';
  }

  @override
  String get newProductGenericSaveError => 'Fehler beim Speichern';

  @override
  String newProductSaveErrorWithMessage(Object error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get newProductImageAdd => 'Bild hinzufügen';

  @override
  String get newProductBarcodeLabel => 'Barcode';

  @override
  String get newProductBarcodeHint => 'z. B. 7891234567890';

  @override
  String get newProductCategoryLabel => 'Kategorie';

  @override
  String get newProductCategoryLoading => 'Kategorien werden geladen...';

  @override
  String get newProductCategoryHint => 'Kategorie auswählen';

  @override
  String get newProductCategoryValidator => 'Bitte eine Kategorie auswählen';

  @override
  String get newProductSaveButton => 'Produkt speichern';
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
  String get authChoiceLogin => 'Anmelden';

  @override
  String get authChoiceRegister => 'Registrieren';

  @override
  String get stockToday => 'Ihr Bestand heute';

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
      'Möchten Sie diese Sprache jetzt anwenden?';

  @override
  String get apply => 'Anwenden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get fieldRequired => 'Pflichtfeld';

  @override
  String get newProductTitle => 'Neues Produkt';

  @override
  String get newProductSectionInfo => 'Produktinfos';

  @override
  String get newProductNameLabel => 'Produktname';

  @override
  String get newProductNameHint => 'z. B. Reis 5kg';

  @override
  String get newProductNameMin => 'Der Name muss mindestens 2 Zeichen haben';

  @override
  String get newProductNameMax => 'Der Name darf höchstens 50 Zeichen haben';

  @override
  String get newProductNameDuplicateValidator =>
      'Name existiert bereits. Bitte einen anderen wählen.';

  @override
  String get newProductDuplicateNameMessage =>
      'Dieser Name existiert bereits. Sie können ihn bearbeiten.';

  @override
  String newProductNameHelperChars(int count) {
    return '$count/50 Zeichen';
  }

  @override
  String get newProductNameHelperNearLimit => '(Fast am Limit)';

  @override
  String get newProductNameHelperLimitReached => '(Limit erreicht)';

  @override
  String get newProductQuantityLabel => 'Menge';

  @override
  String get newProductPriceLabel => 'Preis (R\$)';

  @override
  String get newProductFillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get newProductNameAlreadyExists =>
      'Es gibt bereits ein Produkt mit diesem Namen';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'Dieser Barcode ist bereits mit dem Produkt $name verknüpft.';
  }

  @override
  String get newProductGenericSaveError => 'Fehler beim Speichern';

  @override
  String newProductSaveErrorWithMessage(Object error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get newProductImageAdd => 'Bild hinzufügen';

  @override
  String get newProductBarcodeLabel => 'Barcode';

  @override
  String get newProductBarcodeHint => 'z. B. 7891234567890';

  @override
  String get newProductCategoryLabel => 'Kategorie';

  @override
  String get newProductCategoryLoading => 'Kategorien werden geladen...';

  @override
  String get newProductCategoryHint => 'Kategorie auswählen';

  @override
  String get newProductCategoryValidator => 'Bitte eine Kategorie auswählen';

  @override
  String get newProductSaveButton => 'Produkt speichern';
}
