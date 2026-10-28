import 'package:json_annotation/json_annotation.dart';

import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_checkin.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_order.dart';

part 'pickup_checkin_dto.g.dart';

/// The `data` object of `POST /pickup/arrive`.
///
/// [checkedInAt] is kept as a String in the DTO because [DateTime.parse] is
/// called in [toEntity] — the DTO layer never interprets ISO strings itself.
@JsonSerializable()
class PickupCheckinDto {
  final String counter;

  /// ISO-8601 timestamp from the backend (`checked_in_at`).
  final String checkedInAt;

  @JsonKey(defaultValue: <PickupOrderDto>[])
  final List<PickupOrderDto> orders;

  const PickupCheckinDto({
    required this.counter,
    required this.checkedInAt,
    this.orders = const [],
  });

  factory PickupCheckinDto.fromJson(Map<String, dynamic> json) =>
      _$PickupCheckinDtoFromJson(json);

  PickupCheckin toEntity() => PickupCheckin(
    counter: counter,
    checkedInAt: DateTime.parse(checkedInAt),
    orders: orders.map((o) => o.toEntity()).toList(),
  );
}

/// One order inside `POST /pickup/arrive → data.orders`.
@JsonSerializable()
class PickupOrderDto {
  final String orderId;
  final int pickupNo;
  final String status;
  final bool ready;

  @JsonKey(defaultValue: <PickupOrderItemDto>[])
  final List<PickupOrderItemDto> items;

  const PickupOrderDto({
    required this.orderId,
    required this.pickupNo,
    required this.status,
    required this.ready,
    this.items = const [],
  });

  factory PickupOrderDto.fromJson(Map<String, dynamic> json) =>
      _$PickupOrderDtoFromJson(json);

  PickupOrder toEntity() => PickupOrder(
    orderId: orderId,
    pickupNo: pickupNo,
    // Reuse the order feature's mapper; `preparing` and `paid` map to the same
    // student-visible stage.
    status: orderStatusFromBackend(status),
    ready: ready,
    items: items.map((i) => i.toEntity()).toList(),
  );
}

/// One dish line inside a pickup order — name + quantity only.
@JsonSerializable()
class PickupOrderItemDto {
  @JsonKey(defaultValue: 'Item')
  final String name;

  @JsonKey(defaultValue: 1)
  final int quantity;

  const PickupOrderItemDto({required this.name, required this.quantity});

  factory PickupOrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$PickupOrderItemDtoFromJson(json);

  /// Reuses [OrderItem]; the `imageUrl` and `unitPrice` fields are absent at
  /// the pickup counter and will be null.
  OrderItem toEntity() => OrderItem(name: name, quantity: quantity);
}
