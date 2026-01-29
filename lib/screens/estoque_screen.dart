// lib/screens/estoque_screen.dart
import 'dart:async'; // debounce
import 'package:flutter/foundation.dart' show kDebugMode;

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

// ✅ feed misto
import '../feed/feed_builder.dart';
import '../feed/feed_item.dart';

// ✅ ads
import 'widgets/ads/product_ad_card.dart';

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

  // ✅ SEU AD UNIT ID NATIVO OFICIAL (com /)
  // (o da sua tela do AdMob)
  static const String _kNativeAdUnitId =
      'ca-app-pub-7511114302969154/9353304194';

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
                        if (_selectedCategoryIndexNotifier.value == index) {
                          return;
                        }
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
                          category.name,
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
                      product.category ==
                          _categoryNameByIdFallback(selectedCategoryId);

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

                // ✅ Feed misto com anúncios
                final feed = buildFeedWithAds(
                  products: filteredProducts,
                  interval: 8, // 6~10 é saudável
                );

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: feed.length,
                  itemBuilder: (context, index) {
                    final item = feed[index];

                    if (item is AdFeedItem) {
                      return ProductAdCard(
                        key: ValueKey('ad_$index'),
                        adUnitId: _kNativeAdUnitId,

                        // ✅ Debug => teste; Release => real
                        // Se um dia quiser forçar real no debug, troque por: false
                        useTestAdUnit: kDebugMode,

                        aspectRatio: 1.0,
                      );
                    }

                    final product = (item as ProductFeedItem).product;

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

  String _categoryNameByIdFallback(String categoryId) {
    return categoryId;
  }
}
