import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:market_hub/models/cart_info_model.dart';
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

// Provider to load cart IDs and Quantities from Firebase
final loadCartDataProvider = FutureProvider<Map<String, List<dynamic>>>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return {'id': [], 'quantity': []};
  }

  final doc = await FirebaseFirestore.instance
      .collection('cart_items')
      .doc(user.uid)
      .get();

  if (!doc.exists) {
    return {'id': [], 'quantity': []};
  }

  final data = doc.data();
  return {
    'id': List<int>.from(data?['id'] ?? []),
    'quantity': List<int>.from(data?['quantity'] ?? []),
  };
});

// this loading state is useful when adding data or removing the data from firestore database
final loadingCartItemsProvider = StateProvider<bool>((_) => false);

final cartProvider = StateNotifierProvider<CartNotifier, List<CartInfoModel>>(
  (ref) => CartNotifier(),
);

// Provider to add carts in Firebase
class CartNotifier extends StateNotifier<List<CartInfoModel>> {
  CartNotifier() : super([]);

  // Add product ids and quantity to firebase
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
        ids = List<int>.from(doc.data()?['id'] ?? []);
        quantities = List<int>.from(doc.data()?['quantity'] ?? []);
      }

      // Add or update the product
      if (!ids.contains(productId)) {
        ids.add(productId);
        quantities.add(quantity);
      } else {
        int index = ids.indexOf(productId);
        quantities[index] = quantity;
      }

      await docRef.set({'id': ids, 'quantity': quantities});
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  // Remove product from cart
  Future<bool> removeData(int productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('cart_items')
          .doc(user.uid);

      final doc = await docRef.get();

      if (doc.exists) {
        List<int> ids = List<int>.from(doc.data()?['id'] ?? []);
        List<int> quantities = List<int>.from(doc.data()?['quantity'] ?? []);

        int index = ids.indexOf(productId);
        if (index != -1) {
          ids.removeAt(index);
          quantities.removeAt(index);
          await docRef.set({'id': ids, 'quantity': quantities});
        }
      }
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }
}
