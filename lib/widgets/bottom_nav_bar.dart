import 'package:flutter/material.dart';
import 'package:market_hub/pages/cart_details.dart';
import 'package:market_hub/pages/fav_cart_products.dart';
import 'package:market_hub/pages/landing_page.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/pages/user_profile.dart';
import 'package:market_hub/widgets/internet_connection.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
      onTap: (index) {
        if (index == currentIndex) return;

        Widget target;
        if (index == 0) {
          target = const LandingPage();
        } else if (index == 1) {
          target = const CartDetails();
        } else if (index == 2) {
          target = const FavCartProducts();
        } else {
          target = const UserProfile();
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => InternetConnection(child: target),
          ),
        );
      },
    );
  }
}
