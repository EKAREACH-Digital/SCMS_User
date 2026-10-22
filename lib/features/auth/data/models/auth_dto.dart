import 'package:json_annotation/json_annotation.dart';

import 'package:smart_canteen_user_frontend/features/auth/domain/entities/school.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/user.dart';

part 'auth_dto.g.dart';

// API shapes for the auth feature. They mirror the backend JSON and stay in the
// data layer — the repository hands entities (via `toEntity`) to everyone else.

@JsonSerializable()
class RoleDto {
  final String id;
  final String name;

  const RoleDto({required this.id, required this.name});

  factory RoleDto.fromJson(Map<String, dynamic> json) =>
      _$RoleDtoFromJson(json);
}

@JsonSerializable()
class SchoolDto {
  final String id;
  final String name;

  const SchoolDto({required this.id, required this.name});

  factory SchoolDto.fromJson(Map<String, dynamic> json) =>
      _$SchoolDtoFromJson(json);

  School toEntity() => School(id: id, name: name);
}

/// Mirrors the backend `User` entity (backend `src/modules/users/entities/user.entity.ts`),
/// as returned by `GET /users/me`, `POST /auth/register` and in the `user`
/// field of auth responses.
@JsonSerializable()
class UserProfileDto {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  @JsonKey(defaultValue: 'active')
  final String status;
  @JsonKey(readValue: _readRole)
  final RoleDto? role;
  @JsonKey(readValue: _readSchool)
  final SchoolDto? school;
  final String? homeBranchId;

  /// The backend's `profile_completed`. Null if a response leaves it out; the
  /// entity then falls back to "has a phone and a school".
  final bool? profileCompleted;

  /// True when the account has a password set, so email/password sign-in works.
  /// False for Google-only accounts — the app offers "Set a password" then.
  /// Absent on the raw `/users/me` entity, where a password is assumed.
  @JsonKey(defaultValue: true)
  final bool canUseEmailPassword;

  const UserProfileDto({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    required this.status,
    this.role,
    this.school,
    this.homeBranchId,
    this.profileCompleted,
    this.canUseEmailPassword = true,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  /// `role` is the joined relation object in both shapes today; a bare name
  /// string is tolerated so a flattened payload can't crash parsing.
  static Object? _readRole(Map<dynamic, dynamic> json, String key) {
    final role = json[key];
    if (role is String && role.isNotEmpty) return {'id': '', 'name': role};
    return role is Map ? role : null;
  }

  /// `school` arrives in two different shapes:
  /// - `GET /users/me` returns the raw entity, so it's the joined relation
  ///   object `{ id, name }`.
  /// - Auth responses (`/auth/login`, `/auth/google`, `/auth/complete-profile`)
  ///   go through the backend's `serializeUser`, which flattens it to just the
  ///   school's **name string**, with the id left in `school_id`.
  ///
  /// Handling both keeps either response parseable.
  static Object? _readSchool(Map<dynamic, dynamic> json, String key) {
    final school = json[key];
    if (school is String && school.isNotEmpty) {
      return {'id': json['school_id'] ?? '', 'name': school};
    }
    return school is Map ? school : null;
  }

  User toEntity() => User(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    avatarUrl: avatarUrl,
    schoolId: school?.id,
    schoolName: school?.name,
    homeBranchId: homeBranchId,
    role: UserRole.fromString(role?.name),
    canUseEmailPassword: canUseEmailPassword,
    profileCompleted: profileCompleted ?? _looksComplete,
  );

  bool get _looksComplete =>
      (phone?.trim().isNotEmpty ?? false) &&
      (school?.id.trim().isNotEmpty ?? false);
}
