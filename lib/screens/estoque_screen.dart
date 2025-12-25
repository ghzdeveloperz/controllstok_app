import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/products_firestore.dart';
import '../firebase/firestore/categories_firestore.dart';
import '../firebase/firestore/users_firestore.dart';

import 'widgets/product_card.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'alertas_screen.dart';

class EstoqueScreen extends StatefulWidget {
  final String uid;

  const EstoqueScreen({super.key, required this.uid});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  String _searchText = '';
  String _selectedCategory = 'Todos';

  int _selectedCategoryIndex = 0;
  int _slideDirection = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearch(),
            _buildCategories(),
            Expanded(child: _buildProducts()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<String?>(
            stream: UsersFirestore.streamLogin(
              widget.uid,
            ).map((snapshot) => snapshot.data()?['company'] as String?),
            builder: (context, snapshot) {
              final company = snapshot.data;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company == null ? 'Olá' : 'Olá, $company.',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Seu estoque hoje',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            },
          ),

          /// 🔔 Alertas (animado – apenas visual)
          AnimatedNotificationIcon(
            onTap: () {
              showGeneralDialog(
                context: context,
                barrierDismissible:
                    false, // deixamos false porque vamos tratar manualmente
                barrierLabel: 'Alertas',
                barrierColor: Colors.transparent,
                transitionDuration: const Duration(milliseconds: 260),
                pageBuilder: (context, animation, secondaryAnimation) {
                  final fadeAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuad,
                  );

                  final slideAnimation =
                      Tween<Offset>(
                        begin: const Offset(0.9, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutQuart,
                        ),
                      );

                  return Stack(
                    children: [
                      // 🔹 FUNDO (fade simples, captura toque)
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pop(context), // fecha ao tocar fora
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.32),
                            ),
                          ),
                        ),
                      ),

                      // 🔹 PAINEL LATERAL
                      Align(
                        alignment: Alignment.centerRight,
                        child: SlideTransition(
                          position: slideAnimation,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                decoration: TextDecoration
                                    .none, // remove sublinhado verde
                                color: Colors.black, // cor padrão para textos
                                fontSize: 14,
                              ),
                              child: AlertasScreen(uid: widget.uid),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                transitionBuilder: (_, __, ___, child) => child,
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar produto...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  // ================= CATEGORIES =================
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        height: 44,
        child: StreamBuilder<List<Category>>(
          stream: CategoriesFirestore.streamCategories(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(); // remove loading visual feio
            }

            final categories = [
              Category(id: 'todos', name: 'Todos'),
              ...(snapshot.data ?? []),
            ];

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category.name == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    if (_selectedCategoryIndex == index) return;

                    setState(() {
                      _slideDirection = index > _selectedCategoryIndex ? 1 : -1;
                      _selectedCategoryIndex = index;
                      _selectedCategory = category.name;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ================= PRODUCTS (ANIMADO) =================
  Widget _buildProducts() {
    return StreamBuilder<List<Product>>(
      stream: ProductsFirestore.streamProducts(widget.uid),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];

        final filteredProducts = products.where((product) {
          final matchesSearch = product.name.toLowerCase().contains(
            _searchText,
          );

          final matchesCategory =
              _selectedCategory == 'Todos' ||
              product.category == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: Offset(_slideDirection * 0.06, 0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: filteredProducts.isEmpty
              ? Center(
                  key: const ValueKey('empty'),
                  child: Text(
                    'Nenhum produto encontrado',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : GridView.builder(
                  key: ValueKey(_selectedCategory),
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: filteredProducts[index],
                      uid: widget.uid,
                      userCategories: products
                          .map((p) => p.category)
                          .toSet()
                          .toList(),
                    );
                  },
                ),
        );
      },
    );
  }
}

/// ============================
/// 🔔 ÍCONE DE ALERTA ANIMADO
/// ============================
class AnimatedNotificationIcon extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedNotificationIcon({super.key, required this.onTap});

  @override
  State<AnimatedNotificationIcon> createState() =>
      _AnimatedNotificationIconState();
}

class _AnimatedNotificationIconState extends State<AnimatedNotificationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: const Icon(
          Icons.notifications_none_outlined,
          size: 28,
          color: Colors.black87,
        ),
      ),
    );
  }
}
