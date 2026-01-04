// lib/screens/estoque_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Para debounce

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
  // Isolar estado da busca e filtros com ValueNotifier para reduzir rebuilds globais
  final ValueNotifier<String> _searchTextNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _selectedCategoryNotifier = ValueNotifier<String>('Todos');
  final ValueNotifier<int> _selectedCategoryIndexNotifier = ValueNotifier<int>(0);

  // Debounce para busca (evita rebuilds excessivos ao digitar)
  Timer? _debounceTimer;

  // Cache de imagens fora do build (inicializado em initState)
  final Map<String, CachedNetworkImageProvider> _cachedImages = {};

  // Estado local para animação do avatar (leve, não afeta performance global)
  bool _isAvatarPulsing = false;

  @override
  void initState() {
    super.initState();
    // Pré-cache inicial pode ser feito aqui se necessário, mas para streams, será tratado no builder
  }

  @override
  void dispose() {
    _searchTextNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    _selectedCategoryIndexNotifier.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Método para atualizar busca com debounce
  void _updateSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchTextNotifier.value = value.toLowerCase();
    });
  }

  // Método para pré-cache de imagens (chamado fora do build, quando produtos chegam)
  void _precacheImages(List<Product> products) {
    for (var product in products) {
      if (!_cachedImages.containsKey(product.id)) {
        final provider = CachedNetworkImageProvider(product.image);
        _cachedImages[product.id] = provider;
        // Resolve fora do build para evitar latência
        provider.resolve(const ImageConfiguration()).addListener(ImageStreamListener((_, _) {}));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Centralizar fontes no ThemeData para evitar chamadas repetidas a GoogleFonts
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(), // Header usa StreamBuilder, mas é isolado e não rebuilda com busca/filtros
              _buildSearch(), // Busca isolada com ValueNotifier
              _buildCategories(), // Categorias usam ValueListenableBuilder para selectedCategory
              Expanded(child: _buildProducts()), // Produtos com filtragem fora do build
            ],
          ),
        ),
      ),
    );
  }

  // Header permanece com StreamBuilder, mas otimizado: remove sombras custosas para priorizar fluidez
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
                    style: const TextStyle( // Usa ThemeData para fonte
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      // Sombras removidas para reduzir custo no scroll
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Seu estoque hoje',
                    style: TextStyle( // Usa ThemeData
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // Sombras reduzidas para performance
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3, // Blur reduzido
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

  // Busca isolada com ValueNotifier (não causa rebuild global)
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: _updateSearch, // Usa debounce para evitar setState imediato
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

  // Categorias usam ValueListenableBuilder para selectedCategory (rebuilda apenas quando muda)
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 1),
      child: SizedBox(
        height: 44,
        child: StreamBuilder<List<Category>>(
          stream: CategoriesFirestore.streamCategories(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final categories = [
              Category(id: 'todos', name: 'Todos'), // Removido 'const' pois Category não é const
              ...(snapshot.data ?? []),
            ];

            return ValueListenableBuilder<String>(
              valueListenable: _selectedCategoryNotifier,
              builder: (context, selectedCategory, _) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10), // Corrigido para (_, _)
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.name == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        if (_selectedCategoryIndexNotifier.value == index) return;
                        _selectedCategoryIndexNotifier.value = index;
                        _selectedCategoryNotifier.value = category.name;
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
                            color: isSelected ? Colors.black : Colors.grey.shade300,
                            width: 1.4,
                          ),
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle( // Usa ThemeData
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

  // Produtos: Filtragem fora do build usando ValueListenableBuilder para search e category
  // Remove AnimatedSwitcher para evitar animação custosa da árvore inteira
  // Pré-cache de imagens movido para método separado
  Widget _buildProducts() {
    return StreamBuilder<List<Product>>(
      stream: ProductsFirestore.streamProducts(widget.uid),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];

        // Pré-cache fora do build
        _precacheImages(products);

        if (widget.onProductsLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onProductsLoaded!(products);
          });
        }

        // Filtragem isolada com ValueListenableBuilder (rebuilda apenas quando search ou category mudam)
        return ValueListenableBuilder<String>(
          valueListenable: _searchTextNotifier,
          builder: (context, searchText, _) {
            return ValueListenableBuilder<String>(
              valueListenable: _selectedCategoryNotifier,
              builder: (context, selectedCategory, _) {
                final filteredProducts = products.where((product) {
                  final matchesSearch = product.name.toLowerCase().contains(searchText);
                  final matchesCategory = selectedCategory == 'Todos' || product.category == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList(); // Lista criada apenas quando necessário

                return filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum produto encontrado',
                          style: TextStyle(color: Colors.grey), // Usa ThemeData
                        ),
                      )
                    : GridView.builder(
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
                            userCategories: products.map((p) => p.category).toSet().toList(), // Evitar recriação desnecessária
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
}

// Ícone de notificações simples, sem pulsar (mantido como está, pois é leve)
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

// Função auxiliar para avatar (mantida, mas otimizada com const onde possível)
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