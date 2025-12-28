import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertasScreen extends StatefulWidget {
  final String uid;

  const AlertasScreen({super.key, required this.uid});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  String _searchQuery = '';
  String _filter = 'Todos'; // 'Todos', 'Zerado', 'Crítico'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Fundo premium em cinza muito claro
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Alertas de Estoque',
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
          // Barra de Pesquisa e Filtro Premium
          Padding(
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
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 8,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar produto...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
                        blurRadius: 8,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) => setState(() => _filter = value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Todos', child: Text('Todos')),
                      const PopupMenuItem(value: 'Zerado', child: Text('Zerado')),
                      const PopupMenuItem(value: 'Crítico', child: Text('Crítico')),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(Icons.filter_list, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
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
                  return _EmptyState();
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toLowerCase() ?? '';
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                final zeroStock = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['quantity'] ?? 0) == 0;
                }).toList();

                final criticalStock = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final quantity = int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
                  final minStock = int.tryParse(data['minStock']?.toString() ?? '0') ?? 0;
                  return quantity > 0 && quantity <= minStock;
                }).toList();

                final filteredZero = _filter == 'Crítico' ? [] : zeroStock;
                final filteredCritical = _filter == 'Zerado' ? [] : criticalStock;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    if (filteredZero.isNotEmpty) ...[
                      _SectionHeader(title: 'Estoque Zerado', color: const Color(0xFFD32F2F)),
                      const SizedBox(height: 16),
                      ...filteredZero.map((doc) => _PremiumAlertCard(
                            doc: doc,
                            isCritical: true,
                          )),
                      const SizedBox(height: 32),
                    ],
                    if (filteredCritical.isNotEmpty) ...[
                      _SectionHeader(title: 'Estoque Crítico', color: const Color(0xFFF57C00)),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: filteredCritical.length,
                        itemBuilder: (context, index) => _PremiumAlertCard(
                          doc: filteredCritical[index],
                          isCritical: false,
                        ),
                      ),
                    ],
                    if (filteredZero.isEmpty && filteredCritical.isEmpty) _EmptyState(),
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

// Header de Seção Premium
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Card de Alerta Premium Unificado
class _PremiumAlertCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final bool isCritical;

  const _PremiumAlertCard({required this.doc, required this.isCritical});

  @override
  State<_PremiumAlertCard> createState() => _PremiumAlertCardState();
}

class _PremiumAlertCardState extends State<_PremiumAlertCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.isCritical) {
      _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    if (widget.isCritical) _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final quantity = int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
    final color = widget.isCritical ? const Color(0xFFD32F2F) : const Color(0xFFF57C00);

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
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 16,
                    offset: const Offset(-6, -6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    blurRadius: 12,
                    offset: const Offset(-4, -4),
                  ),
                ],
        ),
        child: widget.isCritical
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: data['image'] != null && data['image'].isNotEmpty
                        ? Image.network(data['image'], width: 70, height: 70, fit: BoxFit.cover)
                        : Container(
                            width: 70,
                            height: 70,
                            color: color.withOpacity(0.1),
                            child: Icon(Icons.cancel_outlined, color: color, size: 32),
                          ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'Produto',
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
                          'Quantidade: $quantity',
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          elevation: 0,
                        ),
                        child: Text('Pedir Agora', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color, width: 1.5),
                          foregroundColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: Text('Notificar', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: data['image'] != null && data['image'].isNotEmpty
                        ? Image.network(data['image'], width: 60, height: 60, fit: BoxFit.cover)
                        : Container(
                            width: 60,
                            height: 60,
                            color: color.withOpacity(0.1),
                            child: Icon(Icons.warning_amber_rounded, color: color, size: 28),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['name'] ?? 'Produto',
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
                      widthFactor: quantity / 10.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: quantity > 5 ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)] : [color, color.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Quantidade: $quantity',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );

    return widget.isCritical
        ? AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: card),
          )
        : card;
  }
}

// Estado Vazio Premium
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 16,
                  offset: const Offset(-6, -6),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhum alerta ativo',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seu estoque está em ordem!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}