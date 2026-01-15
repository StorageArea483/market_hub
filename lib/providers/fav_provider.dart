import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:market_hub/models/fav_products_data.dart';
import 'package:market_hub/providers/product_provider.dart';

final favProvider = StateNotifierProvider<FavNotifier, List<int>>(
  (ref) => FavNotifier(),
);

class FavNotifier extends StateNotifier<List<int>> {
  FavNotifier() : super([]) {
    _loadFavourites();
  }

  Future<bool> _loadFavourites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('cart_items')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        state = List<int>.from(data?['favourites'] ?? []);
      }
    } catch (e) {
      // Handle error cleanly
      return false;
    }
    return true;
  }

  Future<bool> addFav(int productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final isFav = state.contains(productId);

    // Toggle state locally
    if (isFav) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }

    try {
      // Update Firebase with merge to avoid overwriting cart data
      await FirebaseFirestore.instance
          .collection('cart_items')
          .doc(user.uid)
          .set({'favourites': state}, SetOptions(merge: true));
    } catch (e) {
      // If error, revert state (optional, keeping simple)
      return false;
    }
    return true;
  }
}

final loadFavCartProducts = FutureProvider<FavProductsData>((ref) async {
  // Watch postProvider to get all products
  final postsAsyncValue = await ref.watch(postProvider.future);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const FavProductsData(products: []);
  }
  final doc = await FirebaseFirestore.instance
      .collection('cart_items')
      .doc(user.uid)
      .get();

  if (!doc.exists) {
    return const FavProductsData(products: []);
  }

  final data = doc.data();
  final List<int> favIds = List<int>.from(data?['favourites'] ?? []);
  return FavProductsData(
    products: postsAsyncValue
        .where((product) => favIds.contains(product.id))
        .toList(),
  );
});
