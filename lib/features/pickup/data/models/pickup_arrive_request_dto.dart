import 'package:json_annotation/json_annotation.dart';

part 'pickup_arrive_request_dto.g.dart';

/// Request body for `POST /pickup/arrive`.
@JsonSerializable(createFactory: false, createToJson: true)
class PickupArriveRequestDto {
  final String code;

  const PickupArriveRequestDto({required this.code});

  Map<String, dynamic> toJson() => _$PickupArriveRequestDtoToJson(this);
}
