// lib/screens/estoque_screen.dart
import 'dart:async'; // debounce
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore/products_firestore.dart';
import '../firebase/firestore/categories_firestore.dart';
import '../firebase/firestore/users_firestore.dart';

import 'widgets/product_card/product_card.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'userPerfil/perfil_screen.dart';

import '../l10n/app_localizations.dart';

class EstoqueScreen extends StatefulWidget {
  final String uid;
  final void Function(List<Product>)? onProductsLoaded;

  const EstoqueScreen({super.key, required this.uid, this.onProductsLoaded});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  // ✅ ID estável para categoria "Todos" (não depende do idioma)
  static const String _kAllCategoryId = '__all__';

  // Busca e filtros
  final ValueNotifier<String> _searchTextNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _selectedCategoryIdNotifier =
      ValueNotifier<String>(_kAllCategoryId);
  final ValueNotifier<int> _selectedCategoryIndexNotifier =
      ValueNotifier<int>(0);

  Timer? _debounceTimer;

  // Cache de imagens fora do build
  final Map<String, CachedNetworkImageProvider> _cachedImages = {};

  // Avatar pulse
  bool _isAvatarPulsing = false;

  @override
  void dispose() {
    _searchTextNotifier.dispose();
    _selectedCategoryIdNotifier.dispose();
    _selectedCategoryIndexNotifier.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updateSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchTextNotifier.value = value.toLowerCase();
    });
  }

  void _precacheImages(List<Product> products) {
    for (final product in products) {
      if (!_cachedImages.containsKey(product.id)) {
        final provider = CachedNetworkImageProvider(product.image);
        _cachedImages[product.id] = provider;
        provider
            .resolve(const ImageConfiguration())
            .addListener(ImageStreamListener((_, __) {}));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              _buildSearch(l10n),
              _buildCategories(l10n),
              Expanded(child: _buildProducts(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UsersFirestore.streamLogin(widget.uid),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          final company = data?['company'] as String?;
          final email = data?['email'] as String? ?? '';
          final photoUrl = data?['photoUrl'] as String?;

          final greeting = (company == null || company.trim().isEmpty)
              ? l10n.hello
              : l10n.helloCompany(company.trim());

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.stockToday,
                    style: TextStyle(
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
                    MaterialPageRoute(builder: (_) => const PerfilScreen()),
                  );
                },
                onTapCancel: () => setState(() => _isAvatarPulsing = false),
                child: AnimatedScale(
                  scale: _isAvatarPulsing ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black87,
                      backgroundImage:
                          (photoUrl != null && photoUrl.isNotEmpty)
                              ? CachedNetworkImageProvider(photoUrl)
                              : null,
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? Text(
                              email.isNotEmpty
                                  ? email[0].toUpperCase()
                                  : 'U',
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

  Widget _buildSearch(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: _updateSearch,
        decoration: InputDecoration(
          hintText: l10n.searchProductHint,
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

  Widget _buildCategories(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 1),
      child: SizedBox(
        height: 44,
        child: StreamBuilder<List<Category>>(
          stream: CategoriesFirestore.streamCategories(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            // ✅ Primeiro item é "Todos" com ID estável
            final categories = <Category>[
              Category(id: _kAllCategoryId, name: l10n.allCategory),
              ...(snapshot.data ?? []),
            ];

            return ValueListenableBuilder<String>(
              valueListenable: _selectedCategoryIdNotifier,
              builder: (context, selectedCategoryId, _) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == selectedCategoryId;

                    return GestureDetector(
                      onTap: () {
                        if (_selectedCategoryIndexNotifier.value == index) return;
                        _selectedCategoryIndexNotifier.value = index;
                        _selectedCategoryIdNotifier.value = category.id;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.grey.shade300,
                            width: 1.4,
                          ),
                        ),
                        child: Text(
                          category.name, // "Todos" já vem traduzido aqui
                          style: TextStyle(
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildProducts(AppLocalizations l10n) {
    return StreamBuilder<List<Product>>(
      stream: ProductsFirestore.streamProducts(widget.uid),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];

        _precacheImages(products);

        if (widget.onProductsLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onProductsLoaded!(products);
          });
        }

        return ValueListenableBuilder<String>(
          valueListenable: _searchTextNotifier,
          builder: (context, searchText, _) {
            return ValueListenableBuilder<String>(
              valueListenable: _selectedCategoryIdNotifier,
              builder: (context, selectedCategoryId, _) {
                final filteredProducts = products.where((product) {
                  final matchesSearch =
                      product.name.toLowerCase().contains(searchText);

                  final matchesCategory = selectedCategoryId == _kAllCategoryId ||
                      product.category == selectedCategoryId ||
                      product.category == _categoryNameByIdFallback(selectedCategoryId);

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noProductsFound,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
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
                      userCategories:
                          products.map((p) => p.category).toSet().toList(),
                      imageProvider: _cachedImages[product.id],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// ⚠️ Fallback: se seu Product.category salva "nome" ao invés de "id",
  /// você pode adaptar aqui. Mantive um fallback simples.
  String _categoryNameByIdFallback(String categoryId) {
    // Se o seu product.category salva "nome", então selectedCategoryId deveria ser "nome".
    // Como não tenho o seu model aqui, deixei neutro.
    return categoryId;
  }
}

// Ícone de notificações simples (mantido)
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
