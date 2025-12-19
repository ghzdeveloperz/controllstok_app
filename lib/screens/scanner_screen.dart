import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/scan_result_card.dart';
import 'widgets/bottom_cart.dart';

class ScannerScreen extends StatefulWidget {
  final String userLogin;

  const ScannerScreen({super.key, required this.userLogin});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  String? scannedCode;
  String? productName;
  bool _hasScanned = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) return;
    if (_hasScanned) return;

    _controller.stop();

    setState(() {
      scannedCode = code;
      _hasScanned = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(widget.userLogin)
          .collection('products')
          .where('barcode', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        final String name = data['name'] ?? 'Nome não disponível';
        final String imageBase64 = data['image'] ?? '';

        // ✅ CORREÇÃO DEFINITIVA DO unitPrice
        final double unitPrice = data.containsKey('unitPrice')
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
        HapticFeedback.vibrate();
        setState(() {
          productName = 'Produto não encontrado';
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar produto: $e');
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
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          if (!_hasScanned)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 80,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 3, color: Colors.greenAccent),
                    bottom: BorderSide(width: 3, color: Colors.greenAccent),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Posicione o código de barras aqui',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

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
              onFinalize: () {
                // ação de finalizar
              },
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
