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

  @override
  String get fieldRequired => 'Required field';

  @override
  String get newProductTitle => 'New Product';

  @override
  String get newProductSectionInfo => 'Product information';

  @override
  String get newProductNameLabel => 'Product name';

  @override
  String get newProductNameHint => 'e.g. Rice 5kg';

  @override
  String get newProductNameMin => 'Name must be at least 2 characters';

  @override
  String get newProductNameMax => 'Name must be at most 50 characters';

  @override
  String get newProductNameDuplicateValidator =>
      'Name already exists. Choose another.';

  @override
  String get newProductDuplicateNameMessage =>
      'This name already exists. You can edit it.';

  @override
  String newProductNameHelperChars(int count) {
    return '$count/50 characters';
  }

  @override
  String get newProductNameHelperNearLimit => '(Near the limit)';

  @override
  String get newProductNameHelperLimitReached => '(limit reached)';

  @override
  String get newProductQuantityLabel => 'Quantity';

  @override
  String get newProductPriceLabel => 'Price (R\$)';

  @override
  String get newProductFillAllFields => 'Please fill in all fields';

  @override
  String get newProductNameAlreadyExists =>
      'A product with this name already exists';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'This barcode is already linked to product $name.';
  }

  @override
  String get newProductGenericSaveError => 'Error while saving';

  @override
  String newProductSaveErrorWithMessage(Object error) {
    return 'Error while saving: $error';
  }

  @override
  String get newProductImageAdd => 'Add image';

  @override
  String get newProductBarcodeLabel => 'Barcode';

  @override
  String get newProductBarcodeHint => 'e.g. 7891234567890';

  @override
  String get newProductCategoryLabel => 'Category';

  @override
  String get newProductCategoryLoading => 'Loading categories...';

  @override
  String get newProductCategoryHint => 'Select a category';

  @override
  String get newProductCategoryValidator => 'Select a category';

  @override
  String get newProductSaveButton => 'Save product';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginSubmitButton => 'Sign in';

  @override
  String get loginOrContinueWith => 'or continue with';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginWithApple => 'Continue with Apple';

  @override
  String get loginWelcomeBackTitle => 'Welcome back!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Sign in and manage your stock with ease.';

  @override
  String get loginNoAccountPrefix => 'Don\'t have an account? ';

  @override
  String get loginCreateNow => 'Create now';

  @override
  String get loginErrorFillEmailAndPassword =>
      'Please enter email and password';

  @override
  String get loginErrorGetUser => 'Failed to get user';

  @override
  String get loginErrorUserNotFound => 'User not found';

  @override
  String get loginErrorAccountDisabled => 'Your account is disabled.';

  @override
  String get loginDialogAccountDisabledTitle => 'Account disabled';

  @override
  String get loginDialogAccountDisabledMessage =>
      'Your account is disabled. Please contact support.';

  @override
  String get ok => 'OK';

  @override
  String get loginErrorCheckUser => 'Error checking user';

  @override
  String get loginResetPasswordEmailRequired =>
      'Enter your email to reset your password';

  @override
  String get loginResetPasswordSuccess => 'We sent a reset link to your email.';

  @override
  String get loginResetPasswordUnexpectedError =>
      'Unexpected error while resetting password';

  @override
  String get loginLoadingGoogle => 'Signing in with Google...';

  @override
  String get loginLoadingPrepareAccount => 'Preparing your account...';

  @override
  String get loginFillEmailAndPassword => 'Please fill in email and password';

  @override
  String get loginErrorGettingUser => 'Error getting user';

  @override
  String get loginUserNotFound => 'User not found';

  @override
  String get loginAccountDisabledShort => 'Your account is disabled.';

  @override
  String get loginAccountDisabledTitle => 'Account disabled';

  @override
  String get loginAccountDisabledMessage =>
      'Your account is disabled. Please contact support.';

  @override
  String get loginErrorCheckingUser => 'Error checking user';

  @override
  String get loginEnterEmailToReset =>
      'Enter your email to reset your password';

  @override
  String get loginResetLinkSent =>
      'We sent a password reset link to your email.';

  @override
  String get loginUnexpectedResetError =>
      'Unexpected error while resetting password';

  @override
  String get loginSigningInWithGoogle => 'Signing in with Google...';

  @override
  String get loginPreparingAccount => 'Preparing your account...';
}
