import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/models/post_model.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/styles/style.dart';

class AddToCart extends ConsumerWidget {
  final PostModel product;
  const AddToCart({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          final quantity = ref.read(productCartCountProvider);
          ref.read(isLoadingProvider.notifier).state = true;
          bool result = await ref
              .read(cartProvider.notifier)
              .addData(product.id, quantity);

          if (result) {
            ref.invalidate(loadCartIdsProvider);
            ref.read(isLoadingProvider.notifier).state = false;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Product added to cart',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            }
          } else {
            ref.read(isLoadingProvider.notifier).state = false;
            if (context.mounted) {
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
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 20),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, _) {
                return ref.watch(isLoadingProvider)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
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
      ),
    );
  }
}
