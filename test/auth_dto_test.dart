import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/auth_session_dto.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/models/branch_dto.dart';

/// The backend returns the signed-in user in two different shapes, and both
/// have to parse. `GET /users/me` serves the raw entity (school is the joined
/// relation object), while auth responses run through `serializeUser`, which
/// flattens school to just its name string and keeps the id in `school_id`.
/// Parsing the flattened shape used to throw a cast error during onboarding.
void main() {
  group('UserProfileDto.fromJson', () {
    test('parses the /users/me shape (school as a nested object)', () {
      final dto = UserProfileDto.fromJson({
        'id': 'user-1',
        'email': 'a@b.com',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'status': 'active',
        'school_id': 'school-1',
        'role': {'id': 'role-1', 'name': 'student'},
        'school': {'id': 'school-1', 'name': 'CADT'},
        'notify_order_updates': true,
        'notify_promotions': false,
        'notify_system_alerts': true,
      });

      expect(dto.school?.id, 'school-1');
      expect(dto.school?.name, 'CADT');
      expect(dto.role?.name, 'student');
      // Absent on the raw entity — assume a password exists.
      expect(dto.canUseEmailPassword, isTrue);
    });

    test(
      'parses the auth-response shape (school flattened to a name string)',
      () {
        final dto = UserProfileDto.fromJson({
          'id': 'user-1',
          'email': 'a@b.com',
          'first_name': 'Ada',
          'last_name': 'Lovelace',
          'status': 'active',
          'school_id': 'school-1',
          'role': {'id': 'role-1', 'name': 'student'},
          'school': 'Cambodia Academy of Digital Technology',
          'can_use_email_password': false,
          'notify_order_updates': true,
          'notify_promotions': false,
          'notify_system_alerts': true,
        });

        // The id has to come from school_id, since school carries only the name.
        expect(dto.school?.id, 'school-1');
        expect(dto.school?.name, 'Cambodia Academy of Digital Technology');
        expect(dto.role?.name, 'student');
        // A Google-only account: no password yet.
        expect(dto.canUseEmailPassword, isFalse);
      },
    );

    test('tolerates a missing school', () {
      final dto = UserProfileDto.fromJson({
        'id': 'user-1',
        'email': 'a@b.com',
        'status': 'active',
        'school': null,
        'role': null,
      });

      expect(dto.school, isNull);
      expect(dto.role, isNull);
    });
  });

  group('profile_completed', () {
    test('drives needsProfileCompletion when present', () {
      final user = UserProfileDto.fromJson({
        'id': 'user-1',
        'email': 'a@b.com',
        'phone': '+855',
        'school_id': 'school-1',
        'school': 'CADT',
        'profile_completed': false,
        'home_branch_id': null,
      }).toEntity();

      // Phone and school are set, but the backend flag wins.
      expect(user.needsProfileCompletion, isTrue);
      expect(user.homeBranchId, isNull);
    });

    test('falls back to phone + school when absent', () {
      final user = UserProfileDto.fromJson({
        'id': 'user-1',
        'email': 'a@b.com',
        'phone': '+855',
        'school': {'id': 'school-1', 'name': 'CADT'},
        'home_branch_id': 'branch-1',
      }).toEntity();

      expect(user.needsProfileCompletion, isFalse);
      expect(user.homeBranchId, 'branch-1');
    });
  });

  test('AuthSessionDto parses the login response', () {
    final session = AuthSessionDto.fromJson({
      'access_token': 'a',
      'refresh_token': 'r',
      'expires_in': 900,
      'user': {
        'id': 'user-1',
        'email': 'a@b.com',
        'status': 'active',
        'profile_completed': false,
        'school_id': null,
        'school': null,
        'can_use_email_password': true,
      },
      'mustChangePassword': true,
    });

    expect(session.accessToken, 'a');
    expect(session.refreshToken, 'r');
    final user = session.toEntity();
    expect(user.mustChangePassword, isTrue);
    expect(user.needsProfileCompletion, isTrue);
  });

  test('BranchDto parses a pickup branch', () {
    final branch = BranchDto.fromJson({
      'id': 'b-1',
      'name': 'Branch C',
      'school_id': 's-1',
      'is_home': true,
    }).toEntity();

    expect(branch.id, 'b-1');
    expect(branch.schoolId, 's-1');
    expect(branch.isHome, isTrue);
  });
}
