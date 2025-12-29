// lib/screens/estoque_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore/products_firestore.dart';
import '../firebase/firestore/categories_firestore.dart';
import '../firebase/firestore/users_firestore.dart';

import 'widgets/product_card.dart';
import 'models/product.dart';
import 'models/category.dart';
import '../screens/conf_options/perfil_screen.dart'; // Adicione este import, assumindo que PerfilScreen está em '../screens/perfil_screen.dart'

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
  bool _isAvatarPulsing = false; // Estado para controlar a animação de pulso

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
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UsersFirestore.streamLogin(widget.uid),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          final company = data?['company'] as String?;
          final email = data?['email'] as String? ?? '';
          final photoUrl = data?['photoUrl'] as String?;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                          color: Colors.black.withValues(alpha: 0.15),
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
              ),
              GestureDetector(
                onTapDown: (_) => setState(() => _isAvatarPulsing = true),
                onTapUp: (_) {
                  setState(() => _isAvatarPulsing = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PerfilScreen()),
                  );
                },
                onTapCancel: () => setState(() => _isAvatarPulsing = false),
                child: AnimatedScale(
                  scale: _isAvatarPulsing ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black87,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? CachedNetworkImageProvider(photoUrl)
                          : null,
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? Text(
                              email.isNotEmpty ? email[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
                .addListener(ImageStreamListener((_, _) {}));
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

Widget buildAvatar({
  required String email,
  String? photoUrl,
  double radius = 20,
}) {
  final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.black87,
    backgroundImage: hasPhoto ? CachedNetworkImageProvider(photoUrl) : null,
    child: hasPhoto
        ? null
        : Text(
            email.isNotEmpty ? email[0].toUpperCase() : 'U',
            style: TextStyle(
              fontSize: radius,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
  );
}
