// lib/screens/widgets/product_card/product_card.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/product.dart';
import '../product_details/product_details_modal.dart';
import '../../../l10n/app_localizations.dart';

import 'product_card_view_model.dart';
import 'product_card_formatters.dart';
import 'product_status.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String uid;
  final List<String> userCategories;
  final ImageProvider? imageProvider;

  /// Blur é lindo, mas pode pesar em grids longos.
  final bool enableGlassBlur;

  /// Ajusta o tamanho de decode/cache das imagens
  final int imageCacheSizePx;

  /// ✅ Mantém o card quadrado (1:1) e evita “crescer demais”
  final double aspectRatio;

  const ProductCard({
    super.key,
    required this.product,
    required this.uid,
    required this.userCategories,
    this.imageProvider,
    this.enableGlassBlur = false,
    this.imageCacheSizePx = 512,
    this.aspectRatio = 1.0,
  });

  static const _formatters = ProductCardFormatters();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = ProductCardViewModel(product);

    final status = vm.status;
    final statusColor = status.color();
    final statusLabel = _formatters.statusLabel(l10n, status);

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: aspectRatio, // ✅ aqui controla o tamanho do card
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ProductDetailsModal(product: product, uid: uid),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _ProductCardImage(
                      imageUrl: vm.imageUrl,
                      imageProvider: imageProvider,
                      cacheSizePx: imageCacheSizePx,
                    ),
                  ),
                  const Positioned.fill(child: _GradientOverlay()),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _InfoBlock(
                      enableGlassBlur: enableGlassBlur,
                      name: vm.name,
                      category: vm.category,
                      stockLabel: _formatters.stockLabel(l10n, vm.quantity),
                      totalValueLabel: _formatters.currency(l10n, vm.totalValue),
                      statusLabel: statusLabel,
                      statusColor: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  final String imageUrl;
  final ImageProvider? imageProvider;
  final int cacheSizePx;

  const _ProductCardImage({
    required this.imageUrl,
    required this.imageProvider,
    required this.cacheSizePx,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const _ImagePlaceholder();

    if (imageProvider != null) {
      return Image(
        image: imageProvider!,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheWidth: cacheSizePx,
      memCacheHeight: cacheSizePx,
      maxWidthDiskCache: cacheSizePx * 2,
      maxHeightDiskCache: cacheSizePx * 2,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => const _ImagePlaceholder(),
      errorWidget: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.12),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final bool enableGlassBlur;

  final String name;
  final String category;
  final String stockLabel;
  final String totalValueLabel;
  final String statusLabel;
  final Color statusColor;

  const _InfoBlock({
    required this.enableGlassBlur,
    required this.name,
    required this.category,
    required this.stockLabel,
    required this.totalValueLabel,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(enableGlassBlur ? 0.18 : 0.22),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(name: name, category: category),
          const SizedBox(height: 2),
          _StockAndValueRow(
            stockLabel: stockLabel,
            totalValueLabel: totalValueLabel,
          ),
          const SizedBox(height: 1),
          _StatusRow(
            statusLabel: statusLabel,
            statusColor: statusColor,
          ),
        ],
      ),
    );

    if (!enableGlassBlur) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
          child: content,
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String name;
  final String category;

  const _HeaderRow({
    required this.name,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _StockAndValueRow extends StatelessWidget {
  final String stockLabel;
  final String totalValueLabel;

  const _StockAndValueRow({
    required this.stockLabel,
    required this.totalValueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            stockLabel,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          totalValueLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.green.shade300,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String statusLabel;
  final Color statusColor;

  const _StatusRow({
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          statusLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: statusColor.withOpacity(0.9),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
