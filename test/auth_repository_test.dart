import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/services/storage_service.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Session handling across the auth layers, using the dev mock datasource and
/// an in-memory secure storage.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepositoryImpl repo;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    repo = AuthRepositoryImpl(AuthMockDatasource(), StorageService.instance);
  });

  test('login stores the session and returns the mapped user', () async {
    expect(await repo.hasSession(), isFalse);

    final user = await repo.login(email: 'a@b.com', password: 'secret');

    expect(await repo.hasSession(), isTrue);
    expect(user.id, 'mock-user-001');
    expect(user.schoolName, 'CADT');
    expect(user.fullName, 'John Doe');
  });

  test(
    'register does not sign in; verifyEmail activates and signs in',
    () async {
      final userId = await repo.register(
        name: 'Jane Doe',
        email: 'jane@b.com',
        password: 'Pass1234',
      );

      expect(userId, isNotEmpty);
      expect(await repo.hasSession(), isFalse);

      final user = await repo.verifyEmail(
        userId: userId,
        email: 'jane@b.com',
        password: 'Pass1234',
        code: AuthMockDatasource.mockCode,
      );

      expect(await repo.hasSession(), isTrue);
      // A fresh sign-up still has to go through Complete Profile.
      expect(user.needsProfileCompletion, isTrue);
    },
  );

  test('verifyEmail with a wrong code throws and stays signed out', () async {
    final userId = await repo.register(
      name: 'Jane Doe',
      email: 'jane@b.com',
      password: 'Pass1234',
    );

    await expectLater(
      repo.verifyEmail(
        userId: userId,
        email: 'jane@b.com',
        password: 'Pass1234',
        code: '000000',
      ),
      throwsA(isA<ApiException>()),
    );
    expect(await repo.hasSession(), isFalse);
  });

  test(
    'completeProfile saves the branch and marks the profile complete',
    () async {
      final userId = await repo.register(
        name: 'Jane Doe',
        email: 'jane@b.com',
        password: 'Pass1234',
      );
      await repo.verifyEmail(
        userId: userId,
        email: 'jane@b.com',
        password: 'Pass1234',
        code: AuthMockDatasource.mockCode,
      );
      final schools = await repo.getSchools();
      final branches = await repo.getBranches(schools.first.id);

      final user = await repo.completeProfile(
        fullName: 'Jane Doe',
        phone: '+85512345678',
        schoolId: schools.first.id,
        homeBranchId: branches.first.id,
      );

      expect(user.needsProfileCompletion, isFalse);
      expect(user.homeBranchId, branches.first.id);
    },
  );

  test('logout clears the session', () async {
    await repo.login(email: 'a@b.com', password: 'secret');
    await repo.logout();
    expect(await repo.hasSession(), isFalse);
  });

  group('AuthViewModel', () {
    test('restoreSession without a token is unauthenticated', () async {
      final vm = AuthViewModel(repo);
      expect(vm.status, AuthStatus.unknown);

      await vm.restoreSession();

      expect(vm.status, AuthStatus.unauthenticated);
      expect(vm.user, isNull);
    });

    test('restoreSession with a stored token loads the user', () async {
      await repo.login(email: 'a@b.com', password: 'secret');
      final vm = AuthViewModel(repo);

      await vm.restoreSession();

      expect(vm.status, AuthStatus.authenticated);
      expect(vm.displayName, 'John Doe');
    });

    test('setPassword flips canUseEmailPassword on the shared user', () async {
      final vm = AuthViewModel(repo);
      await vm.login(email: 'a@b.com', password: 'secret');
      // The mock starts as a Google-only account.
      expect(vm.canUseEmailPassword, isFalse);

      expect(await vm.setPassword('NewPassw0rd!'), isNull);

      expect(vm.canUseEmailPassword, isTrue);
    });

    test('logout signs out and drops the user', () async {
      final vm = AuthViewModel(repo);
      await vm.login(email: 'a@b.com', password: 'secret');

      await vm.logout();

      expect(vm.status, AuthStatus.unauthenticated);
      expect(vm.user, isNull);
      expect(await repo.hasSession(), isFalse);
    });
  });
}
