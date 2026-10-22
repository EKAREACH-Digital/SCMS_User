import 'package:smart_canteen_user_frontend/features/auth/domain/entities/school.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/user.dart';

// API shapes for the auth feature. They mirror the backend JSON and stay in the
// data layer — the repository hands entities (via `toEntity`) to everyone else.

class RoleDto {
  final String id;
  final String name;

  const RoleDto({required this.id, required this.name});

  factory RoleDto.fromJson(Map<String, dynamic> json) =>
      RoleDto(id: json['id'] as String, name: json['name'] as String);
}

class SchoolDto {
  final String id;
  final String name;

  const SchoolDto({required this.id, required this.name});

  factory SchoolDto.fromJson(Map<String, dynamic> json) =>
      SchoolDto(id: json['id'] as String, name: json['name'] as String);

  School toEntity() => School(id: id, name: name);
}

/// Mirrors the backend `User` entity (backend `src/modules/users/entities/user.entity.ts`),
/// as returned by `GET /users/me`, `POST /auth/register` and in the `user`
/// field of auth responses.
class UserProfileDto {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final String status;
  final RoleDto? role;
  final SchoolDto? school;
  final String? homeBranchId;

  /// The backend's `profile_completed`. Null if a response leaves it out; the
  /// entity then falls back to "has a phone and a school".
  final bool? profileCompleted;

  /// True when the account has a password set, so email/password sign-in works.
  /// False for Google-only accounts — the app offers "Set a password" then.
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

  factory UserProfileDto.fromJson(Map<String, dynamic> json) => UserProfileDto(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    phone: json['phone'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    status: json['status'] as String? ?? 'active',
    role: _parseRole(json['role']),
    school: _parseSchool(json),
    homeBranchId: json['home_branch_id'] as String?,
    profileCompleted: json['profile_completed'] as bool?,
    // Backend sends this on auth responses (serializeUser). Absent on the
    // raw /users/me entity, where we assume a password exists.
    canUseEmailPassword: json['can_use_email_password'] as bool? ?? true,
  );

  /// `role` is the joined relation object in both shapes today; a bare name
  /// string is tolerated so a flattened payload can't crash parsing.
  static RoleDto? _parseRole(dynamic role) {
    if (role is Map<String, dynamic>) return RoleDto.fromJson(role);
    if (role is String && role.isNotEmpty) return RoleDto(id: '', name: role);
    return null;
  }

  /// `school` arrives in two different shapes:
  /// - `GET /users/me` returns the raw entity, so it's the joined relation
  ///   object `{ id, name }`.
  /// - Auth responses (`/auth/login`, `/auth/google`, `/auth/complete-profile`)
  ///   go through the backend's `serializeUser`, which flattens it to just the
  ///   school's **name string**, with the id left in `school_id`.
  ///
  /// Handling both keeps either response parseable.
  static SchoolDto? _parseSchool(Map<String, dynamic> json) {
    final school = json['school'];
    if (school is Map<String, dynamic>) return SchoolDto.fromJson(school);
    if (school is String && school.isNotEmpty) {
      return SchoolDto(id: json['school_id'] as String? ?? '', name: school);
    }
    return null;
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
