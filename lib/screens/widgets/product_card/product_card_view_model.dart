// lib/screens/widgets/product_card/product_card_view_model.dart
import '../../models/product.dart';
import 'product_status.dart';

class ProductCardViewModel {
  final Product product;

  const ProductCardViewModel(this.product);

  ProductStockStatus get status {
    if (product.quantity == 0) return ProductStockStatus.unavailable;
    if (product.quantity <= product.minStock) return ProductStockStatus.critical;
    return ProductStockStatus.available;
  }

  double get unitValue => product.price != 0 ? product.price : product.cost;

  double get totalValue => unitValue * product.quantity;

  int get quantity => product.quantity;

  String get name => product.name;

  String get category => product.category;

  String get imageUrl => product.image;
}
