import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/pages/landing_page.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/styles/style.dart';

class CartDetails extends StatelessWidget {
  const CartDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingPage()),
          ),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final cartAsync = ref.watch(loadCartIdsProvider);

                  return cartAsync.when(
                    skipLoadingOnRefresh: false,
                    skipLoadingOnReload: false,
                    data: (cartData) {
                      if (cartData.products.isEmpty) {
                        return const Center(child: Text('Your cart is empty'));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartData.products.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final product = cartData.products[index];
                          final quantity = cartData.quantities[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Simple Image
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Image.network(
                                    product.thumbnail,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(color: Colors.grey[200]),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Simple Quantity Row
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed: () async {
                                              if (quantity > 1) {
                                                await ref
                                                    .read(cartProvider.notifier)
                                                    .updateQuantity(
                                                      product.id,
                                                      quantity - 1,
                                                    );
                                                ref.invalidate(
                                                  loadCartIdsProvider,
                                                );
                                              }
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            iconSize: 24,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text('$quantity'),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            onPressed: () async {
                                              await ref
                                                  .read(cartProvider.notifier)
                                                  .updateQuantity(
                                                    product.id,
                                                    quantity + 1,
                                                  );
                                              ref.invalidate(
                                                loadCartIdsProvider,
                                              );
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            iconSize: 24,
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () async {
                                              await ref
                                                  .read(cartProvider.notifier)
                                                  .removeData(product.id);
                                              ref.invalidate(
                                                loadCartIdsProvider,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Error loading cart'),
                          TextButton(
                            onPressed: () => ref.invalidate(postProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Simple Summary Section
            Consumer(
              builder: (context, ref, child) {
                final cartAsync = ref.watch(loadCartIdsProvider);

                return cartAsync.when(
                  data: (cartData) {
                    if (cartData.products.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    double subtotal = 0;
                    for (int i = 0; i < cartData.products.length; i++) {
                      subtotal +=
                          cartData.products[i].price * cartData.quantities[i];
                    }
                    const double delivery = 2.00;
                    final double total = subtotal + delivery;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text('\$${subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery'),
                              Text('\$${delivery.toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('Checkout'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
