// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSessionDto _$AuthSessionDtoFromJson(Map<String, dynamic> json) =>
    AuthSessionDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 900,
      user: UserProfileDto.fromJson(json['user'] as Map<String, dynamic>),
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
