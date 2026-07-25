import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../config/api_client.dart';
import '../../config/api_config.dart';
import '../../config/google_auth_config.dart';
import '../../dtos/auth_dto.dart';
import '../../exceptions/api_exception.dart';
import '../../local/token_storage.dart';
import 'auth_repository.dart';

class AuthRepositoryNestjs implements AuthRepository {
  AuthRepositoryNestjs({Dio? dio, TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage.instance,
        _dio = dio ?? createApiClient(tokenStorage: tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;
  Future<void>? _googleSignInInit;

  @override
  Future<AuthTokenDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(ApiConfig.login, {
      'email': email,
      'password': password,
    });
    return _extractTokens(response);
  }

  @override
  Future<AuthTokenDto> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final response = await _post(ApiConfig.register, {
      'email': email,
      'password': password,
      'first_name': nameParts.isNotEmpty ? nameParts.first : null,
      'last_name': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
    });
    return _extractTokens(response);
  }

  @override
  Future<AuthTokenDto> loginWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const ApiException('Google sign-in was cancelled');
      }
      throw ApiException('Google sign-in failed: ${e.description ?? e.code}');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ApiException(
        'Google returned no ID token. This usually means the OAuth client for '
        'this platform is not configured in Google Cloud Console (check the '
        'package name / SHA-1 for Android, or the bundle ID for iOS), or the '
        'serverClientId is wrong.',
      );
    }

    final response = await _post(ApiConfig.googleLogin, {'id_token': idToken});
    return _extractTokens(response);
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= GoogleSignIn.instance.initialize(
      clientId: _platformClientId,
      serverClientId: GoogleAuthConfig.serverClientId,
    );
  }

  /// The native client ID for the current platform. iOS needs its own client
  /// ID; Android reads it from `google-services.json`, and web uses the
  /// serverClientId, so both are left null here.
  String? get _platformClientId {
    if (kIsWeb) return null;
    return defaultTargetPlatform == TargetPlatform.iOS
        ? GoogleAuthConfig.iosClientId
        : null;
  }

  @override
  Future<AuthTokenDto> refreshToken(String refreshToken) async {
    final response = await _post(ApiConfig.refreshToken, {
      'refresh_token': refreshToken,
    });
    final tokens = AuthTokenDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<UserProfileDto> getProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profile);
      return UserProfileDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error loading profile: $e');
    }
  }

  @override
  Future<UserProfileDto> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConfig.userProfile(userId),
        data: {
          'first_name': ?firstName,
          'last_name': ?lastName,
          'phone': ?phone,
          'school_id': ?schoolId,
        },
      );
      return UserProfileDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error updating profile: $e');
    }
  }

  @override
  Future<UserProfileDto> completeProfile({
    required String fullName,
    required String phone,
    required String schoolId,
    String? password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.completeProfile,
        data: {
          'name': fullName,
          'phone': phone,
          'school_id': schoolId,
          'password': ?password,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      // The endpoint returns a fresh token pair (the JWT now embeds the
      // school), so replace the stored session before returning the user.
      await _tokenStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return UserProfileDto.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error completing profile: $e');
    }
  }

  @override
  Future<void> setPassword(String password) async {
    try {
      await _dio.post(ApiConfig.setPassword, data: {'password': password});
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error setting password: $e');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _post(ApiConfig.forgotPassword, {'email': email});
  }

  @override
  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    final response = await _post(ApiConfig.verifyResetCode, {
      'email': email,
      'code': code,
    });
    return response.data['data']['reset_token'] as String;
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    await _post(ApiConfig.resetPassword, {
      'reset_token': resetToken,
      'password': password,
    });
  }

  @override
  Future<NotificationPreferencesDto> updateNotificationPreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConfig.userNotificationPreferences(userId),
        data: {
          'notify_order_updates': ?orderUpdates,
          'notify_promotions': ?promotions,
          'notify_system_alerts': ?systemAlerts,
        },
      );
      // The endpoint returns the full user record; read the prefs off it.
      return NotificationPreferencesDto.fromUserJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error updating notification preferences: $e');
    }
  }

  @override
  Future<List<SchoolDto>> getSchools() async {
    try {
      final response = await _dio.get(ApiConfig.schools);
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => SchoolDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error loading schools: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } on DioException {
      // Best-effort: even if the server call fails, clear the local session.
    } finally {
      await _tokenStorage.clear();
      final signedIn = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (signedIn != null) {
        await GoogleSignIn.instance.signOut();
      }
    }
  }

  Future<Response<dynamic>> _post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error calling $path: $e');
    }
  }

  Future<AuthTokenDto> _extractTokens(Response<dynamic> response) async {
    final tokens = AuthTokenDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  ApiException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      // Validation failures (class-validator) carry the useful, field-level
      // detail in `errors`; `message` is just a generic "Bad Request Exception".
      // Prefer the specific reason when it's there. See backend
      // `AllExceptionsFilter`.
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return ApiException(
          errors.join('\n'),
          statusCode: e.response?.statusCode,
        );
      }
      final message = data['message'];
      if (message is String) {
        return ApiException(message, statusCode: e.response?.statusCode);
      }
      if (message is List && message.isNotEmpty) {
        return ApiException(
          message.join('\n'),
          statusCode: e.response?.statusCode,
        );
      }
    }
    // No response reached the app at all (connection refused, CORS block,
    // timeout, DNS failure, ...) — surface Dio's own diagnosis rather than a
    // vague string, since this is a network-layer failure, not a backend one.
    return ApiException('${e.type.name}: ${e.message ?? e.error ?? e}');
  }
}
