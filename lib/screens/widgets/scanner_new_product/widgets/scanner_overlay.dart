import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class ScannerOverlay extends StatelessWidget {
  final Animation<double> scanLineTop;
  final bool isTorchOn;
  final VoidCallback onClose;
  final VoidCallback onToggleTorch;

  const ScannerOverlay({
    super.key,
    required this.scanLineTop,
    required this.isTorchOn,
    required this.onClose,
    required this.onToggleTorch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
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
                Colors.black.withAlpha(20),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
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
            child: AnimatedBuilder(
              animation: scanLineTop,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: scanLineTop.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.white.withAlpha(20),
                      ),
                    ),
                  ],
                );
              },
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
            child: Text(
              l10n.scannerBarcodeInstruction,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Botão de fechar
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onClose,
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

        // Botão de flash
        Positioned(
          bottom: 20,
          left: 20,
          child: GestureDetector(
            onTap: onToggleTorch,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(128), width: 1),
              ),
              child: Icon(
                isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
