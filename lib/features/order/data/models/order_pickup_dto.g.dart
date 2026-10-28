// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_pickup_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderPickupDto _$OrderPickupDtoFromJson(Map<String, dynamic> json) =>
    OrderPickupDto(
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      pickupNo: (json['pickup_no'] as num?)?.toInt(),
      pickupQrToken: json['pickup_qr_token'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => OrderPickupItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

OrderPickupItemDto _$OrderPickupItemDtoFromJson(Map<String, dynamic> json) =>
    OrderPickupItemDto(
      name: json['name'] as String? ?? 'Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
