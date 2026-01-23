// lib/screens/products/new_product/utils/product_name_utils.dart
String normalizeProductName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String formatTitleCase(String value) {
  final normalized = normalizeProductName(value);
  if (normalized.isEmpty) return normalized;

  return normalized
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        final first = word[0].toUpperCase();
        final rest = word.length > 1 ? word.substring(1).toLowerCase() : '';
        return '$first$rest';
      })
      .join(' ');
}

String? requiredFieldValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
  return null;
}
