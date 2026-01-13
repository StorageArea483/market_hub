import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/styles/style.dart';

class CartDetails extends StatelessWidget {
  const CartDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('My Cart', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cart Items List wrapped in Consumer for performance
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final cartAsync = ref.watch(loadCartIdsProvider);

                return cartAsync.when(
                  skipLoadingOnRefresh: false,
                  skipLoadingOnReload: false,
                  data: (cartData) {
                    if (cartData.products.isEmpty) {
                      return const Center(
                        child: Text(
                          'Your cart is empty',
                          style: AppTextStyles.subtitle,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cartData.products.length,
                      itemBuilder: (context, index) {
                        final product = cartData.products[index];
                        final quantity = cartData.quantities[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.thumbnail,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .removeData(product.id);
                                            ref.invalidate(loadCartIdsProvider);
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.grey,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${product.category} • ${product.weight}g',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        // Quantity Controls
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildQuantityButton(
                                                icon: Icons.remove,
                                                onTap: () {
                                                  if (quantity > 1) {
                                                    ref
                                                        .read(
                                                          cartProvider.notifier,
                                                        )
                                                        .updateQuantity(
                                                          product.id,
                                                          quantity - 1,
                                                        );
                                                    ref.invalidate(
                                                      loadCartIdsProvider,
                                                    );
                                                  }
                                                },
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Text(
                                                  '$quantity',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              _buildQuantityButton(
                                                icon: Icons.add,
                                                isPrimary: true,
                                                onTap: () {
                                                  ref
                                                      .read(
                                                        cartProvider.notifier,
                                                      )
                                                      .updateQuantity(
                                                        product.id,
                                                        quantity + 1,
                                                      );
                                                  ref.invalidate(
                                                    loadCartIdsProvider,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
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
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),

          // Bottom Summary Section wrapped in Consumer
          Consumer(
            builder: (context, ref, child) {
              final cartAsync = ref.watch(loadCartIdsProvider);

              return cartAsync.when(
                data: (cartData) {
                  if (cartData.products.isEmpty) return const SizedBox.shrink();

                  double subtotal = 0;
                  for (int i = 0; i < cartData.products.length; i++) {
                    subtotal +=
                        cartData.products[i].price * cartData.quantities[i];
                  }
                  const double delivery = 2.00;
                  const double discount = 0.00; // Assuming 0 as per image match
                  final double total = subtotal + delivery - discount;

                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryRow('Subtotal', subtotal),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Delivery', delivery),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Discount',
                          -discount,
                          isDiscount: true,
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              // Checkout logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF65E040,
                              ), // Bright green from image
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 24), // Spacer
                                Text(
                                  'Proceed to Checkout',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          '${isDiscount ? '-' : ''}\$${value.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.lightGreen : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF65E040) : Colors.white,
          shape: BoxShape.circle,
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}
