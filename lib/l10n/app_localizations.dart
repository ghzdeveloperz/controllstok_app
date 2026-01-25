import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('de', 'CH'),
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'PT'),
  ];

  /// GERAL / APP — Título principal do aplicativo
  ///
  /// In pt, this message translates to:
  /// **'MyStoreDay'**
  String get appTitle;

  /// GERAL / APP — Saudação genérica
  ///
  /// In pt, this message translates to:
  /// **'Olá'**
  String get hello;

  /// GERAL / APP — Saudação com nome da empresa
  ///
  /// In pt, this message translates to:
  /// **'Olá, {company}.'**
  String helloCompany(Object company);

  /// TELA AUTH_CHOICE — Texto do botão Login
  ///
  /// In pt, this message translates to:
  /// **'Login'**
  String get authChoiceLogin;

  /// TELA AUTH_CHOICE — Texto do botão Cadastrar
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get authChoiceRegister;

  /// TELA ESTOQUE / HOME — Título do resumo do estoque
  ///
  /// In pt, this message translates to:
  /// **'Seu estoque hoje'**
  String get stockToday;

  /// TELA ESTOQUE / HOME — Placeholder do campo de busca de produtos
  ///
  /// In pt, this message translates to:
  /// **'Buscar produto...'**
  String get searchProductHint;

  /// TELA ESTOQUE / HOME — Filtro 'Todos' (categorias)
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get allCategory;

  /// TELA ESTOQUE / HOME — Mensagem quando não há produtos
  ///
  /// In pt, this message translates to:
  /// **'Nenhum produto encontrado'**
  String get noProductsFound;

  /// TELA IDIOMA — Título da tela de idioma
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

  /// TELA IDIOMA — Opção para usar idioma do sistema
  ///
  /// In pt, this message translates to:
  /// **'Idioma do sistema'**
  String get languageSystem;

  /// TELA IDIOMA — Descrição do idioma do sistema
  ///
  /// In pt, this message translates to:
  /// **'Usar o idioma do seu dispositivo automaticamente'**
  String get languageSystemDescription;

  /// TELA IDIOMA — Placeholder do campo de busca de idioma
  ///
  /// In pt, this message translates to:
  /// **'Buscar idioma...'**
  String get searchLanguageHint;

  /// TELA IDIOMA — Título da seção de preferências
  ///
  /// In pt, this message translates to:
  /// **'Preferências'**
  String get languageSectionPreferences;

  /// TELA IDIOMA — Título da seção de idiomas disponíveis
  ///
  /// In pt, this message translates to:
  /// **'Idiomas disponíveis'**
  String get languageSectionAvailable;

  /// TELA IDIOMA — Label exibido quando idioma está selecionado
  ///
  /// In pt, this message translates to:
  /// **'Selecionado'**
  String get selectedLabel;

  /// TELA IDIOMA — Mensagem quando a busca não encontra idiomas
  ///
  /// In pt, this message translates to:
  /// **'Nenhum idioma encontrado'**
  String get noLanguageFound;

  /// MODAL IDIOMA — Título do modal de confirmação
  ///
  /// In pt, this message translates to:
  /// **'Confirmar alteração'**
  String get languageConfirmTitle;

  /// MODAL IDIOMA — Mensagem do modal de confirmação
  ///
  /// In pt, this message translates to:
  /// **'Deseja aplicar este idioma agora? Você pode alterar novamente quando quiser.'**
  String get languageConfirmMessage;

  /// MODAL / BOTÕES — Ação de confirmar/aplicar
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// MODAL / BOTÕES — Ação de cancelar/voltar
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// VALIDAÇÃO — Mensagem padrão de campo obrigatório
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get fieldRequired;

  /// TELA NOVO_PRODUTO — Título do AppBar
  ///
  /// In pt, this message translates to:
  /// **'Novo Produto'**
  String get newProductTitle;

  /// TELA NOVO_PRODUTO — Título da seção principal
  ///
  /// In pt, this message translates to:
  /// **'Informações do produto'**
  String get newProductSectionInfo;

  /// TELA NOVO_PRODUTO — Label do campo nome
  ///
  /// In pt, this message translates to:
  /// **'Nome do produto'**
  String get newProductNameLabel;

  /// TELA NOVO_PRODUTO — Hint do campo nome
  ///
  /// In pt, this message translates to:
  /// **'Ex: Arroz 5kg'**
  String get newProductNameHint;

  /// VALIDAÇÃO — Nome mínimo
  ///
  /// In pt, this message translates to:
  /// **'Nome deve ter pelo menos 2 caracteres'**
  String get newProductNameMin;

  /// VALIDAÇÃO — Nome máximo
  ///
  /// In pt, this message translates to:
  /// **'Nome deve ter no máximo 50 caracteres'**
  String get newProductNameMax;

  /// VALIDAÇÃO — Nome duplicado
  ///
  /// In pt, this message translates to:
  /// **'Nome já existe. Escolha outro.'**
  String get newProductNameDuplicateValidator;

  /// TELA NOVO_PRODUTO — Mensagem auxiliar quando nome está duplicado
  ///
  /// In pt, this message translates to:
  /// **'Este nome já existe. Você pode editá-lo.'**
  String get newProductDuplicateNameMessage;

  /// TELA NOVO_PRODUTO — Helper contagem de caracteres do nome
  ///
  /// In pt, this message translates to:
  /// **'{count}/50 caracteres'**
  String newProductNameHelperChars(int count);

  /// TELA NOVO_PRODUTO — Helper quando está perto do limite
  ///
  /// In pt, this message translates to:
  /// **'(Quase perto do limite)'**
  String get newProductNameHelperNearLimit;

  /// TELA NOVO_PRODUTO — Helper quando atingiu o limite
  ///
  /// In pt, this message translates to:
  /// **'(limite atingido)'**
  String get newProductNameHelperLimitReached;

  /// TELA NOVO_PRODUTO — Label do campo quantidade
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get newProductQuantityLabel;

  /// TELA NOVO_PRODUTO — Label do campo preço
  ///
  /// In pt, this message translates to:
  /// **'Preço (R\$)'**
  String get newProductPriceLabel;

  /// SNACKBAR — Falta preencher dados
  ///
  /// In pt, this message translates to:
  /// **'Preencha todos os campos'**
  String get newProductFillAllFields;

  /// SNACKBAR — Nome de produto já existe
  ///
  /// In pt, this message translates to:
  /// **'Já existe um produto com este nome'**
  String get newProductNameAlreadyExists;

  /// SNACKBAR — Código de barras já cadastrado em outro produto
  ///
  /// In pt, this message translates to:
  /// **'Este código de barras já está associado ao produto {name}.'**
  String newProductBarcodeAlreadyLinked(Object name);

  /// SNACKBAR — Erro genérico ao salvar
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar'**
  String get newProductGenericSaveError;

  /// SNACKBAR — Erro ao salvar com detalhes
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar: {error}'**
  String newProductSaveErrorWithMessage(Object error);

  /// TELA NOVO_PRODUTO — Botão/ação para adicionar imagem do produto
  ///
  /// In pt, this message translates to:
  /// **'Adicionar imagem'**
  String get newProductImageAdd;

  /// TELA NOVO_PRODUTO — Label do campo de código de barras
  ///
  /// In pt, this message translates to:
  /// **'Código de barras'**
  String get newProductBarcodeLabel;

  /// TELA NOVO_PRODUTO — Hint/placeholder do campo de código de barras
  ///
  /// In pt, this message translates to:
  /// **'Ex: 7891234567890'**
  String get newProductBarcodeHint;

  /// TELA NOVO_PRODUTO — Label do campo de categoria
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get newProductCategoryLabel;

  /// TELA NOVO_PRODUTO — Texto exibido enquanto carrega categorias
  ///
  /// In pt, this message translates to:
  /// **'Carregando categorias...'**
  String get newProductCategoryLoading;

  /// TELA NOVO_PRODUTO — Hint do seletor de categoria
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma categoria'**
  String get newProductCategoryHint;

  /// VALIDAÇÃO — Mensagem quando a categoria não foi selecionada
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma categoria'**
  String get newProductCategoryValidator;

  /// TELA NOVO_PRODUTO — Texto do botão de salvar
  ///
  /// In pt, this message translates to:
  /// **'Salvar produto'**
  String get newProductSaveButton;

  /// TELA LOGIN — Hint do campo email
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get loginEmailHint;

  /// TELA LOGIN — Hint do campo senha
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPasswordHint;

  /// TELA LOGIN — Botão/link de reset de senha
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get loginForgotPassword;

  /// TELA LOGIN — Texto do botão principal de entrar
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSubmitButton;

  /// TELA LOGIN — Divisor social (ou continue com)
  ///
  /// In pt, this message translates to:
  /// **'ou continue com'**
  String get loginOrContinueWith;

  /// TELA LOGIN — Botão social Google
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google'**
  String get loginWithGoogle;

  /// TELA LOGIN — Botão social Apple
  ///
  /// In pt, this message translates to:
  /// **'Entre com Apple'**
  String get loginWithApple;

  /// TELA LOGIN — Título do header
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta!'**
  String get loginWelcomeBackTitle;

  /// TELA LOGIN — Subtítulo do header
  ///
  /// In pt, this message translates to:
  /// **'Entre, e gerencie seu estoque com facilidade.'**
  String get loginWelcomeBackSubtitle;

  /// TELA LOGIN — Texto antes do link para cadastro
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem conta? '**
  String get loginNoAccountPrefix;

  /// TELA LOGIN — Link/botão para ir ao cadastro
  ///
  /// In pt, this message translates to:
  /// **'Criar agora'**
  String get loginCreateNow;

  /// LOGIN — Erro quando email/senha estão vazios
  ///
  /// In pt, this message translates to:
  /// **'Preencha email e senha'**
  String get loginErrorFillEmailAndPassword;

  /// LOGIN — Erro quando currentUser é null após login
  ///
  /// In pt, this message translates to:
  /// **'Erro ao obter usuário'**
  String get loginErrorGetUser;

  /// LOGIN — Erro quando doc do usuário não existe no Firestore
  ///
  /// In pt, this message translates to:
  /// **'Usuário não encontrado'**
  String get loginErrorUserNotFound;

  /// LOGIN — Erro quando conta está desativada
  ///
  /// In pt, this message translates to:
  /// **'Sua conta está desativada.'**
  String get loginErrorAccountDisabled;

  /// DIALOG — Título do modal de conta desativada
  ///
  /// In pt, this message translates to:
  /// **'Conta desativada'**
  String get loginDialogAccountDisabledTitle;

  /// DIALOG — Mensagem do modal de conta desativada
  ///
  /// In pt, this message translates to:
  /// **'Sua conta está desativada. Entre em contato com o suporte.'**
  String get loginDialogAccountDisabledMessage;

  /// GERAL / BOTÕES — Ação de confirmar/fechar
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// LOGIN — Erro genérico ao checar status do usuário
  ///
  /// In pt, this message translates to:
  /// **'Erro ao verificar usuário'**
  String get loginErrorCheckUser;

  /// LOGIN — Erro ao tentar resetar senha sem email
  ///
  /// In pt, this message translates to:
  /// **'Informe seu email para redefinir a senha'**
  String get loginResetPasswordEmailRequired;

  /// LOGIN — Mensagem de sucesso no reset de senha
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um link de redefinição para seu e-mail.'**
  String get loginResetPasswordSuccess;

  /// LOGIN — Erro inesperado no reset de senha
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado ao redefinir senha'**
  String get loginResetPasswordUnexpectedError;

  /// LOADER — Texto enquanto faz login com Google
  ///
  /// In pt, this message translates to:
  /// **'Entrando com Google...'**
  String get loginLoadingGoogle;

  /// LOADER — Texto enquanto executa warmup/bootstrap após login
  ///
  /// In pt, this message translates to:
  /// **'Preparando sua conta...'**
  String get loginLoadingPrepareAccount;

  /// LOGIN — Erro quando email ou senha estão vazios (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Preencha email e senha'**
  String get loginFillEmailAndPassword;

  /// LOGIN — Erro ao obter usuário autenticado
  ///
  /// In pt, this message translates to:
  /// **'Erro ao obter usuário'**
  String get loginErrorGettingUser;

  /// LOGIN — Usuário não encontrado no Firestore (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Usuário não encontrado'**
  String get loginUserNotFound;

  /// LOGIN — Conta desativada (mensagem curta)
  ///
  /// In pt, this message translates to:
  /// **'Sua conta está desativada.'**
  String get loginAccountDisabledShort;

  /// LOGIN — Título do modal de conta desativada (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Conta desativada'**
  String get loginAccountDisabledTitle;

  /// LOGIN — Mensagem do modal de conta desativada (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Sua conta está desativada. Entre em contato com o suporte.'**
  String get loginAccountDisabledMessage;

  /// LOGIN — Erro ao verificar status do usuário (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Erro ao verificar usuário'**
  String get loginErrorCheckingUser;

  /// LOGIN — Email obrigatório para reset (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Informe seu email para redefinir a senha'**
  String get loginEnterEmailToReset;

  /// LOGIN — Confirmação de envio de link de redefinição (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um link de redefinição para seu e-mail.'**
  String get loginResetLinkSent;

  /// LOGIN — Erro inesperado no reset (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado ao redefinir senha'**
  String get loginUnexpectedResetError;

  /// LOGIN — Loader ao iniciar login com Google (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Entrando com Google...'**
  String get loginSigningInWithGoogle;

  /// LOGIN — Loader durante warmup/bootstrap após login (alternativo)
  ///
  /// In pt, this message translates to:
  /// **'Preparando sua conta...'**
  String get loginPreparingAccount;

  /// REGISTER — Título do header
  ///
  /// In pt, this message translates to:
  /// **'Crie sua conta'**
  String get registerHeaderTitle;

  /// REGISTER — Subtítulo do header
  ///
  /// In pt, this message translates to:
  /// **'Tenha controle total do seu estoque desde o primeiro dia.'**
  String get registerHeaderSubtitle;

  /// REGISTER — Falha genérica ao entrar com Google
  ///
  /// In pt, this message translates to:
  /// **'Falha ao entrar com Google. Tente novamente.'**
  String get registerGoogleGenericFail;

  /// REGISTER — Falha ao cancelar
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível cancelar agora. Tente novamente.'**
  String get registerCancelFail;

  /// REGISTER — E-mail obrigatório
  ///
  /// In pt, this message translates to:
  /// **'Preencha o e-mail.'**
  String get registerEmailRequired;

  /// REGISTER — Erro inesperado ao enviar verificação
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado ao enviar verificação.'**
  String get registerSendVerificationUnexpectedError;

  /// REGISTER — E-mail de verificação reenviado
  ///
  /// In pt, this message translates to:
  /// **'E-mail reenviado. Verifique a caixa de entrada (e spam).'**
  String get registerVerificationEmailResent;

  /// REGISTER — Erro inesperado ao reenviar verificação
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado ao reenviar verificação.'**
  String get registerResendVerificationUnexpectedError;

  /// REGISTER — Dica para alterar o e-mail
  ///
  /// In pt, this message translates to:
  /// **'Você pode alterar o e-mail e tentar novamente.'**
  String get registerChangeEmailHint;

  /// REGISTER — Falha ao alterar e-mail
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível alterar agora. Tente novamente.'**
  String get registerChangeEmailFail;

  /// REGISTER — Senha e confirmação obrigatórias
  ///
  /// In pt, this message translates to:
  /// **'Preencha a senha e a confirmação.'**
  String get registerPasswordAndConfirmRequired;

  /// REGISTER — Senhas não coincidem
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem.'**
  String get registerPasswordsDoNotMatch;

  /// REGISTER — Erro inesperado ao criar conta
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado ao criar conta.'**
  String get registerCreateAccountUnexpectedError;

  /// REGISTER — E-mail já em uso
  ///
  /// In pt, this message translates to:
  /// **'Este e-mail já está em uso.'**
  String get registerErrorEmailAlreadyInUse;

  /// REGISTER — Senha fraca
  ///
  /// In pt, this message translates to:
  /// **'Senha fraca.'**
  String get registerErrorWeakPassword;

  /// REGISTER — Sem conexão
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Tente novamente.'**
  String get registerErrorNoConnection;

  /// REGISTER — Muitas tentativas
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Aguarde um pouco.'**
  String get registerErrorTooManyRequests;

  /// REGISTER — Erro genérico
  ///
  /// In pt, this message translates to:
  /// **'Erro ao continuar o cadastro.'**
  String get registerErrorGeneric;

  /// REGISTER — Label do campo e-mail
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// REGISTER — Validação: e-mail obrigatório
  ///
  /// In pt, this message translates to:
  /// **'Informe o email'**
  String get registerEmailValidatorRequired;

  /// REGISTER — Texto antes do link de login
  ///
  /// In pt, this message translates to:
  /// **'Já possui conta? '**
  String get registerFooterHaveAccount;

  /// REGISTER — Texto do link de login
  ///
  /// In pt, this message translates to:
  /// **'Fazer login'**
  String get registerFooterLogin;

  /// REGISTER — Label do campo senha
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get registerPasswordLabel;

  /// REGISTER — Label do campo confirmar senha
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get registerConfirmPasswordLabel;

  /// REGISTER — Botão social Google
  ///
  /// In pt, this message translates to:
  /// **'Continue com Google'**
  String get registerContinueWithGoogle;

  /// REGISTER — Botão social Apple
  ///
  /// In pt, this message translates to:
  /// **'Continue com Apple'**
  String get registerContinueWithApple;

  /// REGISTER — Google cancelado
  ///
  /// In pt, this message translates to:
  /// **'Login com Google cancelado.'**
  String get registerGoogleCancelled;

  /// REGISTER — Usuário Google não obtido
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter o usuário do Google.'**
  String get registerGoogleUserNotFound;

  /// REGISTER — E-mail inválido
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido.'**
  String get registerInvalidEmail;

  /// REGISTER — Verificação enviada
  ///
  /// In pt, this message translates to:
  /// **'E-mail de verificação enviado. Verifique sua caixa de entrada (e spam).'**
  String get registerVerificationEmailSent;

  /// REGISTER — Aviso para verificar e-mail
  ///
  /// In pt, this message translates to:
  /// **'Verifique seu e-mail antes de continuar.'**
  String get registerVerifyEmailBeforeContinue;

  /// REGISTER — Aviso de senha forte
  ///
  /// In pt, this message translates to:
  /// **'A senha precisa ser forte para criar a conta.'**
  String get registerPasswordMustBeStrong;

  /// REGISTER — Sessão inválida
  ///
  /// In pt, this message translates to:
  /// **'Sessão inválida. Refaça a verificação do e-mail.'**
  String get registerInvalidSessionRedoEmailVerification;

  /// REGISTER — Loader ao iniciar login/cadastro com Google
  ///
  /// In pt, this message translates to:
  /// **'Entrando com Google...'**
  String get registerEnteringWithGoogleLoading;

  /// REGISTER — Erro quando currentUser é null após login/cadastro
  ///
  /// In pt, this message translates to:
  /// **'Login não concluído. Tente novamente.'**
  String get registerLoginNotCompleted;

  /// REGISTER — Loader durante warmup/bootstrap após login/cadastro
  ///
  /// In pt, this message translates to:
  /// **'Preparando sua conta...'**
  String get registerPreparingAccountLoading;

  /// REGISTER — Hint do campo e-mail
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get registerEmailHint;

  /// REGISTER — Botão para enviar e-mail de verificação
  ///
  /// In pt, this message translates to:
  /// **'Enviar e-mail de verificação'**
  String get registerSendVerificationButton;

  /// REGISTER — Botão para reenviar e-mail de verificação
  ///
  /// In pt, this message translates to:
  /// **'Reenviar e-mail de verificação'**
  String get registerResendVerificationButton;

  /// REGISTER — Texto do botão de reenviar com cooldown
  ///
  /// In pt, this message translates to:
  /// **'Reenviar em {seconds}s'**
  String registerResendInSeconds(int seconds);

  /// REGISTER — Link para trocar e-mail
  ///
  /// In pt, this message translates to:
  /// **'Não é esse e-mail?'**
  String get registerNotThisEmail;

  /// REGISTER — Divisor social
  ///
  /// In pt, this message translates to:
  /// **'ou continue com'**
  String get registerOrContinueWith;

  /// REGISTER — Apple login não disponível
  ///
  /// In pt, this message translates to:
  /// **'Apple ainda não implementado.'**
  String get registerAppleNotImplemented;

  /// REGISTER — Hint do campo senha
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get registerPasswordHint;

  /// REGISTER — Hint do campo confirmar senha
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get registerConfirmPasswordHint;

  /// REGISTER — Botão principal de criar conta
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerCreateAccountButton;

  /// REGISTER — Ação para cancelar/excluir fluxo de cadastro
  ///
  /// In pt, this message translates to:
  /// **'Excluir cadastro'**
  String get registerDeleteRegistration;

  /// REGISTER — Força de senha (muito fraca)
  ///
  /// In pt, this message translates to:
  /// **'Muito fraca'**
  String get registerPasswordStrengthVeryWeak;

  /// REGISTER — Força de senha (fraca)
  ///
  /// In pt, this message translates to:
  /// **'Fraca'**
  String get registerPasswordStrengthWeak;

  /// REGISTER — Força de senha (forte)
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get registerPasswordStrengthStrong;

  /// REGISTER — Linha que mostra força da senha
  ///
  /// In pt, this message translates to:
  /// **'Força da senha: {label}'**
  String registerPasswordStrengthLine(String label);

  /// REGISTER — Dica para senha forte
  ///
  /// In pt, this message translates to:
  /// **'Dica: 8+ chars, maiúscula, minúscula, número e símbolo.'**
  String get registerPasswordTip;

  /// REGISTER — Status quando email foi verificado
  ///
  /// In pt, this message translates to:
  /// **'E-mail verificado.'**
  String get registerEmailVerifiedStatus;

  /// REGISTER — Status quando está aguardando o usuário verificar email
  ///
  /// In pt, this message translates to:
  /// **'Aguardando verificação do usuário'**
  String get registerAwaitingUserVerification;

  /// REGISTER — Mensagem exibida ao restaurar cadastro/estado
  ///
  /// In pt, this message translates to:
  /// **'Restaurando seu cadastro...'**
  String get registerRestoringRegistration;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'de':
      {
        switch (locale.countryCode) {
          case 'CH':
            return AppLocalizationsDeCh();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
