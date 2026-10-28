import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';

/// One order returned by `POST /pickup/arrive`.
///
/// [ready] is the backend's authoritative flag — true means the student can
/// collect right now. [status] lets the UI show the same status label as the
/// History screen, so both places read the same thing.
class PickupOrder {
  final String orderId;
  final int pickupNo;
  final OrderStatus status;
  final bool ready;

  /// The dishes in this order — name + quantity only; no prices at the counter.
  final List<OrderItem> items;

  const PickupOrder({
    required this.orderId,
    required this.pickupNo,
    required this.status,
    required this.ready,
    required this.items,
  });

  PickupOrder copyWith({
    String? orderId,
    int? pickupNo,
    OrderStatus? status,
    bool? ready,
    List<OrderItem>? items,
  }) => PickupOrder(
    orderId: orderId ?? this.orderId,
    pickupNo: pickupNo ?? this.pickupNo,
    status: status ?? this.status,
    ready: ready ?? this.ready,
    items: items ?? this.items,
  );
}
