class Product {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final String image;

  final double price;      // preço de venda
  final double cost;       // custo médio
  final double unitPrice;  // preço unitário (Firestore)

  final int quantity;
  final int minStock;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.image,
    required this.price,
    required this.cost,
    required this.unitPrice,
    required this.quantity,
    required this.minStock,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      barcode: map['barcode'] ?? '',
      category: map['category'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      cost: (map['cost'] ?? 0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      minStock: map['minStock'] ?? 0,
    );
  }
}
