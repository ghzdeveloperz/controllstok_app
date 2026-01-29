import 'feed_item.dart';
import '../screens/models/product.dart';

List<FeedItem> buildFeedWithAds({
  required List<Product> products,
  int interval = 8,
}) {
  final out = <FeedItem>[];

  for (int i = 0; i < products.length; i++) {
    out.add(ProductFeedItem(products[i]));

    if ((i + 1) % interval == 0) {
      out.add(const AdFeedItem());
    }
  }

  return out;
}
