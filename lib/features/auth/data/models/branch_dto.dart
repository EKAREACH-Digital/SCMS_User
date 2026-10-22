import 'package:json_annotation/json_annotation.dart';

import 'package:smart_canteen_user_frontend/features/auth/domain/entities/branch.dart';

part 'branch_dto.g.dart';

/// One item of `GET /pickup/branches?school_id=`.
@JsonSerializable()
class BranchDto {
  final String id;
  final String name;
  final String? schoolId;
  final bool? isHome;

  const BranchDto({
    required this.id,
    required this.name,
    this.schoolId,
    this.isHome,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) =>
      _$BranchDtoFromJson(json);

  Branch toEntity() => Branch(
    id: id,
    name: name,
    schoolId: schoolId ?? '',
    isHome: isHome ?? false,
  );
}
