// lib/screens/userPerfil/config_options/traducer/widgets/language_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;
  final String? trailingText;

  const LanguageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
    this.trailingText,
  });

  @override
  State<LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<LanguageCard> {
  bool _pressed = false;

  // Paleta premium (preto/branco)
  static const Color _surface = Colors.white;
  static const Color _ink = Color(0xFF0B0F14);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE7E9EE);

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.selected ? _ink : _border;

    // Micro-press: reduz um pouco quando pressiona
    final scale = _pressed ? 0.985 : 1.0;

    // “Sheen” sutil quando pressiona
    final highlight = _pressed
        ? _ink.withValues(alpha: 0.035)
        : Colors.transparent;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _pressed ? 0.03 : 0.045),
              blurRadius: _pressed ? 10 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),

            // splash/hover preto sutil
            splashColor: _ink.withValues(alpha: 0.06),
            highlightColor: _ink.withValues(alpha: 0.04),

            child: Ink(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                  width: widget.selected ? 1.6 : 1.0,
                ),
              ),
              child: Stack(
                children: [
                  // highlight overlay (premium)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: highlight,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        widget.leading,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _ink,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              if (widget.subtitle.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.2,
                                    fontWeight: FontWeight.w500,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        if (widget.trailingText != null && widget.selected) ...[
                          Text(
                            widget.trailingText!,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _ink.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],

                        _SelectPill(selected: widget.selected),
                      ],
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

class _SelectPill extends StatelessWidget {
  final bool selected;
  const _SelectPill({required this.selected});

  static const Color _ink = Color(0xFF0B0F14);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected ? _ink : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? _ink : _border, width: 1.2),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 18,
        color: selected ? Colors.white : Colors.transparent,
      ),
    );
  }
}
