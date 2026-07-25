import '../../dtos/auth_dto.dart';
import '../../exceptions/api_exception.dart';
import 'auth_repository.dart';

class AuthRepositoryMock implements AuthRepository {
  @override
  Future<AuthTokenDto> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    return const AuthTokenDto(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiresIn: 3600,
    );
  }

  @override
  Future<AuthTokenDto> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return const AuthTokenDto(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiresIn: 3600,
    );
  }

  @override
  Future<AuthTokenDto> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return const AuthTokenDto(
      accessToken: 'mock-google-access-token',
      refreshToken: 'mock-refresh-token',
      expiresIn: 3600,
    );
  }

  @override
  Future<AuthTokenDto> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthTokenDto(
      accessToken: 'mock-access-token-refreshed',
      refreshToken: 'mock-refresh-token',
      expiresIn: 3600,
    );
  }

  // In-memory prefs so mock toggles persist for the life of the app session.
  NotificationPreferencesDto _prefs = const NotificationPreferencesDto(
    orderUpdates: true,
    promotions: false,
    systemAlerts: true,
  );

  @override
  Future<UserProfileDto> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserProfileDto(
      id: 'mock-user-001',
      email: 'john.doe@cadt.edu.kh',
      firstName: 'John',
      lastName: 'Doe',
      status: 'active',
      role: const RoleDto(id: 'mock-role-student', name: 'student'),
      school: const SchoolDto(id: 'mock-school-cadt', name: 'CADT'),
      notificationPreferences: _prefs,
      // Mock starts as a Google-only account so the "Set a password" flow is
      // reachable in the dev flavour.
      canUseEmailPassword: _hasPassword,
    );
  }

  static const _mockSchools = [
    SchoolDto(id: 'mock-school-cadt', name: 'CADT'),
    SchoolDto(id: 'mock-school-rupp', name: 'RUPP'),
    SchoolDto(id: 'mock-school-itc', name: 'ITC'),
  ];

  @override
  Future<UserProfileDto> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final school = _mockSchools.firstWhere(
      (s) => s.id == schoolId,
      orElse: () => _mockSchools.first,
    );
    return UserProfileDto(
      id: userId,
      email: 'john.doe@cadt.edu.kh',
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      status: 'active',
      role: const RoleDto(id: 'mock-role-student', name: 'student'),
      school: school,
      notificationPreferences: _prefs,
      canUseEmailPassword: _hasPassword,
    );
  }

  @override
  Future<NotificationPreferencesDto> updateNotificationPreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _prefs = NotificationPreferencesDto(
      orderUpdates: orderUpdates ?? _prefs.orderUpdates,
      promotions: promotions ?? _prefs.promotions,
      systemAlerts: systemAlerts ?? _prefs.systemAlerts,
    );
    return _prefs;
  }

  // Flips to true once a password is set, mirroring the backend flag.
  bool _hasPassword = false;

  @override
  Future<UserProfileDto> completeProfile({
    required String fullName,
    required String phone,
    required String schoolId,
    String? password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (password != null && password.isNotEmpty) _hasPassword = true;
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final school = _mockSchools.firstWhere(
      (s) => s.id == schoolId,
      orElse: () => _mockSchools.first,
    );
    return UserProfileDto(
      id: 'mock-user-001',
      email: 'john.doe@cadt.edu.kh',
      firstName: parts.isNotEmpty ? parts.first : null,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : null,
      phone: phone,
      status: 'active',
      role: const RoleDto(id: 'mock-role-student', name: 'student'),
      school: school,
      notificationPreferences: _prefs,
      canUseEmailPassword: _hasPassword,
    );
  }

  @override
  Future<void> setPassword(String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _hasPassword = true;
  }

  /// Accepted by the mock reset flow, mirroring the demo code the web client
  /// uses. The real backend emails a random 6-digit code instead.
  static const mockResetCode = '123456';

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (code != mockResetCode) {
      throw const ApiException('That code is invalid or has expired.');
    }
    return 'mock-reset-token';
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _hasPassword = true;
  }

  @override
  Future<List<SchoolDto>> getSchools() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSchools;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
