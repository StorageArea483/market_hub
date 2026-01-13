// Cart state model to hold ids and quantities
class CartData {
  final List<int> ids;
  final List<int> quantities;

  CartData({required this.ids, required this.quantities});

  CartData copyWith({List<int>? ids, List<int>? quantities}) {
    return CartData(
      ids: ids ?? this.ids,
      quantities: quantities ?? this.quantities,
    );
  }
}
