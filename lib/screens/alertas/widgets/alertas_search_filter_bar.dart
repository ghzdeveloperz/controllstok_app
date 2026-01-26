// lib/screens/alertas/widgets/alertas_search_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../models/alertas_filter.dart';

class AlertasSearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChange;

  final AlertasFilter filter;
  final ValueChanged<AlertasFilter> onFilterChange;

  const AlertasSearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChange,
    required this.filter,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(230),
                    blurRadius: 8,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChange,
                decoration: InputDecoration(
                  hintText: l10n.alertasSearchHint,
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.white.withAlpha(230),
                  blurRadius: 8,
                  offset: const Offset(-4, -4),
                ),
              ],
            ),
            child: PopupMenuButton<AlertasFilter>(
              onSelected: onFilterChange,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: AlertasFilter.all,
                  child: Text(l10n.alertasFilterAll),
                ),
                PopupMenuItem(
                  value: AlertasFilter.zero,
                  child: Text(l10n.alertasFilterZero),
                ),
                PopupMenuItem(
                  value: AlertasFilter.critical,
                  child: Text(l10n.alertasFilterCritical),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(Icons.filter_list, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
