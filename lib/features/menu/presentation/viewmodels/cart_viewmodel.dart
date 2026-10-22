import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/features/menu/domain/entities/cart_entry.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/meal_session.dart';

/// The shared cart — filled from the home and menu screens, paid for on the
/// order summary.
class CartViewModel extends ChangeNotifier {
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
    final idx = _indexOf(item.id);
    if (idx >= 0) {
      _setQuantity(idx, _entries[idx].quantity + 1);
    } else {
      _setState(() => _entries.add(CartEntry(item: item)));
    }
  }

  void increment(String id) {
    final idx = _indexOf(id);
    if (idx >= 0) _setQuantity(idx, _entries[idx].quantity + 1);
  }

  void decrement(String id) {
    final idx = _indexOf(id);
    if (idx < 0) return;
    if (_entries[idx].quantity <= 1) {
      _setState(() => _entries.removeAt(idx));
    } else {
      _setQuantity(idx, _entries[idx].quantity - 1);
    }
  }

  void clear() => _setState(_entries.clear);

  int quantityOf(String id) {
    final idx = _indexOf(id);
    return idx >= 0 ? _entries[idx].quantity : 0;
  }

  int _indexOf(String id) => _entries.indexWhere((e) => e.item.id == id);

  void _setQuantity(int idx, int quantity) => _setState(
    () => _entries[idx] = _entries[idx].copyWith(quantity: quantity),
  );

  /// The only place listeners are notified: applies [update], then rebuilds
  /// listeners. This view model has no async work, so it has no `ViewState`.
  void _setState(VoidCallback update) {
    update();
    notifyListeners();
  }
}
