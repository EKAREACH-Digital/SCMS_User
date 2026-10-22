import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen_user_frontend/core/config/app_config.dart';

/// `.env.example` documents every key [AppConfig] reads, so a fresh clone can
/// build its `.env` from it.
void main() {
  test('.env.example lists every key AppConfig reads', () {
    final source = File('lib/core/config/app_config.dart').readAsStringSync();
    final keys = RegExp(r"_require\('([A-Z_]+)'\)")
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toSet();
    final example = File('.env.example').readAsStringSync();

    expect(keys, isNotEmpty);
    for (final key in keys) {
      expect(example, contains('$key='), reason: '$key missing');
    }
  });

  test('a missing key fails loudly instead of returning blank', () {
    dotenv.loadFromString(envString: 'API_BASE_URL=http://localhost:3000');
    expect(AppConfig.apiBaseUrl, 'http://localhost:3000');
    expect(() => AppConfig.microsoftClientId, throwsStateError);
  });
}
