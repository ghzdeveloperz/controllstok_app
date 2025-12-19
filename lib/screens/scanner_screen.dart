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

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? scannedCode;
  String? productName;
  bool _isError = false;
  bool _hasScanned = false;

  List<CartItem> cart = [];

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 1,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _cleanBase64(String base64String) {
    return base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
  }

  // 🔥 Atualiza unitPrice no Firestore + carrinho
  Future<void> _updatePrice(String barcode, double newPrice) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.userLogin)
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'unitPrice': newPrice});
      }

      if (!mounted) return;

      setState(() {
        final index = cart.indexWhere((item) => item.barcode == barcode);
        if (index != -1) cart[index].unitPrice = newPrice;
      });
    } catch (e) {
      debugPrint('Erro ao atualizar unitPrice: $e');
    }
  }

  // 🔥 Finaliza carrinho
  Future<void> _finalizeCart() async {
    if (cart.isEmpty) return;

    for (final item in cart) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(widget.userLogin)
            .collection('products')
            .where('barcode', isEqualTo: item.barcode)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) continue;

        final docRef = snapshot.docs.first.reference;
        final data = snapshot.docs.first.data();

        final oldQty = (data['quantity'] ?? 0).toInt();
        final oldCost = (data['cost'] ?? 0).toDouble();
        final loteUnitPrice = item.unitPrice;

        final newAvgCost =
            ((oldQty * oldCost) + (item.quantity * loteUnitPrice)) /
                (oldQty + item.quantity);

        await docRef.update({
          'quantity': oldQty + item.quantity,
          'cost': newAvgCost,
          'unitPrice': loteUnitPrice,
          'updatedAt': DateTime.now(),
        });
      } catch (e) {
        debugPrint('Erro ao finalizar item ${item.name}: $e');
      }
    }

    if (!mounted) return;
    setState(() => cart.clear());
  }

  Future<void> _openFinalizeModal() async {
    if (cart.isEmpty) return;

    final result = await showDialog<FinalizeModalResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FinalizeModal(),
    );

    if (!mounted) return;

    if (result != null) {
      await _finalizeCart();
      if (mounted) Navigator.of(context).pop();
    }
  }

  // 🔥 SCAN
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty || _hasScanned) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _controller.stop();
    if (!mounted) return;

    setState(() {
      scannedCode = code;
      _hasScanned = true;
      _isError = false;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.userLogin)
          .collection('products')
          .where('barcode', isEqualTo: code)
          .limit(1)
          .get();

      if (!mounted) return;

      // ❌ NÃO ENCONTROU
      if (snapshot.docs.isEmpty) {
        setState(() {
          productName = 'Produto não encontrado';
          _isError = true;
        });
      } else {
        // ✅ ENCONTROU
        final data = snapshot.docs.first.data();
        HapticFeedback.vibrate();

        setState(() {
          final index = cart.indexWhere((item) => item.barcode == code);

          if (index != -1) {
            cart[index].quantity++;
          } else {
            cart.add(
              CartItem(
                barcode: code,
                name: data['name'] ?? '',
                imageBase64: _cleanBase64(data['image'] ?? ''),
                unitPrice: (data['unitPrice'] ?? 0).toDouble(),
                quantity: 1,
              ),
            );
          }

          productName = data['name'];
          _isError = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao detectar código: $e');
      if (!mounted) return;

      setState(() {
        productName = 'Erro ao buscar produto';
        _isError = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;
    setState(() {
      scannedCode = null;
      productName = null;
      _isError = false;
      _hasScanned = false;
    });

    _controller.start();
  }

  void _incrementQuantity(int index) =>
      setState(() => cart[index].quantity++);

  void _decrementQuantity(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }

  Widget _buildScannerOverlay() {
    if (_hasScanned) return const SizedBox();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _opacityAnimation,
            child: const Text(
              'Posicione o código de barras aqui',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          _buildScannerOverlay(),

          if (_hasScanned && scannedCode != null && productName != null)
            ScanResultCard(
              productName: productName!,
              scannedCode: scannedCode!,
              isError: _isError,
              onDismiss: () {},
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: BottomCart(
              cart: cart,
              increment: _incrementQuantity,
              decrement: _decrementQuantity,
              onFinalize: _openFinalizeModal,
              onEditPrice: _updatePrice,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// MODEL
// ========================
class CartItem {
  final String barcode;
  final String name;
  final String imageBase64;
  double unitPrice;
  int quantity;

  CartItem({
    required this.barcode,
    required this.name,
    required this.imageBase64,
    required this.unitPrice,
    required this.quantity,
  });
}
