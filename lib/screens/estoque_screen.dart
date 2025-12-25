// lib/screens/estoque_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../firebase/firestore/products_firestore.dart';
import '../firebase/firestore/categories_firestore.dart';
import '../firebase/firestore/users_firestore.dart';

import 'widgets/product_card.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'alertas_screen.dart';

class EstoqueScreen extends StatefulWidget {
  final String uid;
  final void Function(List<Product>)? onProductsLoaded;

  const EstoqueScreen({super.key, required this.uid, this.onProductsLoaded});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  String _searchText = '';
  String _selectedCategory = 'Todos';
  int _selectedCategoryIndex = 0;
  int _slideDirection = 1;

  final Map<String, CachedNetworkImageProvider> _cachedImages = {};

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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
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
          // Ícone de notificações sem pulsar
          GestureDetector(
            onTap: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: false,
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
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.32),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SlideTransition(
                          position: slideAnimation,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.black,
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
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 28,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) => setState(() => _searchText = value.toLowerCase()),
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

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        height: 44,
        child: StreamBuilder<List<Category>>(
          stream: CategoriesFirestore.streamCategories(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final categories = [
              Category(id: 'todos', name: 'Todos'),
              ...(snapshot.data ?? []),
            ];

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
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

  Widget _buildProducts() {
    return StreamBuilder<List<Product>>(
      stream: ProductsFirestore.streamProducts(widget.uid),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];

        for (var product in products) {
          if (!_cachedImages.containsKey(product.id)) {
            final provider = CachedNetworkImageProvider(product.image);
            _cachedImages[product.id] = provider;
            provider
                .resolve(const ImageConfiguration())
                .addListener(ImageStreamListener((_, __) {}));
          }
        }

        if (widget.onProductsLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onProductsLoaded!(products);
          });
        }

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
                    final product = filteredProducts[index];
                    return ProductCard(
                      product: product,
                      uid: widget.uid,
                      userCategories: products
                          .map((p) => p.category)
                          .toSet()
                          .toList(),
                      imageProvider: _cachedImages[product.id],
                    );
                  },
                ),
        );
      },
    );
  }
}

// Ícone de notificações simples, sem pulsar
class AnimatedNotificationIcon extends StatelessWidget {
  final VoidCallback onTap;
  const AnimatedNotificationIcon({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.notifications_none_outlined,
        size: 28,
        color: Colors.black87,
      ),
    );
  }
}
