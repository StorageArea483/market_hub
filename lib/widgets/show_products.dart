import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/models/post_model.dart';
import 'package:market_hub/pages/product_detail_screen.dart';
import 'package:market_hub/providers/category_provider.dart';
import 'package:market_hub/providers/fav_provider.dart';
import 'package:market_hub/providers/product_provider.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/widgets/internet_connection.dart';

class ShowProducts extends ConsumerWidget {
  final double? productPrice;
  const ShowProducts({super.key, this.productPrice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(postProvider);
    final selectedCategory = ref.watch(categoryProvider).name;
    List<PostModel> filteredProducts = [];

    return productsAsyncValue.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      data: (products) {
        filteredProducts = selectedCategory == 'All'
            ? products
            : products
                  .where(
                    (product) =>
                        product.category.toLowerCase() ==
                        selectedCategory.toLowerCase(),
                  )
                  .toList();

        if (productPrice != null) {
          filteredProducts = filteredProducts
              .where((product) => product.price <= productPrice!)
              .toList();
        }

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No products found for this category',
                style: AppTextStyles.subtitle,
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _ProductCard(product: product);
            },
          ),
        );
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

class _ProductCard extends ConsumerWidget {
  final PostModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => InternetConnection(
              child: ProductDetailScreen(product: product),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textSecondary,
                            size: 32,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final favIds = ref.watch(favProvider);
                        final isFav = favIds.contains(product.id);
                        return InkWell(
                          onTap: () {
                            ref.read(favProvider.notifier).addFav(product.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFav
                                  ? Colors.red
                                  : AppColors.primaryGreen,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                product.title,
                style: AppTextStyles.button.copyWith(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.category.toUpperCase(),
                    style: AppTextStyles.footer.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  product.rating.toString(),
                  style: AppTextStyles.footer.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '\$${product.price}',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryGreen,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
