import 'package:flutter/widgets.dart';

import '../ui/utils/meal_session.dart';
import 'food_item.dart';

class CartEntry {
  final FoodItem item;
  int quantity;

  CartEntry({required this.item, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  final List<CartEntry> _entries = [];

  List<CartEntry> get entries => List.unmodifiable(_entries);

  int get totalItems => _entries.fold(0, (s, e) => s + e.quantity);

  double get subtotal =>
      _entries.fold(0.0, (s, e) => s + e.item.price * e.quantity);

  // No client-side discount/fee: the backend charges exactly Σ price×qty, so the
  // cart total must equal the subtotal (kept as getters for existing UI rows).
  double get discount => 0.0;

  double get serviceFee => 0.0;

  double get total => subtotal;

  /// True when everything in the cart is sold all day (drinks), so checkout
  /// shouldn't wait for a meal window. An empty cart is not "anytime" — there
  /// is nothing to buy.
  bool get isAnytimeOnly =>
      _entries.isNotEmpty &&
      _entries.every((e) => MealSession.isAnytimeCategory(e.item.category));

  void add(FoodItem item) {
    final idx = _entries.indexWhere((e) => e.item.id == item.id);
    if (idx >= 0) {
      _entries[idx].quantity++;
    } else {
      _entries.add(CartEntry(item: item));
    }
    notifyListeners();
  }

  void increment(String id) {
    final idx = _entries.indexWhere((e) => e.item.id == id);
    if (idx >= 0) {
      _entries[idx].quantity++;
      notifyListeners();
    }
  }

  void decrement(String id) {
    final idx = _entries.indexWhere((e) => e.item.id == id);
    if (idx >= 0) {
      if (_entries[idx].quantity <= 1) {
        _entries.removeAt(idx);
      } else {
        _entries[idx].quantity--;
      }
      notifyListeners();
    }
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  int quantityOf(String id) {
    final idx = _entries.indexWhere((e) => e.item.id == id);
    return idx >= 0 ? _entries[idx].quantity : 0;
  }
}

class CartProvider extends InheritedNotifier<CartModel> {
  const CartProvider({
    super.key,
    required CartModel cart,
    required super.child,
  }) : super(notifier: cart);

  static CartModel of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CartProvider>()!.notifier!;
}