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
      final formatted = text.split(' ').map((word) {
        if (word.isNotEmpty) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }
        return word;
      }).join(' ');
      _nameController.value = _nameController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length), // Preserva cursor no final
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
        _duplicateNameMessage = _isDuplicateName ? 'Este nome já existe. Você pode editá-lo.' : '';
      });
    });
  }

  // Normalização para consistência (usado em verificação e salvamento)
  String _normalizeProductName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' '); // Trim e normaliza espaços
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

    final permission = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (!permission.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permissão negada',
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

    final picked = await _picker.pickImage(source: source, imageQuality: 85);

    if (picked != null && mounted) {
      // ====== Compressão da imagem ======
      final compressedImage = await _compressImage(File(picked.path));
      setState(() => _selectedImage = compressedImage);
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
      final finalProductName = productName.split(' ').map((word) {
        if (word.isNotEmpty) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }
        return word;
      }).join(' ');
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Novo Produto',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.black,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.30),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagePicker(),
                const SizedBox(height: 30),
                _sectionTitle('Informações do produto'),
                const SizedBox(height: 18),
                _productNameInput(), // Substituído por widget específico
                const SizedBox(height: 16),
                _barcodeInput(), // campo com scanner modal
                const SizedBox(height: 16),
                _categoryDropdown(),
                const SizedBox(height: 16),
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
                const SizedBox(height: 40),
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : _saveButton(),
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
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
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
                      size: 38,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicionar imagem',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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
      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600),
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
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
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
        Text('Nome do produto', style: GoogleFonts.poppins(fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
                    focusNode: _nameFocusNode,
          keyboardType: TextInputType.text,
          maxLength: 100, // Limite máximo
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9\s\-_.,]'), // Permite letras, números, espaços e símbolos comuns; bloqueia controle chars
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
            if (normalized.length > 100) {
              return 'Nome deve ter no máximo 100 caracteres';
            }
            if (_isDuplicateName) {
              return 'Nome já existe. Escolha outro.'; // Bloqueia salvamento se duplicata
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Ex: Arroz 5kg',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            counterText: '', // Remove contador padrão para usar helper customizado
            helperText: _buildHelperText(), // Feedback não intrusivo
            helperStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
            suffixIcon: _isDuplicateName
                ? const Icon(Icons.warning, color: Colors.orange) // Aviso visual amigável
                : null,
          ),
        ),
      ],
    );
  }

  String _buildHelperText() {
    final length = _normalizeProductName(_nameController.text).length;
    final remaining = 100 - length;
    String text = '$length/100 caracteres';
    if (remaining < 10 && remaining >= 0) {
      text += ' (quase no limite)';
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
        Text('Código de barras', style: GoogleFonts.poppins(fontSize: 14)),
        const SizedBox(height: 6),
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
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _openBarcodeScanner,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
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
        Text('Categoria', style: GoogleFonts.poppins(fontSize: 14)),
        const SizedBox(height: 6),
        StreamBuilder<List<Category>>(
          stream: CategoriesFirestore.streamCategories(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Carregando categorias...'),
                  ],
                ),
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height:
                        52, // Altura ajustada para ficar alinhado com código de barras
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selecione a categoria',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
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
                                    color: Colors.black87,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    c.name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: GoogleFonts.poppins(color: Colors.black87),
                      icon: const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showAddCategoryDialog,
                  child: Container(
                    height: 50, // um pouco menor que o dropdown
                    width: 50, // quadrado proporcional
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
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

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Salvar Produto'),
      ),
    );
  }
}