import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:market_hub/models/post_model.dart';

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

final selectedPriceProvider = StateProvider<double?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
