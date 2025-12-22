import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertasScreen extends StatelessWidget {
  final String userLogin;

  const AlertasScreen({super.key, required this.userLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Alertas de Estoque',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userLogin)
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado'));
          }

          final docs = snapshot.data!.docs;

          // 🔴 Estoque zerado
          final zeroStock = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['quantity'] ?? 0) == 0;
          }).toList();

          // 🟠 Estoque crítico
          final criticalStock = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final int quantity = data['quantity'] is int
                ? data['quantity']
                : int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;

            final int minStock = data['minStock'] is int
                ? data['minStock']
                : int.tryParse(data['minStock']?.toString() ?? '0') ?? 0;

            return quantity > 0 && quantity <= minStock;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                if (zeroStock.isNotEmpty) ...[
                  const _SectionHeader(
                    title: 'Estoque Zerado',
                    backgroundColor: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  ...zeroStock.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    final String name =
                        (data['name'] is String &&
                                data['name'].toString().isNotEmpty)
                            ? data['name']
                            : 'Produto sem nome';

                    // ✅ CAMPO CORRETO: image
                    final String? imageBase64 =
                        data['image'] is String ? data['image'] : null;

                    return _AlertCard(
                      name: name,
                      quantity: 0,
                      color: Colors.red,
                      icon: Icons.cancel_outlined,
                      imageBase64: imageBase64,
                    );
                  }),
                  const SizedBox(height: 28),
                ],
                if (criticalStock.isNotEmpty) ...[
                  const _SectionHeader(
                    title: 'Estoque Crítico',
                    backgroundColor: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  ...criticalStock.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    final String name =
                        (data['name'] is String &&
                                data['name'].toString().isNotEmpty)
                            ? data['name']
                            : 'Produto sem nome';

                    final int quantity = data['quantity'] is int
                        ? data['quantity']
                        : int.tryParse(
                                data['quantity']?.toString() ?? '0') ??
                            0;

                    // ✅ CAMPO CORRETO: image
                    final String? imageBase64 =
                        data['image'] is String ? data['image'] : null;

                    return _AlertCard(
                      name: name,
                      quantity: quantity,
                      color: Colors.orange,
                      icon: Icons.warning_amber_rounded,
                      imageBase64: imageBase64,
                    );
                  }),
                ],
                if (zeroStock.isEmpty && criticalStock.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Nenhum alerta de estoque no momento',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================
/// 🧩 HEADER DE SEÇÃO
/// ============================
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;

  const _SectionHeader({
    required this.title,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ============================
/// 🧩 CARD DE ALERTA (BASE64 REAL)
/// ============================
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
        // 🧹 Remove "data:image/png;base64,"
        final String cleanedBase64 = imageBase64!.contains(',')
            ? imageBase64!.split(',').last
            : imageBase64!;

        imageBytes = base64Decode(cleanedBase64);
      } catch (_) {
        imageBytes = null;
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(icon, color: color, size: 32),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Quantidade: $quantity',
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}
