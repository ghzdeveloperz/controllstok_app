class Product {
  final String id;
  final String name;
  final String category;
  final String image;
  final String barcode;
  final double price;
  final double cost;
  final int quantity;
  final int minStock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.barcode,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.minStock,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      image: data['image'] ?? '',
      barcode: data['barcode'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      cost: (data['cost'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toInt(),
      minStock: (data['minStock'] ?? 0).toInt(),
    );
  }
}
