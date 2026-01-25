// lib/screens/widgets/relatorios/days/widgets/products_moved_card.dart
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../firebase/firestore/movements_days.dart';
import '../utils/relatorios_days_tag.dart';
import 'product_image.dart';

class ProductsMovedCard extends StatelessWidget {
  final Map<String, List<Movement>> grouped;
  final ValueChanged<String> onGoToProduct;

  const ProductsMovedCard({
    super.key,
    required this.grouped,
    required this.onGoToProduct,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.relatoriosMovedProductsTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),

            ...grouped.entries.map((entry) {
              final productId = entry.key;
              final productMovements = entry.value;
              final product = productMovements.first;

              final add = productMovements
                  .where((e) => e.type == 'add')
                  .fold<int>(0, (p, e) => p + e.quantity);

              final remove = productMovements
                  .where((e) => e.type == 'remove')
                  .fold<int>(0, (p, e) => p + e.quantity);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImage(imageUrl: product.image),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (add > 0)
                                RelatoriosTag(
                                  text: l10n.relatoriosEntriesWithValue(add),
                                  bg: const Color(0xFFD5F4E6),
                                  fg: const Color(0xFF27AE60),
                                ),
                              if (remove > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: RelatoriosTag(
                                    text: l10n.relatoriosExitsWithValue(remove),
                                    bg: const Color(0xFFFADBD8),
                                    fg: const Color(0xFFE74C3C),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF424242)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        onPressed: () => onGoToProduct(productId),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
