import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';

/// A paid order's pickup ticket, from `GET /pickup/my/{orderId}`: the token
/// the canteen scans and where the order is in the pickup flow.
class OrderPickup {
  final String orderId;
  final OrderStatus status;
  final int? pickupNo;

  /// Encoded into the pickup QR.
  final String? pickupQrToken;
  final List<OrderItem> items;

  const OrderPickup({
    required this.orderId,
    required this.status,
    this.pickupNo,
    this.pickupQrToken,
    this.items = const [],
  });

  OrderPickup copyWith({
    String? orderId,
    OrderStatus? status,
    int? pickupNo,
    String? pickupQrToken,
    List<OrderItem>? items,
  }) {
    return OrderPickup(
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      pickupNo: pickupNo ?? this.pickupNo,
      pickupQrToken: pickupQrToken ?? this.pickupQrToken,
      items: items ?? this.items,
    );
  }
}
