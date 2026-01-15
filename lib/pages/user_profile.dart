import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/pages/google_signup.dart';
import 'package:market_hub/pages/landing_page.dart';
import 'package:market_hub/providers/cart_provider.dart';
import 'package:market_hub/providers/cart_ui_provider.dart';
import 'package:market_hub/providers/category_provider.dart';
import 'package:market_hub/providers/fav_provider.dart';
import 'package:market_hub/providers/product_provider.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/widgets/bottom_nav_bar.dart';
import 'package:market_hub/widgets/internet_connection.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? userName;
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userEmail = user.email;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userName = doc.data()?['name'];
            isLoading = false;
          });
        } else {
          setState(() {
            userName = user.displayName ?? 'User';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          userName = user.displayName ?? 'User';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        userName = 'Guest';
        userEmail = 'Not logged in';
        isLoading = false;
      });
    }
  }

  Future<bool> _logout(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('cart_items')
            .doc(user.uid)
            .delete();
      } catch (e) {
        return false;
      }
    }
    // Invalidate providers to clear local state
    ref.invalidate(cartProvider);
    ref.invalidate(loadCartIdsProvider);
    ref.invalidate(categoryProvider);
    ref.invalidate(favProvider);
    ref.invalidate(loadFavCartProducts);
    ref.invalidate(productCartCountProvider);
    ref.invalidate(postProvider);

    await FirebaseAuth.instance.signOut();
    ref.read(isLoadingProvider.notifier).state = false;
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const InternetConnection(child: GoogleSignup()),
        ),
        (route) => false,
      );
    }
    return true;
  }

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
            'User Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Circle Avatar with first letter
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: AppColors.primaryGreen,
                            child: Text(
                              userName != null && userName!.isNotEmpty
                                  ? userName![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // User Name
                        Text(
                          userName ?? 'User',
                          style: AppTextStyles.title.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        // User Email
                        Text(
                          userEmail ?? '',
                          style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 40),
                        // Action buttons
                        const SizedBox(height: 32),
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final isLoading = ref.watch(isLoadingProvider);
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _logout(ref),
                                style: ElevatedButton.styleFrom(
                                  // ignore: deprecated_member_use
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.logout, size: 20),
                                          SizedBox(width: 10),
                                          Text(
                                            'Logout',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      ),
    );
  }
}
