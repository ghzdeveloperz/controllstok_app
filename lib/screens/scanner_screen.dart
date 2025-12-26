import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Adicionado para tipografia premium

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
  late Animation<double> _scaleAnimation; // Nova animação para escala premium

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Duração aumentada para suavidade
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ========================
  // OVERLAY DO SCANNER PREMIUM
  // ========================
  Widget _buildScannerOverlay() {
    if (_hasScanned) return const SizedBox.shrink();

    return Align(
      alignment: const Alignment(0, -0.4), // Movido mais para cima (Y negativo para subir)
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Retângulo de scanner premium com gradiente e sombra
          Container(
            width: 320,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24), // Bordas mais arredondadas
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(50), // Semi-transparente para efeito vidro
                  Colors.white.withAlpha(20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ],
              border: Border.all(
                color: Colors.white.withAlpha(150),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Cantos premium com ícones
                _buildPremiumCorner(top: 0, left: 0),
                _buildPremiumCorner(top: 0, right: 0, rotate: true),
                _buildPremiumCorner(bottom: 0, left: 0, rotate: true),
                _buildPremiumCorner(bottom: 0, right: 0),
                // Linha de varredura animada com brilho
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: _animationController.value * 140, // Animação vertical suave
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.cyanAccent,
                              Colors.white,
                              Colors.cyanAccent,
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withAlpha(150),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), // Espaçamento aumentado
          // Texto premium com fonte elegante
          FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                'Posicione o código de barras',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Subtexto adicional para orientação
          FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              'Mantenha estável para melhor leitura',
              style: GoogleFonts.poppins(
                color: Colors.white.withAlpha(180),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cantos premium com ícones e efeitos
  Widget _buildPremiumCorner({
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
        angle: rotate ? 3.14159 / 2 : 0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent.withAlpha(200),
                Colors.white.withAlpha(100),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withAlpha(100),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Icon(
            Icons.qr_code_scanner,
            color: Colors.white.withAlpha(200),
            size: 20,
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

    /// 🔒 PRÉ-VALIDAÇÃO DE ESTOQUE (SÓ PARA SAÍDA)
    if (movementType == 'saida') {
      for (final item in cart) {
        final snapshot = await _firestore
            .collection('users')
            .doc(widget.uid)
            .collection('products')
            .where('barcode', isEqualTo: item.barcode)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produto ${item.name} não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final currentQty = (snapshot.docs.first.data()['quantity'] ?? 0).toInt();

        if (item.quantity > currentQty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Estoque insuficiente para ${item.name}. Disponível: $currentQty',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    /// 🔄 ATUALIZAÇÃO REAL (SE PASSOU NA VALIDAÇÃO)
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

        double newCost = oldCost;

        if (movementType == 'entrada') {
          newCost = ((oldQty * oldCost) + (item.quantity * item.unitPrice)) / newQty;
        }

        await docRef.update({
          'quantity': newQty,
          'cost': newCost,
          'unitPrice': item.unitPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('users').doc(widget.uid).collection('movements').add({
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
                imageUrl: data['image'] ?? '',
                unitPrice: (data['unitPrice'] ?? 0).toDouble(),
                quantity: 1,
                initialQuantity: (data['quantity'] ?? 0).toInt(),
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

  void _incrementQuantity(int index) => setState(() => cart[index].quantity++);

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
          if (_hasScanned && scannedCode != null && productName != null)
            ScanResultCard(
              productName: productName!,
              scannedCode: scannedCode!,
              isError: _isError,
              onDismiss: () {},
            ), // Agora no final para aparecer acima de tudo
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
  final String imageUrl;
  double unitPrice;
  int quantity;
  final int initialQuantity;

  CartItem({
    required this.barcode,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.initialQuantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      barcode: barcode,
      name: name,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      initialQuantity: initialQuantity,
    );
  }
}