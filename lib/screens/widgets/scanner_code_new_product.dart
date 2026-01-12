import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Importe o arquivo scan_result.dart aqui
import 'scan_result_card.dart'; // Ajuste o caminho se necessário

class BarcodeScannerModal extends StatefulWidget {
  const BarcodeScannerModal({super.key});

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  // Novo: Controller para o scanner
  late MobileScannerController _scannerController;
  bool _isTorchOn = false; // Estado do flash

  // Novo: variável para controlar a exibição do resultado
  bool _showResult = false;
  String? _scannedCode;
  String? _productName;
  bool _isError = false;

  // Flag to prevent multiple pops
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(); // Inicializar controller

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 120).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose(); // Dispose do controller
    super.dispose();
  }

  void _onBarcodeDetected(String code) {
    if (_hasPopped) return; // Prevent further actions if already popped
    _animationController.stop();
    setState(() {
      _scannedCode = code;
      _productName = 'Código escaneado'; // Ou busque o nome do produto se disponível
      _isError = false; // Assumindo sucesso; ajuste se houver validação
      _showResult = true;
    });
  }

  void _onResultDismiss() {
    if (_hasPopped) return;
    setState(() {
      _showResult = false;
    });
    _safePop(_scannedCode);
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  void _safePop([dynamic result]) {
    if (!_hasPopped && Navigator.canPop(context)) {
      _hasPopped = true;
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (!_showResult) ...[
              MobileScanner(
                controller: _scannerController, // Passar o controller
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final code = barcodes.first.rawValue ?? '';
                    if (code.isNotEmpty) {
                      _onBarcodeDetected(code);
                    }
                  }
                },
              ),
              // Overlay com gradiente para foco
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(20),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withAlpha(20)
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
              // Retângulo de foco central
              Center(
                child: Container(
                  width: 280,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(51),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Linha de escaneamento animada
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanLineAnimation.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: Colors.white.withAlpha(20),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Instruções no topo
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(179),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(77), width: 1),
                  ),
                  child: const Text(
                    'Posicione o código de barras dentro da área destacada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Botão de fechar premium
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    _animationController.stop();
                    _safePop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(128), width: 1),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Botão de flash (agora funcional)
              Positioned(
                bottom: 20,
                left: 20,
                child: GestureDetector(
                  onTap: _toggleTorch,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(128), width: 1),
                    ),
                    child: Icon(
                      _isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ] else
              // Exibir o ScanResultCard quando _showResult for true
              ScanResultCard(
                productName: _productName ?? 'Produto',
                scannedCode: _scannedCode ?? '',
                isError: _isError,
                onDismiss: _onResultDismiss,
              ),
          ],
        ),
      ),
    );
  }
}