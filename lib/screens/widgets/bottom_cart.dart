// lib/screens/widgets/bottom_cart.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../scanner_screen.dart'; // CartItem


class BottomCart extends StatelessWidget {
  final List<CartItem> cart;
  final void Function(int) increment;
  final void Function(int) decrement;
  final VoidCallback onFinalize;

  const BottomCart({
    super.key,
    required this.cart,
    required this.increment,
    required this.decrement,
    required this.onFinalize,
  });

  double get total =>
      cart.fold(0, (sum, item) => sum + item.quantity * item.unitPrice);

  @override
  Widget build(BuildContext context) {
    final cartHeight = MediaQuery.of(context).size.height * 0.35;

    return Container(
      height: cartHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.5 * 255).round()),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 🔹 LISTA DE PRODUTOS
          Expanded(
            child: cart.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              item.imageBase64.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(item.imageBase64),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.black45,
                                    ),
                              const SizedBox(width: 8),

                              // 🔹 Nome + preço
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'R\$ ${item.unitPrice.toStringAsFixed(2)} / un',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 🔹 Quantidade
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => decrement(index),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => increment(index),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Nenhum produto escaneado ainda',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
          ),

          const SizedBox(height: 8),

          // 🔹 TOTAL
          Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(
                text: 'Total: ',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'R\$ ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: total > 0 ? Colors.green : Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 BOTÃO FINALIZAR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onFinalize,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Finalizar'),
            ),
          ),
        ],
      ),
    );
  }
}
