import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_session_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/branch_dto.dart';

/// Raw auth API (see docs/features/student-auth-api.md). Speaks DTOs only;
/// storing the session and mapping to entities is the repository's job.
abstract class AuthDatasource {
  Future<AuthSessionDto> login({
    required String email,
    required String password,
    required bool rememberDevice,
  });

  /// Creates an inactive student and emails a code. No tokens.
  Future<UserProfileDto> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Activates the account. [password] must match the sign-up one: the
  /// backend stores it again.
  Future<void> verifyOtp({
    required String userId,
    required String code,
    required String password,
  });

  Future<void> resendOtp(String userId);

  Future<void> resendVerification(String email);

  Future<AuthSessionDto> loginWithGoogle();

  Future<AuthSessionDto> loginWithMicrosoft();

  Future<UserProfileDto> getProfile();

  Future<UserProfileDto> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  });

  Future<List<SchoolDto>> getSchools();

  Future<List<BranchDto>> getBranches(String schoolId);

  Future<AuthSessionDto> completeProfile({
    required String name,
    required String phone,
    required String schoolId,
    String? homeBranchId,
    String? password,
  });

  Future<void> setPassword(String password);

  Future<void> verifyAccountOtp(String otp);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> requestPasswordReset(String email);

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  /// Signs this device out when [refreshToken] is given (every device when
  /// null), and signs out of the native providers. Best effort.
  Future<void> logout(String? refreshToken);
}
