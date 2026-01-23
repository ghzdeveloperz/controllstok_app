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
}
