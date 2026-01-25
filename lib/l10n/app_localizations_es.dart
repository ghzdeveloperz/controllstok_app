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
  String get authChoiceLogin => 'Iniciar sesión';

  @override
  String get authChoiceRegister => 'Registrarse';

  @override
  String get stockToday => 'Tu stock hoy';

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
      'Usar automáticamente el idioma de tu dispositivo';

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
  String get languageConfirmTitle => 'Confirmar cambio';

  @override
  String get languageConfirmMessage =>
      '¿Deseas aplicar este idioma ahora? Puedes cambiarlo nuevamente cuando quieras.';

  @override
  String get apply => 'Aplicar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get fieldRequired => 'Campo obligatorio';

  @override
  String get newProductTitle => 'Nuevo producto';

  @override
  String get newProductSectionInfo => 'Información del producto';

  @override
  String get newProductNameLabel => 'Nombre del producto';

  @override
  String get newProductNameHint => 'Ej.: Arroz 5 kg';

  @override
  String get newProductNameMin => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get newProductNameMax =>
      'El nombre debe tener como máximo 50 caracteres';

  @override
  String get newProductNameDuplicateValidator =>
      'El nombre ya existe. Elige otro.';

  @override
  String get newProductDuplicateNameMessage =>
      'Este nombre ya existe. Puedes editarlo.';

  @override
  String newProductNameHelperChars(int count) {
    return '$count/50 caracteres';
  }

  @override
  String get newProductNameHelperNearLimit => '(Cerca del límite)';

  @override
  String get newProductNameHelperLimitReached => '(límite alcanzado)';

  @override
  String get newProductQuantityLabel => 'Cantidad';

  @override
  String get newProductPriceLabel => 'Precio (\$)';

  @override
  String get newProductFillAllFields => 'Completa todos los campos';

  @override
  String get newProductNameAlreadyExists =>
      'Ya existe un producto con este nombre';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'Este código de barras ya está asociado al producto $name.';
  }

  @override
  String get newProductGenericSaveError => 'Error al guardar';

  @override
  String newProductSaveErrorWithMessage(Object error) {
    return 'Error al guardar: $error';
  }

  @override
  String get newProductImageAdd => 'Agregar imagen';

  @override
  String get newProductBarcodeLabel => 'Código de barras';

  @override
  String get newProductBarcodeHint => 'Ej.: 7891234567890';

  @override
  String get newProductCategoryLabel => 'Categoría';

  @override
  String get newProductCategoryLoading => 'Cargando categorías...';

  @override
  String get newProductCategoryHint => 'Selecciona una categoría';

  @override
  String get newProductCategoryValidator => 'Selecciona una categoría';

  @override
  String get newProductSaveButton => 'Guardar producto';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Contraseña';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginSubmitButton => 'Entrar';

  @override
  String get loginOrContinueWith => 'o continúa con';

  @override
  String get loginWithGoogle => 'Entrar con Google';

  @override
  String get loginWithApple => 'Entrar con Apple';

  @override
  String get loginWelcomeBackTitle => '¡Bienvenido de nuevo!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Entra y gestiona tu stock con facilidad.';

  @override
  String get loginNoAccountPrefix => '¿Aún no tienes cuenta? ';

  @override
  String get loginCreateNow => 'Crear ahora';

  @override
  String get loginErrorFillEmailAndPassword =>
      'Completa el email y la contraseña';

  @override
  String get loginErrorGetUser => 'Error al obtener el usuario';

  @override
  String get loginErrorUserNotFound => 'Usuario no encontrado';

  @override
  String get loginErrorAccountDisabled => 'Tu cuenta está desactivada.';

  @override
  String get loginDialogAccountDisabledTitle => 'Cuenta desactivada';

  @override
  String get loginDialogAccountDisabledMessage =>
      'Tu cuenta está desactivada. Ponte en contacto con soporte.';

  @override
  String get ok => 'OK';

  @override
  String get loginErrorCheckUser => 'Error al verificar el usuario';

  @override
  String get loginResetPasswordEmailRequired =>
      'Introduce tu email para restablecer la contraseña';

  @override
  String get loginResetPasswordSuccess =>
      'Enviamos un enlace de restablecimiento a tu email.';

  @override
  String get loginResetPasswordUnexpectedError =>
      'Error inesperado al restablecer la contraseña';

  @override
  String get loginLoadingGoogle => 'Entrando con Google...';

  @override
  String get loginLoadingPrepareAccount => 'Preparando tu cuenta...';

  @override
  String get loginFillEmailAndPassword => 'Completa el email y la contraseña';

  @override
  String get loginErrorGettingUser => 'Error al obtener el usuario';

  @override
  String get loginUserNotFound => 'Usuario no encontrado';

  @override
  String get loginAccountDisabledShort => 'Tu cuenta está desactivada.';

  @override
  String get loginAccountDisabledTitle => 'Cuenta desactivada';

  @override
  String get loginAccountDisabledMessage =>
      'Tu cuenta está desactivada. Ponte en contacto con soporte.';

  @override
  String get loginErrorCheckingUser => 'Error al verificar el usuario';

  @override
  String get loginEnterEmailToReset =>
      'Introduce tu email para restablecer la contraseña';

  @override
  String get loginResetLinkSent =>
      'Enviamos un enlace de restablecimiento a tu email.';

  @override
  String get loginUnexpectedResetError =>
      'Error inesperado al restablecer la contraseña';

  @override
  String get loginSigningInWithGoogle => 'Entrando con Google...';

  @override
  String get loginPreparingAccount => 'Preparando tu cuenta...';

  @override
  String get registerHeaderTitle => 'Crea tu cuenta';

  @override
  String get registerHeaderSubtitle =>
      'Ten control total de tu stock desde el primer día.';

  @override
  String get registerGoogleGenericFail =>
      'No se pudo entrar con Google. Inténtalo de nuevo.';

  @override
  String get registerCancelFail =>
      'No se pudo cancelar ahora. Inténtalo de nuevo.';

  @override
  String get registerEmailRequired => 'Completa el email.';

  @override
  String get registerSendVerificationUnexpectedError =>
      'Error inesperado al enviar la verificación.';

  @override
  String get registerVerificationEmailResent =>
      'Email reenviado. Revisa tu bandeja de entrada (y spam).';

  @override
  String get registerResendVerificationUnexpectedError =>
      'Error inesperado al reenviar la verificación.';

  @override
  String get registerChangeEmailHint =>
      'Puedes cambiar el email e intentarlo de nuevo.';

  @override
  String get registerChangeEmailFail =>
      'No se pudo cambiar ahora. Inténtalo de nuevo.';

  @override
  String get registerPasswordAndConfirmRequired =>
      'Completa la contraseña y la confirmación.';

  @override
  String get registerPasswordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get registerCreateAccountUnexpectedError =>
      'Error inesperado al crear la cuenta.';

  @override
  String get registerErrorEmailAlreadyInUse => 'Este email ya está en uso.';

  @override
  String get registerErrorWeakPassword => 'Contraseña débil.';

  @override
  String get registerErrorNoConnection => 'Sin conexión. Inténtalo de nuevo.';

  @override
  String get registerErrorTooManyRequests =>
      'Demasiados intentos. Espera un momento.';

  @override
  String get registerErrorGeneric => 'Error al continuar el registro.';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailValidatorRequired => 'Introduce el email';

  @override
  String get registerFooterHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get registerFooterLogin => 'Iniciar sesión';

  @override
  String get registerPasswordLabel => 'Contraseña';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerContinueWithGoogle => 'Continuar con Google';

  @override
  String get registerContinueWithApple => 'Continuar con Apple';

  @override
  String get registerGoogleCancelled =>
      'Inicio de sesión con Google cancelado.';

  @override
  String get registerGoogleUserNotFound =>
      'No se pudo obtener el usuario de Google.';

  @override
  String get registerInvalidEmail => 'Email inválido.';

  @override
  String get registerVerificationEmailSent =>
      'Email de verificación enviado. Revisa tu bandeja de entrada (y spam).';

  @override
  String get registerVerifyEmailBeforeContinue =>
      'Verifica tu email antes de continuar.';

  @override
  String get registerPasswordMustBeStrong =>
      'La contraseña debe ser fuerte para crear la cuenta.';

  @override
  String get registerInvalidSessionRedoEmailVerification =>
      'Sesión inválida. Repite la verificación del email.';

  @override
  String get registerEnteringWithGoogleLoading => 'Entrando con Google...';

  @override
  String get registerLoginNotCompleted =>
      'Inicio de sesión no completado. Inténtalo de nuevo.';

  @override
  String get registerPreparingAccountLoading => 'Preparando tu cuenta...';

  @override
  String get registerEmailHint => 'Email';

  @override
  String get registerSendVerificationButton => 'Enviar email de verificación';

  @override
  String get registerResendVerificationButton =>
      'Reenviar email de verificación';

  @override
  String registerResendInSeconds(int seconds) {
    return 'Reenviar en ${seconds}s';
  }

  @override
  String get registerNotThisEmail => '¿No es este email?';

  @override
  String get registerOrContinueWith => 'o continúa con';

  @override
  String get registerAppleNotImplemented => 'Apple aún no está implementado.';

  @override
  String get registerPasswordHint => 'Contraseña';

  @override
  String get registerConfirmPasswordHint => 'Confirmar contraseña';

  @override
  String get registerCreateAccountButton => 'Crear cuenta';

  @override
  String get registerDeleteRegistration => 'Eliminar registro';

  @override
  String get registerPasswordStrengthVeryWeak => 'Muy débil';

  @override
  String get registerPasswordStrengthWeak => 'Débil';

  @override
  String get registerPasswordStrengthStrong => 'Fuerte';

  @override
  String registerPasswordStrengthLine(String label) {
    return 'Fuerza de la contraseña: $label';
  }

  @override
  String get registerPasswordTip =>
      'Consejo: 8+ caracteres, mayúscula, minúscula, número y símbolo.';

  @override
  String get registerEmailVerifiedStatus => 'Email verificado.';

  @override
  String get registerAwaitingUserVerification =>
      'Esperando la verificación del usuario';

  @override
  String get registerRestoringRegistration => 'Restaurando tu registro...';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get companyEmailFallback => '—';

  @override
  String get companyHeaderTitle => 'Configura tu empresa';

  @override
  String companyHeaderAccountLine(Object email) {
    return 'Cuenta: $email';
  }

  @override
  String get companyHeaderSubtitle =>
      'Estos datos ayudan a personalizar tu sistema y organizar tus informes.';

  @override
  String get companyCompanyHint => 'Razón social / nombre de la empresa';

  @override
  String get companyHasFantasyNameQuestion =>
      '¿Tu empresa tiene nombre comercial?';

  @override
  String get companyFantasyNameHint => 'Nombre comercial';

  @override
  String get companyHasOwnerQuestion => '¿Quieres informar un responsable?';

  @override
  String get companyOwnerHint => 'Responsable';

  @override
  String get companyHasPhoneQuestion => '¿Quieres informar teléfono/WhatsApp?';

  @override
  String get companyPhoneHint => 'Teléfono / WhatsApp';

  @override
  String get companyBusinessTypeHint => 'Tipo de negocio';

  @override
  String get companyBusinessTypeSelectTitle => 'Selecciona el tipo de negocio';

  @override
  String get companyBusinessTypeOtherHint => 'Describe (hasta 20 caracteres)';

  @override
  String get companyBusinessTypeRestaurant => 'Restaurante';

  @override
  String get companyBusinessTypeMarket => 'Mercado';

  @override
  String get companyBusinessTypeBakery => 'Panadería';

  @override
  String get companyBusinessTypePharmacy => 'Farmacia';

  @override
  String get companyBusinessTypeStore => 'Tienda';

  @override
  String get companyBusinessTypeWorkshop => 'Taller';

  @override
  String get companyBusinessTypeIndustry => 'Industria';

  @override
  String get companyBusinessTypeDistributor => 'Distribuidora';

  @override
  String get companyBusinessTypeOther => 'Otro';

  @override
  String get companyAcceptTermsPrefix => 'He leído y acepto los';

  @override
  String get companyTermsLink => 'Términos de uso';

  @override
  String get companyAcceptPrivacyPrefix => 'He leído y acepto la';

  @override
  String get companyPrivacyLink => 'Política de privacidad';

  @override
  String get companyFinishButton => 'Finalizar registro';

  @override
  String get companyErrorCompanyRequired =>
      'Completa la razón social / nombre de la empresa';

  @override
  String get companyErrorBusinessTypeRequired =>
      'Selecciona el tipo de negocio';

  @override
  String get companyErrorOtherBusinessTypeRequired =>
      'Describe el tipo de negocio (hasta 20 caracteres)';

  @override
  String get companyErrorFantasyRequired => 'Completa el nombre comercial';

  @override
  String get companyErrorOwnerRequired => 'Completa el responsable';

  @override
  String get companyErrorPhoneRequired => 'Completa el teléfono / WhatsApp';

  @override
  String get companyErrorAcceptLegal =>
      'Debes aceptar los Términos de uso y la Política de privacidad.';

  @override
  String get companyErrorSaveFailed =>
      'Error al guardar los datos. Inténtalo de nuevo.';

  @override
  String get privacyPolicyTitle => 'Política de Privacidad';

  @override
  String get privacyPolicySection1Title => '1. Introducción';

  @override
  String get privacyPolicySection1Body =>
      'ControllStok es una aplicación de gestión de inventario. Esta Política de Privacidad describe cómo se tratan y protegen los datos de los usuarios.';

  @override
  String get privacyPolicySection2Title => '2. Recopilación de Datos';

  @override
  String get privacyPolicySection2Body =>
      'La aplicación puede recopilar información básica necesaria para su funcionamiento, como datos de inicio de sesión e información relacionada con los productos registrados en el inventario.';

  @override
  String get privacyPolicySection3Title => '3. Uso de la Información';

  @override
  String get privacyPolicySection3Body =>
      'La información recopilada se utiliza exclusivamente para el funcionamiento de la aplicación, la mejora de la experiencia del usuario y el control interno del inventario.';

  @override
  String get privacyPolicySection4Title => '4. Compartición de Datos';

  @override
  String get privacyPolicySection4Body =>
      'ControllStok no comparte datos personales con terceros, excepto cuando sea requerido por ley.';

  @override
  String get privacyPolicySection5Title => '5. Seguridad';

  @override
  String get privacyPolicySection5Body =>
      'Adoptamos medidas técnicas y organizativas para proteger los datos almacenados, reduciendo el riesgo de accesos no autorizados.';

  @override
  String get privacyPolicySection6Title => '6. Responsabilidades del Usuario';

  @override
  String get privacyPolicySection6Body =>
      'El usuario es responsable de mantener seguras sus credenciales de acceso y de todas las actividades realizadas en su cuenta.';

  @override
  String get privacyPolicySection7Title => '7. Cambios';

  @override
  String get privacyPolicySection7Body =>
      'Esta Política de Privacidad puede actualizarse periódicamente. Recomendamos que el usuario revise este documento con regularidad.';

  @override
  String get privacyPolicySection8Title => '8. Contacto';

  @override
  String get privacyPolicySection8Body =>
      'Si tiene alguna duda sobre esta Política de Privacidad, póngase en contacto a través del correo electrónico: contact@mystoreday.com.';

  @override
  String get privacyPolicyLastUpdate => 'Última actualización: enero de 2025';

  @override
  String get termsOfUseTitle => 'Términos de Uso';

  @override
  String get termsOfUseSection1Title => '1. Aceptación de los Términos';

  @override
  String get termsOfUseSection1Body =>
      'Al utilizar la aplicación MyStoreDay, el usuario acepta plenamente estos Términos de Uso. Si no está de acuerdo, se recomienda no utilizar la aplicación.';

  @override
  String get termsOfUseSection2Title => '2. Finalidad de la Aplicación';

  @override
  String get termsOfUseSection2Body =>
      'MyStoreDay tiene como finalidad ayudar en la gestión de inventario, permitiendo el control de productos, cantidades e información relacionada.';

  @override
  String get termsOfUseSection3Title => '3. Registro y Responsabilidad';

  @override
  String get termsOfUseSection3Body =>
      'El usuario es responsable de la información proporcionada durante el registro y de mantener la confidencialidad de sus credenciales de acceso.';

  @override
  String get termsOfUseSection4Title => '4. Uso Adecuado';

  @override
  String get termsOfUseSection4Body =>
      'Está prohibido utilizar la aplicación con fines ilícitos, fraudulentos o que puedan comprometer la seguridad y el funcionamiento del sistema.';

  @override
  String get termsOfUseSection5Title => '5. Limitación de Responsabilidad';

  @override
  String get termsOfUseSection5Body =>
      'MyStoreDay no se responsabiliza por pérdidas, daños o perjuicios derivados del uso inadecuado de la aplicación o de información incorrecta proporcionada por el usuario.';

  @override
  String get termsOfUseSection6Title => '6. Disponibilidad';

  @override
  String get termsOfUseSection6Body =>
      'La aplicación puede sufrir interrupciones temporales por mantenimiento, actualizaciones o factores externos fuera del control del desarrollador.';

  @override
  String get termsOfUseSection7Title => '7. Modificaciones de los Términos';

  @override
  String get termsOfUseSection7Body =>
      'Los Términos de Uso pueden modificarse en cualquier momento. Se recomienda que el usuario revise este documento periódicamente.';

  @override
  String get termsOfUseSection8Title => '8. Contacto';

  @override
  String get termsOfUseSection8Body =>
      'Si tiene dudas relacionadas con estos Términos de Uso, póngase en contacto a través del correo electrónico: contact@mystoreday.com.';

  @override
  String get termsOfUseLastUpdate => 'Última actualización: enero de 2025';

  @override
  String get reportsTitle => 'Informes';

  @override
  String get relatoriosPercentAll => 'Todos';

  @override
  String get reportsPeriodDay => 'Día';

  @override
  String get relatoriosCumulativeMovementsTitle =>
      'Movimientos acumulados a lo largo del día';

  @override
  String get relatoriosEntries => 'Entradas';

  @override
  String get relatoriosExits => 'Salidas';

  @override
  String get relatoriosAll => 'Todos';

  @override
  String get relatoriosTimeAxisLabel => 'Hora';

  @override
  String get relatoriosEntry => 'Entrada';

  @override
  String get relatoriosExit => 'Salida';

  @override
  String relatoriosPieTitle(String modeLabel) {
    return 'Distribución porcentual — $modeLabel';
  }

  @override
  String get relatoriosChartLine => 'Línea';

  @override
  String get relatoriosChartPercent => 'Circular';

  @override
  String get relatoriosToday => 'Hoy';

  @override
  String relatoriosNoMovementsForDate(String dateText) {
    return 'No hay movimientos en $dateText';
  }

  @override
  String get relatoriosSelectAnotherDateHint =>
      'Seleccione otra fecha o agregue nuevos movimientos.';

  @override
  String relatoriosEntryWithValue(int value) {
    return 'Entrada: $value';
  }

  @override
  String relatoriosExitWithValue(int value) {
    return 'Salida: $value';
  }

  @override
  String relatoriosEntriesWithValue(int value) {
    return 'Entradas: $value';
  }

  @override
  String relatoriosExitsWithValue(int value) {
    return 'Salidas: $value';
  }

  @override
  String get relatoriosMovedProductsTitle => 'Productos movidos';

  @override
  String get relatoriosExecutiveSummaryTitle => 'Resumen ejecutivo del día';

  @override
  String get relatoriosNetBalance => 'Saldo neto';

  @override
  String get relatoriosExportReport => 'Exportar informe';

  @override
  String relatoriosLineTooltip(String label, num value) {
    return '$label: $value';
  }
}
