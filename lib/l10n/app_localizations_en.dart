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

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get companyEmailFallback => '—';

  @override
  String get companyHeaderTitle => 'Set up your company';

  @override
  String companyHeaderAccountLine(Object email) {
    return 'Account: $email';
  }

  @override
  String get companyHeaderSubtitle =>
      'These details help personalize your system and keep your reports organized.';

  @override
  String get companyCompanyHint => 'Legal name / company name';

  @override
  String get companyHasFantasyNameQuestion =>
      'Does your company use a trade name?';

  @override
  String get companyFantasyNameHint => 'Trade name';

  @override
  String get companyHasOwnerQuestion =>
      'Would you like to add a person in charge?';

  @override
  String get companyOwnerHint => 'Person in charge';

  @override
  String get companyHasPhoneQuestion =>
      'Would you like to add a phone/WhatsApp number?';

  @override
  String get companyPhoneHint => 'Phone / WhatsApp';

  @override
  String get companyBusinessTypeHint => 'Business type';

  @override
  String get companyBusinessTypeSelectTitle => 'Select the business type';

  @override
  String get companyBusinessTypeOtherHint => 'Describe (up to 20 characters)';

  @override
  String get companyBusinessTypeRestaurant => 'Restaurant';

  @override
  String get companyBusinessTypeMarket => 'Market';

  @override
  String get companyBusinessTypeBakery => 'Bakery';

  @override
  String get companyBusinessTypePharmacy => 'Pharmacy';

  @override
  String get companyBusinessTypeStore => 'Store';

  @override
  String get companyBusinessTypeWorkshop => 'Workshop';

  @override
  String get companyBusinessTypeIndustry => 'Industry';

  @override
  String get companyBusinessTypeDistributor => 'Distributor';

  @override
  String get companyBusinessTypeOther => 'Other';

  @override
  String get companyAcceptTermsPrefix => 'I have read and agree to the';

  @override
  String get companyTermsLink => 'Terms of use';

  @override
  String get companyAcceptPrivacyPrefix => 'I have read and agree to the';

  @override
  String get companyPrivacyLink => 'Privacy policy';

  @override
  String get companyFinishButton => 'Finish setup';

  @override
  String get companyErrorCompanyRequired =>
      'Please enter the legal/company name';

  @override
  String get companyErrorBusinessTypeRequired =>
      'Please select a business type';

  @override
  String get companyErrorOtherBusinessTypeRequired =>
      'Please describe the business type (up to 20 characters)';

  @override
  String get companyErrorFantasyRequired => 'Please enter the trade name';

  @override
  String get companyErrorOwnerRequired => 'Please enter the person in charge';

  @override
  String get companyErrorPhoneRequired =>
      'Please enter the phone/WhatsApp number';

  @override
  String get companyErrorAcceptLegal =>
      'You must accept the Terms of Use and the Privacy Policy.';

  @override
  String get companyErrorSaveFailed =>
      'Could not save your details. Please try again.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySection1Title => '1. Introduction';

  @override
  String get privacyPolicySection1Body =>
      'ControllStok is an inventory management app. This Privacy Policy describes how users’ information is handled and protected.';

  @override
  String get privacyPolicySection2Title => '2. Data Collection';

  @override
  String get privacyPolicySection2Body =>
      'The app may collect basic information necessary for its operation, such as login data and information related to products registered in your inventory.';

  @override
  String get privacyPolicySection3Title => '3. Use of Information';

  @override
  String get privacyPolicySection3Body =>
      'The collected information is used exclusively for the app’s operation, improving the user experience, and internal inventory control.';

  @override
  String get privacyPolicySection4Title => '4. Data Sharing';

  @override
  String get privacyPolicySection4Body =>
      'ControllStok does not share personal data with third parties, except when required by law.';

  @override
  String get privacyPolicySection5Title => '5. Security';

  @override
  String get privacyPolicySection5Body =>
      'We adopt technical and organizational measures to protect stored data, reducing the risk of unauthorized access.';

  @override
  String get privacyPolicySection6Title => '6. User Responsibilities';

  @override
  String get privacyPolicySection6Body =>
      'The user is responsible for keeping their access credentials secure and for all activities performed under their account.';

  @override
  String get privacyPolicySection7Title => '7. Changes';

  @override
  String get privacyPolicySection7Body =>
      'This Privacy Policy may be updated periodically. We recommend that the user review this document regularly.';

  @override
  String get privacyPolicySection8Title => '8. Contact';

  @override
  String get privacyPolicySection8Body =>
      'If you have questions about this Privacy Policy, please contact us at: contact@mystoreday.com.';

  @override
  String get privacyPolicyLastUpdate => 'Last updated: January 2025';

  @override
  String get termsOfUseTitle => 'Terms of Use';

  @override
  String get termsOfUseSection1Title => '1. Acceptance of Terms';

  @override
  String get termsOfUseSection1Body =>
      'By using the MyStoreDay application, the user fully agrees to these Terms of Use. If you do not agree, it is recommended not to use the application.';

  @override
  String get termsOfUseSection2Title => '2. Application Purpose';

  @override
  String get termsOfUseSection2Body =>
      'MyStoreDay is designed to assist with inventory management, allowing control of products, quantities, and related information.';

  @override
  String get termsOfUseSection3Title => '3. Registration and Responsibility';

  @override
  String get termsOfUseSection3Body =>
      'The user is responsible for the information provided during registration and for keeping their access credentials confidential.';

  @override
  String get termsOfUseSection4Title => '4. Proper Use';

  @override
  String get termsOfUseSection4Body =>
      'It is prohibited to use the application for illegal or fraudulent purposes or in ways that may compromise the security and operation of the system.';

  @override
  String get termsOfUseSection5Title => '5. Limitation of Liability';

  @override
  String get termsOfUseSection5Body =>
      'MyStoreDay is not responsible for losses, damages, or harm resulting from improper use of the application or incorrect information provided by the user.';

  @override
  String get termsOfUseSection6Title => '6. Availability';

  @override
  String get termsOfUseSection6Body =>
      'The application may experience temporary interruptions for maintenance, updates, or external factors beyond the developer’s control.';

  @override
  String get termsOfUseSection7Title => '7. Changes to the Terms';

  @override
  String get termsOfUseSection7Body =>
      'The Terms of Use may be changed at any time. Users are advised to review this document periodically.';

  @override
  String get termsOfUseSection8Title => '8. Contact';

  @override
  String get termsOfUseSection8Body =>
      'If you have questions regarding these Terms of Use, please contact us at: contact@mystoreday.com.';

  @override
  String get termsOfUseLastUpdate => 'Last updated: January 2025';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get relatoriosPercentAll => 'All';

  @override
  String get reportsPeriodDay => 'Day';

  @override
  String get relatoriosCumulativeMovementsTitle =>
      'Cumulative movements throughout the day';

  @override
  String get relatoriosEntries => 'Entries';

  @override
  String get relatoriosExits => 'Exits';

  @override
  String get relatoriosAll => 'All';

  @override
  String get relatoriosTimeAxisLabel => 'Time';

  @override
  String get relatoriosEntry => 'Entry';

  @override
  String get relatoriosExit => 'Exit';

  @override
  String relatoriosPieTitle(String modeLabel) {
    return 'Percentage distribution — $modeLabel';
  }

  @override
  String get relatoriosChartLine => 'Line';

  @override
  String get relatoriosChartPercent => 'Pie';

  @override
  String get relatoriosToday => 'Today';

  @override
  String relatoriosNoMovementsForDate(String dateText) {
    return 'No movements on $dateText';
  }

  @override
  String get relatoriosSelectAnotherDateHint =>
      'Select another date or add new movements.';

  @override
  String relatoriosEntryWithValue(int value) {
    return 'Entry: $value';
  }

  @override
  String relatoriosExitWithValue(int value) {
    return 'Exit: $value';
  }

  @override
  String relatoriosEntriesWithValue(int value) {
    return 'Entries: $value';
  }

  @override
  String relatoriosExitsWithValue(int value) {
    return 'Exits: $value';
  }

  @override
  String get relatoriosMovedProductsTitle => 'Moved products';

  @override
  String get relatoriosExecutiveSummaryTitle => 'Daily executive summary';

  @override
  String get relatoriosNetBalance => 'Net balance';

  @override
  String get relatoriosExportReport => 'Export report';

  @override
  String relatoriosLineTooltip(String label, num value) {
    return '$label: $value';
  }

  @override
  String get relatoriosProductReportTitle => 'Product report';

  @override
  String relatoriosNoMovementsForPeriod(String periodDescription) {
    return 'No movements in $periodDescription';
  }

  @override
  String get relatoriosSelectAnotherMonthHint =>
      'Select another month or add new movements.';

  @override
  String get relatoriosAvailabilityAvailable => 'Available';

  @override
  String get relatoriosAvailabilityUnavailable => 'Unavailable';

  @override
  String relatoriosCurrentStockWithValue(int value) {
    return 'Current stock: $value';
  }

  @override
  String relatoriosCumulativeMovementsOfProduct(String productName) {
    return 'Cumulative movements for $productName';
  }

  @override
  String relatoriosCumulativeMovementsOfProductInMonth(String productName) {
    return 'Cumulative movements for $productName this month';
  }

  @override
  String get relatoriosExecutiveSummaryProductTitle =>
      'Product executive summary';

  @override
  String get relatoriosDetailedMovementsTitle => 'Detailed movements';

  @override
  String get relatoriosTimeLabel => 'Time';

  @override
  String get alertasTitle => 'Stock alerts';

  @override
  String get alertasSearchHint => 'Search product...';

  @override
  String get alertasFilterAll => 'All';

  @override
  String get alertasFilterZero => 'Out of stock';

  @override
  String get alertasFilterCritical => 'Critical';

  @override
  String get alertasSectionZero => 'Out of stock';

  @override
  String get alertasSectionCritical => 'Critical stock';

  @override
  String alertasQuantityWithValue(String value) {
    return 'Quantity: $value';
  }

  @override
  String get alertasOrderNow => 'Order now';

  @override
  String get alertasNotify => 'Notify';

  @override
  String get alertasEmptyTitle => 'No active alerts';

  @override
  String get alertasEmptySubtitle => 'Your stock is in order!';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get productDetailsProductName => 'Product name';

  @override
  String get productDetailsCategory => 'Category';

  @override
  String get productDetailsTotalCostInStock => 'Total stock cost';

  @override
  String get productDetailsMinStock => 'Minimum stock';

  @override
  String get productDetailsStockQuantity => 'Stock quantity';

  @override
  String get productDetailsUnitPrice => 'Unit price';

  @override
  String get productDetailsAvgCost => 'Average cost';

  @override
  String get productDetailsBarcode => 'Barcode';

  @override
  String get productDetailsSaveChanges => 'Save changes';

  @override
  String get productDetailsDeleteProduct => 'Delete product';

  @override
  String get productDetailsMinStockInvalid => 'Invalid minimum stock';

  @override
  String get productDetailsDeletedSuccess => 'Product deleted successfully';

  @override
  String get productDetailsConfirmDeletionTitle => 'Confirm deletion';

  @override
  String get productDetailsConfirmDeletionMessage =>
      'For security, enter your password to continue.';

  @override
  String get productDetailsPasswordLabel => 'Password';

  @override
  String get productDetailsPasswordEmpty => 'Please enter your password.';

  @override
  String get productDetailsPasswordVerifyError =>
      'Could not verify password. Try again.';

  @override
  String get productDetailsPasswordWrong => 'Wrong password. Try again.';

  @override
  String get scannerBarcodeInstruction =>
      'Place the barcode inside the highlighted area';

  @override
  String get scannerBarcodeScannedLabel => 'Scanned code';

  @override
  String get scannerResultSuccessTitle => 'Code scanned';

  @override
  String get scannerResultErrorTitle => 'Scan error';

  @override
  String scannerResultCode(String code) {
    return 'Code: $code';
  }

  @override
  String get addCategoryTitle => 'Add category';

  @override
  String get addCategoryHint => 'Category name';

  @override
  String get addCategoryAction => 'Add';

  @override
  String get addCategoryNameRequired => 'Please enter a category name.';

  @override
  String get addCategoryError => 'Could not add category. Please try again.';

  @override
  String get homeTabStock => 'Stock';

  @override
  String get homeTabNew => 'New';

  @override
  String get homeTabScanner => 'Scanner';

  @override
  String get homeTabReports => 'Reports';

  @override
  String get homeTabAlerts => 'Alerts';

  @override
  String get homeProductSavedSuccess => 'Product saved successfully';

  @override
  String get homeAccountDeactivatedTitle => 'Account deactivated';

  @override
  String get homeAccountDeactivatedMessage =>
      'Your account has been deactivated. Please contact support.';

  @override
  String get commonOk => 'OK';

  @override
  String get productStatusUnavailable => 'Unavailable';

  @override
  String get productStatusCritical => 'Low stock';

  @override
  String get productStatusAvailable => 'Available';

  @override
  String productStockWithValue(int value) {
    return 'Stock: $value';
  }

  @override
  String currencyValue(double value) {
    return '\$ $value';
  }
}
