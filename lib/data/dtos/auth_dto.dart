class AuthTokenDto {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthTokenDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) => AuthTokenDto(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: json['expires_in'] as int,
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
      };
}

class RoleDto {
  final String id;
  final String name;

  const RoleDto({required this.id, required this.name});

  factory RoleDto.fromJson(Map<String, dynamic> json) => RoleDto(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}

class SchoolDto {
  final String id;
  final String name;

  const SchoolDto({required this.id, required this.name});

  factory SchoolDto.fromJson(Map<String, dynamic> json) => SchoolDto(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}

/// The signed-in user's push-notification preferences. Persisted on the backend
/// `User` (`notify_*` columns) and edited from Settings → Notifications.
class NotificationPreferencesDto {
  final bool orderUpdates;
  final bool promotions;
  final bool systemAlerts;

  const NotificationPreferencesDto({
    required this.orderUpdates,
    required this.promotions,
    required this.systemAlerts,
  });

  /// Reads the flat `notify_*` fields off a backend `User` JSON, defaulting to
  /// the same values as the backend column defaults if any are absent.
  factory NotificationPreferencesDto.fromUserJson(Map<String, dynamic> json) =>
      NotificationPreferencesDto(
        orderUpdates: json['notify_order_updates'] as bool? ?? true,
        promotions: json['notify_promotions'] as bool? ?? false,
        systemAlerts: json['notify_system_alerts'] as bool? ?? true,
      );
}

/// Mirrors the backend `User` entity (backend `src/modules/users/entities/user.entity.ts`),
/// as returned by `GET /users/me` and embedded in the `user` field of auth responses.
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
  final NotificationPreferencesDto notificationPreferences;

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
    required this.notificationPreferences,
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
        notificationPreferences:
            NotificationPreferencesDto.fromUserJson(json),
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
      return SchoolDto(
        id: json['school_id'] as String? ?? '',
        name: school,
      );
    }
    return null;
  }
}
