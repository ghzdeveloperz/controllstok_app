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
  String get stockToday => 'Tu inventario hoy';

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
      '¿Deseas aplicar este idioma ahora? Puedes cambiarlo cuando quieras.';

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
  String get newProductNameHint => 'Ej: Arroz 5kg';

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
  String get newProductPriceLabel => 'Precio (R\$)';

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
  String get newProductBarcodeHint => 'Ej: 7891234567890';

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
  String get loginEmailHint => 'Correo';

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
  String get loginWelcomeBackTitle => '¡Bienvenido de vuelta!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Entra y gestiona tu inventario con facilidad.';

  @override
  String get loginNoAccountPrefix => '¿Aún no tienes cuenta? ';

  @override
  String get loginCreateNow => 'Crear ahora';

  @override
  String get loginErrorFillEmailAndPassword =>
      'Completa el correo y la contraseña';

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
      'Indica tu correo para restablecer la contraseña';

  @override
  String get loginResetPasswordSuccess =>
      'Enviamos un enlace de restablecimiento a tu correo.';

  @override
  String get loginResetPasswordUnexpectedError =>
      'Error inesperado al restablecer la contraseña';

  @override
  String get loginLoadingGoogle => 'Iniciando con Google...';

  @override
  String get loginLoadingPrepareAccount => 'Preparando tu cuenta...';

  @override
  String get loginFillEmailAndPassword => 'Completa el correo y la contraseña';

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
      'Tu cuenta está desactivada. Ponte en contacto con el soporte.';

  @override
  String get loginErrorCheckingUser => 'Error al verificar el usuario';

  @override
  String get loginEnterEmailToReset =>
      'Introduce tu correo para restablecer la contraseña';

  @override
  String get loginResetLinkSent =>
      'Te enviamos un enlace para restablecer tu contraseña.';

  @override
  String get loginUnexpectedResetError =>
      'Error inesperado al restablecer la contraseña';

  @override
  String get loginSigningInWithGoogle => 'Iniciando sesión con Google...';

  @override
  String get loginPreparingAccount => 'Preparando tu cuenta...';
}
