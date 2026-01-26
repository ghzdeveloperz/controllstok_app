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
    Locale('pt', 'PT')
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

  /// GERAL / BOTÕES — Opção afirmativa (Sim)
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get yes;

  /// GERAL / BOTÕES — Opção negativa (Não)
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get no;

  /// ONBOARDING EMPRESA — Placeholder quando email está vazio
  ///
  /// In pt, this message translates to:
  /// **'—'**
  String get companyEmailFallback;

  /// ONBOARDING EMPRESA — Título do header
  ///
  /// In pt, this message translates to:
  /// **'Configure sua empresa'**
  String get companyHeaderTitle;

  /// ONBOARDING EMPRESA — Linha exibindo a conta/email
  ///
  /// In pt, this message translates to:
  /// **'Conta: {email}'**
  String companyHeaderAccountLine(Object email);

  /// ONBOARDING EMPRESA — Subtítulo do header
  ///
  /// In pt, this message translates to:
  /// **'Essas informações ajudam a personalizar seu sistema e organizar seus relatórios.'**
  String get companyHeaderSubtitle;

  /// ONBOARDING EMPRESA — Hint do campo razão social/nome da empresa
  ///
  /// In pt, this message translates to:
  /// **'Razão social / nome da empresa'**
  String get companyCompanyHint;

  /// ONBOARDING EMPRESA — Pergunta toggle: possui nome fantasia
  ///
  /// In pt, this message translates to:
  /// **'Sua empresa tem nome fantasia?'**
  String get companyHasFantasyNameQuestion;

  /// ONBOARDING EMPRESA — Hint do campo nome fantasia
  ///
  /// In pt, this message translates to:
  /// **'Nome fantasia'**
  String get companyFantasyNameHint;

  /// ONBOARDING EMPRESA — Pergunta toggle: informar responsável
  ///
  /// In pt, this message translates to:
  /// **'Deseja informar um responsável?'**
  String get companyHasOwnerQuestion;

  /// ONBOARDING EMPRESA — Hint do campo responsável
  ///
  /// In pt, this message translates to:
  /// **'Responsável'**
  String get companyOwnerHint;

  /// ONBOARDING EMPRESA — Pergunta toggle: informar telefone/WhatsApp
  ///
  /// In pt, this message translates to:
  /// **'Deseja informar telefone/WhatsApp?'**
  String get companyHasPhoneQuestion;

  /// ONBOARDING EMPRESA — Hint do campo telefone/WhatsApp
  ///
  /// In pt, this message translates to:
  /// **'Telefone / WhatsApp'**
  String get companyPhoneHint;

  /// ONBOARDING EMPRESA — Hint do seletor de tipo de negócio
  ///
  /// In pt, this message translates to:
  /// **'Tipo de negócio'**
  String get companyBusinessTypeHint;

  /// ONBOARDING EMPRESA — Título do modal de seleção de tipo de negócio
  ///
  /// In pt, this message translates to:
  /// **'Selecione o tipo de negócio'**
  String get companyBusinessTypeSelectTitle;

  /// ONBOARDING EMPRESA — Hint do campo quando tipo de negócio é 'Outro' (max 20)
  ///
  /// In pt, this message translates to:
  /// **'Descreva (até 20 caracteres)'**
  String get companyBusinessTypeOtherHint;

  /// ONBOARDING EMPRESA — Tipo de negócio: restaurante
  ///
  /// In pt, this message translates to:
  /// **'Restaurante'**
  String get companyBusinessTypeRestaurant;

  /// ONBOARDING EMPRESA — Tipo de negócio: mercado
  ///
  /// In pt, this message translates to:
  /// **'Mercado'**
  String get companyBusinessTypeMarket;

  /// ONBOARDING EMPRESA — Tipo de negócio: padaria
  ///
  /// In pt, this message translates to:
  /// **'Padaria'**
  String get companyBusinessTypeBakery;

  /// ONBOARDING EMPRESA — Tipo de negócio: farmácia
  ///
  /// In pt, this message translates to:
  /// **'Farmácia'**
  String get companyBusinessTypePharmacy;

  /// ONBOARDING EMPRESA — Tipo de negócio: loja
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get companyBusinessTypeStore;

  /// ONBOARDING EMPRESA — Tipo de negócio: oficina
  ///
  /// In pt, this message translates to:
  /// **'Oficina'**
  String get companyBusinessTypeWorkshop;

  /// ONBOARDING EMPRESA — Tipo de negócio: indústria
  ///
  /// In pt, this message translates to:
  /// **'Indústria'**
  String get companyBusinessTypeIndustry;

  /// ONBOARDING EMPRESA — Tipo de negócio: distribuidora
  ///
  /// In pt, this message translates to:
  /// **'Distribuidora'**
  String get companyBusinessTypeDistributor;

  /// ONBOARDING EMPRESA — Tipo de negócio: outro
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get companyBusinessTypeOther;

  /// ONBOARDING EMPRESA — Checkbox termos: prefixo antes do link
  ///
  /// In pt, this message translates to:
  /// **'Eu li e concordo com os'**
  String get companyAcceptTermsPrefix;

  /// ONBOARDING EMPRESA — Checkbox termos: texto do link
  ///
  /// In pt, this message translates to:
  /// **'Termos de uso'**
  String get companyTermsLink;

  /// ONBOARDING EMPRESA — Checkbox privacidade: prefixo antes do link
  ///
  /// In pt, this message translates to:
  /// **'Eu li e concordo com as'**
  String get companyAcceptPrivacyPrefix;

  /// ONBOARDING EMPRESA — Checkbox privacidade: texto do link
  ///
  /// In pt, this message translates to:
  /// **'Políticas de privacidade'**
  String get companyPrivacyLink;

  /// ONBOARDING EMPRESA — Texto do botão principal de finalizar
  ///
  /// In pt, this message translates to:
  /// **'Finalizar cadastro'**
  String get companyFinishButton;

  /// ONBOARDING EMPRESA — Erro: nome/razão social obrigatório
  ///
  /// In pt, this message translates to:
  /// **'Preencha a razão social / nome da empresa'**
  String get companyErrorCompanyRequired;

  /// ONBOARDING EMPRESA — Erro: tipo de negócio obrigatório
  ///
  /// In pt, this message translates to:
  /// **'Selecione o tipo de negócio'**
  String get companyErrorBusinessTypeRequired;

  /// ONBOARDING EMPRESA — Erro: tipo 'Outro' precisa ser descrito
  ///
  /// In pt, this message translates to:
  /// **'Descreva o tipo de negócio (até 20 caracteres)'**
  String get companyErrorOtherBusinessTypeRequired;

  /// ONBOARDING EMPRESA — Erro: nome fantasia obrigatório quando habilitado
  ///
  /// In pt, this message translates to:
  /// **'Preencha o nome fantasia'**
  String get companyErrorFantasyRequired;

  /// ONBOARDING EMPRESA — Erro: responsável obrigatório quando habilitado
  ///
  /// In pt, this message translates to:
  /// **'Preencha o responsável'**
  String get companyErrorOwnerRequired;

  /// ONBOARDING EMPRESA — Erro: telefone obrigatório quando habilitado
  ///
  /// In pt, this message translates to:
  /// **'Preencha o telefone / WhatsApp'**
  String get companyErrorPhoneRequired;

  /// ONBOARDING EMPRESA — Erro: precisa aceitar termos e privacidade
  ///
  /// In pt, this message translates to:
  /// **'Você precisa aceitar os Termos e a Política de Privacidade.'**
  String get companyErrorAcceptLegal;

  /// ONBOARDING EMPRESA — Erro genérico ao salvar no Firestore
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar os dados. Tente novamente.'**
  String get companyErrorSaveFailed;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título do AppBar
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacyPolicyTitle;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 1
  ///
  /// In pt, this message translates to:
  /// **'1. Introdução'**
  String get privacyPolicySection1Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 1
  ///
  /// In pt, this message translates to:
  /// **'O MyStoreDay é um aplicativo de gerenciamento de estoque. Esta Política de Privacidade descreve como as informações dos usuários são tratadas e protegidas.'**
  String get privacyPolicySection1Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 2
  ///
  /// In pt, this message translates to:
  /// **'2. Coleta de Dados'**
  String get privacyPolicySection2Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 2
  ///
  /// In pt, this message translates to:
  /// **'O aplicativo pode coletar informações básicas necessárias para o funcionamento, como dados de login e informações relacionadas aos produtos cadastrados no estoque.'**
  String get privacyPolicySection2Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 3
  ///
  /// In pt, this message translates to:
  /// **'3. Uso das Informações'**
  String get privacyPolicySection3Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 3
  ///
  /// In pt, this message translates to:
  /// **'As informações coletadas são utilizadas exclusivamente para o funcionamento do aplicativo, melhoria da experiência do usuário e controle interno de estoque.'**
  String get privacyPolicySection3Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 4
  ///
  /// In pt, this message translates to:
  /// **'4. Compartilhamento de Dados'**
  String get privacyPolicySection4Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 4
  ///
  /// In pt, this message translates to:
  /// **'O MyStoreDay não compartilha dados pessoais com terceiros, exceto quando exigido por lei.'**
  String get privacyPolicySection4Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 5
  ///
  /// In pt, this message translates to:
  /// **'5. Segurança'**
  String get privacyPolicySection5Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 5
  ///
  /// In pt, this message translates to:
  /// **'Adotamos medidas técnicas e organizacionais para proteger os dados armazenados, reduzindo riscos de acesso não autorizado.'**
  String get privacyPolicySection5Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 6
  ///
  /// In pt, this message translates to:
  /// **'6. Responsabilidades do Usuário'**
  String get privacyPolicySection6Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 6
  ///
  /// In pt, this message translates to:
  /// **'O usuário é responsável por manter suas credenciais de acesso seguras e por todas as atividades realizadas em sua conta.'**
  String get privacyPolicySection6Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 7
  ///
  /// In pt, this message translates to:
  /// **'7. Alterações'**
  String get privacyPolicySection7Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 7
  ///
  /// In pt, this message translates to:
  /// **'Esta Política de Privacidade pode ser atualizada periodicamente. Recomendamos que o usuário revise este documento regularmente.'**
  String get privacyPolicySection7Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Título da seção 8
  ///
  /// In pt, this message translates to:
  /// **'8. Contato'**
  String get privacyPolicySection8Title;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Texto da seção 8
  ///
  /// In pt, this message translates to:
  /// **'Em caso de dúvidas sobre esta Política de Privacidade, entre em contato pelo e-mail: contact@mystoreday.com.'**
  String get privacyPolicySection8Body;

  /// TELA POLÍTICA_DE_PRIVACIDADE — Linha final com data da última atualização
  ///
  /// In pt, this message translates to:
  /// **'Última atualização: Janeiro de 2025'**
  String get privacyPolicyLastUpdate;

  /// TELA TERMOS_DE_USO — Título da AppBar
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get termsOfUseTitle;

  /// TELA TERMOS_DE_USO — Título da seção 1
  ///
  /// In pt, this message translates to:
  /// **'1. Aceitação dos Termos'**
  String get termsOfUseSection1Title;

  /// TELA TERMOS_DE_USO — Texto da seção 1
  ///
  /// In pt, this message translates to:
  /// **'Ao utilizar o aplicativo MyStoreDay, o usuário concorda integralmente com estes Termos de Uso. Caso não concorde, recomenda-se não utilizar o aplicativo.'**
  String get termsOfUseSection1Body;

  /// TELA TERMOS_DE_USO — Título da seção 2
  ///
  /// In pt, this message translates to:
  /// **'2. Finalidade do Aplicativo'**
  String get termsOfUseSection2Title;

  /// TELA TERMOS_DE_USO — Texto da seção 2
  ///
  /// In pt, this message translates to:
  /// **'O MyStoreDay tem como finalidade auxiliar no gerenciamento de estoque, permitindo o controle de produtos, quantidades e informações relacionadas.'**
  String get termsOfUseSection2Body;

  /// TELA TERMOS_DE_USO — Título da seção 3
  ///
  /// In pt, this message translates to:
  /// **'3. Cadastro e Responsabilidade'**
  String get termsOfUseSection3Title;

  /// TELA TERMOS_DE_USO — Texto da seção 3
  ///
  /// In pt, this message translates to:
  /// **'O usuário é responsável pelas informações fornecidas durante o cadastro e por manter a confidencialidade de seus dados de acesso.'**
  String get termsOfUseSection3Body;

  /// TELA TERMOS_DE_USO — Título da seção 4
  ///
  /// In pt, this message translates to:
  /// **'4. Uso Adequado'**
  String get termsOfUseSection4Title;

  /// TELA TERMOS_DE_USO — Texto da seção 4
  ///
  /// In pt, this message translates to:
  /// **'É proibido utilizar o aplicativo para fins ilícitos, fraudulentos ou que possam comprometer a segurança e o funcionamento do sistema.'**
  String get termsOfUseSection4Body;

  /// TELA TERMOS_DE_USO — Título da seção 5
  ///
  /// In pt, this message translates to:
  /// **'5. Limitação de Responsabilidade'**
  String get termsOfUseSection5Title;

  /// TELA TERMOS_DE_USO — Texto da seção 5
  ///
  /// In pt, this message translates to:
  /// **'O MyStoreDay não se responsabiliza por perdas, danos ou prejuízos decorrentes do uso inadequado do aplicativo ou de informações incorretas inseridas pelo usuário.'**
  String get termsOfUseSection5Body;

  /// TELA TERMOS_DE_USO — Título da seção 6
  ///
  /// In pt, this message translates to:
  /// **'6. Disponibilidade'**
  String get termsOfUseSection6Title;

  /// TELA TERMOS_DE_USO — Texto da seção 6
  ///
  /// In pt, this message translates to:
  /// **'O aplicativo pode sofrer interrupções temporárias para manutenção, atualizações ou por fatores externos fora do controle do desenvolvedor.'**
  String get termsOfUseSection6Body;

  /// TELA TERMOS_DE_USO — Título da seção 7
  ///
  /// In pt, this message translates to:
  /// **'7. Alterações nos Termos'**
  String get termsOfUseSection7Title;

  /// TELA TERMOS_DE_USO — Texto da seção 7
  ///
  /// In pt, this message translates to:
  /// **'Os Termos de Uso podem ser alterados a qualquer momento. Recomenda-se que o usuário revise este documento periodicamente.'**
  String get termsOfUseSection7Body;

  /// TELA TERMOS_DE_USO — Título da seção 8
  ///
  /// In pt, this message translates to:
  /// **'8. Contato'**
  String get termsOfUseSection8Title;

  /// TELA TERMOS_DE_USO — Texto da seção 8
  ///
  /// In pt, this message translates to:
  /// **'Em caso de dúvidas relacionadas a estes Termos de Uso, entre em contato pelo e-mail: contact@mystoreday.com.'**
  String get termsOfUseSection8Body;

  /// TELA TERMOS_DE_USO — Linha final com data da última atualização
  ///
  /// In pt, this message translates to:
  /// **'Última atualização: Janeiro de 2025'**
  String get termsOfUseLastUpdate;

  /// TELA RELATORIOS — Título do header
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get reportsTitle;

  /// Relatórios — filtro percentual: Todos
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get relatoriosPercentAll;

  /// TELA RELATORIOS — Seletor de período: Dia
  ///
  /// In pt, this message translates to:
  /// **'Dia'**
  String get reportsPeriodDay;

  /// No description provided for @relatoriosCumulativeMovementsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Movimentações cumulativas ao longo do dia'**
  String get relatoriosCumulativeMovementsTitle;

  /// No description provided for @relatoriosEntries.
  ///
  /// In pt, this message translates to:
  /// **'Entradas'**
  String get relatoriosEntries;

  /// No description provided for @relatoriosExits.
  ///
  /// In pt, this message translates to:
  /// **'Saídas'**
  String get relatoriosExits;

  /// No description provided for @relatoriosAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get relatoriosAll;

  /// No description provided for @relatoriosTimeAxisLabel.
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get relatoriosTimeAxisLabel;

  /// No description provided for @relatoriosEntry.
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get relatoriosEntry;

  /// No description provided for @relatoriosExit.
  ///
  /// In pt, this message translates to:
  /// **'Saída'**
  String get relatoriosExit;

  /// Título do gráfico de pizza, variando conforme o modo selecionado (Todos/Entradas/Saídas).
  ///
  /// In pt, this message translates to:
  /// **'Distribuição percentual — {modeLabel}'**
  String relatoriosPieTitle(String modeLabel);

  /// No description provided for @relatoriosChartLine.
  ///
  /// In pt, this message translates to:
  /// **'Linha'**
  String get relatoriosChartLine;

  /// No description provided for @relatoriosChartPercent.
  ///
  /// In pt, this message translates to:
  /// **'Pizza'**
  String get relatoriosChartPercent;

  /// No description provided for @relatoriosToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get relatoriosToday;

  /// Mensagem de estado vazio quando não há movimentações na data selecionada.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma movimentação em {dateText}'**
  String relatoriosNoMovementsForDate(String dateText);

  /// No description provided for @relatoriosSelectAnotherDateHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione outra data ou adicione novas movimentações.'**
  String get relatoriosSelectAnotherDateHint;

  /// Tag no card de detalhe do produto mostrando total de entradas.
  ///
  /// In pt, this message translates to:
  /// **'Entrada: {value}'**
  String relatoriosEntryWithValue(int value);

  /// Tag no card de detalhe do produto mostrando total de saídas.
  ///
  /// In pt, this message translates to:
  /// **'Saída: {value}'**
  String relatoriosExitWithValue(int value);

  /// Tag no card 'Produtos Movimentados' mostrando total de entradas.
  ///
  /// In pt, this message translates to:
  /// **'Entradas: {value}'**
  String relatoriosEntriesWithValue(int value);

  /// Tag no card 'Produtos Movimentados' mostrando total de saídas.
  ///
  /// In pt, this message translates to:
  /// **'Saídas: {value}'**
  String relatoriosExitsWithValue(int value);

  /// No description provided for @relatoriosMovedProductsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Produtos movimentados'**
  String get relatoriosMovedProductsTitle;

  /// No description provided for @relatoriosExecutiveSummaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo executivo do dia'**
  String get relatoriosExecutiveSummaryTitle;

  /// No description provided for @relatoriosNetBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo líquido'**
  String get relatoriosNetBalance;

  /// No description provided for @relatoriosExportReport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar relatório'**
  String get relatoriosExportReport;

  /// Texto do tooltip no gráfico de linha (label + valor).
  ///
  /// In pt, this message translates to:
  /// **'{label}: {value}'**
  String relatoriosLineTooltip(String label, num value);

  /// Título do AppBar do relatório por produto
  ///
  /// In pt, this message translates to:
  /// **'Relatório do Produto'**
  String get relatoriosProductReportTitle;

  /// Estado vazio do relatório por produto, com descrição do período
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma movimentação em {periodDescription}'**
  String relatoriosNoMovementsForPeriod(String periodDescription);

  /// Hint do estado vazio quando o período é mês
  ///
  /// In pt, this message translates to:
  /// **'Selecione outro mês ou adicione novas movimentações.'**
  String get relatoriosSelectAnotherMonthHint;

  /// Tag de disponibilidade do produto
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get relatoriosAvailabilityAvailable;

  /// Tag de indisponibilidade do produto
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get relatoriosAvailabilityUnavailable;

  /// Tag do estoque atual do produto
  ///
  /// In pt, this message translates to:
  /// **'Estoque atual: {value}'**
  String relatoriosCurrentStockWithValue(int value);

  /// Título do gráfico (dia) no relatório por produto
  ///
  /// In pt, this message translates to:
  /// **'Movimentações cumulativas de {productName}'**
  String relatoriosCumulativeMovementsOfProduct(String productName);

  /// Título do gráfico (mês) no relatório por produto
  ///
  /// In pt, this message translates to:
  /// **'Movimentações cumulativas de {productName} no mês'**
  String relatoriosCumulativeMovementsOfProductInMonth(String productName);

  /// Título do card de resumo executivo do produto
  ///
  /// In pt, this message translates to:
  /// **'Resumo executivo do produto'**
  String get relatoriosExecutiveSummaryProductTitle;

  /// Título do card de lista de movimentações do produto
  ///
  /// In pt, this message translates to:
  /// **'Movimentações detalhadas'**
  String get relatoriosDetailedMovementsTitle;

  /// Label 'Horário:' na lista detalhada
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get relatoriosTimeLabel;

  /// Título da tela de alertas de estoque
  ///
  /// In pt, this message translates to:
  /// **'Alertas de Estoque'**
  String get alertasTitle;

  /// Hint do campo de busca na tela de alertas
  ///
  /// In pt, this message translates to:
  /// **'Buscar produto...'**
  String get alertasSearchHint;

  /// Filtro: Todos
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get alertasFilterAll;

  /// Filtro: Estoque zerado
  ///
  /// In pt, this message translates to:
  /// **'Zerado'**
  String get alertasFilterZero;

  /// Filtro: Estoque crítico
  ///
  /// In pt, this message translates to:
  /// **'Crítico'**
  String get alertasFilterCritical;

  /// Título da seção de produtos com estoque zerado
  ///
  /// In pt, this message translates to:
  /// **'Estoque Zerado'**
  String get alertasSectionZero;

  /// Título da seção de produtos com estoque crítico
  ///
  /// In pt, this message translates to:
  /// **'Estoque Crítico'**
  String get alertasSectionCritical;

  /// Label de quantidade com valor
  ///
  /// In pt, this message translates to:
  /// **'Quantidade: {value}'**
  String alertasQuantityWithValue(String value);

  /// Botão: pedir agora
  ///
  /// In pt, this message translates to:
  /// **'Pedir Agora'**
  String get alertasOrderNow;

  /// Botão: notificar
  ///
  /// In pt, this message translates to:
  /// **'Notificar'**
  String get alertasNotify;

  /// Título do estado vazio na tela de alertas
  ///
  /// In pt, this message translates to:
  /// **'Nenhum alerta ativo'**
  String get alertasEmptyTitle;

  /// Subtítulo do estado vazio na tela de alertas
  ///
  /// In pt, this message translates to:
  /// **'Seu estoque está em ordem!'**
  String get alertasEmptySubtitle;

  /// Ação comum: cancelar
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// Ação genérica: confirmar
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// Label do campo: nome do produto
  ///
  /// In pt, this message translates to:
  /// **'Nome do produto'**
  String get productDetailsProductName;

  /// Label do campo: categoria
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get productDetailsCategory;

  /// Card: custo total do estoque
  ///
  /// In pt, this message translates to:
  /// **'Custo total em estoque'**
  String get productDetailsTotalCostInStock;

  /// Label do campo: estoque mínimo
  ///
  /// In pt, this message translates to:
  /// **'Estoque mínimo'**
  String get productDetailsMinStock;

  /// Card: quantidade em estoque
  ///
  /// In pt, this message translates to:
  /// **'Quantidade em estoque'**
  String get productDetailsStockQuantity;

  /// Card: preço unitário
  ///
  /// In pt, this message translates to:
  /// **'Preço unitário'**
  String get productDetailsUnitPrice;

  /// Card: custo médio
  ///
  /// In pt, this message translates to:
  /// **'Custo médio'**
  String get productDetailsAvgCost;

  /// Seção: código de barras
  ///
  /// In pt, this message translates to:
  /// **'Código de barras'**
  String get productDetailsBarcode;

  /// Botão: salvar alterações
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get productDetailsSaveChanges;

  /// Botão: excluir produto
  ///
  /// In pt, this message translates to:
  /// **'Excluir produto'**
  String get productDetailsDeleteProduct;

  /// Erro: estoque mínimo inválido
  ///
  /// In pt, this message translates to:
  /// **'Estoque mínimo inválido'**
  String get productDetailsMinStockInvalid;

  /// Snackbar: produto excluído com sucesso
  ///
  /// In pt, this message translates to:
  /// **'Produto excluído com sucesso'**
  String get productDetailsDeletedSuccess;

  /// Título do modal de confirmação por senha
  ///
  /// In pt, this message translates to:
  /// **'Confirmar exclusão'**
  String get productDetailsConfirmDeletionTitle;

  /// Texto do modal de confirmação por senha
  ///
  /// In pt, this message translates to:
  /// **'Por segurança, digite sua senha para continuar.'**
  String get productDetailsConfirmDeletionMessage;

  /// Label do campo senha
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get productDetailsPasswordLabel;

  /// Erro quando a senha está vazia
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite sua senha.'**
  String get productDetailsPasswordEmpty;

  /// Erro genérico ao verificar senha
  ///
  /// In pt, this message translates to:
  /// **'Erro ao verificar senha. Tente novamente.'**
  String get productDetailsPasswordVerifyError;

  /// Erro: senha incorreta
  ///
  /// In pt, this message translates to:
  /// **'Senha incorreta. Tente novamente.'**
  String get productDetailsPasswordWrong;

  /// Instrução exibida no topo do modal de scanner
  ///
  /// In pt, this message translates to:
  /// **'Posicione o código de barras dentro da área destacada'**
  String get scannerBarcodeInstruction;

  /// Label exibida no card de resultado do scanner
  ///
  /// In pt, this message translates to:
  /// **'Código escaneado'**
  String get scannerBarcodeScannedLabel;

  /// Título do card quando o scanner detecta um código com sucesso
  ///
  /// In pt, this message translates to:
  /// **'Código escaneado'**
  String get scannerResultSuccessTitle;

  /// Título do card quando ocorre erro no scanner
  ///
  /// In pt, this message translates to:
  /// **'Erro ao escanear'**
  String get scannerResultErrorTitle;

  /// Linha exibindo o código escaneado (geralmente em caso de erro)
  ///
  /// In pt, this message translates to:
  /// **'Código: {code}'**
  String scannerResultCode(String code);

  /// Diálogo: título para adicionar categoria
  ///
  /// In pt, this message translates to:
  /// **'Adicionar categoria'**
  String get addCategoryTitle;

  /// Diálogo: hint do campo nome da categoria
  ///
  /// In pt, this message translates to:
  /// **'Nome da categoria'**
  String get addCategoryHint;

  /// Diálogo: botão principal para confirmar adicionar categoria
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get addCategoryAction;

  /// Validação: nome da categoria obrigatório
  ///
  /// In pt, this message translates to:
  /// **'Digite o nome da categoria.'**
  String get addCategoryNameRequired;

  /// Erro genérico ao salvar categoria no Firestore
  ///
  /// In pt, this message translates to:
  /// **'Erro ao adicionar categoria. Tente novamente.'**
  String get addCategoryError;

  /// Bottom navigation — aba Estoque
  ///
  /// In pt, this message translates to:
  /// **'Estoque'**
  String get homeTabStock;

  /// Bottom navigation — aba Novo Produto
  ///
  /// In pt, this message translates to:
  /// **'Novo'**
  String get homeTabNew;

  /// Bottom navigation — ação/aba Scanner (botão central)
  ///
  /// In pt, this message translates to:
  /// **'Scanner'**
  String get homeTabScanner;

  /// Bottom navigation — aba Relatórios
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get homeTabReports;

  /// Bottom navigation — aba Alertas
  ///
  /// In pt, this message translates to:
  /// **'Alertas'**
  String get homeTabAlerts;

  /// Snackbar ao salvar produto e voltar para o estoque
  ///
  /// In pt, this message translates to:
  /// **'Produto salvo com sucesso'**
  String get homeProductSavedSuccess;

  /// Título do modal quando a conta é desativada
  ///
  /// In pt, this message translates to:
  /// **'Conta desativada'**
  String get homeAccountDeactivatedTitle;

  /// Mensagem do modal quando a conta é desativada
  ///
  /// In pt, this message translates to:
  /// **'Sua conta foi desativada. Entre em contato com o suporte.'**
  String get homeAccountDeactivatedMessage;

  /// Botão OK genérico
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// PRODUCT CARD — Status quando o produto está zerado
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get productStatusUnavailable;

  /// PRODUCT CARD — Status quando abaixo/igual ao mínimo
  ///
  /// In pt, this message translates to:
  /// **'Estoque crítico'**
  String get productStatusCritical;

  /// PRODUCT CARD — Status quando está ok
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get productStatusAvailable;

  /// PRODUCT CARD — Linha de estoque com valor
  ///
  /// In pt, this message translates to:
  /// **'Estoque: {value}'**
  String productStockWithValue(int value);

  /// GERAL — Formatação simples de moeda via i18n
  ///
  /// In pt, this message translates to:
  /// **'R\$ {value}'**
  String currencyValue(double value);

  /// PERFIL — Título da tela de perfil
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// PERFIL — Tooltip do botão de configurações
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get profileOpenSettings;

  /// PERFIL — Erro ao carregar dados com detalhe
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar dados: {value}'**
  String profileLoadErrorWithValue(String value);

  /// GERAL — Botão tentar novamente
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get actionTryAgain;

  /// PERFIL — Estado vazio sem usuário
  ///
  /// In pt, this message translates to:
  /// **'Nenhum usuário logado'**
  String get profileNoUser;

  /// PERFIL — Fallback quando não há nome/email
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get profileUserFallback;

  /// PERFIL — Fallback quando email é nulo
  ///
  /// In pt, this message translates to:
  /// **'Sem email'**
  String get profileNoEmail;

  /// PERFIL — Título do diálogo de editar empresa
  ///
  /// In pt, this message translates to:
  /// **'Editar empresa'**
  String get profileEditCompanyTitle;

  /// PERFIL — Label do campo nome da empresa
  ///
  /// In pt, this message translates to:
  /// **'Nome da empresa'**
  String get profileCompanyNameLabel;

  /// PERFIL — Snackbar sucesso ao atualizar avatar
  ///
  /// In pt, this message translates to:
  /// **'Imagem atualizada com sucesso!'**
  String get profileAvatarUpdated;

  /// PERFIL — Snackbar erro ao atualizar avatar
  ///
  /// In pt, this message translates to:
  /// **'Erro ao atualizar imagem.'**
  String get profileAvatarUpdateError;

  /// PERFIL — Chip do plano Free
  ///
  /// In pt, this message translates to:
  /// **'GRÁTIS'**
  String get profilePlanFree;

  /// PERFIL — Chip do plano Pro
  ///
  /// In pt, this message translates to:
  /// **'PRÓ'**
  String get profilePlanPro;

  /// PERFIL — Chip do plano Max
  ///
  /// In pt, this message translates to:
  /// **'MAX'**
  String get profilePlanMax;

  /// PERFIL — Seção informações da conta
  ///
  /// In pt, this message translates to:
  /// **'Informações da conta'**
  String get profileAccountInfoTitle;

  /// PERFIL — Label Email
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// PERFIL — Label UID
  ///
  /// In pt, this message translates to:
  /// **'UID'**
  String get profileUidLabel;

  /// PERFIL — Label data de criação
  ///
  /// In pt, this message translates to:
  /// **'Criado em'**
  String get profileCreatedAtLabel;

  /// PERFIL — Label último login
  ///
  /// In pt, this message translates to:
  /// **'Último login'**
  String get profileLastLoginLabel;

  /// GERAL — Valor não disponível
  ///
  /// In pt, this message translates to:
  /// **'N/A'**
  String get commonNotAvailable;

  /// PERFIL — Snackbar ao copiar um valor
  ///
  /// In pt, this message translates to:
  /// **'{value} copiado para a área de transferência'**
  String profileCopiedWithValue(String value);

  /// PERFIL — Seção segurança
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get profileSecurityTitle;

  /// PERFIL — Título do diálogo de sair
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get profileSignOutTitle;

  /// PERFIL — Mensagem de confirmação de sair
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair?'**
  String get profileSignOutConfirm;

  /// PERFIL — Botão sair da conta
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get profileSignOutButton;

  /// PERFIL — Título do diálogo de desativar conta
  ///
  /// In pt, this message translates to:
  /// **'Desativar conta'**
  String get profileDeactivateTitle;

  /// PERFIL — Texto explicativo ao desativar conta
  ///
  /// In pt, this message translates to:
  /// **'Para desativar sua conta, confirme sua senha. Esta ação é irreversível.'**
  String get profileDeactivateHint;

  /// PERFIL — Label campo senha
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get profilePasswordLabel;

  /// PERFIL — Validação senha obrigatória
  ///
  /// In pt, this message translates to:
  /// **'Digite sua senha'**
  String get profilePasswordRequired;

  /// PERFIL — Erro senha incorreta
  ///
  /// In pt, this message translates to:
  /// **'Senha incorreta. Verifique e tente novamente.'**
  String get profileWrongPassword;

  /// PERFIL — Erro quando email está ausente
  ///
  /// In pt, this message translates to:
  /// **'Email do usuário não encontrado.'**
  String get profileNoEmailError;

  /// PERFIL — Erro genérico ao desativar
  ///
  /// In pt, this message translates to:
  /// **'Erro ao desativar a conta.'**
  String get profileDeactivateGenericError;

  /// PERFIL — Botão desativar conta
  ///
  /// In pt, this message translates to:
  /// **'Desativar'**
  String get profileDeactivateButton;

  /// AÇÕES — Botão salvar (padrão do app)
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get actionSave;

  /// AÇÕES — Botão cancelar (padrão do app)
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// CONFIG — Título da tela de configurações
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// CONFIG — Título da opção Idioma
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageTitle;

  /// CONFIG — Subtítulo da opção Idioma
  ///
  /// In pt, this message translates to:
  /// **'Idioma e região'**
  String get settingsLanguageSubtitle;

  /// CONFIG — Título da opção Categorias
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get settingsCategoriesTitle;

  /// CONFIG — Subtítulo da opção Categorias
  ///
  /// In pt, this message translates to:
  /// **'Organize seu estoque'**
  String get settingsCategoriesSubtitle;

  /// CONFIG — Título da opção Sobre
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get settingsAboutTitle;

  /// CONFIG — Subtítulo da opção Sobre
  ///
  /// In pt, this message translates to:
  /// **'Versão e informações do app'**
  String get settingsAboutSubtitle;
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
      'that was used.');
}
