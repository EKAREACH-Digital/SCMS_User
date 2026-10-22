import 'package:json_annotation/json_annotation.dart';

import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/user.dart';

part 'auth_session_dto.g.dart';

/// A signed-in session: the shape shared by `POST /auth/login`,
/// `POST /auth/google` and `POST /auth/complete-profile`.
@JsonSerializable()
class AuthSessionDto {
  final String accessToken;
  final String refreshToken;

  /// Access-token lifetime in seconds (900 = 15 minutes).
  @JsonKey(defaultValue: 900)
  final int expiresIn;
  final UserProfileDto user;

  /// Present (true) only for an account given a temporary password. The
  /// backend spells this one in camelCase.
  @JsonKey(name: 'mustChangePassword', defaultValue: false)
  final bool mustChangePassword;

  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    this.mustChangePassword = false,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionDtoFromJson(json);

  /// The signed-in user, carrying the session-only [mustChangePassword] flag.
  User toEntity() =>
      user.toEntity().copyWith(mustChangePassword: mustChangePassword);
}
