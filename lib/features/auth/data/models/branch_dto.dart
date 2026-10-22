import 'package:smart_canteen_user_frontend/features/auth/domain/entities/branch.dart';

/// One item of `GET /pickup/branches?school_id=`.
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

  factory BranchDto.fromJson(Map<String, dynamic> json) => BranchDto(
    id: json['id'] as String,
    name: json['name'] as String,
    schoolId: json['school_id'] as String?,
    isHome: json['is_home'] as bool?,
  );

  Branch toEntity() => Branch(
    id: id,
    name: name,
    schoolId: schoolId ?? '',
    isHome: isHome ?? false,
  );
}
