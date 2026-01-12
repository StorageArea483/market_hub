import 'package:market_hub/models/post_model.dart';

class CartInfoModel {
  final PostModel productId;
  final int quantity;

  CartInfoModel({required this.productId, required this.quantity});

  CartInfoModel copyWith({PostModel? productId, int? quantity}) {
    return CartInfoModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }
}
