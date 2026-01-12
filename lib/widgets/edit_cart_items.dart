import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/models/post_model.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/styles/style.dart';

class EditCartItems extends ConsumerWidget {
  final PostModel product;
  const EditCartItems({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final quantity = ref.read(productCartCountProvider);
        ref.read(loadingCartItemsProvider.notifier).state = true;

        bool result = await ref
            .read(cartProvider.notifier)
            .addData(product.id, quantity);

        if (result) {
          ref.read(loadingCartItemsProvider.notifier).state = false;
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Product added to cart',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        } else {
          ref.read(loadingCartItemsProvider.notifier).state = false;
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to add product to cart',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag, size: 20),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, _) {
              return ref.watch(loadingCartItemsProvider)
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
            },
          ),
          const SizedBox(width: 8),
          Text(
            '| \$${(product.price - (product.price * product.discountPercentage / 100)).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
