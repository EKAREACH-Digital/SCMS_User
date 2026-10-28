import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_order.dart';

/// The result of `POST /pickup/arrive` — a successful check-in at a counter stand.
///
/// [counter] is the human-readable counter name shown in the result panel.
/// [checkedInAt] is stored in UTC; format to local time before displaying.
class PickupCheckin {
  final String counter;
  final DateTime checkedInAt;
  final List<PickupOrder> orders;

  const PickupCheckin({
    required this.counter,
    required this.checkedInAt,
    required this.orders,
  });

  PickupCheckin copyWith({
    String? counter,
    DateTime? checkedInAt,
    List<PickupOrder>? orders,
  }) => PickupCheckin(
    counter: counter ?? this.counter,
    checkedInAt: checkedInAt ?? this.checkedInAt,
    orders: orders ?? this.orders,
  );
}
