import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_details_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String uid;
  final List<String> userCategories;

  /// ⚡ Recebe o imageProvider pré-carregado
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ProductDetailsModal(product: product, uid: uid),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(22, 0, 0, 0),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildImage()),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Em estoque: ${product.quantity}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                          ),
                        ),
                        Text(
                          'R\$ ${totalValue.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.image.isEmpty) return _imagePlaceholder();

    return Image(
      image: imageProvider ?? CachedNetworkImageProvider(product.image),
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Erro ao carregar imagem da URL: $error');
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 34, color: Colors.grey),
      ),
    );
  }
}
