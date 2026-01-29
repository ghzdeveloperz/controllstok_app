// lib/screens/widgets/ads/sponsored_loader.dart
import 'dart:math' as math;
import 'dart:ui'; // necessário para lerpDouble

import 'package:flutter/material.dart';

class SponsoredLoader extends StatefulWidget {
  final double size;

  const SponsoredLoader({
    super.key,
    this.size = 36,
  });

  @override
  State<SponsoredLoader> createState() => _SponsoredLoaderState();
}

class _SponsoredLoaderState extends State<SponsoredLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;

          // movimento horizontal suave
          final dx = lerpDouble(
            14,
            -14,
            (math.sin(t * 2 * math.pi) + 1) / 2,
          )!;

          // variação de escala (respiração)
          final scale = lerpDouble(
            1,
            0.4,
            (math.cos(t * 2 * math.pi) + 1) / 2,
          )!;

          return Stack(
            alignment: Alignment.center,
            children: [
              _dot(
                color: const Color(0xFF18181B), // preto zinc-900
                offsetX: dx,
                scale: scale,
              ),
              _dot(
                color: const Color(0xFFE4E4E7), // off-white zinc-200
                offsetX: -dx,
                scale: 1 - (scale - 0.4),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dot({
    required Color color,
    required double offsetX,
    required double scale,
  }) {
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
