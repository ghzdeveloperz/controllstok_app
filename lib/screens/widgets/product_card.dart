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

class _ProductCardState extends State<ProductCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 16,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Imagem preenchendo o card com gradiente overlay
                      Positioned.fill(
                        child: _buildImage(),
                      ),
                      // Gradiente sutil sobre a imagem
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Informações sobrepostas na parte inferior com glassmorphism
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
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    if (widget.product.image.isEmpty) return _imagePlaceholder();

    return CachedNetworkImage(
      imageUrl: widget.product.image,
      fit: BoxFit.cover,
      placeholder: (context, url) => _imagePlaceholder(),
      errorWidget: (context, url, error) => _imagePlaceholder(),
    );
  }

  Widget _buildInfoBlock() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
                Colors.grey.shade50.withValues(alpha: 0.5),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // Padding reduzido
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
                        fontSize: 16, // Fonte menor
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Padding menor
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16), // Raio menor
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.product.category,
                      style: const TextStyle(
                        fontSize: 11, // Fonte menor
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Espaçamento menor
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Em estoque: ${widget.product.quantity}',
                      style: TextStyle(
                        fontSize: 12, // Fonte menor
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ ${totalValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14, // Fonte menor
                      fontWeight: FontWeight.w800,
                      color: Colors.green.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2), // Espaçamento menor
              Row(
                children: [
                  Container(
                    width: 7, // Tamanho menor
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12, // Fonte menor
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}