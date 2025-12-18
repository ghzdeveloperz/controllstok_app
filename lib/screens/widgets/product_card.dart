import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  // ===== STATUS =====
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

  double get totalValue => (product.price != 0 ? product.price : product.cost) * product.quantity;


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===== IMAGEM =====
                Expanded(child: _buildImage()),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== NOME + CATEGORIA =====
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // ===== ESTOQUE + VALOR TOTAL =====
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Em estoque: ${product.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'R\$ ${totalValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // ===== PREÇO MÉDIO =====
                      Text(
                        'Preço médio: R\$ ${product.cost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // ===== STATUS =====
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
                          Expanded(
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  // ===== IMAGEM =====
  Widget _buildImage() {
    if (product.image.isEmpty) return _imagePlaceholder();

    try {
      final base64Data = product.image.split(',').last;
      final bytes = base64Decode(base64Data);

      return AspectRatio(
        aspectRatio: 4 / 3, 
        child: Image.memory(
          bytes,
          width: double.infinity,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      );
    } catch (_) {
      return _imagePlaceholder();
    }
  }

  Widget _imagePlaceholder() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: 34,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
