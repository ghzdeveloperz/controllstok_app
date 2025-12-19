// lib/screens/widgets/bottom_cart.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../scanner_screen.dart';

class BottomCart extends StatefulWidget {
  final List<CartItem> cart;
  final void Function(int) increment;
  final void Function(int) decrement;
  final VoidCallback onFinalize;
  final void Function(String barcode, double newPrice) onEditPrice;

  const BottomCart({
    super.key,
    required this.cart,
    required this.increment,
    required this.decrement,
    required this.onFinalize,
    required this.onEditPrice,
  });

  @override
  State<BottomCart> createState() => _BottomCartState();
}

class _BottomCartState extends State<BottomCart> {
  String? _movementType; // entrada | saida

  double get total =>
      widget.cart.fold(0, (sum, item) => sum + item.quantity * item.unitPrice);

  void _editPrice(BuildContext context, CartItem item) {
    final controller = TextEditingController(
      text: item.unitPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alterar preço unitário'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              if (value != null && value > 0) {
                // Atualiza unitPrice no Firestore e no carrinho
                widget.onEditPrice(item.barcode, value);
                setState(() {}); // rebuild para atualizar total
              }
              Navigator.pop(context);
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartHeight = MediaQuery.of(context).size.height * 0.4;

    return Container(
      height: cartHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.9 * 255).round()),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Entrada'),
                  selected: _movementType == 'entrada',
                  selectedColor: Colors.green.shade600,
                  labelStyle: TextStyle(
                    color: _movementType == 'entrada'
                        ? Colors.white
                        : Colors.black,
                  ),
                  onSelected: (_) => setState(() => _movementType = 'entrada'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Saída'),
                  selected: _movementType == 'saida',
                  selectedColor: Colors.red.shade600,
                  labelStyle: TextStyle(
                    color: _movementType == 'saida'
                        ? Colors.white
                        : Colors.black,
                  ),
                  onSelected: (_) => setState(() => _movementType = 'saida'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: widget.cart.isEmpty
                ? const Center(child: Text('Nenhum produto no carrinho'))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widget.cart.length,
                    itemBuilder: (_, index) {
                      final item = widget.cart[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              item.imageBase64.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(item.imageBase64),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.image_not_supported),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'R\$ ${item.unitPrice.toStringAsFixed(2)} / un',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (_movementType == 'entrada')
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _editPrice(context, item),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => widget.decrement(index),
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(item.quantity.toString()),
                                  IconButton(
                                    onPressed: () => widget.increment(index),
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 8),

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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_movementType == null || widget.cart.isEmpty)
                  ? null
                  : widget.onFinalize,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
