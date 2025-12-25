import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_details_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatefulWidget {
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

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  static const Color cardBackgroundColor = Color(0xFFF8F8F8); // Off-white padrão

  String get statusLabel {
    if (widget.product.quantity == 0) return 'Indisponível';
    if (widget.product.quantity <= widget.product.minStock) return 'Estoque Crítico';
    return 'Disponível';
  }

  Color get statusColor {
    if (widget.product.quantity == 0) return Colors.red.shade600;
    if (widget.product.quantity <= widget.product.minStock) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  double get unitValue => widget.product.price != 0 ? widget.product.price : widget.product.cost;
  double get totalValue => unitValue * widget.product.quantity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ProductDetailsModal(product: widget.product, uid: widget.uid),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(40, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Imagem preenchendo o card
              Positioned.fill(
                child: _buildImage(),
              ),
              // Informações sobrepostas na parte inferior
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
    );
  }

  Widget _buildImage() {
    if (widget.product.image.isEmpty) return _imagePlaceholder();

    return CachedNetworkImage(
      imageUrl: widget.product.image,
      fit: BoxFit.cover,
      placeholder: (context, url) => _imagePlaceholder(),
      errorWidget: (context, url, error) {
        // Removido print para evitar uso em produção; considere usar um logger se necessário
        return _imagePlaceholder();
      },
    );
  }

  Widget _buildInfoBlock() {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Fundo com desfoque reduzido
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Desfoque reduzido para efeito mais sutil
              child: Container(
                color: Colors.white.withValues(alpha: 0.7), // Substituído withOpacity por withValues
                height: 80, // Altura reduzida para ocupar menos espaço
              ),
            ),
          ),
          // Conteúdo
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // Padding reduzido para compactar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100.withValues(alpha: 0.6), // Substituído withOpacity por withValues
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.product.category,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4), // Espaçamento reduzido
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Em estoque: ${widget.product.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Text(
                      'R\$ ${totalValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2), // Espaçamento reduzido
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
      ),
    );
  }
}