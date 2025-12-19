import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/scan_result_card.dart';
import 'widgets/bottom_cart.dart';
import 'widgets/finalize_modal.dart';

class ScannerScreen extends StatefulWidget {
  final String userLogin;

  const ScannerScreen({super.key, required this.userLogin});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? scannedCode;
  String? productName;
  bool _hasScanned = false;

  List<CartItem> cart = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _cleanBase64(String base64String) {
    return base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
  }

  // 🔥 MODAL DE FINALIZAÇÃO
  Future<void> _openFinalizeModal() async {
    if (cart.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FinalizeModal(),
    );

    if (confirmed == true) {
      debugPrint('Compra finalizada');

      setState(() {
        cart.clear();
      });
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty || _hasScanned) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _controller.stop();

    setState(() {
      scannedCode = code;
      _hasScanned = true;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.userLogin)
          .collection('products')
          .where('barcode', isEqualTo: code)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        final name = data['name'] ?? 'Nome não disponível';
        final imageBase64 = data['image'] ?? '';
        final unitPrice = data.containsKey('unitPrice')
            ? (data['unitPrice'] as num).toDouble()
            : 0.0;

        HapticFeedback.vibrate();

        setState(() {
          final index = cart.indexWhere((item) => item.barcode == code);

          if (index != -1) {
            cart[index].quantity++;
          } else {
            cart.add(
              CartItem(
                barcode: code,
                name: name,
                imageBase64: _cleanBase64(imageBase64),
                unitPrice: unitPrice,
                quantity: 1,
              ),
            );
          }

          productName = name;
        });
      } else {
        setState(() {
          productName = 'Produto não encontrado';
        });
      }
    } catch (e) {
      debugPrint('Erro: $e');
      setState(() {
        productName = 'Erro ao buscar produto';
      });
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        scannedCode = null;
        productName = null;
        _hasScanned = false;
      });
      _controller.start();
    }
  }

  void _incrementQuantity(int index) {
    setState(() {
      cart[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scanner de Código de Barras'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          if (_hasScanned)
            ScanResultCard(
              productName: productName ?? '',
              scannedCode: scannedCode ?? '',
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: BottomCart(
              cart: cart,
              increment: _incrementQuantity,
              decrement: _decrementQuantity,
              onFinalize: _openFinalizeModal, // ✅ CONECTADO
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String barcode;
  final String name;
  final String imageBase64;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.barcode,
    required this.name,
    required this.imageBase64,
    required this.unitPrice,
    required this.quantity,
  });
}
