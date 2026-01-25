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

  @override
  String get registerHeaderTitle => 'Crie sua conta';

  @override
  String get registerHeaderSubtitle =>
      'Tenha controle total do seu estoque desde o primeiro dia.';

  @override
  String get registerGoogleGenericFail =>
      'Falha ao entrar com Google. Tente novamente.';

  @override
  String get registerCancelFail =>
      'Não foi possível cancelar agora. Tente novamente.';

  @override
  String get registerEmailRequired => 'Preencha o e-mail.';

  @override
  String get registerSendVerificationUnexpectedError =>
      'Erro inesperado ao enviar verificação.';

  @override
  String get registerVerificationEmailResent =>
      'E-mail reenviado. Verifique a caixa de entrada (e spam).';

  @override
  String get registerResendVerificationUnexpectedError =>
      'Erro inesperado ao reenviar verificação.';

  @override
  String get registerChangeEmailHint =>
      'Você pode alterar o e-mail e tentar novamente.';

  @override
  String get registerChangeEmailFail =>
      'Não foi possível alterar agora. Tente novamente.';

  @override
  String get registerPasswordAndConfirmRequired =>
      'Preencha a senha e a confirmação.';

  @override
  String get registerPasswordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get registerCreateAccountUnexpectedError =>
      'Erro inesperado ao criar conta.';

  @override
  String get registerErrorEmailAlreadyInUse => 'Este e-mail já está em uso.';

  @override
  String get registerErrorWeakPassword => 'Senha fraca.';

  @override
  String get registerErrorNoConnection => 'Sem conexão. Tente novamente.';

  @override
  String get registerErrorTooManyRequests =>
      'Muitas tentativas. Aguarde um pouco.';

  @override
  String get registerErrorGeneric => 'Erro ao continuar o cadastro.';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailValidatorRequired => 'Informe o email';

  @override
  String get registerFooterHaveAccount => 'Já possui conta? ';

  @override
  String get registerFooterLogin => 'Fazer login';

  @override
  String get registerPasswordLabel => 'Senha';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar senha';

  @override
  String get registerContinueWithGoogle => 'Continue com Google';

  @override
  String get registerContinueWithApple => 'Continue com Apple';

  @override
  String get registerGoogleCancelled => 'Login com Google cancelado.';

  @override
  String get registerGoogleUserNotFound =>
      'Não foi possível obter o usuário do Google.';

  @override
  String get registerInvalidEmail => 'E-mail inválido.';

  @override
  String get registerVerificationEmailSent =>
      'E-mail de verificação enviado. Verifique sua caixa de entrada (e spam).';

  @override
  String get registerVerifyEmailBeforeContinue =>
      'Verifique seu e-mail antes de continuar.';

  @override
  String get registerPasswordMustBeStrong =>
      'A senha precisa ser forte para criar a conta.';

  @override
  String get registerInvalidSessionRedoEmailVerification =>
      'Sessão inválida. Refaça a verificação do e-mail.';

  @override
  String get registerEnteringWithGoogleLoading => 'Entrando com Google...';

  @override
  String get registerLoginNotCompleted =>
      'Login não concluído. Tente novamente.';

  @override
  String get registerPreparingAccountLoading => 'Preparando sua conta...';

  @override
  String get registerEmailHint => 'Email';

  @override
  String get registerSendVerificationButton => 'Enviar e-mail de verificação';

  @override
  String get registerResendVerificationButton =>
      'Reenviar e-mail de verificação';

  @override
  String registerResendInSeconds(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String get registerNotThisEmail => 'Não é esse e-mail?';

  @override
  String get registerOrContinueWith => 'ou continue com';

  @override
  String get registerAppleNotImplemented => 'Apple ainda não implementado.';

  @override
  String get registerPasswordHint => 'Senha';

  @override
  String get registerConfirmPasswordHint => 'Confirmar senha';

  @override
  String get registerCreateAccountButton => 'Criar conta';

  @override
  String get registerDeleteRegistration => 'Excluir cadastro';

  @override
  String get registerPasswordStrengthVeryWeak => 'Muito fraca';

  @override
  String get registerPasswordStrengthWeak => 'Fraca';

  @override
  String get registerPasswordStrengthStrong => 'Forte';

  @override
  String registerPasswordStrengthLine(String label) {
    return 'Força da senha: $label';
  }

  @override
  String get registerPasswordTip =>
      'Dica: 8+ chars, maiúscula, minúscula, número e símbolo.';

  @override
  String get registerEmailVerifiedStatus => 'E-mail verificado.';

  @override
  String get registerAwaitingUserVerification =>
      'Aguardando verificação do usuário';

  @override
  String get registerRestoringRegistration => 'Restaurando seu cadastro...';
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
  String get authChoiceRegister => 'Criar conta';

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
      'Utilizar automaticamente o idioma do seu dispositivo';

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
      'Deseja aplicar este idioma agora? Pode alterar novamente quando quiser.';

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
  String get newProductNameHint => 'Ex: Arroz 5 kg';

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
  String get newProductNameHelperNearLimit => '(Quase perto do limite)';

  @override
  String get newProductNameHelperLimitReached => '(limite atingido)';

  @override
  String get newProductQuantityLabel => 'Quantidade';

  @override
  String get newProductPriceLabel => 'Preço (€)';

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
  String get newProductBarcodeHint => 'Ex: 7891234567890';

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
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Palavra-passe';

  @override
  String get loginForgotPassword => 'Esqueceu a palavra-passe?';

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
  String get loginErrorFillEmailAndPassword => 'Preencha email e palavra-passe';

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
      'A sua conta está desativada. Entre em contacto com o suporte.';

  @override
  String get ok => 'OK';

  @override
  String get loginErrorCheckUser => 'Erro ao verificar utilizador';

  @override
  String get loginResetPasswordEmailRequired =>
      'Informe o seu email para redefinir a palavra-passe';

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
  String get loginFillEmailAndPassword => 'Preencha email e palavra-passe';

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
      'Informe o seu email para redefinir a palavra-passe';

  @override
  String get loginResetLinkSent =>
      'Enviámos um link de redefinição para o seu e-mail.';

  @override
  String get loginUnexpectedResetError =>
      'Erro inesperado ao redefinir a palavra-passe';

  @override
  String get loginSigningInWithGoogle => 'A entrar com Google...';

  @override
  String get loginPreparingAccount => 'A preparar a sua conta...';

  @override
  String get registerHeaderTitle => 'Crie a sua conta';

  @override
  String get registerHeaderSubtitle =>
      'Tenha controlo total do seu stock desde o primeiro dia.';

  @override
  String get registerGoogleGenericFail =>
      'Falha ao entrar com Google. Tente novamente.';

  @override
  String get registerCancelFail =>
      'Não foi possível cancelar agora. Tente novamente.';

  @override
  String get registerEmailRequired => 'Preencha o e-mail.';

  @override
  String get registerSendVerificationUnexpectedError =>
      'Erro inesperado ao enviar verificação.';

  @override
  String get registerVerificationEmailResent =>
      'E-mail reenviado. Verifique a caixa de entrada (e spam).';

  @override
  String get registerResendVerificationUnexpectedError =>
      'Erro inesperado ao reenviar verificação.';

  @override
  String get registerChangeEmailHint =>
      'Pode alterar o e-mail e tentar novamente.';

  @override
  String get registerChangeEmailFail =>
      'Não foi possível alterar agora. Tente novamente.';

  @override
  String get registerPasswordAndConfirmRequired =>
      'Preencha a palavra-passe e a confirmação.';

  @override
  String get registerPasswordsDoNotMatch => 'As palavras-passe não coincidem.';

  @override
  String get registerCreateAccountUnexpectedError =>
      'Erro inesperado ao criar conta.';

  @override
  String get registerErrorEmailAlreadyInUse => 'Este e-mail já está em uso.';

  @override
  String get registerErrorWeakPassword => 'Palavra-passe fraca.';

  @override
  String get registerErrorNoConnection => 'Sem ligação. Tente novamente.';

  @override
  String get registerErrorTooManyRequests =>
      'Muitas tentativas. Aguarde um pouco.';

  @override
  String get registerErrorGeneric => 'Erro ao continuar o registo.';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailValidatorRequired => 'Informe o email';

  @override
  String get registerFooterHaveAccount => 'Já possui conta? ';

  @override
  String get registerFooterLogin => 'Iniciar sessão';

  @override
  String get registerPasswordLabel => 'Palavra-passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar palavra-passe';

  @override
  String get registerContinueWithGoogle => 'Continuar com Google';

  @override
  String get registerContinueWithApple => 'Continuar com Apple';

  @override
  String get registerGoogleCancelled => 'Login com Google cancelado.';

  @override
  String get registerGoogleUserNotFound =>
      'Não foi possível obter o utilizador do Google.';

  @override
  String get registerInvalidEmail => 'E-mail inválido.';

  @override
  String get registerVerificationEmailSent =>
      'E-mail de verificação enviado. Verifique a sua caixa de entrada (e spam).';

  @override
  String get registerVerifyEmailBeforeContinue =>
      'Verifique o seu e-mail antes de continuar.';

  @override
  String get registerPasswordMustBeStrong =>
      'A palavra-passe precisa de ser forte para criar a conta.';

  @override
  String get registerInvalidSessionRedoEmailVerification =>
      'Sessão inválida. Refazer a verificação do e-mail.';

  @override
  String get registerEnteringWithGoogleLoading => 'A entrar com Google...';

  @override
  String get registerLoginNotCompleted =>
      'Login não concluído. Tente novamente.';

  @override
  String get registerPreparingAccountLoading => 'A preparar a sua conta...';

  @override
  String get registerEmailHint => 'Email';

  @override
  String get registerSendVerificationButton => 'Enviar e-mail de verificação';

  @override
  String get registerResendVerificationButton =>
      'Reenviar e-mail de verificação';

  @override
  String registerResendInSeconds(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String get registerNotThisEmail => 'Não é este e-mail?';

  @override
  String get registerOrContinueWith => 'ou continue com';

  @override
  String get registerAppleNotImplemented => 'Apple ainda não implementado.';

  @override
  String get registerPasswordHint => 'Palavra-passe';

  @override
  String get registerConfirmPasswordHint => 'Confirmar palavra-passe';

  @override
  String get registerCreateAccountButton => 'Criar conta';

  @override
  String get registerDeleteRegistration => 'Excluir cadastro';

  @override
  String get registerPasswordStrengthVeryWeak => 'Muito fraca';

  @override
  String get registerPasswordStrengthWeak => 'Fraca';

  @override
  String get registerPasswordStrengthStrong => 'Forte';

  @override
  String registerPasswordStrengthLine(String label) {
    return 'Força da senha: $label';
  }

  @override
  String get registerPasswordTip =>
      'Dica: 8+ chars, maiúscula, minúscula, número e símbolo.';

  @override
  String get registerEmailVerifiedStatus => 'E-mail verificado.';

  @override
  String get registerAwaitingUserVerification =>
      'Aguardando verificação do usuário';

  @override
  String get registerRestoringRegistration => 'Restaurando seu cadastro...';
}
