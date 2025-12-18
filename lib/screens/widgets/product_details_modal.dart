// lib/screens/widgets/product_details_modal.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../firebase/firestore/products_firestore.dart';

class ProductDetailsModal extends StatefulWidget {
  final Product product;
  final String userLogin;

  const ProductDetailsModal({
    super.key,
    required this.product,
    required this.userLogin,
  });

  @override
  State<ProductDetailsModal> createState() => _ProductDetailsModalState();
}

class _ProductDetailsModalState extends State<ProductDetailsModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _minStockController;

  bool _editName = false;
  bool _editCategory = false;
  bool _editMinStock = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _categoryController =
        TextEditingController(text: widget.product.category);
    _minStockController =
        TextEditingController(text: widget.product.minStock.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _handle(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    _image(),
                    const SizedBox(height: 20),

                    _editableRow(
                      label: 'Nome do produto',
                      controller: _nameController,
                      isEditing: _editName,
                      onToggle: () =>
                          setState(() => _editName = !_editName),
                    ),

                    _editableRow(
                      label: 'Categoria',
                      controller: _categoryController,
                      isEditing: _editCategory,
                      onToggle: () =>
                          setState(() => _editCategory = !_editCategory),
                    ),

                    _editableRow(
                      label: 'Estoque mínimo',
                      controller: _minStockController,
                      isEditing: _editMinStock,
                      keyboardType: TextInputType.number,
                      onToggle: () =>
                          setState(() => _editMinStock = !_editMinStock),
                    ),

                    const SizedBox(height: 12),

                    _info(
                      'Quantidade em estoque',
                      widget.product.quantity.toString(),
                    ),

                    _info(
                      'Preço unitário',
                      'R\$ ${widget.product.price.toStringAsFixed(2)}',
                    ),

                    _info(
                      'Custo médio',
                      'R\$ ${widget.product.cost.toStringAsFixed(2)}',
                    ),

                    const SizedBox(height: 28),

                    const Divider(height: 1),

                    const SizedBox(height: 16),

                    _barcodeSection(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _saveButton(),
            ],
          ),
        );
      },
    );
  }

  // ================= UI =================

  Widget _handle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _image() {
    if (widget.product.image.isEmpty) return const SizedBox.shrink();

    try {
      final bytes =
          base64Decode(widget.product.image.split(',').last);
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          bytes,
          height: 160,
          fit: BoxFit.contain,
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _editableRow({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        autofocus: true,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    : Text(
                        controller.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barcodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código de barras',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.product.barcode,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _saving ? null : _saveChanges,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Salvar alterações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final minStock =
        int.tryParse(_minStockController.text.trim());

    if (minStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estoque mínimo inválido')),
      );
      return;
    }

    setState(() => _saving = true);

    await ProductsFirestore.updateProduct(
      userLogin: widget.userLogin,
      productId: widget.product.id,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      minStock: minStock,
    );

    if (mounted) Navigator.pop(context);
  }
}
