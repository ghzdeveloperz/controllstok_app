// lib/screens/products/new_product/widgets/np_category_dropdown.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/category.dart';
import '../../../../firebase/firestore/categories_firestore.dart';

class NPCategoryDropdown extends StatelessWidget {
  final String uid;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddTap;

  // ✅ l10n
  final String label;
  final String loadingText;
  final String hintText;
  final String validatorText;

  const NPCategoryDropdown({
    super.key,
    required this.uid,
    required this.selectedCategory,
    required this.onChanged,
    required this.onAddTap,

    this.label = 'Categoria',
    this.loadingText = 'Carregando categorias...',
    this.hintText = 'Selecione a categoria',
    this.validatorText = 'Selecione uma categoria',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Category>>(
          stream: CategoriesFirestore.streamCategories(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                      loadingText,
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
                          color: Colors.black.withAlpha(5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      hint: Row(
                        children: [
                          Icon(Icons.category_outlined, color: Colors.grey.shade500, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            hintText,
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
                                  const Icon(Icons.label_outline, color: Colors.black, size: 18),
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
                      onChanged: onChanged,
                      validator: (v) => v == null ? validatorText : null,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      dropdownColor: Colors.white,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onAddTap,
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
}
