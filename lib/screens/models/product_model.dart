// lib/screens/models/product_model.dart
class Product {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final int quantity;
  final int minStock;
  final double price;
  final double cost;
  final double unitPrice;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.quantity,
    required this.minStock,
    required this.price,
    required this.cost,
    required this.unitPrice,
    required this.image,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      barcode: data['barcode'] ?? '',
      category: data['category'] ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
      minStock: (data['minStock'] ?? 0).toInt(),
      price: (data['price'] ?? 0).toDouble(),
      cost: (data['cost'] ?? 0).toDouble(),
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      image: data['image'] ?? '', // <-- garantir que venha algo
    );
  }
}
