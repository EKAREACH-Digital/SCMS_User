import 'package:smart_canteen_user_frontend/features/order/domain/entities/meal_coupon.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';

/// One line in a placed order (request body).
class OrderItemInput {
  final String menuItemId;
  final int quantity;

  const OrderItemInput({required this.menuItemId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'menu_item_id': menuItemId,
        'quantity': quantity,
      };
}

/// A meal-ticket coupon, returned by `GET /coupons/my`.
class CouponDto {
  final String id;
  final String qrToken;
  final String? couponCode;
  final String mealSession;
  final String status;
  final String? validDate;
  final String? menuItemName;

  const CouponDto({
    required this.id,
    required this.qrToken,
    this.couponCode,
    required this.mealSession,
    required this.status,
    this.validDate,
    this.menuItemName,
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

  MealCoupon toEntity() => MealCoupon(
        id: id,
        qrToken: qrToken,
        couponCode: couponCode,
        mealSession: mealSession,
        status: status,
        validDate: validDate,
        menuItemName: menuItemName,
      );
}

/// The result of `POST /orders/checkout` — payment session from the gateway.
///
/// The backend calculates prices; the app never sends them. [qrImage] is an
/// SVG URL for CutLuy (Bakong) or a `data:image/png;base64,...` for ABA PayWay.
class PlacedOrderDto {
  final String orderId;
  final String provider;
  final double totalAmount;
  final String qrString;
  final String qrImage;
  final String? checkoutUrl;
  final String? deeplink;
  final String? expiresAt;

  const PlacedOrderDto({
    required this.orderId,
    required this.provider,
    required this.totalAmount,
    required this.qrString,
    required this.qrImage,
    this.checkoutUrl,
    this.deeplink,
    this.expiresAt,
  });

  factory PlacedOrderDto.fromJson(Map<String, dynamic> json) => PlacedOrderDto(
        orderId: json['order_id'] as String,
        provider: json['provider'] as String? ?? 'CUTLUY',
        totalAmount: _toDouble(json['total_amount']),
        qrString: json['qr_string'] as String? ?? '',
        qrImage: json['qr_image'] as String? ?? '',
        checkoutUrl: json['checkout_url'] as String?,
        deeplink: json['deeplink'] as String?,
        expiresAt: json['expires_at'] as String?,
      );

  PlacedOrder toEntity() => PlacedOrder(
        orderId: orderId,
        provider: provider,
        totalAmount: totalAmount,
        qrString: qrString,
        qrImage: qrImage,
        checkoutUrl: checkoutUrl,
        deeplink: deeplink,
        expiresAt: expiresAt != null ? DateTime.tryParse(expiresAt!) : null,
      );

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

  /// What one unit cost. Read from the order line's own `unit_price` when the
  /// backend snapshots it, so a past order keeps the price it was actually
  /// charged at rather than today's menu price; the joined menu item is only a
  /// fallback. Null when neither is present — history then shows the order
  /// total without a per-line breakdown.
  final double? unitPrice;

  const OrderLineDto({
    required this.name,
    required this.quantity,
    this.imageUrl,
    this.unitPrice,
  });

  /// Total charged for this line.
  double? get lineTotal =>
      unitPrice == null ? null : unitPrice! * quantity;

  factory OrderLineDto.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] ?? json['menu_item'];
    final asMap = menuItem is Map<String, dynamic> ? menuItem : null;
    final image = asMap?['image_url'] as String?;
    final rawPrice =
        json['unit_price'] ?? json['price'] ?? asMap?['price'];
    return OrderLineDto(
      name: asMap?['name'] as String? ?? 'Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: (image != null && image.isNotEmpty) ? image : null,
      unitPrice: rawPrice == null ? null : PlacedOrderDto._toDouble(rawPrice),
    );
  }

  OrderItem toEntity() => OrderItem(
        name: name,
        quantity: quantity,
        imageUrl: imageUrl,
        unitPrice: unitPrice,
      );
}

/// A past order from `GET /orders/my`, used by the History screen.
class OrderSummaryDto {
  final String id;
  final double totalAmount;
  /// pending_payment | paid | ready | completed | cancelled
  final String status;
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
      status: json['status'] as String? ?? 'pending_payment',
      mealSession: json['meal_session'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      items: itemsJson
          .map((e) => OrderLineDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Order toEntity() => Order(
        id: id,
        totalAmount: totalAmount,
        status: orderStatusFromBackend(status),
        mealSession: mealSession,
        createdAt: createdAt,
        items: items.map((i) => i.toEntity()).toList(),
      );
}

/// Maps the backend's status string to [OrderStatus]. `preparing` is the same
/// stage as `paid` for the student (still cooking). An unknown value counts as
/// unpaid: that is the safe guess, since an unpaid order shows no pickup QR.
OrderStatus orderStatusFromBackend(String value) => switch (value) {
  'paid' || 'preparing' => OrderStatus.paid,
  'ready' => OrderStatus.ready,
  'completed' => OrderStatus.completed,
  'cancelled' => OrderStatus.cancelled,
  _ => OrderStatus.pendingPayment,
};
