import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/models/post_model.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/styles/style.dart';

class SaleItems extends ConsumerWidget {
  const SaleItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(postProvider);

    final searchQuery = ref.watch(searchQueryProvider);

    return productsAsync.when(
      data: (products) {
        List<PostModel> displayProducts;

        if (searchQuery.isNotEmpty) {
          displayProducts = products
              .where(
                (p) =>
                    p.title.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
        } else {
          displayProducts = products
              .where((p) => p.discountPercentage > 0)
              .toList();

          // Sort by discount descending
          displayProducts.sort(
            (a, b) => b.discountPercentage.compareTo(a.discountPercentage),
          );
        }

        if (displayProducts.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isNotEmpty
                  ? 'No items found'
                  : 'No Items found in sale for now',
              style: AppTextStyles.subtitle,
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayProducts.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _ProductCard(product: displayProducts[index]);
            },
          ),
        ); // Modified logic ends here
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
      error: (error, stack) => Column(
        children: [
          const Text(
            'An error occurred while loading products',
            style: AppTextStyles.subtitle,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => ref.invalidate(postProvider),
            label: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PostModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Product Image with Error Handling
            Image.network(
              product.thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                );
              },
            ),
            // Title and Discount Overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black54, // Lightweight background for readability
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
