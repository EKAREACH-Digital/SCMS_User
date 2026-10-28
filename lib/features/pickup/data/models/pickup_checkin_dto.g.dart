// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_checkin_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupCheckinDto _$PickupCheckinDtoFromJson(Map<String, dynamic> json) =>
    PickupCheckinDto(
      counter: json['counter'] as String,
      checkedInAt: json['checked_in_at'] as String,
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => PickupOrderDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

PickupOrderDto _$PickupOrderDtoFromJson(Map<String, dynamic> json) =>
    PickupOrderDto(
      orderId: json['order_id'] as String,
      pickupNo: (json['pickup_no'] as num).toInt(),
      status: json['status'] as String,
      ready: json['ready'] as bool,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => PickupOrderItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

PickupOrderItemDto _$PickupOrderItemDtoFromJson(Map<String, dynamic> json) =>
    PickupOrderItemDto(
      name: json['name'] as String? ?? 'Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
