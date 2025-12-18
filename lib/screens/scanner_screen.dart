import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() {
      scannedCode = code;
      _hasScanned = true;
    });

    _controller.stop();

    try {
      debugPrint(
        'Buscando produto no caminho: /users/${widget.userLogin}/products',
      );
      debugPrint('Barcode escaneado: $code');

      // Consulta no Firestore pelo barcode
      final querySnapshot = await _firestore
          .collection('users')
          .doc(widget.userLogin)
          .collection('products')
          .where('barcode', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        debugPrint('Produto encontrado: ${doc['name']} (Barcode: $code)');
        setState(() {
          productName = doc['name'] ?? 'Nome não disponível';
        });
      } else {
        debugPrint('Produto não encontrado para o barcode: $code');
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
  }

  void _resetScanner() {
    setState(() {
      scannedCode = null;
      productName = null;
      _hasScanned = false;
    });
    _controller.start();
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
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetScanner),
        ],
      ),
      body: Stack(
        children: [
          // Câmera full screen
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Marcador central
          if (!_hasScanned)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 80,
                decoration: BoxDecoration(
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

          // Resultado do scan
          if (_hasScanned)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.75 * 255).toInt()),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      productName == 'Produto não encontrado' ||
                              productName == 'Erro ao buscar produto'
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color:
                          productName == 'Produto não encontrado' ||
                              productName == 'Erro ao buscar produto'
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      productName ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (productName == 'Produto não encontrado' ||
                        productName == 'Erro ao buscar produto')
                      const SizedBox(height: 6),
                    if (productName == 'Produto não encontrado' ||
                        productName == 'Erro ao buscar produto')
                      Text(
                        'Código: $scannedCode',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Botão reset
          if (_hasScanned)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _resetScanner,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Escanear novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
