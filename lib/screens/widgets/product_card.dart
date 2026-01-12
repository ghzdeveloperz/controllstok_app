import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_details_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String uid;
  final List<String> userCategories;
  final ImageProvider? imageProvider;

  const ProductCard({
    super.key,
    required this.product,
    required this.uid,
    required this.userCategories,
    this.imageProvider,
  });

  String get statusLabel {
    if (product.quantity == 0) return 'Indisponível';
    if (product.quantity <= product.minStock) return 'Estoque Crítico';
    return 'Disponível';
  }

  Color get statusColor {
    if (product.quantity == 0) return Colors.red.shade600;
    if (product.quantity <= product.minStock) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  double get unitValue => product.price != 0 ? product.price : product.cost;
  double get totalValue => unitValue * product.quantity;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ProductDetailsModal(product: product, uid: uid),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          scale: 1.0, // Pode ser ajustado dinamicamente se necessário, mas mantido simples
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, // Uma sombra leve
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Imagem preenchendo o card
                  Positioned.fill(
                    child: _buildImage(),
                  ),
                  // Gradiente overlay sutil para visibilidade
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Informações na parte inferior com falso glassmorphism
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildInfoBlock(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.image.isEmpty) return _imagePlaceholder();

    // Usa imageProvider se disponível, senão CachedNetworkImage
    return imageProvider != null
        ? Image(image: imageProvider!, fit: BoxFit.cover)
        : CachedNetworkImage(
            imageUrl: product.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => _imagePlaceholder(),
            errorWidget: (context, url, error) => _imagePlaceholder(),
          );
  }

  Widget _buildInfoBlock() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2), // Falso glassmorphism: cor semi-transparente
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Estoque: ${product.quantity}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'R\$ ${totalValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade300,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor.withOpacity(0.9),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}