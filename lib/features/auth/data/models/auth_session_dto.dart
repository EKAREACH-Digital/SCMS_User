import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/user.dart';

/// A signed-in session: the shape shared by `POST /auth/login`,
/// `POST /auth/google` and `POST /auth/complete-profile`.
class AuthSessionDto {
  final String accessToken;
  final String refreshToken;

  /// Access-token lifetime in seconds (900 = 15 minutes).
  final int expiresIn;
  final UserProfileDto user;

  /// Present (true) only for an account given a temporary password.
  final bool mustChangePassword;

  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    this.mustChangePassword = false,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) => AuthSessionDto(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiresIn: json['expires_in'] as int? ?? 900,
    user: UserProfileDto.fromJson(json['user'] as Map<String, dynamic>),
    // The backend spells this one in camelCase.
    mustChangePassword: json['mustChangePassword'] as bool? ?? false,
  );

  /// The signed-in user, carrying the session-only [mustChangePassword] flag.
  User toEntity() =>
      user.toEntity().copyWith(mustChangePassword: mustChangePassword);
}
