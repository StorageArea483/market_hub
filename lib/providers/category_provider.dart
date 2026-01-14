import 'package:flutter_riverpod/legacy.dart';
import 'package:market_hub/models/categories.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, Category>(
  (ref) => CategoryNotifier(),
);

class CategoryNotifier extends StateNotifier<Category> {
  CategoryNotifier() : super(Category(name: 'All', isSelected: true));

  void selectCategory(Category category) {
    state = category;
  }
}
