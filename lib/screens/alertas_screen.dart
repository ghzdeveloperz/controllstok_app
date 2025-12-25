import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertasScreen extends StatelessWidget {
  final String uid;

  const AlertasScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: width * 0.85,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(-8, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // ───────── HEADER ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Alertas de Estoque',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: Colors.black, // 🔥 título preto (paleta base)
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black),
                    splashRadius: 22,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ───────── CONTEÚDO ─────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _EmptyState();
                  }

                  final docs = snapshot.data!.docs;

                  final zeroStock = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return (data['quantity'] ?? 0) == 0;
                  }).toList();

                  final criticalStock = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final quantity =
                        int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;

                    final minStock =
                        int.tryParse(data['minStock']?.toString() ?? '0') ?? 0;

                    return quantity > 0 && quantity <= minStock;
                  }).toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: [
                      if (zeroStock.isNotEmpty) ...[
                        const _SectionHeader(
                          title: 'Estoque zerado',
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        ...zeroStock.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};

                          return _AlertCard(
                            name: data['name'] ?? 'Produto sem nome',
                            quantity: 0,
                            color: Colors.red,
                            icon: Icons.cancel_outlined,
                            imageBase64: data['image'],
                          );
                        }),
                        const SizedBox(height: 28),
                      ],
                      if (criticalStock.isNotEmpty) ...[
                        const _SectionHeader(
                          title: 'Estoque crítico',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        ...criticalStock.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};

                          final quantity =
                              int.tryParse(
                                data['quantity']?.toString() ?? '0',
                              ) ??
                              0;

                          return _AlertCard(
                            name: data['name'] ?? 'Produto sem nome',
                            quantity: quantity,
                            color: Colors.orange,
                            icon: Icons.warning_amber_rounded,
                            imageBase64: data['image'],
                          );
                        }),
                      ],
                      if (zeroStock.isEmpty && criticalStock.isEmpty)
                        const _EmptyState(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────
/// HEADER DE SEÇÃO
/// ─────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// ─────────────────────────────
/// CARD DE ALERTA
/// ─────────────────────────────
class _AlertCard extends StatelessWidget {
  final String name;
  final int quantity;
  final Color color;
  final IconData icon;
  final String? imageBase64;

  const _AlertCard({
    required this.name,
    required this.quantity,
    required this.color,
    required this.icon,
    this.imageBase64,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        imageBytes = base64Decode(
          imageBase64!.contains(',')
              ? imageBase64!.split(',').last
              : imageBase64!,
        );
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          imageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    imageBytes,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantidade: $quantity',
                  style: GoogleFonts.poppins(fontSize: 13, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────
/// ESTADO VAZIO
/// ─────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: Colors.black.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum alerta no momento',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
