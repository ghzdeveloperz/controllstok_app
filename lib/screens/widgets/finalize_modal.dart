import 'package:flutter/material.dart';

class FinalizeModal extends StatelessWidget {
  const FinalizeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Finalizar compra',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Deseja realmente finalizar esta operação?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // ❌ cancelou
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true); // ✅ confirmou
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
