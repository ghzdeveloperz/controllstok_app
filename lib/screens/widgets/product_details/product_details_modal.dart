import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../../../firebase/firestore/products_firestore.dart';
import '../../../l10n/app_localizations.dart';

import 'confirmation_pass_modal.dart';
import 'widgets/action_buttons.dart';
import 'widgets/barcode_section.dart';
import 'widgets/category_dropdown.dart';
import 'widgets/editable_field_row.dart';
import 'widgets/info_card.dart';
import 'widgets/product_image.dart';
import 'widgets/sheet_handle.dart';

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

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product.name);
    _minStockController = TextEditingController(text: widget.product.minStock.toString());

    _nameController.addListener(_checkChanges);
    _minStockController.addListener(_checkChanges);

    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadImage();
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minStockController.dispose();
    _animationController.dispose();
    super.dispose();
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
    } catch (_) {
      setState(() {
        _loadingImage = false;
        _imageError = true;
      });
    }
  }

  void _checkChanges() {
    final nameChanged = _nameController.text.trim() != widget.product.name;
    final categoryChanged = _selectedCategory != widget.product.category;
    final minStockChanged = _minStockController.text.trim() != widget.product.minStock.toString();

    setState(() => _hasChanges = nameChanged || categoryChanged || minStockChanged);
  }

  String _currency(BuildContext context, num value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = NumberFormat.simpleCurrency(locale: locale);
    return formatter.format(value);
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;
    final minStock = int.tryParse(_minStockController.text.trim());

    if (minStock == null) {
      _snack(l10n.productDetailsMinStockInvalid);
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

  Future<void> _deleteProduct() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationPassModal(),
    );

    if (confirmed != true) return;

    await ProductsFirestore.deleteProduct(
      uid: widget.uid,
      productId: widget.product.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.productDetailsDeletedSuccess,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                const SheetHandle(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      ProductImage(
                        loading: _loadingImage,
                        error: _imageError || _imageUrl == null,
                        child: (_imageError || _imageUrl == null)
                            ? null
                            : CachedNetworkImage(
                                imageUrl: _imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.grey),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 48, color: Colors.redAccent),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      EditableFieldRow(
                        label: l10n.productDetailsProductName,
                        controller: _nameController,
                        isEditing: _editName,
                        onToggle: () => setState(() => _editName = !_editName),
                      ),

                      CategoryDropdown(
                        uid: widget.uid,
                        initialCategory: widget.product.category,
                        onChanged: (val) {
                          setState(() {
                            _selectedCategory = val;
                            _checkChanges();
                          });
                        },
                        label: l10n.productDetailsCategory,
                      ),

                      InfoCard(
                        label: l10n.productDetailsTotalCostInStock,
                        value: _currency(context, totalCost),
                        icon: Icons.attach_money,
                      ),

                      EditableFieldRow(
                        label: l10n.productDetailsMinStock,
                        controller: _minStockController,
                        isEditing: _editMinStock,
                        keyboardType: TextInputType.number,
                        onToggle: () => setState(() => _editMinStock = !_editMinStock),
                      ),

                      const SizedBox(height: 16),

                      InfoCard(
                        label: l10n.productDetailsStockQuantity,
                        value: widget.product.quantity.toString(),
                        icon: Icons.inventory,
                      ),

                      InfoCard(
                        label: l10n.productDetailsUnitPrice,
                        value: _currency(context, widget.product.unitPrice),
                        icon: Icons.price_change,
                      ),

                      InfoCard(
                        label: l10n.productDetailsAvgCost,
                        value: _currency(context, widget.product.cost),
                        icon: Icons.trending_up,
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      const SizedBox(height: 16),

                      BarcodeSection(
                        title: l10n.productDetailsBarcode,
                        barcode: widget.product.barcode,
                      ),

                      const SizedBox(height: 32),

                      ActionButtons.delete(
                        label: l10n.productDetailsDeleteProduct,
                        onPressed: _deleteProduct,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                if (_hasChanges)
                  ActionButtons.save(
                    label: l10n.productDetailsSaveChanges,
                    saving: _saving,
                    onPressed: _saving ? null : _saveChanges,
                  ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
