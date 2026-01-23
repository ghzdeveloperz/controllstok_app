// lib/screens/products/new_product/novo_produto_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';

import '../../../screens/widgets/add_category.dart';
import '../../../screens/widgets/scanner_code_new_product.dart';
import '../../models/product_overlay.dart';

import '../new_product/data/new_product_state.dart';
import '../new_product/services/new_product_firestore_service.dart';
import '../new_product/services/new_product_image_service.dart';
import '../new_product/utils/product_name_utils.dart';
import '../new_product/utils/snackbars.dart';

import '../new_product/widgets/np_image_picker.dart';
import '../new_product/widgets/np_section_title.dart';
import '../new_product/widgets/np_text_field.dart';
import '../new_product/widgets/np_product_name_field.dart';
import '../new_product/widgets/np_barcode_field.dart';
import '../new_product/widgets/np_category_dropdown.dart';
import '../new_product/widgets/np_save_button.dart';

class NovoProdutoScreen extends StatefulWidget {
  final String uid;
  final VoidCallback? onProductSaved;

  const NovoProdutoScreen({super.key, required this.uid, this.onProductSaved});

  @override
  State<NovoProdutoScreen> createState() => _NovoProdutoScreenState();
}

class _NovoProdutoScreenState extends State<NovoProdutoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();

  Timer? _duplicateCheckTimer;

  NewProductState _state = const NewProductState();

  late final NewProductImageService _imageService;
  late final NewProductFirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _imageService = NewProductImageService(uid: widget.uid);
    _firestoreService = NewProductFirestoreService(uid: widget.uid);

    _nameFocusNode.addListener(_onNameFocusChange);
  }

  @override
  void dispose() {
    _duplicateCheckTimer?.cancel();
    _nameFocusNode.removeListener(_onNameFocusChange);
    _nameFocusNode.dispose();

    _nameController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onNameFocusChange() {
    if (!_nameFocusNode.hasFocus) {
      final formatted = formatTitleCase(_nameController.text);
      if (formatted != _nameController.text) {
        _nameController.value = _nameController.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  void _onCategoryChanged(String? v) {
    setState(() => _state = _state.copyWith(selectedCategory: v));
  }

  Future<void> _pickImage(BuildContext context) async {
    final img = await _imageService.pickAndCompress(context);
    if (!mounted) return;
    if (img == null) return;
    setState(() => _state = _state.copyWith(selectedImage: img));
  }

  void _checkDuplicateNameDebounced(String value) {
    _duplicateCheckTimer?.cancel();
    _duplicateCheckTimer = Timer(const Duration(milliseconds: 500), () async {
      final raw = value.trim();

      if (raw.isEmpty) {
        if (!mounted) return;
        setState(() {
          _state = _state.copyWith(
            isDuplicateName: false,
            duplicateNameMessage: '',
          );
        });
        return;
      }

      final normalized = normalizeProductName(raw);
      final exists = await _firestoreService.productNameExists(normalized);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);

      setState(() {
        _state = _state.copyWith(
          isDuplicateName: exists,
          duplicateNameMessage: exists
              ? l10n?.newProductDuplicateNameMessage ??
                    'Este nome já existe. Você pode editá-lo.'
              : '',
        );
      });
    });
  }

  Future<void> _openBarcodeScanner() async {
    final scannedCode = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerModal(),
    );

    if (!mounted) return;

    if (scannedCode != null && scannedCode.trim().isNotEmpty) {
      setState(() => _barcodeController.text = scannedCode.trim());
    }
  }

  Future<void> _saveProduct() async {
    final l10n = AppLocalizations.of(context);

    final formOk = _formKey.currentState?.validate() == true;
    final hasCategory = _state.selectedCategory != null;
    final hasImage = _state.selectedImage != null;

    if (!formOk || !hasCategory || !hasImage) {
      showErrorSnack(
        context,
        l10n?.newProductFillAllFields ?? 'Preencha todos os campos',
      );
      return;
    }

    setState(() => _state = _state.copyWith(isSaving: true));

    try {
      final rawName = _nameController.text;
      final finalName = formatTitleCase(normalizeProductName(rawName));
      final barcode = _barcodeController.text.trim();

      final nameExists = await _firestoreService.productNameExists(finalName);
      if (!mounted) return;

      if (nameExists) {
        showErrorSnack(
          context,
          l10n?.newProductNameAlreadyExists ??
              'Já existe um produto com este nome',
        );
        setState(() => _state = _state.copyWith(isSaving: false));
        return;
      }

      final barcodeDup = await _firestoreService.findByBarcode(barcode);
      if (!mounted) return;

      if (barcodeDup != null) {
        final existingName = barcodeDup['name']?.toString() ?? '';

        final msg =
            l10n?.newProductBarcodeAlreadyLinked(existingName) ??
            'Este código de barras já está associado ao produto $existingName.';

        showErrorSnack(context, msg, smallText: true);
        setState(() => _state = _state.copyWith(isSaving: false));
        return;
      }

      final imageUrl = await _imageService.upload(_state.selectedImage!);

      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final price =
          double.tryParse(_priceController.text.replaceAll(',', '.').trim()) ??
          0.0;

      final created = await _firestoreService.createProductAndMovement(
        name: finalName,
        category: _state.selectedCategory!,
        quantity: quantity,
        price: price,
        barcode: barcode,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      if (created == null) {
        showErrorSnack(
          context,
          l10n?.newProductGenericSaveError ?? 'Erro ao salvar',
        );
        setState(() => _state = _state.copyWith(isSaving: false));
        return;
      }

      widget.onProductSaved?.call();

      _nameController.clear();
      _barcodeController.clear();
      _quantityController.clear();
      _priceController.clear();

      setState(() {
        _state = _state.copyWith(
          selectedCategory: null,
          selectedImage: null,
          isDuplicateName: false,
          duplicateNameMessage: '',
          isSaving: false,
        );
      });
    } catch (e) {
      if (!mounted) return;

      final msg =
          l10n?.newProductSaveErrorWithMessage(e.toString()) ??
          'Erro ao salvar: $e';

      showErrorSnack(context, msg);
      setState(() => _state = _state.copyWith(isSaving: false));
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(uid: widget.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Aqui a gente mata TODOS os "receiver can be null"
    // Se seu AppLocalizations.of(context) é nullable, fazemos fallback seguro.
    final l10n = AppLocalizations.of(context);

    final title = l10n?.newProductTitle ?? 'Novo Produto';
    final sectionInfo = l10n?.newProductSectionInfo ?? 'Informações do produto';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NPImagePicker(
                      image: _state.selectedImage,
                      onTap: () => _pickImage(context),
                      emptyText: l10n?.newProductImageAdd ?? 'Adicionar imagem',
                    ),
                    const SizedBox(height: 32),

                    NPSectionTitle(sectionInfo),
                    const SizedBox(height: 24),

                    NPProductNameField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      isDuplicate: _state.isDuplicateName,
                      duplicateMessage: _state.duplicateNameMessage,
                      onChanged: _checkDuplicateNameDebounced,

                      label: l10n?.newProductNameLabel ?? 'Nome do produto',
                      hint: l10n?.newProductNameHint ?? 'Ex: Arroz 5kg',
                      requiredMessage:
                          l10n?.fieldRequired ?? 'Campo obrigatório',
                      minLengthMessage:
                          l10n?.newProductNameMin ??
                          'Nome deve ter pelo menos 2 caracteres',
                      maxLengthMessage:
                          l10n?.newProductNameMax ??
                          'Nome deve ter no máximo 50 caracteres',
                      duplicateValidatorMessage:
                          l10n?.newProductNameDuplicateValidator ??
                          'Nome já existe. Escolha outro.',
                      helperChars: (count) =>
                          l10n?.newProductNameHelperChars(count) ??
                          '$count/50 caracteres',
                      helperNearLimit:
                          l10n?.newProductNameHelperNearLimit ??
                          '(Quase perto do limite)',
                      helperLimitReached:
                          l10n?.newProductNameHelperLimitReached ??
                          '(limite atingido)',
                    ),
                    const SizedBox(height: 20),

                    NPBarcodeField(
                      controller: _barcodeController,
                      onScanTap: _openBarcodeScanner,
                      label: l10n?.newProductBarcodeLabel ?? 'Código de barras',
                      hint: l10n?.newProductBarcodeHint ?? 'Ex: 7891234567890',
                      requiredMessage:
                          l10n?.fieldRequired ?? 'Campo obrigatório',
                    ),
                    const SizedBox(height: 20),

                    NPCategoryDropdown(
                      uid: widget.uid,
                      selectedCategory: _state.selectedCategory,
                      onChanged: _onCategoryChanged,
                      onAddTap: _showAddCategoryDialog,
                      label: l10n?.newProductCategoryLabel ?? 'Categoria',
                      loadingText:
                          l10n?.newProductCategoryLoading ??
                          'Carregando categorias...',
                      hintText:
                          l10n?.newProductCategoryHint ??
                          'Selecione uma categoria',
                      validatorText:
                          l10n?.newProductCategoryValidator ??
                          'Selecione uma categoria',
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: NPTextField(
                            controller: _quantityController,
                            label:
                                l10n?.newProductQuantityLabel ?? 'Quantidade',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            validator: requiredFieldValidator,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NPTextField(
                            controller: _priceController,
                            label: l10n?.newProductPriceLabel ?? 'Preço (R\$)',
                            hint: '0,00',
                            keyboardType: TextInputType.number,
                            validator: requiredFieldValidator,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // ✅ Corrigido: NPSaveButton não tem `text:`
                    // Vamos só exibir o texto padrão dele por enquanto.
                    // (Abaixo eu te passo a versão do botão com l10n)
                    NPSaveButton(
                      isSaving: _state.isSaving,
                      onPressed: _saveProduct,
                      label: l10n?.newProductSaveButton ?? 'Salvar Produto',
                    ),
                  ],
                ),
              ),
            ),

            if (_state.isSaving)
              Positioned.fill(
                child: ProductOverlay(
                  isVisible: _state.isSaving,
                  productName: _nameController.text,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
