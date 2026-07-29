/// One line in a placed order.
class OrderItemInput {
  final String menuItemId;
  final int quantity;

  const OrderItemInput({required this.menuItemId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'menu_item_id': menuItemId,
        'quantity': quantity,
      };
}

/// A meal-ticket coupon minted by the backend (one per ordered item). The
/// [qrToken] is the exact string the canteen scanner reads and redeems, so the
/// QR the app shows must encode it verbatim.
class CouponDto {
  final String id;
  final String qrToken;
  final String? couponCode;
  final String mealSession; // breakfast | lunch | dinner
  final String status; // active | redeemed | expired | cancelled
  final String? validDate; // yyyy-MM-dd
  final String? menuItemName;

  const CouponDto({
    required this.id,
    required this.qrToken,
    required this.couponCode,
    required this.mealSession,
    required this.status,
    required this.validDate,
    required this.menuItemName,
  });

  factory CouponDto.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] ?? json['menu_item'];
    return CouponDto(
      id: json['id'] as String,
      qrToken: json['qr_token'] as String,
      couponCode: json['coupon_code'] as String?,
      mealSession: json['meal_session'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      validDate: json['valid_date'] as String?,
      menuItemName:
          menuItem is Map<String, dynamic> ? menuItem['name'] as String? : null,
    );
  }

  bool get isActive => status == 'active';
}

/// The result of `POST /orders` — the order plus the coupons minted for it.
class PlacedOrderDto {
  final String id;
  final double totalAmount;
  final String mealSession;
  final String status;
  final List<CouponDto> coupons;

  const PlacedOrderDto({
    required this.id,
    required this.totalAmount,
    required this.mealSession,
    required this.status,
    required this.coupons,
  });

  factory PlacedOrderDto.fromJson(Map<String, dynamic> json) {
    final couponsJson = (json['coupons'] as List<dynamic>?) ?? const [];
    return PlacedOrderDto(
      id: json['id'] as String,
      totalAmount: _toDouble(json['total_amount']),
      mealSession: json['meal_session'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      coupons: couponsJson
          .map((e) => CouponDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _toDouble(dynamic value) => switch (value) {
        num n => n.toDouble(),
        String s => double.tryParse(s) ?? 0.0,
        _ => 0.0,
      };
}

/// One line of a past order (a menu item + quantity), for history display.
class OrderLineDto {
  final String name;
  final int quantity;

  /// The dish's photo (`image_url` on the joined menu item). The backend
  /// already returns the full menu item on `GET /orders/my`, so history can
  /// show the same picture the menu does.
  final String? imageUrl;

  const OrderLineDto({
    required this.name,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderLineDto.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] ?? json['menu_item'];
    final asMap = menuItem is Map<String, dynamic> ? menuItem : null;
    final image = asMap?['image_url'] as String?;
    return OrderLineDto(
      name: asMap?['name'] as String? ?? 'Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: (image != null && image.isNotEmpty) ? image : null,
    );
  }
}

/// A past order from `GET /orders/my`, used by the History screen.
class OrderSummaryDto {
  final String id;
  final double totalAmount;
  final String status; // pending | preparing | ready | completed | cancelled
  final String mealSession;
  final DateTime createdAt;
  final List<OrderLineDto> items;

  const OrderSummaryDto({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.mealSession,
    required this.createdAt,
    required this.items,
  });

  factory OrderSummaryDto.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>?) ?? const [];
    return OrderSummaryDto(
      id: json['id'] as String,
      totalAmount: PlacedOrderDto._toDouble(json['total_amount']),
      status: json['status'] as String? ?? 'pending',
      mealSession: json['meal_session'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      items: itemsJson
          .map((e) => OrderLineDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
