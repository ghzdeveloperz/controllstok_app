// lib/screens/widgets/relatorios/days/widgets/product_detail_card.dart
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../firebase/firestore/movements_days.dart';
import '../utils/relatorios_days_tag.dart';
import 'product_image.dart';

class ProductDetailCard extends StatelessWidget {
  final List<Movement> movements;

  const ProductDetailCard({
    super.key,
    required this.movements,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final product = movements.first;

    final add = movements
        .where((e) => e.type == 'add')
        .fold<int>(0, (p, e) => p + e.quantity);

    final remove = movements
        .where((e) => e.type == 'remove')
        .fold<int>(0, (p, e) => p + e.quantity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
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
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (add > 0)
                        RelatoriosTag(
                          text: l10n.relatoriosEntryWithValue(add),
                          bg: const Color(0xFFD5F4E6),
                          fg: const Color(0xFF27AE60),
                        ),
                      if (remove > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: RelatoriosTag(
                            text: l10n.relatoriosExitWithValue(remove),
                            bg: const Color(0xFFFADBD8),
                            fg: const Color(0xFFE74C3C),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
