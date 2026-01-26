// lib/screens/widgets/relatorios/days/for_product/widgets/product_header_card.dart
import 'package:flutter/material.dart';

import 'premium_tag.dart';

class RelatoriosForProductHeaderCard extends StatelessWidget {
  final String productName;
  final String? imageUrl;

  final int currentStock;
  final String currentStockLabel;

  final String availabilityLabel;

  const RelatoriosForProductHeaderCard({
    super.key,
    required this.productName,
    required this.imageUrl,
    required this.currentStock,
    required this.currentStockLabel,
    required this.availabilityLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = currentStock > 0;

    final availabilityBg = isAvailable ? const Color(0xFFE8F5E8) : const Color(0xFFFCE4EC);
    final availabilityFg = isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final availabilityIcon = isAvailable ? Icons.check_circle : Icons.cancel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F4F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8ECF2).withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 15,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildProductImage(imageUrl),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PremiumTag(
                        text: currentStockLabel,
                        bg: const Color(0xFFE8F5E8),
                        fg: const Color(0xFF2E7D32),
                        icon: Icons.inventory,
                      ),
                      const SizedBox(width: 12),
                      PremiumTag(
                        text: availabilityLabel,
                        bg: availabilityBg,
                        fg: availabilityFg,
                        icon: availabilityIcon,
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

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return _imagePlaceholder();

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: const Icon(
        Icons.image_not_supported,
        color: Color(0xFFBDC3C7),
        size: 24,
      ),
    );
  }
}
