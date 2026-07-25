import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen_user_frontend/data/dtos/auth_dto.dart';

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

    test('parses the auth-response shape (school flattened to a name string)',
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
    });

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

    test('reads notification preferences with backend defaults', () {
      final dto = UserProfileDto.fromJson({
        'id': 'user-1',
        'email': 'a@b.com',
        'status': 'active',
      });

      expect(dto.notificationPreferences.orderUpdates, isTrue);
      expect(dto.notificationPreferences.promotions, isFalse);
      expect(dto.notificationPreferences.systemAlerts, isTrue);
    });
  });
}
