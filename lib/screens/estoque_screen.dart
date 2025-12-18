// lib/screens/estoque_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/products_firestore.dart';
import '../firebase/firestore/categories_firestore.dart';

import 'widgets/product_card.dart';
import 'models/product.dart';
import 'models/category.dart';

class EstoqueScreen extends StatefulWidget {
  final String userLogin;

  const EstoqueScreen({super.key, required this.userLogin});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  String _searchText = '';
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estoque',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.userLogin,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const Icon(Icons.inventory_2_outlined, size: 28),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar produto...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= CATEGORIES =================
  // ================= CATEGORIES =================
  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: StreamBuilder<List<Category>>(
        stream: CategoriesFirestore.streamCategories(widget.userLogin),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = [
            Category(id: 'todos', name: 'Todos'),
            ...(snapshot.data ?? []),
          ];

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black
                        : Colors.transparent, // transparente
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : Colors.grey.shade400, // apenas contorno sutil
                    ),
                  ),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
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
      stream: ProductsFirestore.streamProducts(widget.userLogin),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar produtos\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

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

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum produto encontrado',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

 return GridView.builder(
  padding: const EdgeInsets.all(16),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 250,
    childAspectRatio: 0.80,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemCount: filteredProducts.length,
  itemBuilder: (context, index) {
    return ProductCard(
      product: filteredProducts[index],
      userLogin: widget.userLogin,
      userCategories: snapshot.data?.map((c) => c.name).toList() ?? [], // 🔥 PASSA A LISTA DE CATEGORIAS
    );
  },
);
      },
    );
  }
}