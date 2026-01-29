// lib/feed/feed_item.dart
import '../screens/models/product.dart';

sealed class FeedItem {
  const FeedItem();
}

class ProductFeedItem extends FeedItem {
  final Product product;

  const ProductFeedItem(this.product);
}

class AdFeedItem extends FeedItem {
  const AdFeedItem();
}
