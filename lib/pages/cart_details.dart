import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/pages/landing_page.dart';
import 'package:market_hub/providers/cart_provider.dart';
import 'package:market_hub/providers/cart_ui_provider.dart';
import 'package:market_hub/services/stripe_payment_service.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/widgets/bottom_nav_bar.dart';
import 'package:market_hub/widgets/internet_connection.dart';

class CartDetails extends StatelessWidget {
  const CartDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const InternetConnection(child: LandingPage()),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    const InternetConnection(child: LandingPage()),
              ),
            ),
          ),
          title: const Text(
            'My Cart',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cart Items List
                Consumer(
                  builder: (context, ref, child) {
                    final cartAsync = ref.watch(loadCartIdsProvider);
                    return cartAsync.when(
                      skipLoadingOnRefresh: false,
                      skipLoadingOnReload: false,
                      data: (cartData) {
                        if (cartData.products.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 100,
                                    color: AppColors.textPrimary,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Your cart is empty',
                                    style: AppTextStyles.subtitle,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                                      errorBuilder:
                                          (context, error, stackTrace) =>
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                color: Colors.grey,
                                              ),
                                              constraints:
                                                  const BoxConstraints(),
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  _buildQuantityButton(
                                                    icon: Icons.remove,
                                                    onTap: () async {
                                                      if (quantity > 1) {
                                                        await ref
                                                            .read(
                                                              cartProvider
                                                                  .notifier,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  _buildQuantityButton(
                                                    icon: Icons.add,
                                                    onTap: () async {
                                                      await ref
                                                          .read(
                                                            cartProvider
                                                                .notifier,
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
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'An error occurred while loading products',
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.white,
                              ),
                              onPressed: () =>
                                  ref.invalidate(loadCartIdsProvider),
                              label: const Text("Retry"),
                              icon: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Summary Section
                Consumer(
                  builder: (context, ref, child) {
                    final cartAsync = ref.watch(loadCartIdsProvider);

                    return cartAsync.when(
                      data: (cartData) {
                        double subtotal = 0;
                        for (int i = 0; i < cartData.products.length; i++) {
                          subtotal +=
                              cartData.products[i].price *
                              cartData.quantities[i];
                        }
                        const double delivery = 2.00;
                        const double discount = 0.00;
                        final double total = subtotal + delivery - discount;

                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSummaryRow('Subtotal', subtotal),
                              const SizedBox(height: 12),
                              _buildSummaryRow('Delivery', delivery),
                              const SizedBox(height: 12),
                              _buildSummaryRow('Discount', discount),
                              const Divider(height: 32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final stripeService = ref.read(
                                      stripePaymentProvider,
                                    );
                                    final isLoading = ref.watch(
                                      isLoadingProvider,
                                    );
                                    return ElevatedButton(
                                      onPressed: () async {
                                        ref
                                                .read(
                                                  isLoadingProvider.notifier,
                                                )
                                                .state =
                                            true;
                                        try {
                                          await stripeService.initPaymentSheet(
                                            amount: total.toString(),
                                            currency: "USD",
                                            merchantName: "Market Hub",
                                          );
                                          await stripeService
                                              .presentPaymentSheet();
                                          ref
                                                  .read(
                                                    isLoadingProvider.notifier,
                                                  )
                                                  .state =
                                              false;
                                          ScaffoldMessenger.of(
                                            // ignore: use_build_context_synchronously
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Payment successful',
                                                style: TextStyle(
                                                  color: AppColors.primaryGreen,
                                                ),
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ref
                                                  .read(
                                                    isLoadingProvider.notifier,
                                                  )
                                                  .state =
                                              false;
                                          ScaffoldMessenger.of(
                                            // ignore: use_build_context_synchronously
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Payment failed',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: AppColors.primaryGreen,
                                            )
                                          : const Text(
                                              'Proceed to Checkout',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          '\$${value.abs().toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Future<void> Function() onTap,
  }) {
    return GestureDetector(
      onTap: () async => await onTap(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
