import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/models/categories.dart';
import 'package:market_hub/widgets/bottom_nav_bar.dart';
import 'package:market_hub/widgets/sale_items.dart';
import 'package:market_hub/widgets/show_products.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? 'User';
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'User';
          isLoading = false;
        });
      }
    } else {
      // No user logged in
      setState(() {
        userName = 'Guest';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prices = [100, 200, 400, 600, 800, 2000, 4000];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'MarketHub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Consumer(
              builder: (context, ref, child) {
                return ref
                    .watch(loadCartIdsProvider)
                    .when(
                      data: (data) {
                        if (data.products.isNotEmpty) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.black,
                                size: 28,
                              ),
                              // Badge
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${data.products.length}', // cart item count
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                          );
                        }
                      },
                      loading: () =>
                          const Icon(Icons.shopping_cart, color: Colors.black),
                      error: (error, stackTrace) =>
                          const Icon(Icons.shopping_cart, color: Colors.black),
                    );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Good Morning, $userName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to find something special?',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, _) {
                                // reads data if state changes
                                return TextField(
                                  onChanged: (value) {
                                    ref
                                            .read(searchQueryProvider.notifier)
                                            .state =
                                        value;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search for fresh finds...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Banner Section (Placeholder)
                    const SaleItems(),

                    // Categories Section
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryItem(Icons.grid_view, 'All'),
                          _buildCategoryItem(Icons.brush, 'Beauty'),
                          _buildCategoryItem(Icons.local_florist, 'Fragrances'),
                          _buildCategoryItem(Icons.weekend, 'Furniture'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Price Filters
                    SizedBox(
                      height: 50,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final selectedPrice = ref.watch(
                            selectedPriceProvider,
                          );
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: prices.length,
                            itemBuilder: (context, index) {
                              final price = prices[index];
                              final isSelected =
                                  selectedPrice == price.toDouble();

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(selectedPriceProvider.notifier)
                                        .state = price
                                        .toDouble();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? AppColors.primaryGreen
                                        : Colors.white,
                                    foregroundColor: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.primaryGreen
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text('Under \$$price'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Featured Products Section
                    const Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Product Grid (Placeholder)
                    Consumer(
                      builder: (context, ref, _) {
                        return ShowProducts(
                          productPrice: ref.watch(selectedPriceProvider),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Consumer(
      builder: (context, ref, child) {
        final currentCategory = ref.watch(categoryProvider);
        final isSelected = currentCategory.name == label;
        return Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(categoryProvider.notifier)
                      .selectCategory(Category(name: label, isSelected: true));
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: isSelected
                      ? AppColors.primaryGreen
                      : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.grey,
                  elevation: 2,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppColors.textPrimary : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
