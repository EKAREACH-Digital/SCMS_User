// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleDto _$RoleDtoFromJson(Map<String, dynamic> json) =>
    RoleDto(id: json['id'] as String, name: json['name'] as String);

SchoolDto _$SchoolDtoFromJson(Map<String, dynamic> json) =>
    SchoolDto(id: json['id'] as String, name: json['name'] as String);

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String? ?? 'active',
      role: UserProfileDto._readRole(json, 'role') == null
          ? null
          : RoleDto.fromJson(
              UserProfileDto._readRole(json, 'role') as Map<String, dynamic>,
            ),
      school: UserProfileDto._readSchool(json, 'school') == null
          ? null
          : SchoolDto.fromJson(
              UserProfileDto._readSchool(json, 'school')
                  as Map<String, dynamic>,
            ),
      homeBranchId: json['home_branch_id'] as String?,
      profileCompleted: json['profile_completed'] as bool?,
      canUseEmailPassword: json['can_use_email_password'] as bool? ?? true,
    );
