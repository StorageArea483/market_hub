import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:market_hub/models/cart_data.dart';
import 'package:market_hub/models/cart_products_data.dart';
import 'package:market_hub/models/categories.dart';
import 'package:market_hub/models/post_model.dart';
import 'package:http/http.dart' as http;

final isSigningInProvider = StateProvider<bool>((ref) => false);

final internetProvider = StreamProvider<List<ConnectivityResult>>(
  (_) => Connectivity().onConnectivityChanged,
);

final categoryProvider = StateNotifierProvider<CategoryNotifier, Category>(
  (ref) => CategoryNotifier(),
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final postProvider = FutureProvider<List<PostModel>>((ref) async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<PostModel> posts = (data['products'] as List)
        .map((post) => PostModel.fromJson(post))
        .toList();
    return posts;
  } else {
    throw Exception('Failed to load products');
  }
});

class CategoryNotifier extends StateNotifier<Category> {
  CategoryNotifier() : super(Category(name: 'All', isSelected: true));

  void selectCategory(Category category) {
    state = category;
  }
}

final productCartCountProvider =
    StateNotifierProvider<ProductCartCountNotifier, int>(
      (ref) => ProductCartCountNotifier(),
    );

class ProductCartCountNotifier extends StateNotifier<int> {
  ProductCartCountNotifier() : super(1);

  void increment() {
    state = state + 1;
  }

  void decrement() {
    if (state > 1) {
      state = state - 1;
    }
  }
}

// Provider to load cart products from Firebase by matching IDs with postProvider
final loadCartIdsProvider = FutureProvider<CartProductsData>((ref) async {
  // Watch postProvider to get all products
  final postsAsyncValue = await ref.watch(postProvider.future);

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return CartProductsData(products: [], quantities: []);
  }

  final doc = await FirebaseFirestore.instance
      .collection('cart_items')
      .doc(user.uid)
      .get();

  if (!doc.exists) {
    return CartProductsData(products: [], quantities: []);
  }

  final data = doc.data();
  final List<int> cartIds = List<int>.from(data?['ids'] ?? []);
  final List<int> cartQuantities = List<int>.from(data?['quantities'] ?? []);

  // Filter products that match cart IDs and maintain order
  final List<PostModel> cartProducts = [];
  final List<int> matchedQuantities = [];

  for (int i = 0; i < cartIds.length; i++) {
    final productId = cartIds[i];
    final matchingProduct = postsAsyncValue.firstWhere(
      (product) => product.id == productId,
      orElse: () => PostModel.empty(),
    );

    // Only add if product was found (not empty)
    if (matchingProduct.id != 0) {
      cartProducts.add(matchingProduct);
      matchedQuantities.add(i < cartQuantities.length ? cartQuantities[i] : 1);
    }
  }

  return CartProductsData(
    products: cartProducts,
    quantities: matchedQuantities,
  );
});

// this loading state is useful when adding data or removing the data from firestore database
final loadingCartItemsProvider = StateProvider<bool>((_) => false);

final cartProvider = StateNotifierProvider<CartNotifier, CartData>(
  (ref) => CartNotifier(),
);

// Provider to add carts in Firebase
class CartNotifier extends StateNotifier<CartData> {
  CartNotifier() : super(CartData(ids: [], quantities: []));

  // Add product id and quantity to firebase
  Future<bool> addData(int productId, int quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('cart_items')
          .doc(user.uid);

      final doc = await docRef.get();
      List<int> ids = [];
      List<int> quantities = [];

      if (doc.exists) {
        ids = List<int>.from(doc.data()?['ids'] ?? []);
        quantities = List<int>.from(doc.data()?['quantities'] ?? []);
      }

      // Check if product already exists in cart
      final existingIndex = ids.indexOf(productId);
      if (existingIndex != -1) {
        // Update quantity if product already exists
        quantities[existingIndex] = quantity;
      } else {
        // Add new product with its quantity
        ids.add(productId);
        quantities.add(quantity);
      }

      await docRef.set({'ids': ids, 'quantities': quantities});

      // Update local state
      state = CartData(ids: ids, quantities: quantities);
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  // Update quantity for a specific product
  Future<bool> updateQuantity(int productId, int newQuantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('cart_items')
          .doc(user.uid);

      final doc = await docRef.get();

      if (doc.exists) {
        List<int> ids = List<int>.from(doc.data()?['ids'] ?? []);
        List<int> quantities = List<int>.from(doc.data()?['quantities'] ?? []);

        final index = ids.indexOf(productId);
        if (index != -1) {
          quantities[index] = newQuantity;
          await docRef.set({'ids': ids, 'quantities': quantities});

          // Update local state
          state = CartData(ids: ids, quantities: quantities);
          return true;
        }
      }
      return false;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  // Remove product from cart
  Future<void> removeData(int productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('cart_items')
          .doc(user.uid);

      final doc = await docRef.get();

      if (doc.exists) {
        List<int> ids = List<int>.from(doc.data()?['ids'] ?? []);
        List<int> quantities = List<int>.from(doc.data()?['quantities'] ?? []);

        final index = ids.indexOf(productId);
        if (index != -1) {
          ids.removeAt(index);
          quantities.removeAt(index);

          await docRef.set({'ids': ids, 'quantities': quantities});

          // Update local state
          state = CartData(ids: ids, quantities: quantities);
        }
      }
    } catch (e) {
      // Handle error
    }
  }
}
