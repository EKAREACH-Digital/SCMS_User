import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:smart_canteen_user_frontend/core/utils/logger.dart';

/// Persists the JWT access/refresh token pair between app launches.
///
/// Backed by the platform keychain/keystore (via flutter_secure_storage)
/// rather than SharedPreferences, since these tokens grant full API access.
///
/// Token values are logged through [AppLogger], which prints in debug builds
/// only — tokens never reach release logs.
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    AppLogger.d('[StorageService] saved access token: $accessToken');
  }

  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    AppLogger.d('[StorageService] access token: $token');
    return token;
  }

  Future<String?> readRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    AppLogger.d('[StorageService] refresh token: $token');
    return token;
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    AppLogger.d('[StorageService] tokens cleared');
  }
}
