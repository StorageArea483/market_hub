class Category {
  final String name;
  final bool isSelected;

  Category({required this.name, required this.isSelected});

  Category copyWith({String? name, bool? isSelected}) {
    return Category(
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
