import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../firebase/firestore/products_firestore.dart';
import '../../firebase/firestore/categories_firestore.dart';
import '../models/category.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailsModal extends StatefulWidget {
  final Product product;
  final String uid;

  const ProductDetailsModal({
    super.key,
    required this.product,
    required this.uid,
  });

  @override
  State<ProductDetailsModal> createState() => _ProductDetailsModalState();
}

class _ProductDetailsModalState extends State<ProductDetailsModal>
    with TickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _minStockController;

  String _selectedCategory = '';
  bool _editName = false;
  bool _editMinStock = false;
  bool _hasChanges = false;
  bool _saving = false;

  String? _imageUrl;
  bool _loadingImage = true;
  bool _imageError = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product.name);
    _minStockController = TextEditingController(
      text: widget.product.minStock.toString(),
    );

    _nameController.addListener(_checkChanges);
    _minStockController.addListener(_checkChanges);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadImage();
    _animationController.forward();
  }

  Future<void> _loadImage() async {
    if (widget.product.image.isEmpty) {
      setState(() {
        _loadingImage = false;
        _imageError = true;
      });
      return;
    }

    try {
      if (widget.product.image.startsWith('http')) {
        _imageUrl = widget.product.image;
      } else {
        final storageRef = FirebaseStorage.instance.ref(widget.product.image);
        _imageUrl = await storageRef.getDownloadURL();
      }

      setState(() {
        _loadingImage = false;
        _imageError = false;
      });
    } catch (e) {
      setState(() {
        _loadingImage = false;
        _imageError = true;
      });
    }
  }

  void _checkChanges() {
    final nameChanged = _nameController.text.trim() != widget.product.name;
    final categoryChanged = _selectedCategory != widget.product.category;
    final minStockChanged =
        _minStockController.text.trim() != widget.product.minStock.toString();

    setState(() {
      _hasChanges = nameChanged || categoryChanged || minStockChanged;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minStockController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = widget.product.quantity * widget.product.cost;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _handle(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _imageWidget(),
                      const SizedBox(height: 24),
                      _editableRow(
                        label: 'Nome do produto',
                        controller: _nameController,
                        isEditing: _editName,
                        onToggle: () => setState(() => _editName = !_editName),
                      ),
                      _categoryDropdown(),
                      _infoCard(
                        'Custo total em estoque',
                        'R\$ ${totalCost.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                      ),
                      _editableRow(
                        label: 'Estoque mínimo',
                        controller: _minStockController,
                        isEditing: _editMinStock,
                        keyboardType: TextInputType.number,
                        onToggle: () =>
                            setState(() => _editMinStock = !_editMinStock),
                      ),
                      const SizedBox(height: 16),
                      _infoCard(
                        'Quantidade em estoque',
                        widget.product.quantity.toString(),
                        icon: Icons.inventory,
                      ),
                      _infoCard(
                        'Preço unitário',
                        'R\$ ${widget.product.unitPrice.toStringAsFixed(2)}',
                        icon: Icons.price_change,
                      ),
                      _infoCard(
                        'Custo médio',
                        'R\$ ${widget.product.cost.toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      const SizedBox(height: 16),
                      _barcodeSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                if (_hasChanges) _saveButton(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _handle() => Center(
    child: Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    ),
  );

  Widget _imageWidget() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _loadingImage
              ? Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.grey,
                    ),
                  ),
                )
              : _imageError || _imageUrl == null
                  ? Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _editableRow({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Expanded(
                  child: isEditing
                      ? TextField(
                          controller: controller,
                          keyboardType: keyboardType,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            controller.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isEditing ? Colors.grey.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryDropdown() {
    return StreamBuilder<List<Category>>(
      stream: CategoriesFirestore.streamCategories(widget.uid),
      builder: (context, snapshot) {
        final categories = snapshot.data?.map((c) => c.name).toList() ?? [];

        if (_selectedCategory.isEmpty && categories.isNotEmpty) {
          _selectedCategory = categories.contains(widget.product.category)
              ? widget.product.category
              : categories.first;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categoria',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                        _checkChanges();
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black, size: 24),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barcodeSection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.qr_code,
              size: 20,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              'Código de barras',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.barcode,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );

  Widget _saveButton() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.3),
          ),
          onPressed: _saving ? null : _saveChanges,
          child: _saving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Salvar alterações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    ),
  );

  Future<void> _saveChanges() async {
    final minStock = int.tryParse(_minStockController.text.trim());
    if (minStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Estoque mínimo inválido'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    await ProductsFirestore.updateProduct(
      uid: widget.uid,
      productId: widget.product.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      minStock: minStock,
    );

    if (mounted) Navigator.pop(context);
  }
}