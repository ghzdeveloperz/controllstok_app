import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/products_firestore.dart';
import '../firebase/firestore/categories_firestore.dart';
import '../firebase/firestore/users_firestore.dart';

import 'novo_produto_screen.dart';
import 'widgets/product_card.dart';
import 'models/product.dart';
import 'models/category.dart';

class EstoqueScreen extends StatefulWidget {
  final String uid;

  const EstoqueScreen({super.key, required this.uid});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  String _searchText = '';
  String _selectedCategory = 'Todos';

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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estoque',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),

              /// 🔹 Login vindo do Firestore (users/{uid}.login)
              StreamBuilder<String?>(
                stream: UsersFirestore.streamLogin(widget.uid)
                    .map((snapshot) => snapshot.data()?['login'] as String?),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Carregando...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    );
                  }

                  return Text(
                    snapshot.data ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ],
          ),

          /// ➕ Botão Novo Produto
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NovoProdutoScreen(uid: widget.uid),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F0F0F),
                    Color(0xFF1E1E1E),
                    Color(0xFF2A2A2A),
                    Color(0xFF141414),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(150),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(18),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withAlpha(32),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_business_outlined,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // ================= CATEGORIES =================
  Widget _buildCategories() {
    return SizedBox(
      height: 48,
      child: StreamBuilder<List<Category>>(
        stream: CategoriesFirestore.streamCategories(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                  setState(() {
                    _selectedCategory = category.name;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          isSelected ? Colors.black : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= PRODUCTS =================
  Widget _buildProducts() {
    return StreamBuilder<List<Product>>(
      stream: ProductsFirestore.streamProducts(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar produtos\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          );
        }

        final products = snapshot.data ?? [];

        final filteredProducts = products.where((product) {
          final matchesSearch =
              product.name.toLowerCase().contains(_searchText);

          final matchesCategory =
              _selectedCategory == 'Todos' ||
              product.category == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        if (filteredProducts.isEmpty) {
          return Center(
            child: Text(
              'Nenhum produto encontrado',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return GridView.builder(
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
              userCategories:
                  products.map((p) => p.category).toSet().toList(),
            );
          },
        );
      },
    );
  }
}
