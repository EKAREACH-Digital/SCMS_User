import 'package:smart_canteen_user_frontend/core/services/storage_service.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_session_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/branch.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/school.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/user.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource, this._storage);

  final AuthDatasource _datasource;
  final StorageService _storage;

  @override
  Future<User> login({
    required String email,
    required String password,
    bool rememberDevice = true,
  }) => _signIn(
    _datasource.login(
      email: email,
      password: password,
      rememberDevice: rememberDevice,
    ),
  );

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final dto = await _datasource.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    return dto.id;
  }

  @override
  Future<User> verifyEmail({
    required String userId,
    required String email,
    required String password,
    required String code,
  }) async {
    // Verifying returns no tokens, so sign in right after.
    await _datasource.verifyOtp(userId: userId, code: code, password: password);
    return login(email: email, password: password);
  }

  @override
  Future<void> resendOtp(String userId) => _datasource.resendOtp(userId);

  @override
  Future<void> resendVerification(String email) =>
      _datasource.resendVerification(email);

  @override
  Future<User> loginWithGoogle() => _signIn(_datasource.loginWithGoogle());

  @override
  Future<User> loginWithMicrosoft() =>
      _signIn(_datasource.loginWithMicrosoft());

  /// Stores (or replaces) the session from [session] and returns its user.
  Future<User> _signIn(Future<AuthSessionDto> session) async {
    final s = await session;
    await _storage.saveTokens(
      accessToken: s.accessToken,
      refreshToken: s.refreshToken,
    );
    return s.toEntity();
  }

  @override
  Future<bool> hasSession() async => (await _storage.readAccessToken()) != null;

  @override
  Future<User> getProfile() async =>
      (await _datasource.getProfile()).toEntity();

  @override
  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  }) async {
    final dto = await _datasource.updateProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      schoolId: schoolId,
    );
    return dto.toEntity();
  }

  @override
  Future<List<School>> getSchools() async =>
      (await _datasource.getSchools()).map((s) => s.toEntity()).toList();

  @override
  Future<List<Branch>> getBranches(String schoolId) async =>
      (await _datasource.getBranches(
        schoolId,
      )).map((b) => b.toEntity()).toList();

  @override
  Future<User> completeProfile({
    required String fullName,
    required String phone,
    required String schoolId,
    String? homeBranchId,
    String? password,
  }) {
    // The new JWT carries the school, so the stored session is replaced.
    return _signIn(
      _datasource.completeProfile(
        name: fullName,
        phone: phone,
        schoolId: schoolId,
        homeBranchId: homeBranchId,
        password: password,
      ),
    );
  }

  @override
  Future<void> setPassword(String password) =>
      _datasource.setPassword(password);

  @override
  Future<void> verifyAccountOtp(String otp) =>
      _datasource.verifyAccountOtp(otp);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _datasource.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> requestPasswordReset(String email) =>
      _datasource.requestPasswordReset(email);

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) => _datasource.verifyPasswordResetCode(email: email, code: code);

  @override
  Future<void> resetPassword({
    required String email,
    required String password,
  }) => _datasource.resetPassword(email: email, newPassword: password);

  @override
  Future<void> logout() async {
    try {
      // Sending the refresh token signs out this device only.
      await _datasource.logout(await _storage.readRefreshToken());
    } finally {
      await _storage.clear();
    }
  }
}
