import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:msal_auth/msal_auth.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/config/google_auth_config.dart';
import 'package:smart_canteen_user_frontend/core/config/microsoft_auth_config.dart';
import 'package:smart_canteen_user_frontend/core/error/error_handler.dart';
import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_session_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/branch_dto.dart';

/// [AuthDatasource] backed by the NestJS API, plus the native Google and
/// Microsoft sign-in SDKs. Every response is wrapped as
/// `{ statusCode, message, data, timestamp }`; the helpers below return `data`.
class AuthRemoteDatasource implements AuthDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;
  Future<void>? _googleSignInInit;
  SingleAccountPca? _msalPca;

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
    required bool rememberDevice,
  }) async {
    // POST /auth/login — email sign-in; remember_device stretches the refresh
    // token from 7 to 30 days.
    return AuthSessionDto.fromJson(
      await _post(ApiConfig.login, {
        'email': email,
        'password': password,
        'remember_device': rememberDevice,
      }),
    );
  }

  @override
  Future<UserProfileDto> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    // POST /auth/register — creates the inactive student; the code is emailed.
    return UserProfileDto.fromJson(
      await _post(ApiConfig.register, {
        'name': name,
        'email': email,
        'password': password,
        'phone': ?phone,
        'role': 'student',
      }),
    );
  }

  @override
  Future<void> verifyOtp({
    required String userId,
    required String code,
    required String password,
  }) async {
    // POST /auth/verify-otp — activates the account (no tokens returned).
    await _post(ApiConfig.verifyOtp, {
      'userId': userId,
      'code': code,
      'password': password,
    });
  }

  @override
  Future<void> resendOtp(String userId) async {
    // POST /auth/resend-otp — new sign-up code by user id.
    await _post(ApiConfig.resendOtp, {'userId': userId});
  }

  @override
  Future<void> resendVerification(String email) async {
    // POST /auth/resend-verification — new sign-up code by email.
    await _post(ApiConfig.resendVerification, {'email': email});
  }

  @override
  Future<AuthSessionDto> loginWithGoogle() async {
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

    // POST /auth/google — exchanges the Google ID token for our session; the
    // first sign-in creates the student account.
    return AuthSessionDto.fromJson(
      await _post(ApiConfig.googleLogin, {'id_token': idToken}),
    );
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
  Future<AuthSessionDto> loginWithMicrosoft() async {
    final pca = await _ensureMsal();

    final AuthenticationResult result;
    try {
      result = await pca.acquireToken(scopes: MicrosoftAuthConfig.scopes);
    } on MsalUserCancelException {
      throw const ApiException('Microsoft sign-in was cancelled');
    } on MsalException catch (e) {
      throw ApiException('Microsoft sign-in failed: ${e.message}');
    }

    final idToken = result.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ApiException(
        'Microsoft returned no ID token. Check the Azure app registration '
        '(redirect URI, tenant, and that openid/profile/email scopes are granted).',
      );
    }

    return AuthSessionDto.fromJson(
      await _post(ApiConfig.microsoftLogin, {'id_token': idToken}),
    );
  }

  Future<SingleAccountPca> _ensureMsal() async {
    return _msalPca ??= await SingleAccountPca.create(
      clientId: MicrosoftAuthConfig.clientId,
      androidConfig: AndroidConfig(
        configFilePath: 'assets/msal_config.json',
        redirectUri: MicrosoftAuthConfig.androidRedirectUri,
      ),
      appleConfig: AppleConfig(authority: MicrosoftAuthConfig.authority),
    );
  }

  @override
  Future<UserProfileDto> getProfile() async {
    // GET /users/me — the signed-in user, used to restore a session at launch.
    return UserProfileDto.fromJson(await _get(ApiConfig.profile));
  }

  @override
  Future<UserProfileDto> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  }) async {
    // PATCH /users/:id/profile — edit profile from Settings.
    return UserProfileDto.fromJson(
      await _send(
        () => _dio.patch(
          ApiConfig.userProfile(userId),
          data: {
            'first_name': ?firstName,
            'last_name': ?lastName,
            'phone': ?phone,
            'school_id': ?schoolId,
          },
        ),
      ),
    );
  }

  @override
  Future<List<SchoolDto>> getSchools() async {
    // GET /schools — public list for the onboarding school dropdown.
    final list = await _get(ApiConfig.schools) as List<dynamic>;
    return list
        .map((e) => SchoolDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BranchDto>> getBranches(String schoolId) async {
    // GET /pickup/branches — the school's branches for the onboarding branch
    // dropdown.
    final list =
        await _get(ApiConfig.pickupBranches, query: {'school_id': schoolId})
            as List<dynamic>;
    return list
        .map((e) => BranchDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AuthSessionDto> completeProfile({
    required String name,
    required String phone,
    required String schoolId,
    String? homeBranchId,
    String? password,
  }) async {
    // POST /auth/complete-profile — onboarding; returns new tokens because the
    // JWT now carries the school.
    return AuthSessionDto.fromJson(
      await _post(ApiConfig.completeProfile, {
        'name': name,
        'phone': phone,
        'school_id': schoolId,
        'home_branch_id': ?homeBranchId,
        'password': ?password,
      }),
    );
  }

  @override
  Future<void> setPassword(String password) async {
    // POST /auth/set-password — lets a Google account sign in by email too.
    await _post(ApiConfig.setPassword, {'password': password});
  }

  @override
  Future<void> verifyAccountOtp(String otp) async {
    // POST /auth/otp/verify — temporary-password accounts confirm the code.
    await _post(ApiConfig.accountOtpVerify, {'otp': otp});
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // POST /auth/password/change — temporary-password accounts pick a new one,
    // and signed-in users change theirs from Settings.
    await _post(ApiConfig.changePassword, {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    // POST /auth/forgot-password — emails a reset code (same reply either way).
    await _post(ApiConfig.forgotPassword, {'email': email});
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    // POST /auth/forgot-password/verify-otp — checks the reset code.
    await _post(ApiConfig.verifyResetCode, {'email': email, 'otp': code});
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // POST /auth/forgot-password/reset — sets the new password.
    await _post(ApiConfig.resetPassword, {
      'email': email,
      'new_password': newPassword,
    });
  }

  @override
  Future<void> logout(String? refreshToken) async {
    try {
      // POST /auth/logout — with the refresh token signs out this device only.
      await _dio.post(
        ApiConfig.logout,
        data: refreshToken == null ? null : {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      // Best-effort: the local session is cleared regardless.
      AppLogger.w('Server logout failed: ${e.message}');
    }
    final signedIn = await GoogleSignIn.instance
        .attemptLightweightAuthentication();
    if (signedIn != null) {
      await GoogleSignIn.instance.signOut();
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) =>
      _send(() => _dio.post(path, data: data));

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  /// Runs [request], unwraps the envelope's `data`, and turns every failure
  /// into an [ApiException] so no `DioException` leaves the data layer.
  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return (response.data as Map<String, dynamic>)['data'];
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected response from the server: $e');
    }
  }
}
