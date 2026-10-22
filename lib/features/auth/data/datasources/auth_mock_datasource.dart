import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_session_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/branch_dto.dart';

/// In-memory [AuthDatasource] for tests and offline work — no backend needed.
///
/// Every emailed code (sign-up, reset, temporary password) is [mockCode].
class AuthMockDatasource implements AuthDatasource {
  /// Accepted by every mock code check. The real backend emails a random
  /// 6-digit code instead.
  static const mockCode = '123456';

  static const _userId = 'mock-user-001';
  static const _email = 'john.doe@cadt.edu.kh';
  static const _role = RoleDto(id: 'mock-role-student', name: 'student');

  static const _mockSchools = [
    SchoolDto(id: 'mock-school-cadt', name: 'CADT'),
    SchoolDto(id: 'mock-school-rupp', name: 'RUPP'),
    SchoolDto(id: 'mock-school-itc', name: 'ITC'),
  ];

  // In-memory account state so mock changes persist for the app session.
  // The account starts complete (phone + school) so sign-in goes straight
  // home, and Google-only (no password) so "Set a password" is reachable.
  String? _firstName = 'firstname';
  String? _lastName = 'lastname';
  String? _phone = '+85512345678';
  SchoolDto? _school = _mockSchools.first;
  String? _homeBranchId = 'mock-branch-cadt-main';
  bool _profileCompleted = true;
  bool _hasPassword = false;
  UserProfileDto get _user => UserProfileDto(
    id: _userId,
    email: _email,
    firstName: _firstName,
    lastName: _lastName,
    phone: _phone,
    status: 'active',
    role: _role,
    school: _school,
    homeBranchId: _homeBranchId,
    profileCompleted: _profileCompleted,
    canUseEmailPassword: _hasPassword,
  );

  AuthSessionDto get _session => AuthSessionDto(
    accessToken: 'mock-access-token',
    refreshToken: 'mock-refresh-token',
    expiresIn: 900,
    user: _user,
  );

  static Future<void> _delay([int ms = 500]) =>
      Future.delayed(Duration(milliseconds: ms));

  static void _checkCode(String code) {
    if (code != mockCode) {
      throw const ApiException(
        'That code is invalid or has expired.',
        statusCode: 400,
      );
    }
  }

  void _setName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    _firstName = parts.isNotEmpty ? parts.first : null;
    _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
  }

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
    required bool rememberDevice,
  }) async {
    await _delay(1000);
    return _session;
  }

  @override
  Future<UserProfileDto> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    await _delay(1000);
    // A fresh sign-up still has to verify and complete onboarding.
    _setName(name);
    _phone = phone;
    _school = null;
    _homeBranchId = null;
    _profileCompleted = false;
    _hasPassword = true;
    return UserProfileDto(
      id: _userId,
      email: email,
      firstName: _firstName,
      lastName: _lastName,
      phone: phone,
      status: 'inactive',
      role: _role,
      profileCompleted: false,
    );
  }

  @override
  Future<void> verifyOtp({
    required String userId,
    required String code,
    required String password,
  }) async {
    await _delay();
    _checkCode(code);
  }

  @override
  Future<void> resendOtp(String userId) => _delay(400);

  @override
  Future<void> resendVerification(String email) => _delay(400);

  @override
  Future<AuthSessionDto> loginWithGoogle() async {
    await _delay(1000);
    return _session;
  }

  @override
  Future<AuthSessionDto> loginWithMicrosoft() async {
    await _delay(1000);
    return _session;
  }

  @override
  Future<UserProfileDto> getProfile() async {
    await _delay();
    return _user;
  }

  @override
  Future<UserProfileDto> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  }) async {
    await _delay();
    _firstName = firstName ?? _firstName;
    _lastName = lastName ?? _lastName;
    _phone = phone ?? _phone;
    if (schoolId != null) _school = _schoolById(schoolId);
    return _user;
  }

  @override
  Future<List<SchoolDto>> getSchools() async {
    await _delay(300);
    return _mockSchools;
  }

  @override
  Future<List<BranchDto>> getBranches(String schoolId) async {
    await _delay(300);
    final school = _schoolById(schoolId);
    final mainId = 'mock-branch-${school.name.toLowerCase()}-main';
    final annexId = 'mock-branch-${school.name.toLowerCase()}-annex';
    return [
      BranchDto(
        id: mainId,
        name: '${school.name} Main Canteen',
        schoolId: school.id,
        isHome: _homeBranchId == mainId,
      ),
      BranchDto(
        id: annexId,
        name: '${school.name} Annex',
        schoolId: school.id,
        isHome: _homeBranchId == annexId,
      ),
    ];
  }

  SchoolDto _schoolById(String id) => _mockSchools.firstWhere(
    (s) => s.id == id,
    orElse: () => _mockSchools.first,
  );

  @override
  Future<AuthSessionDto> completeProfile({
    required String name,
    required String phone,
    required String schoolId,
    String? homeBranchId,
    String? password,
  }) async {
    await _delay();
    if (password != null && password.isNotEmpty) _hasPassword = true;
    _setName(name);
    _phone = phone;
    _school = _schoolById(schoolId);
    _homeBranchId = homeBranchId;
    _profileCompleted = true;
    return _session;
  }

  @override
  Future<void> setPassword(String password) async {
    await _delay(400);
    _hasPassword = true;
  }

  @override
  Future<void> verifyAccountOtp(String otp) async {
    await _delay();
    _checkCode(otp);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _delay();
    _hasPassword = true;
  }

  @override
  Future<void> requestPasswordReset(String email) => _delay(600);

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await _delay();
    _checkCode(code);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _delay();
    _hasPassword = true;
  }

  @override
  Future<void> logout(String? refreshToken) => _delay(300);
}
