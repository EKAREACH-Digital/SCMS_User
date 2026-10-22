import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';

/// A dish in the cart and how many of it.
class CartEntry {
  final FoodItem item;
  final int quantity;

  const CartEntry({required this.item, this.quantity = 1});

  CartEntry copyWith({FoodItem? item, int? quantity}) {
    return CartEntry(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
