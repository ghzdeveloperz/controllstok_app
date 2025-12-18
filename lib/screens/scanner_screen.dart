import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  String? scannedCode;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
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
  }

  void _resetScanner() {
    setState(() {
      scannedCode = null;
      _hasScanned = false;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Código de Barras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetScanner,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          if (scannedCode != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Código escaneado:\n$scannedCode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
