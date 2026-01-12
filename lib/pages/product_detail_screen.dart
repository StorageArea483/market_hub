import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/models/post_model.dart';
import 'package:market_hub/pages/landing_page.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/widgets/edit_cart_items.dart';
import 'package:market_hub/widgets/show_products.dart';

class ProductDetailScreen extends StatelessWidget {
  final PostModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountedPrice =
        product.price - (product.price * product.discountPercentage / 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LandingPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Image.network(
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

                    // Product Info Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${discountedPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rating Section
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                // add stars according to the rating
                                return Icon(
                                  index < product.rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.reviews.length} reviews)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Description Section
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Reviews Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Rating Summary
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < product.rating.floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.reviews.length} ratings',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildRatingBar(5, 0.7),
                                    _buildRatingBar(4, 0.2),
                                    _buildRatingBar(3, 0.05),
                                    _buildRatingBar(2, 0.03),
                                    _buildRatingBar(1, 0.02),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Review List
                          ...product.reviews.map((review) {
                            // extracting the widgets
                            return _buildReviewItem(review);
                          }),
                          const SizedBox(height: 24),

                          // Related Products Section
                          const Text(
                            'Related Products',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ShowProducts(category: product.category),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Buttons
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        return Row(
                          children: [
                            IconButton(
                              onPressed: () => ref
                                  .read(productCartCountProvider.notifier)
                                  .decrement(),
                              icon: const Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '${ref.watch(productCartCountProvider)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () => ref
                                  .read(productCartCountProvider.notifier)
                                  .increment(),
                              icon: const Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add to Cart Button
                  Expanded(child: EditCartItems(product: product)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.comment,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
