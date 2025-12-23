import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import '../firebase/firestore/categories_firestore.dart';
import '../../screens/models/category.dart';

class NovoProdutoScreen extends StatefulWidget {
  final String userLogin;

  const NovoProdutoScreen({super.key, required this.userLogin});

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

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
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

  Future<void> _handleImagePick(ImageSource source) async {
    Navigator.pop(context);

    final permission = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (!permission.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão negada')),
      );
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(widget.userLogin)
        .child('products')
        .child(fileName);

    final snapshot = await ref.putFile(image);
    return snapshot.ref.getDownloadURL();
  }

  // ================= SALVAR =================

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCategory == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      final imageUrl = await _uploadImage(_selectedImage!);

      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final price =
          double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userLogin)
          .collection('products')
          .add({
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'quantity': quantity,
        'minStock': 0,
        'cost': price,
        'unitPrice': price,
        'price': price,
        'barcode': _barcodeController.text.trim(),
        'image': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Produto salvo com sucesso')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
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
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
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
                _input(
                  controller: _nameController,
                  label: 'Nome do produto',
                  hint: 'Ex: Coca-Cola 2L',
                ),
                const SizedBox(height: 16),
                _input(
                  controller: _barcodeController,
                  label: 'Código de barras',
                  hint: '7894900011517',
                ),
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
                _saveButton(),
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
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
                    Icon(Icons.camera_alt_outlined,
                        size: 38, color: Colors.grey.shade600),
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
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    return StreamBuilder<List<Category>>(
      stream: CategoriesFirestore.streamCategories(widget.userLogin),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          hint: const Text('Selecione a categoria'),
          items: snapshot.data!
              .map(
                (c) => DropdownMenuItem(
                  value: c.name,
                  child: Text(c.name),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
          validator: (v) => v == null ? 'Selecione uma categoria' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveProduct,
        child: const Text('Salvar Produto'),
      ),
    );
  }
}
