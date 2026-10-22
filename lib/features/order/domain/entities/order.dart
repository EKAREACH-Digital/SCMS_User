import 'package:smart_canteen_user_frontend/features/order/domain/entities/meal_coupon.dart';

/// A past order, as returned by `GET /orders/my`.
class Order {
  final String id;
  final double totalAmount;
  final String status; // pending | preparing | ready | completed | cancelled
  final String mealSession;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.mealSession,
    required this.createdAt,
    required this.items,
  });

  Order copyWith({
    String? id,
    double? totalAmount,
    String? status,
    String? mealSession,
    DateTime? createdAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      mealSession: mealSession ?? this.mealSession,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

/// One line of an order: a dish and how many of it.
class OrderItem {
  final String name;
  final int quantity;
  final String? imageUrl;

  /// What one unit cost when the order was placed, or null when the backend
  /// gave no price for this line.
  final double? unitPrice;

  const OrderItem({
    required this.name,
    required this.quantity,
    this.imageUrl,
    this.unitPrice,
  });

  OrderItem copyWith({
    String? name,
    int? quantity,
    String? imageUrl,
    double? unitPrice,
  }) {
    return OrderItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

/// A line of a new order to place.
class NewOrderItem {
  final String menuItemId;
  final int quantity;

  const NewOrderItem({required this.menuItemId, required this.quantity});

  NewOrderItem copyWith({String? menuItemId, int? quantity}) {
    return NewOrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// The result of placing an order — the order plus the coupons minted for it.
class PlacedOrder {
  final String id;
  final double totalAmount;
  final String mealSession;
  final String status;
  final List<MealCoupon> coupons;

  const PlacedOrder({
    required this.id,
    required this.totalAmount,
    required this.mealSession,
    required this.status,
    required this.coupons,
  });

  PlacedOrder copyWith({
    String? id,
    double? totalAmount,
    String? mealSession,
    String? status,
    List<MealCoupon>? coupons,
  }) {
    return PlacedOrder(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      mealSession: mealSession ?? this.mealSession,
      status: status ?? this.status,
      coupons: coupons ?? this.coupons,
    );
  }
}
