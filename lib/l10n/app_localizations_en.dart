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
  String get authChoiceRegister => 'Register';

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
      'Use your device language automatically';

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
      'Do you want to apply this language now? You can change it again whenever you want.';

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
  String get newProductNameHint => 'e.g., Rice 5kg';

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
  String get newProductPriceLabel => 'Price (\$)';

  @override
  String get newProductFillAllFields => 'Fill in all fields';

  @override
  String get newProductNameAlreadyExists =>
      'A product with this name already exists';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'This barcode is already linked to product $name.';
  }

  @override
  String get newProductGenericSaveError => 'Error saving';

  @override
  String newProductSaveErrorWithMessage(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get newProductImageAdd => 'Add image';

  @override
  String get newProductBarcodeLabel => 'Barcode';

  @override
  String get newProductBarcodeHint => 'e.g., 7891234567890';

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
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginWithApple => 'Sign in with Apple';

  @override
  String get loginWelcomeBackTitle => 'Welcome back!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Sign in and manage your stock with ease.';

  @override
  String get loginNoAccountPrefix => 'Don’t have an account? ';

  @override
  String get loginCreateNow => 'Create now';

  @override
  String get loginErrorFillEmailAndPassword => 'Enter email and password';

  @override
  String get loginErrorGetUser => 'Error getting user';

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
  String get loginFillEmailAndPassword => 'Enter email and password';

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
  String get loginResetLinkSent => 'We sent a reset link to your email.';

  @override
  String get loginUnexpectedResetError =>
      'Unexpected error while resetting password';

  @override
  String get loginSigningInWithGoogle => 'Signing in with Google...';

  @override
  String get loginPreparingAccount => 'Preparing your account...';

  @override
  String get registerHeaderTitle => 'Create your account';

  @override
  String get registerHeaderSubtitle =>
      'Get full control of your stock from day one.';

  @override
  String get registerGoogleGenericFail =>
      'Failed to sign in with Google. Try again.';

  @override
  String get registerCancelFail => 'Couldn’t cancel right now. Try again.';

  @override
  String get registerEmailRequired => 'Enter your email.';

  @override
  String get registerSendVerificationUnexpectedError =>
      'Unexpected error sending verification.';

  @override
  String get registerVerificationEmailResent =>
      'Email resent. Check your inbox (and spam).';

  @override
  String get registerResendVerificationUnexpectedError =>
      'Unexpected error resending verification.';

  @override
  String get registerChangeEmailHint =>
      'You can change the email and try again.';

  @override
  String get registerChangeEmailFail =>
      'Couldn’t change the email right now. Try again.';

  @override
  String get registerPasswordAndConfirmRequired =>
      'Enter password and confirmation.';

  @override
  String get registerPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get registerCreateAccountUnexpectedError =>
      'Unexpected error creating account.';

  @override
  String get registerErrorEmailAlreadyInUse => 'This email is already in use.';

  @override
  String get registerErrorWeakPassword => 'Weak password.';

  @override
  String get registerErrorNoConnection => 'No connection. Try again.';

  @override
  String get registerErrorTooManyRequests =>
      'Too many attempts. Please wait a moment.';

  @override
  String get registerErrorGeneric => 'Error continuing registration.';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailValidatorRequired => 'Enter email';

  @override
  String get registerFooterHaveAccount => 'Already have an account? ';

  @override
  String get registerFooterLogin => 'Sign in';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerContinueWithGoogle => 'Continue with Google';

  @override
  String get registerContinueWithApple => 'Continue with Apple';

  @override
  String get registerGoogleCancelled => 'Google sign-in cancelled.';

  @override
  String get registerGoogleUserNotFound => 'Couldn’t get Google user.';

  @override
  String get registerInvalidEmail => 'Invalid email.';

  @override
  String get registerVerificationEmailSent =>
      'Verification email sent. Check your inbox (and spam).';

  @override
  String get registerVerifyEmailBeforeContinue =>
      'Verify your email before continuing.';

  @override
  String get registerPasswordMustBeStrong =>
      'Password must be strong to create the account.';

  @override
  String get registerInvalidSessionRedoEmailVerification =>
      'Invalid session. Redo email verification.';

  @override
  String get registerEnteringWithGoogleLoading => 'Signing in with Google...';

  @override
  String get registerLoginNotCompleted => 'Login not completed. Try again.';

  @override
  String get registerPreparingAccountLoading => 'Preparing your account...';

  @override
  String get registerEmailHint => 'Email';

  @override
  String get registerSendVerificationButton => 'Send verification email';

  @override
  String get registerResendVerificationButton => 'Resend verification email';

  @override
  String registerResendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get registerNotThisEmail => 'Not this email?';

  @override
  String get registerOrContinueWith => 'or continue with';

  @override
  String get registerAppleNotImplemented => 'Apple not implemented yet.';

  @override
  String get registerPasswordHint => 'Password';

  @override
  String get registerConfirmPasswordHint => 'Confirm password';

  @override
  String get registerCreateAccountButton => 'Create account';

  @override
  String get registerDeleteRegistration => 'Delete registration';

  @override
  String get registerPasswordStrengthVeryWeak => 'Very weak';

  @override
  String get registerPasswordStrengthWeak => 'Weak';

  @override
  String get registerPasswordStrengthStrong => 'Strong';

  @override
  String registerPasswordStrengthLine(String label) {
    return 'Password strength: $label';
  }

  @override
  String get registerPasswordTip =>
      'Tip: 8+ chars, uppercase, lowercase, number and symbol.';

  @override
  String get registerEmailVerifiedStatus => 'Email verified.';

  @override
  String get registerAwaitingUserVerification =>
      'Waiting for user verification';

  @override
  String get registerRestoringRegistration => 'Restoring your registration...';
}
