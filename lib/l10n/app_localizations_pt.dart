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

  @override
  String get fieldRequired => 'Campo obrigatório';

  @override
  String get newProductTitle => 'Novo Produto';

  @override
  String get newProductSectionInfo => 'Informações do produto';

  @override
  String get newProductNameLabel => 'Nome do produto';

  @override
  String get newProductNameHint => 'Ex: Arroz 5kg';

  @override
  String get newProductNameMin => 'Nome deve ter pelo menos 2 caracteres';

  @override
  String get newProductNameMax => 'Nome deve ter no máximo 50 caracteres';

  @override
  String get newProductNameDuplicateValidator =>
      'Nome já existe. Escolha outro.';

  @override
  String get newProductDuplicateNameMessage =>
      'Este nome já existe. Você pode editá-lo.';

  @override
  String newProductNameHelperChars(int count) {
    return '$count/50 caracteres';
  }

  @override
  String get newProductNameHelperNearLimit => '(Quase perto do limite)';

  @override
  String get newProductNameHelperLimitReached => '(limite atingido)';

  @override
  String get newProductQuantityLabel => 'Quantidade';

  @override
  String get newProductPriceLabel => 'Preço (R\$)';

  @override
  String get newProductFillAllFields => 'Preencha todos os campos';

  @override
  String get newProductNameAlreadyExists =>
      'Já existe um produto com este nome';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'Este código de barras já está associado ao produto $name.';
  }

  @override
  String get newProductGenericSaveError => 'Erro ao salvar';

  @override
  String newProductSaveErrorWithMessage(Object error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get newProductImageAdd => 'Adicionar imagem';

  @override
  String get newProductBarcodeLabel => 'Código de barras';

  @override
  String get newProductBarcodeHint => 'Ex: 7891234567890';

  @override
  String get newProductCategoryLabel => 'Categoria';

  @override
  String get newProductCategoryLoading => 'Carregando categorias...';

  @override
  String get newProductCategoryHint => 'Selecione uma categoria';

  @override
  String get newProductCategoryValidator => 'Selecione uma categoria';

  @override
  String get newProductSaveButton => 'Salvar produto';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Senha';

  @override
  String get loginForgotPassword => 'Esqueceu a senha?';

  @override
  String get loginSubmitButton => 'Entrar';

  @override
  String get loginOrContinueWith => 'ou continue com';

  @override
  String get loginWithGoogle => 'Entre com Google';

  @override
  String get loginWithApple => 'Entre com Apple';

  @override
  String get loginWelcomeBackTitle => 'Bem-vindo de volta!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Entre, e gerencie seu estoque com facilidade.';

  @override
  String get loginNoAccountPrefix => 'Ainda não tem conta? ';

  @override
  String get loginCreateNow => 'Criar agora';

  @override
  String get loginErrorFillEmailAndPassword => 'Preencha email e senha';

  @override
  String get loginErrorGetUser => 'Erro ao obter usuário';

  @override
  String get loginErrorUserNotFound => 'Usuário não encontrado';

  @override
  String get loginErrorAccountDisabled => 'Sua conta está desativada.';

  @override
  String get loginDialogAccountDisabledTitle => 'Conta desativada';

  @override
  String get loginDialogAccountDisabledMessage =>
      'Sua conta está desativada. Entre em contato com o suporte.';

  @override
  String get ok => 'OK';

  @override
  String get loginErrorCheckUser => 'Erro ao verificar usuário';

  @override
  String get loginResetPasswordEmailRequired =>
      'Informe seu email para redefinir a senha';

  @override
  String get loginResetPasswordSuccess =>
      'Enviamos um link de redefinição para seu e-mail.';

  @override
  String get loginResetPasswordUnexpectedError =>
      'Erro inesperado ao redefinir senha';

  @override
  String get loginLoadingGoogle => 'Entrando com Google...';

  @override
  String get loginLoadingPrepareAccount => 'Preparando sua conta...';

  @override
  String get loginFillEmailAndPassword => 'Preencha email e senha';

  @override
  String get loginErrorGettingUser => 'Erro ao obter usuário';

  @override
  String get loginUserNotFound => 'Usuário não encontrado';

  @override
  String get loginAccountDisabledShort => 'Sua conta está desativada.';

  @override
  String get loginAccountDisabledTitle => 'Conta desativada';

  @override
  String get loginAccountDisabledMessage =>
      'Sua conta está desativada. Entre em contato com o suporte.';

  @override
  String get loginErrorCheckingUser => 'Erro ao verificar usuário';

  @override
  String get loginEnterEmailToReset =>
      'Informe seu email para redefinir a senha';

  @override
  String get loginResetLinkSent =>
      'Enviamos um link de redefinição para seu e-mail.';

  @override
  String get loginUnexpectedResetError => 'Erro inesperado ao redefinir senha';

  @override
  String get loginSigningInWithGoogle => 'Entrando com Google...';

  @override
  String get loginPreparingAccount => 'Preparando sua conta...';
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

  @override
  String get fieldRequired => 'Campo obrigatório';

  @override
  String get newProductTitle => 'Novo Produto';

  @override
  String get newProductSectionInfo => 'Informações do produto';

  @override
  String get newProductNameLabel => 'Nome do produto';

  @override
  String get newProductNameHint => 'Ex.: Arroz 5kg';

  @override
  String get newProductNameMin => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get newProductNameMax => 'O nome deve ter no máximo 50 caracteres';

  @override
  String get newProductNameDuplicateValidator =>
      'O nome já existe. Escolha outro.';

  @override
  String get newProductDuplicateNameMessage =>
      'Este nome já existe. Pode editá-lo.';

  @override
  String newProductNameHelperChars(int count) {
    return '$count/50 caracteres';
  }

  @override
  String get newProductNameHelperNearLimit => '(Quase no limite)';

  @override
  String get newProductNameHelperLimitReached => '(limite atingido)';

  @override
  String get newProductQuantityLabel => 'Quantidade';

  @override
  String get newProductPriceLabel => 'Preço (R\$)';

  @override
  String get newProductFillAllFields => 'Preencha todos os campos';

  @override
  String get newProductNameAlreadyExists =>
      'Já existe um produto com este nome';

  @override
  String newProductBarcodeAlreadyLinked(Object name) {
    return 'Este código de barras já está associado ao produto $name.';
  }

  @override
  String get newProductGenericSaveError => 'Erro ao guardar';

  @override
  String newProductSaveErrorWithMessage(Object error) {
    return 'Erro ao guardar: $error';
  }

  @override
  String get newProductImageAdd => 'Adicionar imagem';

  @override
  String get newProductBarcodeLabel => 'Código de barras';

  @override
  String get newProductBarcodeHint => 'Ex.: 7891234567890';

  @override
  String get newProductCategoryLabel => 'Categoria';

  @override
  String get newProductCategoryLoading => 'A carregar categorias...';

  @override
  String get newProductCategoryHint => 'Selecione uma categoria';

  @override
  String get newProductCategoryValidator => 'Selecione uma categoria';

  @override
  String get newProductSaveButton => 'Guardar produto';

  @override
  String get loginEmailHint => 'E-mail';

  @override
  String get loginPasswordHint => 'Palavra-passe';

  @override
  String get loginForgotPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get loginSubmitButton => 'Entrar';

  @override
  String get loginOrContinueWith => 'ou continue com';

  @override
  String get loginWithGoogle => 'Entrar com Google';

  @override
  String get loginWithApple => 'Entrar com Apple';

  @override
  String get loginWelcomeBackTitle => 'Bem-vindo de volta!';

  @override
  String get loginWelcomeBackSubtitle =>
      'Entre e faça a gestão do seu stock com facilidade.';

  @override
  String get loginNoAccountPrefix => 'Ainda não tem conta? ';

  @override
  String get loginCreateNow => 'Criar agora';

  @override
  String get loginErrorFillEmailAndPassword =>
      'Preencha o e-mail e a palavra-passe';

  @override
  String get loginErrorGetUser => 'Erro ao obter utilizador';

  @override
  String get loginErrorUserNotFound => 'Utilizador não encontrado';

  @override
  String get loginErrorAccountDisabled => 'A sua conta está desativada.';

  @override
  String get loginDialogAccountDisabledTitle => 'Conta desativada';

  @override
  String get loginDialogAccountDisabledMessage =>
      'A sua conta está desativada. Contacte o suporte.';

  @override
  String get ok => 'OK';

  @override
  String get loginErrorCheckUser => 'Erro ao verificar utilizador';

  @override
  String get loginResetPasswordEmailRequired =>
      'Indique o seu e-mail para redefinir a palavra-passe';

  @override
  String get loginResetPasswordSuccess =>
      'Enviámos um link de redefinição para o seu e-mail.';

  @override
  String get loginResetPasswordUnexpectedError =>
      'Erro inesperado ao redefinir a palavra-passe';

  @override
  String get loginLoadingGoogle => 'A entrar com Google...';

  @override
  String get loginLoadingPrepareAccount => 'A preparar a sua conta...';

  @override
  String get loginFillEmailAndPassword => 'Preencha o email e a palavra-passe';

  @override
  String get loginErrorGettingUser => 'Erro ao obter utilizador';

  @override
  String get loginUserNotFound => 'Utilizador não encontrado';

  @override
  String get loginAccountDisabledShort => 'A sua conta está desativada.';

  @override
  String get loginAccountDisabledTitle => 'Conta desativada';

  @override
  String get loginAccountDisabledMessage =>
      'A sua conta está desativada. Entre em contacto com o suporte.';

  @override
  String get loginErrorCheckingUser => 'Erro ao verificar utilizador';

  @override
  String get loginEnterEmailToReset =>
      'Introduza o seu email para redefinir a palavra-passe';

  @override
  String get loginResetLinkSent =>
      'Enviámos um link de redefinição para o seu email.';

  @override
  String get loginUnexpectedResetError =>
      'Erro inesperado ao redefinir a palavra-passe';

  @override
  String get loginSigningInWithGoogle => 'A iniciar sessão com Google...';

  @override
  String get loginPreparingAccount => 'A preparar a sua conta...';
}
