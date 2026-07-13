import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcheck_ai/core/services/secure_local_storage.dart';

void main() {
  const storage = SecureLocalStorage(
    persistSessionKey: 'test_session_key',
    legacySharedPreferencesKey: 'sb-example-auth-token',
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  test('reports no token before anything is persisted', () async {
    expect(await storage.hasAccessToken(), isFalse);
    expect(await storage.accessToken(), isNull);
  });

  test('persists, reads back, and removes a session', () async {
    await storage.persistSession('{"access_token":"abc"}');

    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), '{"access_token":"abc"}');

    await storage.removePersistedSession();

    expect(await storage.hasAccessToken(), isFalse);
    expect(await storage.accessToken(), isNull);
  });

  group('migration from legacy SharedPreferences storage', () {
    test(
      'migrates an existing session on initialize() and removes the legacy copy',
      () async {
        SharedPreferences.setMockInitialValues({
          'sb-example-auth-token': '{"access_token":"legacy-token"}',
        });

        await storage.initialize();

        expect(await storage.accessToken(), '{"access_token":"legacy-token"}');
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('sb-example-auth-token'), isNull);
      },
    );

    test('does nothing when there is no legacy session to migrate', () async {
      await storage.initialize();

      expect(await storage.hasAccessToken(), isFalse);
    });

    test(
      'does not overwrite an already-migrated session on repeated initialize() calls',
      () async {
        SharedPreferences.setMockInitialValues({
          'sb-example-auth-token': '{"access_token":"legacy-token"}',
        });

        await storage.initialize();
        // Simulate a newer session having since been persisted normally.
        await storage.persistSession('{"access_token":"fresher-token"}');
        await storage.initialize();

        expect(await storage.accessToken(), '{"access_token":"fresher-token"}');
      },
    );
  });
}
