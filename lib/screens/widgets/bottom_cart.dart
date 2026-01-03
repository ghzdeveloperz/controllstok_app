  // lib/screens/widgets/bottom_cart.dart
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart'; // Adicionado para tipografia premium
  import '../scanner_screen.dart'; // Assumindo que CartItem está definido aqui e agora inclui 'initialQuantity'

  class BottomCart extends StatefulWidget {
    final List<CartItem> cart;
    final void Function(int) increment;
    final void Function(int) decrement;
    final void Function(String movementType) onFinalize;
    final void Function(String barcode, double newPrice) onEditPrice;

    const BottomCart({
      super.key,
      required this.cart,
      required this.increment,
      required this.decrement,
      required this.onFinalize,
      required this.onEditPrice,
    });

    @override
    State<BottomCart> createState() => _BottomCartState();
  }

  class _BottomCartState extends State<BottomCart> with TickerProviderStateMixin {
    String _movementType = 'entrada'; // ✅ nunca null
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation; // Nova animação para fade premium

    @override
    void initState() {
      super.initState();

      _animationController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      )..forward(); // Anima entrada

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    }

    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }

    double get total =>
        widget.cart.fold(0, (sum, item) => sum + item.quantity * item.unitPrice);

    // ✅ Verificação de erro baseada no modelo: item.quantity > item.initialQuantity em 'saida'
    bool get hasStockError =>
        _movementType == 'saida' &&
        widget.cart.any((item) => item.quantity > item.initialQuantity);

    void _editPrice(BuildContext context, CartItem item) {
      final controller = TextEditingController(
        text: item.unitPrice.toStringAsFixed(2),
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Bordas mais arredondadas
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Editar Preço Unitário',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(fontSize: 16),
            decoration: InputDecoration(
              prefixText: 'R\$ ',
              prefixStyle: GoogleFonts.poppins(color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
                shadowColor: Colors.black.withAlpha(100),
              ),
              onPressed: () {
                final value = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );
                if (value != null && value > 0) {
                  widget.onEditPrice(item.barcode, value);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: Text(
                'Salvar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      // Ajuste dinâmico da altura: expande para 70% quando há erro de estoque para caber o alerta sem sobrepor os produtos
      final cartHeight =
          MediaQuery.of(context).size.height *
          (hasStockError ? 0.75 : 0.55); // Ajustado para mais espaço premium

      return FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400), // Animação suave
          curve: Curves.easeInOut,
          height: cartHeight,
          padding: const EdgeInsets.all(24), // Padding maior para respiro premium
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(250), // Mais opaco para premium
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(40), // Bordas ultra-arredondadas
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50.withAlpha(200)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Barra de arrasto premium com gradiente
              Container(
                width: 50,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título elegante com ícone
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.black87, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Carrinho',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// ---------- TIPO DE MOVIMENTAÇÃO PREMIUM ----------
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _movementType = 'entrada'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _movementType == 'entrada'
                                ? Colors.black87
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _movementType == 'entrada'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: _movementType == 'entrada'
                                    ? Colors.white
                                    : Colors.black87,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Entrada',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: _movementType == 'entrada'
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _movementType = 'saida'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _movementType == 'saida'
                                ? Colors.black87
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _movementType == 'saida'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: _movementType == 'saida'
                                        ? Colors.white
                                        : Colors.black87,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Saída',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: _movementType == 'saida'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                              // ⚠️ AVISO DE ESTOQUE (baseado no modelo: item.quantity > item.initialQuantity)
                              if (hasStockError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Estoque insuficiente',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ⚠️ AVISO GERAL QUANDO EXISTIR ERRO (banner vermelho premium)
              if (hasStockError)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade100,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Alguns produtos têm quantidade maior que a quantidade inicial permitida. Reduza a quantidade para continuar.',
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              /// ---------- LISTA PREMIUM ----------
              Expanded(
                child: widget.cart.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.grey.shade400,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum produto no carrinho',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: widget.cart.length,
                        itemBuilder: (_, index) {
                          final item = widget.cart[index];
                          final isStockError =
                              _movementType == 'saida' &&
                              item.quantity > item.initialQuantity;

                          return Dismissible(
                            key: Key(item.barcode),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              setState(() {
                                widget.cart.removeAt(index);
                              });
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.red.shade600,
                                size: 28,
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: isStockError
                                    ? Border.all(
                                        color: Colors.red.shade400,
                                        width: 2,
                                      )
                                    : Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Imagem circular premium com loading
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(10),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: item.imageUrl.isNotEmpty
                                              ? Image.network(
                                                  item.imageUrl,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) => Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey.shade400,
                                                    size: 30,
                                                  ),
                                                  loadingBuilder: (context, child, progress) {
                                                    if (progress == null)
                                                      return child;
                                                    return SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child: CircularProgressIndicator(
                                                        value:
                                                            progress.expectedTotalBytes !=
                                                                null
                                                            ? progress.cumulativeBytesLoaded /
                                                                  progress
                                                                      .expectedTotalBytes!
                                                            : null,
                                                        strokeWidth: 3,
                                                        color: Colors.black,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey.shade400,
                                                  size: 30,
                                                ),
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  'R\$ ${item.unitPrice.toStringAsFixed(2)} / un',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black87,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                if (_movementType == 'entrada')
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _editPrice(context, item),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10,
                                                          ),
                                                      child: Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            // 🔴 ERRO APARECE NO CARD DO PRODUTO (texto vermelho premium)
                                            if (isStockError)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  'Em estoque: ${item.initialQuantity}',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.red.shade600,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Controles premium com animação
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.black87,
                                                size: 24,
                                              ),
                                              onPressed: () =>
                                                  widget.decrement(index),
                                            ),
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              child: Container(
                                                key: ValueKey(item.quantity),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withAlpha(
                                                    10,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  item.quantity.toString(),
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: Colors.black87,
                                                size: 24,
                                              ),
                                              onPressed: () =>
                                                  widget.increment(index),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // Total proeminente premium
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey.shade800],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ---------- FINALIZAR PREMIUM ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.cart.isEmpty || hasStockError
                      ? null
                      : () => widget.onFinalize(_movementType),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (widget.cart.isNotEmpty && !hasStockError)
                        ? Colors.black
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 8,
                    shadowColor: Colors.black.withAlpha(100),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    'Finalizar',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
