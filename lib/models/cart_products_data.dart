// Model to hold cart products with their quantities
import 'package:market_hub/models/post_model.dart';

class CartProductsData {
  final List<PostModel> products;
  final List<int> quantities;

  CartProductsData({required this.products, required this.quantities});

  // Get quantity for a specific product
  int getQuantityForProduct(int productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1 && index < quantities.length) {
      return quantities[index];
    }
    return 0;
  }
}
