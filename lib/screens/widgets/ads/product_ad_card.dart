// lib/screens/widgets/ads/product_ad_card.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'sponsored_loader.dart';

class ProductAdCard extends StatefulWidget {
  final String adUnitId;
  final String factoryId;
  final double aspectRatio;

  /// ✅ true => usa ad unit de teste (recomendado no debug)
  final bool useTestAdUnit;

  const ProductAdCard({
    super.key,
    required this.adUnitId,
    this.factoryId = 'productCardNative',
    this.aspectRatio = 1.0,
    this.useTestAdUnit = false,
  });

  @override
  State<ProductAdCard> createState() => _ProductAdCardState();
}

class _ProductAdCardState extends State<ProductAdCard> {
  NativeAd? _ad;
  bool _loaded = false;

  static const String _testNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110'; // ✅ teste oficial Google

  String get _resolvedAdUnitId =>
      widget.useTestAdUnit ? _testNativeAdUnitId : widget.adUnitId;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _loaded = false;

    _ad?.dispose();
    _ad = NativeAd(
      adUnitId: _resolvedAdUnitId,
      factoryId: widget.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _ad = ad as NativeAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _loaded = false; // mantém loader
          });
          debugPrint('❌ NativeAd failed: ${error.code} - ${error.message}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: _loaded && _ad != null
                    ? AdWidget(ad: _ad!)
                    : _buildLoadingState(),
              ),

              // 🔖 Selo patrocinado (sempre visível)
              const Positioned(
                top: 10,
                left: 10,
                child: _SponsoredPill(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SponsoredLoader(size: 36),
          const SizedBox(height: 12),
          const Text(
            'Carregando anúncio…',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),

          // ✅ botão opcional pra recarregar (fica profissional e útil)
          TextButton(
            onPressed: _loadAd,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _SponsoredPill extends StatelessWidget {
  const _SponsoredPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: const Text(
        'Patrocinado',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black54,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
