import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/scan_result_card.dart';
import 'widgets/bottom_cart.dart';
import 'widgets/finalize_modal.dart';

class ScannerScreen extends StatefulWidget {
  final String uid;

  const ScannerScreen({super.key, required this.uid});

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

    _opacityAnimation =
        Tween<double>(begin: 0.4, end: 1).animate(_animationController);
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

  // ========================
  // OVERLAY DO SCANNER
  // ========================
  Widget _buildScannerOverlay() {
    if (_hasScanned) return const SizedBox.shrink();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 350,
            height: 130,
            child: Stack(
              children: [
                _buildCorner(top: 0, left: 0),
                _buildCorner(top: 0, right: 0, rotate: true),
                _buildCorner(bottom: 0, left: 0, rotate: true),
                _buildCorner(bottom: 0, right: 0),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 2,
                      width: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              'Alinhe o código de barras',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool rotate = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rotate ? 3.14 / 2 : 0,
        child: Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 2),
              left: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // ATUALIZA PREÇO
  // ========================
  Future<void> _updatePrice(String barcode, double newPrice) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.uid)
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'unitPrice': newPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      setState(() {
        final index = cart.indexWhere((item) => item.barcode == barcode);
        if (index != -1) cart[index].unitPrice = newPrice;
      });
    } catch (e) {
      debugPrint('Erro ao atualizar preço: $e');
    }
  }

  // ========================
  // FINALIZAÇÃO (ENTRADA / SAÍDA)
  // ========================
  Future<void> _finalizeCart(String movementType, DateTime selectedDate) async {
    if (cart.isEmpty) return;

    for (final item in cart) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(widget.uid)
            .collection('products')
            .where('barcode', isEqualTo: item.barcode)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) continue;

        final docRef = snapshot.docs.first.reference;
        final data = snapshot.docs.first.data();

        final oldQty = (data['quantity'] ?? 0).toInt();
        final oldCost = (data['cost'] ?? 0).toDouble();

        final int newQty = movementType == 'entrada'
            ? oldQty + item.quantity
            : oldQty - item.quantity;

        if (newQty < 0) continue;

        double newCost = oldCost;

        if (movementType == 'entrada') {
          newCost =
              ((oldQty * oldCost) + (item.quantity * item.unitPrice)) / newQty;
        }

        await docRef.update({
          'quantity': newQty,
          'cost': newCost,
          'unitPrice': item.unitPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _firestore
            .collection('users')
            .doc(widget.uid)
            .collection('movements')
            .add({
          'productId': docRef.id,
          'productName': item.name,
          'type': movementType == 'entrada' ? 'add' : 'remove',
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'cost': item.quantity * item.unitPrice,
          'timestamp': Timestamp.fromDate(selectedDate),
        });
      } catch (e) {
        debugPrint('Erro ao finalizar ${item.name}: $e');
      }
    }

    if (!mounted) return;
    setState(() => cart.clear());
  }

  Future<void> _openFinalizeModal(String movementType) async {
    if (cart.isEmpty) return;

    final result = await showDialog<FinalizeModalResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FinalizeModal(),
    );

    if (!mounted) return;

    if (result != null) {
      await _finalizeCart(movementType, result.selectedDate);
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ========================
  // SCAN
  // ========================
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty || _hasScanned) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _controller.stop();

    setState(() {
      scannedCode = code;
      _hasScanned = true;
      _isError = false;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.uid)
          .collection('products')
          .where('barcode', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          productName = 'Produto não encontrado';
          _isError = true;
        });
      } else {
        final data = snapshot.docs.first.data();
        HapticFeedback.vibrate();

        setState(() {
          final index = cart.indexWhere((i) => i.barcode == code);

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
        });
      }
    } catch (e) {
      setState(() {
        productName = 'Erro ao buscar produto';
        _isError = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1800));

    setState(() {
      scannedCode = null;
      productName = null;
      _hasScanned = false;
      _isError = false;
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
