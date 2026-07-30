import 'package:flutter/foundation.dart';

import '../../../../data/exceptions/api_exception.dart';
import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../model/user/user.dart';
import '../../../utils/async_value.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AsyncValue<User> _loginState = const AsyncLoading();
  AsyncValue<User> _registerState = const AsyncLoading();

  AuthViewModel(this._authRepository);

  AsyncValue<User> get loginState => _loginState;
  AsyncValue<User> get registerState => _registerState;

  Future<void> login({required String email, required String password}) async {
    _loginState = const AsyncLoading();
    notifyListeners();

    try {
      await _authRepository.login(email: email, password: password);
      final profileDto = await _authRepository.getProfile();
      _loginState = AsyncData(User.fromDto(profileDto));
    } catch (e, s) {
      _loginState = AsyncError(e, s);
    }

    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _registerState = const AsyncLoading();
    notifyListeners();

    try {
      await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      final profileDto = await _authRepository.getProfile();
      _registerState = AsyncData(User.fromDto(profileDto));
    } catch (e, s) {
      _registerState = AsyncError(e, s);
    }

    notifyListeners();
  }

  /// Signs in with Google. Uses the same [loginState] as [login] since,
  /// from the UI's perspective, it's just another way to end up logged in.
  Future<void> loginWithGoogle() async {
    _loginState = const AsyncLoading();
    notifyListeners();

    try {
      await _authRepository.loginWithGoogle();
      final profileDto = await _authRepository.getProfile();
      _loginState = AsyncData(User.fromDto(profileDto));
    } catch (e, s) {
      _loginState = AsyncError(e, s);
    }

    notifyListeners();
  }

  /// Runs the native Microsoft (MSAL) flow and exchanges the resulting ID
  /// token for our own session, then loads the profile so the caller can route
  /// on `profile_completed` exactly as it does after Google sign-in.
  Future<void> loginWithMicrosoft() async {
    _loginState = const AsyncLoading();
    notifyListeners();

    try {
      await _authRepository.loginWithMicrosoft();
      final profileDto = await _authRepository.getProfile();
      _loginState = AsyncData(User.fromDto(profileDto));
    } catch (e, s) {
      _loginState = AsyncError(e, s);
    }

    notifyListeners();
  }

  /// Saves the onboarding details (name, phone, school) via
  /// `POST /auth/complete-profile`, which also marks the account
  /// `profile_completed` and returns a fresh token pair. An optional
  /// [password] additionally enables email/password sign-in — useful for
  /// accounts created with Google, which have no password.
  /// Returns true on success.
  Future<bool> completeProfile({
    required String fullName,
    required String phone,
    required String schoolId,
    String? password,
  }) async {
    try {
      final dto = await _authRepository.completeProfile(
        fullName: fullName.trim(),
        phone: phone.trim(),
        schoolId: schoolId,
        password: password,
      );
      _loginState = AsyncData(User.fromDto(dto));
      notifyListeners();
      return true;
    } catch (e, s) {
      _loginState = AsyncError(e, s);
      notifyListeners();
      return false;
    }
  }

  /// Adds a password to a Google-only account so email/password sign-in works
  /// too. Returns null on success, or an error message to show.
  Future<String?> setPassword(String password) async {
    try {
      await _authRepository.setPassword(password);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not set your password. Please try again.';
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _loginState = const AsyncLoading();
    _registerState = const AsyncLoading();
    notifyListeners();
  }

  void resetStates() {
    _loginState = const AsyncLoading();
    _registerState = const AsyncLoading();
    notifyListeners();
  }
}
