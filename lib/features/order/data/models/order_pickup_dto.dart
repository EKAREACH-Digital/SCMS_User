import 'package:json_annotation/json_annotation.dart';

import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_pickup.dart';

part 'order_pickup_dto.g.dart';

/// The `data` of `GET /pickup/my/{orderId}`.
@JsonSerializable()
class OrderPickupDto {
  final String orderId;
  final String status;
  final int? pickupNo;
  final String? pickupQrToken;
  @JsonKey(defaultValue: <OrderPickupItemDto>[])
  final List<OrderPickupItemDto> items;

  const OrderPickupDto({
    required this.orderId,
    required this.status,
    this.pickupNo,
    this.pickupQrToken,
    this.items = const [],
  });

  factory OrderPickupDto.fromJson(Map<String, dynamic> json) =>
      _$OrderPickupDtoFromJson(json);

  OrderPickup toEntity() => OrderPickup(
    orderId: orderId,
    status: orderStatusFromBackend(status),
    pickupNo: pickupNo,
    pickupQrToken: pickupQrToken,
    items: items.map((i) => i.toEntity()).toList(),
  );
}

/// One line of `GET /pickup/my/{orderId}`: just a dish name and quantity.
@JsonSerializable()
class OrderPickupItemDto {
  @JsonKey(defaultValue: 'Item')
  final String name;
  @JsonKey(defaultValue: 1)
  final int quantity;

  const OrderPickupItemDto({required this.name, required this.quantity});

  factory OrderPickupItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderPickupItemDtoFromJson(json);

  OrderItem toEntity() => OrderItem(name: name, quantity: quantity);
}
