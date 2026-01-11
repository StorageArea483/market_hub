import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/providers/providers.dart';
import 'package:market_hub/models/categories.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'MarketHub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: isLoading
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
                    style: TextStyle(
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
                                  ref.read(searchQueryProvider.notifier).state =
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
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
                  const ShowProducts(category: ''),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
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
