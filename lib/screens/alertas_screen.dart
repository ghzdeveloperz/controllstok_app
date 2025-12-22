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
            .doc(userLogin) // 🔥 user logado
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

          // 🟠 Estoque crítico (1–10)
          final criticalStock = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final int quantity = data['quantity'] ?? 0;
            return quantity > 0 && quantity <= 10;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                if (zeroStock.isNotEmpty) ...[
                  const _SectionTitle(title: 'Estoque Zerado'),
                  const SizedBox(height: 8),
                  ...zeroStock.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    final String name =
                        (data['name'] is String &&
                            data['name'].toString().isNotEmpty)
                        ? data['name'].toString()
                        : 'Produto sem nome';

                    return _AlertCard(
                      name: name,
                      quantity: 0,
                      color: Colors.red,
                      icon: Icons.cancel_outlined,
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                if (criticalStock.isNotEmpty) ...[
                  const _SectionTitle(title: 'Estoque Crítico'),
                  const SizedBox(height: 8),
                  ...criticalStock.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    final String name =
                        (data['name'] is String &&
                            data['name'].toString().isNotEmpty)
                        ? data['name'].toString()
                        : 'Produto sem nome';

                    final int quantity = data['quantity'] is int
                        ? data['quantity']
                        : int.tryParse(data['quantity']?.toString() ?? '0') ??
                              0;

                    return _AlertCard(
                      name: name,
                      quantity: quantity,
                      color: Colors.orange,
                      icon: Icons.warning_amber_rounded,
                    );
                  }),
                ],

                if (zeroStock.isEmpty && criticalStock.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text('Nenhum alerta de estoque no momento'),
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
/// 🧩 TÍTULO DE SEÇÃO
/// ============================
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

/// ============================
/// 🧩 CARD DE ALERTA
/// ============================
class _AlertCard extends StatelessWidget {
  final String name;
  final int quantity;
  final Color color;
  final IconData icon;

  const _AlertCard({
    required this.name,
    required this.quantity,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Quantidade: $quantity', style: TextStyle(color: color)),
      ),
    );
  }
}
