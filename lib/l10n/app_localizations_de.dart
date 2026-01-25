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
      'Die Sprache Ihres Geräts automatisch verwenden';

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
  String get languageConfirmTitle => 'Änderung bestätigen';

  @override
  String get languageConfirmMessage =>
      'Möchten Sie diese Sprache jetzt anwenden? Sie können sie jederzeit wieder ändern.';

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
  String get newProductNameHint => 'z. B. Reis 5 kg';

  @override
  String get newProductNameMin => 'Der Name muss mindestens 2 Zeichen haben';

  @override
  String get newProductNameMax => 'Der Name darf höchstens 50 Zeichen haben';

  @override
  String get newProductNameDuplicateValidator =>
      'Name existiert bereits. Wählen Sie einen anderen.';

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
  String get newProductFillAllFields => 'Füllen Sie alle Felder aus';

  @override
  String get newProductNameAlreadyExists =>
      'Es gibt bereits ein Produkt mit diesem Namen';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'Dieser Barcode ist bereits dem Produkt $name zugeordnet.';
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
  String get newProductCategoryValidator => 'Wählen Sie eine Kategorie aus';

  @override
  String get newProductSaveButton => 'Produkt speichern';

  @override
  String get loginEmailHint => 'E-Mail';

  @override
  String get loginPasswordHint => 'Passwort';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginSubmitButton => 'Anmelden';

  @override
  String get loginOrContinueWith => 'oder weiter mit';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get loginWithApple => 'Mit Apple anmelden';

  @override
  String get loginWelcomeBackTitle => 'Willkommen zurück!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Melden Sie sich an und verwalten Sie Ihren Bestand ganz einfach.';

  @override
  String get loginNoAccountPrefix => 'Noch kein Konto? ';

  @override
  String get loginCreateNow => 'Jetzt erstellen';

  @override
  String get loginErrorFillEmailAndPassword =>
      'Geben Sie E-Mail und Passwort ein';

  @override
  String get loginErrorGetUser => 'Fehler beim Abrufen des Benutzers';

  @override
  String get loginErrorUserNotFound => 'Benutzer nicht gefunden';

  @override
  String get loginErrorAccountDisabled => 'Ihr Konto ist deaktiviert.';

  @override
  String get loginDialogAccountDisabledTitle => 'Konto deaktiviert';

  @override
  String get loginDialogAccountDisabledMessage =>
      'Ihr Konto ist deaktiviert. Bitte wenden Sie sich an den Support.';

  @override
  String get ok => 'OK';

  @override
  String get loginErrorCheckUser => 'Fehler beim Überprüfen des Benutzers';

  @override
  String get loginResetPasswordEmailRequired =>
      'Geben Sie Ihre E-Mail ein, um das Passwort zurückzusetzen';

  @override
  String get loginResetPasswordSuccess =>
      'Wir haben einen Link zum Zurücksetzen an Ihre E-Mail gesendet.';

  @override
  String get loginResetPasswordUnexpectedError =>
      'Unerwarteter Fehler beim Zurücksetzen des Passworts';

  @override
  String get loginLoadingGoogle => 'Anmeldung mit Google...';

  @override
  String get loginLoadingPrepareAccount => 'Ihr Konto wird vorbereitet...';

  @override
  String get loginFillEmailAndPassword => 'Geben Sie E-Mail und Passwort ein';

  @override
  String get loginErrorGettingUser => 'Fehler beim Abrufen des Benutzers';

  @override
  String get loginUserNotFound => 'Benutzer nicht gefunden';

  @override
  String get loginAccountDisabledShort => 'Ihr Konto ist deaktiviert.';

  @override
  String get loginAccountDisabledTitle => 'Konto deaktiviert';

  @override
  String get loginAccountDisabledMessage =>
      'Ihr Konto ist deaktiviert. Bitte wenden Sie sich an den Support.';

  @override
  String get loginErrorCheckingUser => 'Fehler beim Überprüfen des Benutzers';

  @override
  String get loginEnterEmailToReset =>
      'Geben Sie Ihre E-Mail ein, um das Passwort zurückzusetzen';

  @override
  String get loginResetLinkSent =>
      'Wir haben einen Link zum Zurücksetzen an Ihre E-Mail gesendet.';

  @override
  String get loginUnexpectedResetError =>
      'Unerwarteter Fehler beim Zurücksetzen des Passworts';

  @override
  String get loginSigningInWithGoogle => 'Anmeldung mit Google...';

  @override
  String get loginPreparingAccount => 'Ihr Konto wird vorbereitet...';

  @override
  String get registerHeaderTitle => 'Erstellen Sie Ihr Konto';

  @override
  String get registerHeaderSubtitle =>
      'Behalten Sie vom ersten Tag an die volle Kontrolle über Ihren Bestand.';

  @override
  String get registerGoogleGenericFail =>
      'Anmeldung mit Google fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get registerCancelFail =>
      'Abbrechen ist derzeit nicht möglich. Bitte versuchen Sie es erneut.';

  @override
  String get registerEmailRequired => 'Bitte füllen Sie die E-Mail aus.';

  @override
  String get registerSendVerificationUnexpectedError =>
      'Unerwarteter Fehler beim Senden der Verifizierung.';

  @override
  String get registerVerificationEmailResent =>
      'E-Mail erneut gesendet. Prüfen Sie Ihren Posteingang (und Spam).';

  @override
  String get registerResendVerificationUnexpectedError =>
      'Unerwarteter Fehler beim erneuten Senden der Verifizierung.';

  @override
  String get registerChangeEmailHint =>
      'Sie können die E-Mail ändern und es erneut versuchen.';

  @override
  String get registerChangeEmailFail =>
      'Ändern ist derzeit nicht möglich. Bitte versuchen Sie es erneut.';

  @override
  String get registerPasswordAndConfirmRequired =>
      'Geben Sie das Passwort und die Bestätigung ein.';

  @override
  String get registerPasswordsDoNotMatch =>
      'Die Passwörter stimmen nicht überein.';

  @override
  String get registerCreateAccountUnexpectedError =>
      'Unerwarteter Fehler beim Erstellen des Kontos.';

  @override
  String get registerErrorEmailAlreadyInUse =>
      'Diese E-Mail wird bereits verwendet.';

  @override
  String get registerErrorWeakPassword => 'Schwaches Passwort.';

  @override
  String get registerErrorNoConnection =>
      'Keine Verbindung. Bitte versuchen Sie es erneut.';

  @override
  String get registerErrorTooManyRequests =>
      'Zu viele Versuche. Bitte warten Sie einen Moment.';

  @override
  String get registerErrorGeneric =>
      'Fehler beim Fortsetzen der Registrierung.';

  @override
  String get registerEmailLabel => 'E-Mail';

  @override
  String get registerEmailValidatorRequired => 'Geben Sie die E-Mail an';

  @override
  String get registerFooterHaveAccount => 'Haben Sie schon ein Konto? ';

  @override
  String get registerFooterLogin => 'Anmelden';

  @override
  String get registerPasswordLabel => 'Passwort';

  @override
  String get registerConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get registerContinueWithGoogle => 'Mit Google fortfahren';

  @override
  String get registerContinueWithApple => 'Mit Apple fortfahren';

  @override
  String get registerGoogleCancelled => 'Google-Anmeldung abgebrochen.';

  @override
  String get registerGoogleUserNotFound =>
      'Der Google-Benutzer konnte nicht abgerufen werden.';

  @override
  String get registerInvalidEmail => 'Ungültige E-Mail.';

  @override
  String get registerVerificationEmailSent =>
      'Verifizierungs-E-Mail gesendet. Prüfen Sie Ihren Posteingang (und Spam).';

  @override
  String get registerVerifyEmailBeforeContinue =>
      'Bitte verifizieren Sie Ihre E-Mail, bevor Sie fortfahren.';

  @override
  String get registerPasswordMustBeStrong =>
      'Das Passwort muss stark sein, um das Konto zu erstellen.';

  @override
  String get registerInvalidSessionRedoEmailVerification =>
      'Ungültige Sitzung. Wiederholen Sie die E-Mail-Verifizierung.';

  @override
  String get registerEnteringWithGoogleLoading => 'Anmeldung mit Google...';

  @override
  String get registerLoginNotCompleted =>
      'Anmeldung nicht abgeschlossen. Bitte versuchen Sie es erneut.';

  @override
  String get registerPreparingAccountLoading => 'Ihr Konto wird vorbereitet...';

  @override
  String get registerEmailHint => 'E-Mail';

  @override
  String get registerSendVerificationButton => 'Verifizierungs-E-Mail senden';

  @override
  String get registerResendVerificationButton =>
      'Verifizierungs-E-Mail erneut senden';

  @override
  String registerResendInSeconds(int seconds) {
    return 'Erneut senden in ${seconds}s';
  }

  @override
  String get registerNotThisEmail => 'Nicht diese E-Mail?';

  @override
  String get registerOrContinueWith => 'oder weiter mit';

  @override
  String get registerAppleNotImplemented =>
      'Apple ist noch nicht implementiert.';

  @override
  String get registerPasswordHint => 'Passwort';

  @override
  String get registerConfirmPasswordHint => 'Passwort bestätigen';

  @override
  String get registerCreateAccountButton => 'Konto erstellen';

  @override
  String get registerDeleteRegistration => 'Registrierung löschen';

  @override
  String get registerPasswordStrengthVeryWeak => 'Sehr schwach';

  @override
  String get registerPasswordStrengthWeak => 'Schwach';

  @override
  String get registerPasswordStrengthStrong => 'Stark';

  @override
  String registerPasswordStrengthLine(String label) {
    return 'Passwortstärke: $label';
  }

  @override
  String get registerPasswordTip =>
      'Tipp: 8+ Zeichen, Groß-/Kleinbuchstaben, Zahl und Symbol.';

  @override
  String get registerEmailVerifiedStatus => 'E-Mail verifiziert.';

  @override
  String get registerAwaitingUserVerification =>
      'Warten auf Benutzerverifizierung';

  @override
  String get registerRestoringRegistration =>
      'Ihre Registrierung wird wiederhergestellt...';
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
  String get authChoiceLogin => 'Login';

  @override
  String get authChoiceRegister => 'Registrieren';

  @override
  String get stockToday => 'Dein Bestand heute';

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
      'Sprache deines Geräts automatisch verwenden';

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
  String get languageConfirmTitle => 'Änderung bestätigen';

  @override
  String get languageConfirmMessage =>
      'Möchtest du diese Sprache jetzt anwenden? Du kannst sie jederzeit wieder ändern.';

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
  String get newProductNameHint => 'Z. B. Reis 5 kg';

  @override
  String get newProductNameMin => 'Name muss mindestens 2 Zeichen haben';

  @override
  String get newProductNameMax => 'Name darf höchstens 50 Zeichen haben';

  @override
  String get newProductNameDuplicateValidator =>
      'Name existiert bereits. Bitte einen anderen wählen.';

  @override
  String get newProductDuplicateNameMessage =>
      'Dieser Name existiert bereits. Du kannst ihn bearbeiten.';

  @override
  String newProductNameHelperChars(int count) {
    return '$count/50 Zeichen';
  }

  @override
  String get newProductNameHelperNearLimit => '(fast am Limit)';

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
    return 'Dieser Barcode ist bereits dem Produkt $name zugeordnet.';
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
  String get newProductBarcodeHint => 'Z. B. 7891234567890';

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

  @override
  String get loginEmailHint => 'E-Mail';

  @override
  String get loginPasswordHint => 'Passwort';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginSubmitButton => 'Anmelden';

  @override
  String get loginOrContinueWith => 'oder fortfahren mit';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get loginWithApple => 'Mit Apple anmelden';

  @override
  String get loginWelcomeBackTitle => 'Willkommen zurück!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Melde dich an und verwalte deinen Bestand ganz einfach.';

  @override
  String get loginNoAccountPrefix => 'Noch kein Konto? ';

  @override
  String get loginCreateNow => 'Jetzt erstellen';

  @override
  String get loginErrorFillEmailAndPassword => 'E-Mail und Passwort eingeben';

  @override
  String get loginErrorGetUser => 'Fehler beim Abrufen des Benutzers';

  @override
  String get loginErrorUserNotFound => 'Benutzer nicht gefunden';

  @override
  String get loginErrorAccountDisabled => 'Dein Konto ist deaktiviert.';

  @override
  String get loginDialogAccountDisabledTitle => 'Konto deaktiviert';

  @override
  String get loginDialogAccountDisabledMessage =>
      'Dein Konto ist deaktiviert. Bitte kontaktiere den Support.';

  @override
  String get ok => 'OK';

  @override
  String get loginErrorCheckUser => 'Fehler beim Prüfen des Benutzers';

  @override
  String get loginResetPasswordEmailRequired =>
      'Gib deine E-Mail an, um das Passwort zurückzusetzen';

  @override
  String get loginResetPasswordSuccess =>
      'Wir haben einen Link zum Zurücksetzen an deine E-Mail gesendet.';

  @override
  String get loginResetPasswordUnexpectedError =>
      'Unerwarteter Fehler beim Zurücksetzen des Passworts';

  @override
  String get loginLoadingGoogle => 'Anmeldung mit Google...';

  @override
  String get loginLoadingPrepareAccount => 'Dein Konto wird vorbereitet...';

  @override
  String get loginFillEmailAndPassword => 'E-Mail und Passwort eingeben';

  @override
  String get loginErrorGettingUser => 'Fehler beim Abrufen des Benutzers';

  @override
  String get loginUserNotFound => 'Benutzer nicht gefunden';

  @override
  String get loginAccountDisabledShort => 'Dein Konto ist deaktiviert.';

  @override
  String get loginAccountDisabledTitle => 'Konto deaktiviert';

  @override
  String get loginAccountDisabledMessage =>
      'Dein Konto ist deaktiviert. Bitte kontaktiere den Support.';

  @override
  String get loginErrorCheckingUser => 'Fehler beim Prüfen des Benutzers';

  @override
  String get loginEnterEmailToReset =>
      'Gib deine E-Mail an, um das Passwort zurückzusetzen';

  @override
  String get loginResetLinkSent =>
      'Wir haben einen Link zum Zurücksetzen an deine E-Mail gesendet.';

  @override
  String get loginUnexpectedResetError =>
      'Unerwarteter Fehler beim Zurücksetzen des Passworts';

  @override
  String get loginSigningInWithGoogle => 'Anmeldung mit Google...';

  @override
  String get loginPreparingAccount => 'Dein Konto wird vorbereitet...';

  @override
  String get registerHeaderTitle => 'Konto erstellen';

  @override
  String get registerHeaderSubtitle =>
      'Behalte deinen Bestand vom ersten Tag an vollständig im Blick.';

  @override
  String get registerGoogleGenericFail =>
      'Anmeldung mit Google fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get registerCancelFail =>
      'Abbrechen ist derzeit nicht möglich. Bitte erneut versuchen.';

  @override
  String get registerEmailRequired => 'Bitte E-Mail eingeben.';

  @override
  String get registerSendVerificationUnexpectedError =>
      'Unerwarteter Fehler beim Senden der Bestätigung.';

  @override
  String get registerVerificationEmailResent =>
      'E-Mail erneut gesendet. Bitte Posteingang (und Spam) prüfen.';

  @override
  String get registerResendVerificationUnexpectedError =>
      'Unerwarteter Fehler beim erneuten Senden der Bestätigung.';

  @override
  String get registerChangeEmailHint =>
      'Du kannst die E-Mail ändern und es erneut versuchen.';

  @override
  String get registerChangeEmailFail =>
      'E-Mail konnte derzeit nicht geändert werden. Bitte erneut versuchen.';

  @override
  String get registerPasswordAndConfirmRequired =>
      'Bitte Passwort und Bestätigung eingeben.';

  @override
  String get registerPasswordsDoNotMatch =>
      'Die Passwörter stimmen nicht überein.';

  @override
  String get registerCreateAccountUnexpectedError =>
      'Unerwarteter Fehler beim Erstellen des Kontos.';

  @override
  String get registerErrorEmailAlreadyInUse =>
      'Diese E-Mail wird bereits verwendet.';

  @override
  String get registerErrorWeakPassword => 'Schwaches Passwort.';

  @override
  String get registerErrorNoConnection =>
      'Keine Verbindung. Bitte erneut versuchen.';

  @override
  String get registerErrorTooManyRequests =>
      'Zu viele Versuche. Bitte warte kurz.';

  @override
  String get registerErrorGeneric =>
      'Fehler beim Fortfahren mit der Registrierung.';

  @override
  String get registerEmailLabel => 'E-Mail';

  @override
  String get registerEmailValidatorRequired => 'E-Mail angeben';

  @override
  String get registerFooterHaveAccount => 'Schon ein Konto? ';

  @override
  String get registerFooterLogin => 'Anmelden';

  @override
  String get registerPasswordLabel => 'Passwort';

  @override
  String get registerConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get registerContinueWithGoogle => 'Mit Google fortfahren';

  @override
  String get registerContinueWithApple => 'Mit Apple fortfahren';

  @override
  String get registerGoogleCancelled => 'Google-Anmeldung abgebrochen.';

  @override
  String get registerGoogleUserNotFound =>
      'Google-Benutzer konnte nicht abgerufen werden.';

  @override
  String get registerInvalidEmail => 'Ungültige E-Mail.';

  @override
  String get registerVerificationEmailSent =>
      'Bestätigungs-E-Mail gesendet. Bitte Posteingang (und Spam) prüfen.';

  @override
  String get registerVerifyEmailBeforeContinue =>
      'Bitte bestätige deine E-Mail, bevor du fortfährst.';

  @override
  String get registerPasswordMustBeStrong =>
      'Für die Kontoerstellung muss das Passwort stark sein.';

  @override
  String get registerInvalidSessionRedoEmailVerification =>
      'Ungültige Sitzung. Bitte E-Mail-Bestätigung erneut durchführen.';

  @override
  String get registerEnteringWithGoogleLoading => 'Anmeldung mit Google...';

  @override
  String get registerLoginNotCompleted =>
      'Anmeldung nicht abgeschlossen. Bitte erneut versuchen.';

  @override
  String get registerPreparingAccountLoading =>
      'Dein Konto wird vorbereitet...';

  @override
  String get registerEmailHint => 'E-Mail';

  @override
  String get registerSendVerificationButton => 'Bestätigungs-E-Mail senden';

  @override
  String get registerResendVerificationButton =>
      'Bestätigungs-E-Mail erneut senden';

  @override
  String registerResendInSeconds(int seconds) {
    return 'Erneut senden in ${seconds}s';
  }

  @override
  String get registerNotThisEmail => 'Nicht diese E-Mail?';

  @override
  String get registerOrContinueWith => 'oder fortfahren mit';

  @override
  String get registerAppleNotImplemented =>
      'Apple ist noch nicht implementiert.';

  @override
  String get registerPasswordHint => 'Passwort';

  @override
  String get registerConfirmPasswordHint => 'Passwort bestätigen';

  @override
  String get registerCreateAccountButton => 'Konto erstellen';

  @override
  String get registerDeleteRegistration => 'Registrierung löschen';

  @override
  String get registerPasswordStrengthVeryWeak => 'Sehr schwach';

  @override
  String get registerPasswordStrengthWeak => 'Schwach';

  @override
  String get registerPasswordStrengthStrong => 'Stark';

  @override
  String registerPasswordStrengthLine(String label) {
    return 'Passwortstärke: $label';
  }

  @override
  String get registerPasswordTip =>
      'Tipp: 8+ Zeichen, Gross-/Kleinbuchstabe, Zahl und Symbol.';

  @override
  String get registerEmailVerifiedStatus => 'E-Mail bestätigt.';

  @override
  String get registerAwaitingUserVerification =>
      'Warten auf Benutzerbestätigung';

  @override
  String get registerRestoringRegistration =>
      'Deine Registrierung wird wiederhergestellt...';
}
