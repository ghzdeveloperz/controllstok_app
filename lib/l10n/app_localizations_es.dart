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
}
