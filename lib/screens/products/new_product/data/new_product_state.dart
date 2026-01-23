// lib/screens/products/new_product/data/new_product_state.dart
import 'dart:io';

class NewProductState {
  final String? selectedCategory;
  final File? selectedImage;

  final bool isSaving;

  final bool isDuplicateName;
  final String duplicateNameMessage;

  const NewProductState({
    this.selectedCategory,
    this.selectedImage,
    this.isSaving = false,
    this.isDuplicateName = false,
    this.duplicateNameMessage = '',
  });

  NewProductState copyWith({
    String? selectedCategory,
    File? selectedImage,
    bool? isSaving,
    bool? isDuplicateName,
    String? duplicateNameMessage,
  }) {
    return NewProductState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedImage: selectedImage ?? this.selectedImage,
      isSaving: isSaving ?? this.isSaving,
      isDuplicateName: isDuplicateName ?? this.isDuplicateName,
      duplicateNameMessage: duplicateNameMessage ?? this.duplicateNameMessage,
    );
  }
}
