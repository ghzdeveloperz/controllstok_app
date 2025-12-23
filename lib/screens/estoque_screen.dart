import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../firebase/firestore/products_firestore.dart';
import '../firebase/firestore/categories_firestore.dart';
import 'novo_produto_screen.dart';

import 'widgets/product_card.dart';
import 'models/product.dart';
import 'models/category.dart';
import '../firebase/firestore/users_firestore.dart';

class EstoqueScreen extends StatefulWidget {
  final String userId;

  const EstoqueScreen({super.key, required this.userId});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  String _searchText = '';
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .grey
          .shade50, // Fundo sutilmente cinza para elegância e contraste premium
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
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        12,
      ), // Padding maior para respiro visual
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
              StreamBuilder<String?>(
                stream: UsersFirestore.streamLogin(widget.userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(
                      'Carregando...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                      ),
                    );
                  }

                  return Text(
                    snapshot.data!,
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

          // Botão Novo Produto Premium (mantido e refinado para consistência)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NovoProdutoScreen(userId: widget.userId),
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
                    Color(0xFF0F0F0F), // Preto quase absoluto
                    Color(0xFF1E1E1E), // Transição sutil
                    Color(0xFF2A2A2A), // Leve highlight
                    Color(0xFF141414), // Volta ao escuro
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(150), // Sombra forte e limpa
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(18), // Brilho interno sutil
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withAlpha(
                    32,
                  ), // Borda quase imperceptível
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E0E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.add_business_outlined,
                  size: 26,
                  color: Colors.white,
                ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ), // Padding consistente
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar produto...',
          hintStyle: TextStyle(color: Colors.grey.shade500), // Hint discreto
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600, // Ícone discreto
          ),
          filled: true,
          fillColor: Colors
              .grey
              .shade100, // Fundo levemente contrastante, sem agressividade
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              16,
            ), // Cantos arredondados suaves
            borderSide: BorderSide.none, // Sem bordas agressivas
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ), // Padding interno para amplitude
        ),
      ),
    );
  }

  // ================= CATEGORIES =================
  Widget _buildCategories() {
    return SizedBox(
      height: 48, // Altura ligeiramente maior para toque confortável
      child: StreamBuilder<List<Category>>(
        stream: CategoriesFirestore.streamCategories(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = [
            Category(id: 'todos', name: 'Todos'),
            ...(snapshot.data ?? []),
          ];

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ), // Padding consistente
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 10), // Espaço maior para respiro
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
                  duration: const Duration(
                    milliseconds: 300,
                  ), // Transições suaves
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ), // Padding interno generoso
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black
                        : Colors.transparent, // Fundo sólido escuro para ativa
                    borderRadius: BorderRadius.circular(
                      24,
                    ), // Raio maior para elegância
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : Colors
                                .grey
                                .shade300, // Contorno sutil para inativas
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Colors.black87, // Contraste elegante
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
      stream: ProductsFirestore.streamProducts(widget.userId),
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
          final matchesSearch = product.name.toLowerCase().contains(
            _searchText,
          );

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
          padding: const EdgeInsets.all(20), // Padding generoso para respiro
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            childAspectRatio:
                0.85, // Aspecto ajustado para hierarquia clara nos cards
            crossAxisSpacing: 16, // Espaçamento maior para separação visual
            mainAxisSpacing: 16,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(
              product: filteredProducts[index],
              userId: widget.userId,
              userCategories: products.map((p) => p.category).toSet().toList(),
            );
          },
        );
      },
    );
  }
}
