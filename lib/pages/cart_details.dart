import 'package:flutter/material.dart';
import 'package:market_hub/models/post_model.dart';
import 'package:market_hub/pages/product_detail_screen.dart';
import 'package:market_hub/styles/style.dart';

class CartDetails extends StatelessWidget {
  final PostModel product;
  const CartDetails({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        ),
        title: const Text('Cart Details'),
        centerTitle: true,
      ),
    );
  }
}
