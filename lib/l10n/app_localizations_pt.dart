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

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get companyEmailFallback => '—';

  @override
  String get companyHeaderTitle => 'Configure sua empresa';

  @override
  String companyHeaderAccountLine(Object email) {
    return 'Conta: $email';
  }

  @override
  String get companyHeaderSubtitle =>
      'Essas informações ajudam a personalizar seu sistema e organizar seus relatórios.';

  @override
  String get companyCompanyHint => 'Razão social / nome da empresa';

  @override
  String get companyHasFantasyNameQuestion => 'Sua empresa tem nome fantasia?';

  @override
  String get companyFantasyNameHint => 'Nome fantasia';

  @override
  String get companyHasOwnerQuestion => 'Deseja informar um responsável?';

  @override
  String get companyOwnerHint => 'Responsável';

  @override
  String get companyHasPhoneQuestion => 'Deseja informar telefone/WhatsApp?';

  @override
  String get companyPhoneHint => 'Telefone / WhatsApp';

  @override
  String get companyBusinessTypeHint => 'Tipo de negócio';

  @override
  String get companyBusinessTypeSelectTitle => 'Selecione o tipo de negócio';

  @override
  String get companyBusinessTypeOtherHint => 'Descreva (até 20 caracteres)';

  @override
  String get companyBusinessTypeRestaurant => 'Restaurante';

  @override
  String get companyBusinessTypeMarket => 'Mercado';

  @override
  String get companyBusinessTypeBakery => 'Padaria';

  @override
  String get companyBusinessTypePharmacy => 'Farmácia';

  @override
  String get companyBusinessTypeStore => 'Loja';

  @override
  String get companyBusinessTypeWorkshop => 'Oficina';

  @override
  String get companyBusinessTypeIndustry => 'Indústria';

  @override
  String get companyBusinessTypeDistributor => 'Distribuidora';

  @override
  String get companyBusinessTypeOther => 'Outro';

  @override
  String get companyAcceptTermsPrefix => 'Eu li e concordo com os';

  @override
  String get companyTermsLink => 'Termos de uso';

  @override
  String get companyAcceptPrivacyPrefix => 'Eu li e concordo com as';

  @override
  String get companyPrivacyLink => 'Políticas de privacidade';

  @override
  String get companyFinishButton => 'Finalizar cadastro';

  @override
  String get companyErrorCompanyRequired =>
      'Preencha a razão social / nome da empresa';

  @override
  String get companyErrorBusinessTypeRequired => 'Selecione o tipo de negócio';

  @override
  String get companyErrorOtherBusinessTypeRequired =>
      'Descreva o tipo de negócio (até 20 caracteres)';

  @override
  String get companyErrorFantasyRequired => 'Preencha o nome fantasia';

  @override
  String get companyErrorOwnerRequired => 'Preencha o responsável';

  @override
  String get companyErrorPhoneRequired => 'Preencha o telefone / WhatsApp';

  @override
  String get companyErrorAcceptLegal =>
      'Você precisa aceitar os Termos e a Política de Privacidade.';

  @override
  String get companyErrorSaveFailed =>
      'Erro ao salvar os dados. Tente novamente.';

  @override
  String get privacyPolicyTitle => 'Política de Privacidade';

  @override
  String get privacyPolicySection1Title => '1. Introdução';

  @override
  String get privacyPolicySection1Body =>
      'O MyStoreDay é um aplicativo de gerenciamento de estoque. Esta Política de Privacidade descreve como as informações dos usuários são tratadas e protegidas.';

  @override
  String get privacyPolicySection2Title => '2. Coleta de Dados';

  @override
  String get privacyPolicySection2Body =>
      'O aplicativo pode coletar informações básicas necessárias para o funcionamento, como dados de login e informações relacionadas aos produtos cadastrados no estoque.';

  @override
  String get privacyPolicySection3Title => '3. Uso das Informações';

  @override
  String get privacyPolicySection3Body =>
      'As informações coletadas são utilizadas exclusivamente para o funcionamento do aplicativo, melhoria da experiência do usuário e controle interno de estoque.';

  @override
  String get privacyPolicySection4Title => '4. Compartilhamento de Dados';

  @override
  String get privacyPolicySection4Body =>
      'O MyStoreDay não compartilha dados pessoais com terceiros, exceto quando exigido por lei.';

  @override
  String get privacyPolicySection5Title => '5. Segurança';

  @override
  String get privacyPolicySection5Body =>
      'Adotamos medidas técnicas e organizacionais para proteger os dados armazenados, reduzindo riscos de acesso não autorizado.';

  @override
  String get privacyPolicySection6Title => '6. Responsabilidades do Usuário';

  @override
  String get privacyPolicySection6Body =>
      'O usuário é responsável por manter suas credenciais de acesso seguras e por todas as atividades realizadas em sua conta.';

  @override
  String get privacyPolicySection7Title => '7. Alterações';

  @override
  String get privacyPolicySection7Body =>
      'Esta Política de Privacidade pode ser atualizada periodicamente. Recomendamos que o usuário revise este documento regularmente.';

  @override
  String get privacyPolicySection8Title => '8. Contato';

  @override
  String get privacyPolicySection8Body =>
      'Em caso de dúvidas sobre esta Política de Privacidade, entre em contato pelo e-mail: contact@mystoreday.com.';

  @override
  String get privacyPolicyLastUpdate => 'Última atualização: Janeiro de 2025';

  @override
  String get termsOfUseTitle => 'Termos de Uso';

  @override
  String get termsOfUseSection1Title => '1. Aceitação dos Termos';

  @override
  String get termsOfUseSection1Body =>
      'Ao utilizar o aplicativo MyStoreDay, o usuário concorda integralmente com estes Termos de Uso. Caso não concorde, recomenda-se não utilizar o aplicativo.';

  @override
  String get termsOfUseSection2Title => '2. Finalidade do Aplicativo';

  @override
  String get termsOfUseSection2Body =>
      'O MyStoreDay tem como finalidade auxiliar no gerenciamento de estoque, permitindo o controle de produtos, quantidades e informações relacionadas.';

  @override
  String get termsOfUseSection3Title => '3. Cadastro e Responsabilidade';

  @override
  String get termsOfUseSection3Body =>
      'O usuário é responsável pelas informações fornecidas durante o cadastro e por manter a confidencialidade de seus dados de acesso.';

  @override
  String get termsOfUseSection4Title => '4. Uso Adequado';

  @override
  String get termsOfUseSection4Body =>
      'É proibido utilizar o aplicativo para fins ilícitos, fraudulentos ou que possam comprometer a segurança e o funcionamento do sistema.';

  @override
  String get termsOfUseSection5Title => '5. Limitação de Responsabilidade';

  @override
  String get termsOfUseSection5Body =>
      'O MyStoreDay não se responsabiliza por perdas, danos ou prejuízos decorrentes do uso inadequado do aplicativo ou de informações incorretas inseridas pelo usuário.';

  @override
  String get termsOfUseSection6Title => '6. Disponibilidade';

  @override
  String get termsOfUseSection6Body =>
      'O aplicativo pode sofrer interrupções temporárias para manutenção, atualizações ou por fatores externos fora do controle do desenvolvedor.';

  @override
  String get termsOfUseSection7Title => '7. Alterações nos Termos';

  @override
  String get termsOfUseSection7Body =>
      'Os Termos de Uso podem ser alterados a qualquer momento. Recomenda-se que o usuário revise este documento periodicamente.';

  @override
  String get termsOfUseSection8Title => '8. Contato';

  @override
  String get termsOfUseSection8Body =>
      'Em caso de dúvidas relacionadas a estes Termos de Uso, entre em contato pelo e-mail: contact@mystoreday.com.';

  @override
  String get termsOfUseLastUpdate => 'Última atualização: Janeiro de 2025';

  @override
  String get reportsTitle => 'Relatórios';

  @override
  String get relatoriosPercentAll => 'Todos';

  @override
  String get reportsPeriodDay => 'Dia';

  @override
  String get relatoriosCumulativeMovementsTitle =>
      'Movimentações cumulativas ao longo do dia';

  @override
  String get relatoriosEntries => 'Entradas';

  @override
  String get relatoriosExits => 'Saídas';

  @override
  String get relatoriosAll => 'Todos';

  @override
  String get relatoriosTimeAxisLabel => 'Horário';

  @override
  String get relatoriosEntry => 'Entrada';

  @override
  String get relatoriosExit => 'Saída';

  @override
  String relatoriosPieTitle(String modeLabel) {
    return 'Distribuição percentual — $modeLabel';
  }

  @override
  String get relatoriosChartLine => 'Linha';

  @override
  String get relatoriosChartPercent => 'Pizza';

  @override
  String get relatoriosToday => 'Hoje';

  @override
  String relatoriosNoMovementsForDate(String dateText) {
    return 'Nenhuma movimentação em $dateText';
  }

  @override
  String get relatoriosSelectAnotherDateHint =>
      'Selecione outra data ou adicione novas movimentações.';

  @override
  String relatoriosEntryWithValue(int value) {
    return 'Entrada: $value';
  }

  @override
  String relatoriosExitWithValue(int value) {
    return 'Saída: $value';
  }

  @override
  String relatoriosEntriesWithValue(int value) {
    return 'Entradas: $value';
  }

  @override
  String relatoriosExitsWithValue(int value) {
    return 'Saídas: $value';
  }

  @override
  String get relatoriosMovedProductsTitle => 'Produtos movimentados';

  @override
  String get relatoriosExecutiveSummaryTitle => 'Resumo executivo do dia';

  @override
  String get relatoriosNetBalance => 'Saldo líquido';

  @override
  String get relatoriosExportReport => 'Exportar relatório';

  @override
  String relatoriosLineTooltip(String label, num value) {
    return '$label: $value';
  }
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

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get companyEmailFallback => '—';

  @override
  String get companyHeaderTitle => 'Configure a sua empresa';

  @override
  String companyHeaderAccountLine(Object email) {
    return 'Conta: $email';
  }

  @override
  String get companyHeaderSubtitle =>
      'Estas informações ajudam a personalizar o seu sistema e a organizar os seus relatórios.';

  @override
  String get companyCompanyHint => 'Razão social / nome da empresa';

  @override
  String get companyHasFantasyNameQuestion =>
      'A sua empresa tem nome comercial?';

  @override
  String get companyFantasyNameHint => 'Nome comercial';

  @override
  String get companyHasOwnerQuestion => 'Pretende indicar um responsável?';

  @override
  String get companyOwnerHint => 'Responsável';

  @override
  String get companyHasPhoneQuestion => 'Pretende indicar telefone/WhatsApp?';

  @override
  String get companyPhoneHint => 'Telefone / WhatsApp';

  @override
  String get companyBusinessTypeHint => 'Tipo de negócio';

  @override
  String get companyBusinessTypeSelectTitle => 'Selecione o tipo de negócio';

  @override
  String get companyBusinessTypeOtherHint => 'Descreva (até 20 caracteres)';

  @override
  String get companyBusinessTypeRestaurant => 'Restaurante';

  @override
  String get companyBusinessTypeMarket => 'Mercado';

  @override
  String get companyBusinessTypeBakery => 'Padaria';

  @override
  String get companyBusinessTypePharmacy => 'Farmácia';

  @override
  String get companyBusinessTypeStore => 'Loja';

  @override
  String get companyBusinessTypeWorkshop => 'Oficina';

  @override
  String get companyBusinessTypeIndustry => 'Indústria';

  @override
  String get companyBusinessTypeDistributor => 'Distribuidora';

  @override
  String get companyBusinessTypeOther => 'Outro';

  @override
  String get companyAcceptTermsPrefix => 'Li e concordo com os';

  @override
  String get companyTermsLink => 'Termos de utilização';

  @override
  String get companyAcceptPrivacyPrefix => 'Li e concordo com a';

  @override
  String get companyPrivacyLink => 'Política de privacidade';

  @override
  String get companyFinishButton => 'Concluir registo';

  @override
  String get companyErrorCompanyRequired =>
      'Preencha a razão social / nome da empresa';

  @override
  String get companyErrorBusinessTypeRequired => 'Selecione o tipo de negócio';

  @override
  String get companyErrorOtherBusinessTypeRequired =>
      'Descreva o tipo de negócio (até 20 caracteres)';

  @override
  String get companyErrorFantasyRequired => 'Preencha o nome comercial';

  @override
  String get companyErrorOwnerRequired => 'Preencha o responsável';

  @override
  String get companyErrorPhoneRequired => 'Preencha o telefone / WhatsApp';

  @override
  String get companyErrorAcceptLegal =>
      'Precisa de aceitar os Termos e a Política de Privacidade.';

  @override
  String get companyErrorSaveFailed =>
      'Erro ao guardar os dados. Tente novamente.';

  @override
  String get privacyPolicyTitle => 'Política de Privacidade';

  @override
  String get privacyPolicySection1Title => '1. Introdução';

  @override
  String get privacyPolicySection1Body =>
      'O ControllStok é uma aplicação de gestão de stock. Esta Política de Privacidade descreve como as informações dos utilizadores são tratadas e protegidas.';

  @override
  String get privacyPolicySection2Title => '2. Recolha de Dados';

  @override
  String get privacyPolicySection2Body =>
      'A aplicação pode recolher informações básicas necessárias ao seu funcionamento, como dados de início de sessão e informações relacionadas com os produtos registados no stock.';

  @override
  String get privacyPolicySection3Title => '3. Utilização das Informações';

  @override
  String get privacyPolicySection3Body =>
      'As informações recolhidas são utilizadas exclusivamente para o funcionamento da aplicação, melhoria da experiência do utilizador e controlo interno de stock.';

  @override
  String get privacyPolicySection4Title => '4. Partilha de Dados';

  @override
  String get privacyPolicySection4Body =>
      'O ControllStok não partilha dados pessoais com terceiros, excepto quando exigido por lei.';

  @override
  String get privacyPolicySection5Title => '5. Segurança';

  @override
  String get privacyPolicySection5Body =>
      'Adoptamos medidas técnicas e organizacionais para proteger os dados armazenados, reduzindo o risco de acesso não autorizado.';

  @override
  String get privacyPolicySection6Title => '6. Responsabilidades do Utilizador';

  @override
  String get privacyPolicySection6Body =>
      'O utilizador é responsável por manter as suas credenciais de acesso seguras e por todas as actividades realizadas na sua conta.';

  @override
  String get privacyPolicySection7Title => '7. Alterações';

  @override
  String get privacyPolicySection7Body =>
      'Esta Política de Privacidade pode ser actualizada periodicamente. Recomendamos que o utilizador reveja este documento regularmente.';

  @override
  String get privacyPolicySection8Title => '8. Contactos';

  @override
  String get privacyPolicySection8Body =>
      'Em caso de dúvidas sobre esta Política de Privacidade, entre em contacto através do e-mail: contact@mystoreday.com.';

  @override
  String get privacyPolicyLastUpdate => 'Última actualização: Janeiro de 2025';

  @override
  String get termsOfUseTitle => 'Termos de Utilização';

  @override
  String get termsOfUseSection1Title => '1. Aceitação dos Termos';

  @override
  String get termsOfUseSection1Body =>
      'Ao utilizar a aplicação MyStoreDay, o utilizador concorda integralmente com estes Termos de Utilização. Caso não concorde, recomenda-se que não utilize a aplicação.';

  @override
  String get termsOfUseSection2Title => '2. Finalidade da Aplicação';

  @override
  String get termsOfUseSection2Body =>
      'O MyStoreDay tem como finalidade auxiliar na gestão de stock, permitindo o controlo de produtos, quantidades e informações associadas.';

  @override
  String get termsOfUseSection3Title => '3. Registo e Responsabilidade';

  @override
  String get termsOfUseSection3Body =>
      'O utilizador é responsável pelas informações fornecidas no registo e por manter a confidencialidade dos seus dados de acesso.';

  @override
  String get termsOfUseSection4Title => '4. Utilização Adequada';

  @override
  String get termsOfUseSection4Body =>
      'É proibida a utilização da aplicação para fins ilícitos, fraudulentos ou que possam comprometer a segurança e o funcionamento do sistema.';

  @override
  String get termsOfUseSection5Title => '5. Limitação de Responsabilidade';

  @override
  String get termsOfUseSection5Body =>
      'O MyStoreDay não se responsabiliza por perdas, danos ou prejuízos resultantes da utilização inadequada da aplicação ou de informações incorrectas fornecidas pelo utilizador.';

  @override
  String get termsOfUseSection6Title => '6. Disponibilidade';

  @override
  String get termsOfUseSection6Body =>
      'A aplicação pode sofrer interrupções temporárias para manutenção, actualizações ou factores externos fora do controlo do desenvolvedor.';

  @override
  String get termsOfUseSection7Title => '7. Alterações aos Termos';

  @override
  String get termsOfUseSection7Body =>
      'Os Termos de Utilização podem ser alterados a qualquer momento. Recomenda-se que o utilizador reveja este documento regularmente.';

  @override
  String get termsOfUseSection8Title => '8. Contacto';

  @override
  String get termsOfUseSection8Body =>
      'Em caso de dúvidas relacionadas com estes Termos de Utilização, entre em contacto através do e-mail: contact@mystoreday.com.';

  @override
  String get termsOfUseLastUpdate => 'Última actualização: Janeiro de 2025';

  @override
  String get reportsTitle => 'Relatórios';

  @override
  String get relatoriosPercentAll => 'Todos';

  @override
  String get reportsPeriodDay => 'Dia';

  @override
  String get relatoriosCumulativeMovementsTitle =>
      'Movimentações cumulativas ao longo do dia';

  @override
  String get relatoriosEntries => 'Entradas';

  @override
  String get relatoriosExits => 'Saídas';

  @override
  String get relatoriosAll => 'Todos';

  @override
  String get relatoriosTimeAxisLabel => 'Hora';

  @override
  String get relatoriosEntry => 'Entrada';

  @override
  String get relatoriosExit => 'Saída';

  @override
  String relatoriosPieTitle(String modeLabel) {
    return 'Distribuição percentual — $modeLabel';
  }

  @override
  String get relatoriosChartLine => 'Linha';

  @override
  String get relatoriosChartPercent => 'Circular';

  @override
  String get relatoriosToday => 'Hoje';

  @override
  String relatoriosNoMovementsForDate(String dateText) {
    return 'Nenhuma movimentação em $dateText';
  }

  @override
  String get relatoriosSelectAnotherDateHint =>
      'Seleccione outra data ou adicione novas movimentações.';

  @override
  String relatoriosEntryWithValue(int value) {
    return 'Entrada: $value';
  }

  @override
  String relatoriosExitWithValue(int value) {
    return 'Saída: $value';
  }

  @override
  String relatoriosEntriesWithValue(int value) {
    return 'Entradas: $value';
  }

  @override
  String relatoriosExitsWithValue(int value) {
    return 'Saídas: $value';
  }

  @override
  String get relatoriosMovedProductsTitle => 'Produtos movimentados';

  @override
  String get relatoriosExecutiveSummaryTitle => 'Resumo executivo do dia';

  @override
  String get relatoriosNetBalance => 'Saldo líquido';

  @override
  String get relatoriosExportReport => 'Exportar relatório';

  @override
  String relatoriosLineTooltip(String label, num value) {
    return '$label: $value';
  }
}
