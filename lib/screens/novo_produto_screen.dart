import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

import '../firebase/firestore/categories_firestore.dart';
import '../../screens/models/category.dart';
import '../screens/widgets/barcode_scanner_screen.dart'; // <- scanner como modal
import '../screens/widgets/add_category.dart';

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

  String? _selectedCategory;
  File? _selectedImage;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  // Novos para o campo de nome
  final FocusNode _nameFocusNode = FocusNode();
  Timer? _duplicateCheckTimer;
  bool _isDuplicateName = false;
  String _duplicateNameMessage = '';

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_onNameFocusChange);
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _duplicateCheckTimer?.cancel();
    _nameController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Listener para formatação quando foco sai
  void _onNameFocusChange() {
    if (!_nameFocusNode.hasFocus) {
      _formatProductName();
    }
  }

  // Formatação suave: capitaliza primeira letra de cada palavra
  void _formatProductName() {
    final text = _nameController.text;
    if (text.isNotEmpty) {
      final formatted = text
          .split(' ')
          .map((word) {
            if (word.isNotEmpty) {
              return word[0].toUpperCase() + word.substring(1).toLowerCase();
            }
            return word;
          })
          .join(' ');
      _nameController.value = _nameController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length,
        ), // Preserva cursor no final
      );
    }
  }

  // Verificação de duplicata com debounce
  void _checkDuplicateName(String value) {
    _duplicateCheckTimer?.cancel();
    _duplicateCheckTimer = Timer(const Duration(milliseconds: 500), () async {
      if (value.trim().isEmpty) {
        setState(() => _isDuplicateName = false);
        return;
      }
      final normalizedValue = _normalizeProductName(value);
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('products')
          .where('name', isEqualTo: normalizedValue)
          .get();
      setState(() {
        _isDuplicateName = query.docs.isNotEmpty;
        _duplicateNameMessage = _isDuplicateName
            ? 'Este nome já existe. Você pode editá-lo.'
            : '';
      });
    });
  }

  // Normalização para consistência (usado em verificação e salvamento)
  String _normalizeProductName(String value) {
    return value.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    ); // Trim e normaliza espaços
  }

  // ================= IMAGEM =================

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => _handleImagePick(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tirar uma foto'),
                onTap: () => _handleImagePick(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

// =================== _handleImagePick ===================
Future<void> _handleImagePick(ImageSource source) async {
  Navigator.of(context).pop(true);

  try {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    final compressedImage = await _compressImage(File(picked.path));
    setState(() => _selectedImage = compressedImage);
  } catch (_) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Permissão necessária',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Para selecionar imagens, permita o acesso à galeria nas configurações do aplicativo.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text(
              'Abrir configurações',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


  // =================== Compressão ===================
  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;

    // Caminho temporário para salvar a imagem comprimida
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png|.heic'));
    final outPath =
        '${filePath.substring(0, lastIndex)}_compressed${filePath.substring(lastIndex)}';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      minWidth: 400, // <-- Largura máxima (ajustável)
      quality: 85, // <-- Qualidade da compressão (ajustável)
    );

    if (result != null) {
      return File(result.path); // garante que é File
    } else {
      return file; // fallback caso falhe a compressão
    }
  }

  // =================== _uploadImage ===================
  Future<String> _uploadImage(File image) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(widget.uid)
        .child('products')
        .child(fileName);

    // Upload em background
    final uploadTask = ref.putFile(image);

    // Opcional: você pode mostrar progresso usando uploadTask.snapshotEvents
    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  // ================= SALVAR =================

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCategory == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Preencha todos os campos',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final productName = _normalizeProductName(_nameController.text);
      // Aplica capitalização final se necessário (já feito no focus out, mas garante)
      final finalProductName = productName
          .split(' ')
          .map((word) {
            if (word.isNotEmpty) {
              return word[0].toUpperCase() + word.substring(1).toLowerCase();
            }
            return word;
          })
          .join(' ');
      final barcode = _barcodeController.text.trim();

      // Verificar se o nome do produto já existe (usando nome normalizado)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('products')
          .where('name', isEqualTo: finalProductName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Já existe um produto com este nome',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Verificar se o código de barras já existe
      final barcodeQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .get();

      if (barcodeQuery.docs.isNotEmpty) {
        final existingProduct = barcodeQuery.docs.first;
        final existingName = existingProduct['name'];
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este código de barras já está associado ao produto $existingName.',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      final imageUrl = await _uploadImage(_selectedImage!);

      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final price =
          double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid);

      // ================= SALVA PRODUTO =================
      final productRef = await userRef.collection('products').add({
        'name': finalProductName,
        'category': _selectedCategory,
        'quantity': quantity,
        'minStock': 10,
        'cost': price,
        'unitPrice': price,
        'barcode': barcode,
        'image': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ================= REGISTRA ENTRADA NO RELATÓRIO =================
      await userRef.collection('movements').add({
        'productId': productRef.id,
        'productName': finalProductName,
        'type': 'add', // 🔑 PADRÃO DO APP
        'quantity': quantity,
        'unitPrice': price,
        'cost': quantity * price, // 🔑 mesmo nome usado no scanner
        'timestamp': Timestamp.now(), // 🔑 consistente com relatórios
        'barcode': barcode,
        'image': imageUrl,
      });

      if (!mounted) return;

      widget.onProductSaved?.call();

      _nameController.clear();
      _barcodeController.clear();
      _quantityController.clear();
      _priceController.clear();

      setState(() {
        _selectedCategory = null;
        _selectedImage = null;
        _isDuplicateName = false; // Reset para próximo uso
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erro ao salvar: $e',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ================= ABRIR SCANNER =================

  void _openBarcodeScanner() async {
    final scannedCode = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerModal(),
    );
    if (scannedCode != null && scannedCode.isNotEmpty) {
      setState(() {
        _barcodeController.text = scannedCode;
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco para minimalismo
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Sem sombra para limpeza
        centerTitle: true,
        title: Text(
          'Novo Produto',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, // Peso médio para hierarquia
            fontSize: 20, // Tamanho reduzido para sutileza
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black), // Ícones pretos
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ), // Espaçamento generoso
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagePicker(),
                const SizedBox(height: 32), // Espaçamento aumentado
                _sectionTitle('Informações do produto'),
                const SizedBox(height: 24),
                _productNameInput(),
                const SizedBox(height: 20),
                _barcodeInput(),
                const SizedBox(height: 20),
                _categoryDropdown(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _input(
                        controller: _quantityController,
                        label: 'Quantidade',
                        hint: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _input(
                        controller: _priceController,
                        label: 'Preço (R\$)',
                        hint: '0,00',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48), // Espaçamento maior antes do botão
                _isSaving ? _loadingIndicator() : _saveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTES =================

  Widget _imagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 200, // Tamanho reduzido para minimalismo
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade50, // Cinza claro para profundidade
            borderRadius: BorderRadius.circular(12), // Bordas suaves
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Sombra sutil
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            image: _selectedImage != null
                ? DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 32, // Ícone menor
                      color: Colors.grey.shade400, // Cinza neutro
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicionar imagem',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600, // Peso para hierarquia
        color: Colors.black,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700, // Cinza para subtítulos
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor:
                Colors.grey.shade50, // Fundo cinza claro para profundidade
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Bordas suaves
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ), // Borda sutil
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.5,
              ), // Foco preto sutil
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _productNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nome do produto',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          keyboardType: TextInputType.text,
          maxLength: 50, // Limite máximo
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(
                r'[a-zA-Z0-9\s\-_.,]',
              ), // Permite letras, números, espaços e símbolos comuns; bloqueia controle chars
            ),
          ],
          onChanged: (value) {
            _checkDuplicateName(value); // Verificação de duplicata com debounce
          },
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Campo obrigatório';
            }
            final normalized = _normalizeProductName(v);
            if (normalized.length < 2) {
              return 'Nome deve ter pelo menos 2 caracteres';
            }
            if (normalized.length > 50) {
              return 'Nome deve ter no máximo 50 caracteres';
            }
            if (_isDuplicateName) {
              return 'Nome já existe. Escolha outro.'; // Bloqueia salvamento se duplicata
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Ex: Arroz 5kg',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            counterText:
                '', // Remove contador padrão para usar helper customizado
            helperText: _buildHelperText(), // Feedback não intrusivo
            helperStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            suffixIcon: _isDuplicateName
                ? Icon(
                    Icons.warning,
                    color: Colors.grey.shade600,
                  ) // Ícone cinza para aviso sutil
                : null,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _buildHelperText() {
    final length = _normalizeProductName(_nameController.text).length;
    final remaining = 50 - length;
    String text = '$length/50 caracteres';
    if (remaining < 3 && remaining >= 1) {
      text += ' (Quase perto do limite)';
    }
    if (remaining == 0) {
      text += ' (limite atingido)';
    }

    if (_isDuplicateName) {
      text += '\n$_duplicateNameMessage';
    }
    return text;
  }

  Widget _barcodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código de barras',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _barcodeController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                decoration: InputDecoration(
                  hintText: 'Ex: 7894900011517',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _openBarcodeScanner,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= CATEGORIA COM BOTAO + =================

  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Category>>(
          stream: CategoriesFirestore.streamCategories(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Carregando categorias...',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selecione a categoria',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      items: snapshot.data!
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.name,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.label_outline,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    c.name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) =>
                          v == null ? 'Selecione uma categoria' : null,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showAddCategoryDialog,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(uid: widget.uid),
    );
  }

  Widget _loadingIndicator() {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0, // Sem sombra para minimalismo
        ),
        child: Text(
          'Salvar Produto',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
