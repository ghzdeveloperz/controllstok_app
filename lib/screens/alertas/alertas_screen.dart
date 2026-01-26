// lib/screens/alertas/alertas_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import 'models/alertas_filter.dart';
import 'models/stock_alert_item.dart';
import 'widgets/alertas_empty_state.dart';
import 'widgets/alertas_search_filter_bar.dart';
import 'widgets/alertas_section_header.dart';
import 'widgets/premium_alert_card.dart';

class AlertasScreen extends StatefulWidget {
  final String uid;

  const AlertasScreen({super.key, required this.uid});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  String _searchQuery = '';
  AlertasFilter _filter = AlertasFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.alertasTitle,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          AlertasSearchFilterBar(
            searchQuery: _searchQuery,
            onSearchChange: (value) => setState(() => _searchQuery = value),
            filter: _filter,
            onFilterChange: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const AlertasEmptyState();
                }

                final queryLower = _searchQuery.toLowerCase().trim();

                final items = snapshot.data!.docs
                    .map((d) => StockAlertItem.fromDoc(d))
                    .where((item) => item.matchesSearch(queryLower))
                    .toList();

                final zeroStock = items.where((e) => e.isZero).toList();
                final criticalStock = items.where((e) => e.isCritical).toList();

                final filteredZero = _filter == AlertasFilter.critical
                    ? <StockAlertItem>[]
                    : zeroStock;
                final filteredCritical = _filter == AlertasFilter.zero
                    ? <StockAlertItem>[]
                    : criticalStock;

                if (filteredZero.isEmpty && filteredCritical.isEmpty) {
                  return const AlertasEmptyState();
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    if (filteredZero.isNotEmpty) ...[
                      AlertasSectionHeader(
                        title: l10n.alertasSectionZero,
                        color: const Color(0xFFD32F2F),
                      ),
                      const SizedBox(height: 16),
                      ...filteredZero.map(
                        (item) => PremiumAlertCard(
                          item: item,
                          isZero: true,
                          onOrderNow: () {
                            // TODO: conectar ação real
                          },
                          onNotify: () {
                            // TODO: conectar ação real
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (filteredCritical.isNotEmpty) ...[
                      AlertasSectionHeader(
                        title: l10n.alertasSectionCritical,
                        color: const Color(0xFFF57C00),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: filteredCritical.length,
                        itemBuilder: (context, index) => PremiumAlertCard(
                          item: filteredCritical[index],
                          isZero: false,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
