import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../scan_result_card.dart';

import '../../../l10n/app_localizations.dart';

import 'widgets/scanner_overlay.dart';

class BarcodeScannerModal extends StatefulWidget {
  const BarcodeScannerModal({super.key});

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scanLineAnimation;

  late final MobileScannerController _scannerController;

  bool _isTorchOn = false;

  bool _showResult = false;
  String? _scannedCode;
  bool _isError = false;

  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();

    _scannerController = MobileScannerController();

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
    _scannerController.dispose();
    super.dispose();
  }

  void _safePop([dynamic result]) {
    if (!_hasPopped && Navigator.canPop(context)) {
      _hasPopped = true;
      Navigator.of(context).pop(result);
    }
  }

  void _onBarcodeDetected(String code) {
    if (_hasPopped) return;

    _animationController.stop();

    setState(() {
      _scannedCode = code;
      _isError = false;
      _showResult = true;
    });
  }

  void _onResultDismiss() {
    if (_hasPopped) return;

    setState(() => _showResult = false);
    _safePop(_scannedCode);
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    if (!mounted) return;
    setState(() => _isTorchOn = !_isTorchOn);
  }

  void _close() {
    _animationController.stop();
    _safePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                controller: _scannerController,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isEmpty) return;

                  final code = barcodes.first.rawValue ?? '';
                  if (code.isEmpty) return;

                  _onBarcodeDetected(code);
                },
              ),

              ScannerOverlay(
                scanLineTop: _scanLineAnimation,
                isTorchOn: _isTorchOn,
                onClose: _close,
                onToggleTorch: _toggleTorch,
              ),
            ] else
              // Resultado (agora com título i18n)
              ScanResultCard(
                productName: l10n.scannerResultSuccessTitle,
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
