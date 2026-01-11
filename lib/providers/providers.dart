import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/legacy.dart';
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
