// lib/screens/alertas/widgets/premium_alert_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../models/stock_alert_item.dart';

class PremiumAlertCard extends StatefulWidget {
  final StockAlertItem item;

  /// true = estoque zerado (card grande com CTA)
  /// false = estoque crítico (card grid)
  final bool isZero;

  /// callbacks (você conecta depois)
  final VoidCallback? onOrderNow;
  final VoidCallback? onNotify;

  const PremiumAlertCard({
    super.key,
    required this.item,
    required this.isZero,
    this.onOrderNow,
    this.onNotify,
  });

  @override
  State<PremiumAlertCard> createState() => _PremiumAlertCardState();
}

class _PremiumAlertCardState extends State<PremiumAlertCard>
    with TickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    if (widget.isZero) {
      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: true);

      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final item = widget.item;
    final quantity = item.quantity;

    final color = widget.isZero
        ? const Color(0xFFD32F2F)
        : const Color(0xFFF57C00);

    final card = GestureDetector(
      onTap: () => setState(() => _isHovered = !_isHovered),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [Colors.white, const Color(0xFFF0F0F0)]
                : [Colors.white, const Color(0xFFF8F8F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withAlpha(51), width: 1.5),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(31),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(20),
                    blurRadius: 16,
                    offset: const Offset(-6, -6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(230),
                    blurRadius: 12,
                    offset: const Offset(-4, -4),
                  ),
                ],
        ),
        child: widget.isZero
            ? _buildZeroCard(context, l10n, item, quantity, color)
            : _buildCriticalGridCard(context, l10n, item, quantity, color),
      ),
    );

    if (!widget.isZero || _pulseAnimation == null) return card;

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) =>
          Transform.scale(scale: _pulseAnimation!.value, child: card),
    );
  }

  Widget _buildZeroCard(
    BuildContext context,
    AppLocalizations l10n,
    StockAlertItem item,
    int quantity,
    Color color,
  ) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: color.withAlpha(26),
                  child: Icon(Icons.cancel_outlined, color: color, size: 32),
                ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.alertasQuantityWithValue(quantity.toString()),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            ElevatedButton(
              onPressed: widget.onOrderNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.alertasOrderNow,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: widget.onNotify,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 1.5),
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: Text(
                l10n.alertasNotify,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCriticalGridCard(
    BuildContext context,
    AppLocalizations l10n,
    StockAlertItem item,
    int quantity,
    Color color,
  ) {
    // barra: clamp 0..1 (antes podia estourar)
    final raw = quantity / 10.0;
    final widthFactor = raw.isNaN ? 0.0 : raw.clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: color.withAlpha(26),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: color,
                    size: 28,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          item.name,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: quantity > 5
                      ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                      : [color, color.withAlpha(179)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.alertasQuantityWithValue(quantity.toString()),
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
