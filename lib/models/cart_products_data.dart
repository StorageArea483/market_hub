// Model to hold cart products with their quantities
import 'package:market_hub/models/post_model.dart';

class CartProductsData {
  final List<PostModel> products;
  final List<int> quantities;

  CartProductsData({required this.products, required this.quantities});
}
