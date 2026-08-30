import 'dart:async';

// Two silent failures in SettingsController, both of which told the user
// something had happened when it had not.
//
// changePassword — the method took `currentPassword` and never read it. The
// backend `/users/change-password` endpoint (which verified it) was deleted, and
// Supabase's `updateUser` needs only a valid session, so a WRONG current
// password succeeded while the dialog still required the field. Anyone with an
// unlocked device or a stolen session could take the account over without
// knowing the old password.
//
// exportData — the success snackbar fired unconditionally, outside the
// `canLaunchUrl` branch. When nothing opened (no default browser handler on
// Android, iOS declining an unqueryable scheme) the short-lived presigned URL
// was discarded and the user was told their GDPR export was "ready to
// download", with no way left to get it.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, User;

import 'package:fitcheck_ai/core/services/theme_service.dart';
import 'package:fitcheck_ai/features/auth/controllers/auth_controller.dart';
import 'package:fitcheck_ai/features/settings/controllers/settings_controller.dart';
import 'package:fitcheck_ai/features/settings/models/user_preferences_model.dart';
import 'package:fitcheck_ai/features/settings/repositories/settings_repository.dart';

class _FakeAuthController extends GetxController implements AuthController {
  _FakeAuthController({this.wrongPassword = false, this.provider});

  /// Google/Apple sessions carry an email; kept non-null like a real session.
  final String? email = 'user@example.com';

  /// Auth provider from the session's app metadata ('email', 'google', ...).
  /// Null simulates an unknown/no session.
  final String? provider;

  /// When true, `reauthenticate` throws the way Supabase does for a bad password.
  final bool wrongPassword;

  final List<String> reauthCalls = [];
  final List<String> updateCalls = [];

  @override
  User? get currentUser {
    final p = provider;
    if (p == null) return null;
    return User(
      id: 'user-1',
      appMetadata: <String, dynamic>{'provider': p},
      userMetadata: <String, dynamic>{},
      aud: 'authenticated',
      email: email,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  String? get currentUserEmail => email;

  @override
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    reauthCalls.add(password);
    if (wrongPassword) {
      throw const AuthException('Invalid login credentials');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    updateCalls.add(newPassword);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettingsRepository implements SettingsRepository {
  static const exportUrl = 'https://example.com/export.json';

  int exportCalls = 0;
  final List<UserPreferencesModel> preferenceWrites = [];
  Future<UserPreferencesModel> Function()? onGetPreferences;
  Future<UserPreferencesModel> Function(UserPreferencesModel preferences)?
  onUpdatePreferences;

  @override
  Future<UserPreferencesModel> getPreferences() {
    final handler = onGetPreferences;
    return handler == null ? Future.value(UserPreferencesModel()) : handler();
  }

  @override
  Future<UserPreferencesModel> updatePreferences(
    UserPreferencesModel preferences,
  ) async {
    preferenceWrites.add(preferences);
    final handler = onUpdatePreferences;
    return handler == null ? preferences : handler(preferences);
  }

  @override
  Future<String> requestDataExport() async {
    exportCalls += 1;
    return exportUrl;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeThemeService extends ThemeService {
  _FakeThemeService(this._mode);

  AppThemeMode _mode;

  @override
  AppThemeMode get appThemeMode => _mode;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    _mode = mode;
  }

  @override
  void syncFromBackend(AppThemeMode? backendMode) {
    if (backendMode != null) _mode = backendMode;
  }
}

/// Captures the url_launcher platform calls so a launch can be made to fail.
class _LauncherStub {
  _LauncherStub({required this.canLaunch, this.launchSucceeds = true});

  final bool canLaunch;
  final bool launchSucceeds;
  final List<String> launched = [];

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          (call) async {
            switch (call.method) {
              case 'canLaunch':
                return canLaunch;
              case 'launch':
                launched.add(call.arguments['url']?.toString() ?? '');
                return launchSucceeds;
            }
            return null;
          },
        );
  }

  void remove() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          null,
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clipboardWrites = <String>[];

  setUp(() {
    Get.reset();
    Get.put<ThemeService>(ThemeService());
    clipboardWrites.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardWrites.add(
              (call.arguments as Map)['text']?.toString() ?? '',
            );
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    Get.reset();
  });

  group('changePassword re-authenticates', () {
    testWidgets('verifies the current password before updating', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final auth = _FakeAuthController();
      final controller = SettingsController(
        repository: _FakeSettingsRepository(),
        authController: auth,
      );

      await controller.changePassword('current-pw', 'NewPassw0rd');
      // Assert the snackbar before settling: pumpAndSettle drains the
      // snackbar's dismiss timer, so the feedback would be gone by then.
      await tester.pump();

      expect(auth.reauthCalls, ['current-pw']);
      expect(auth.updateCalls, ['NewPassw0rd']);
      // The reworked flow used to close the dialog with no confirmation at
      // all; the success feedback must surface.
      expect(Get.isSnackbarOpen, isTrue);
      expect(find.text('Password updated successfully'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('does NOT update when the current password is wrong', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final auth = _FakeAuthController(wrongPassword: true);
      final controller = SettingsController(
        repository: _FakeSettingsRepository(),
        authController: auth,
      );

      await controller.changePassword('wrong-pw', 'NewPassw0rd');
      await tester.pumpAndSettle();

      expect(auth.reauthCalls, ['wrong-pw']);
      expect(
        auth.updateCalls,
        isEmpty,
        reason: 'a wrong current password must not change it',
      );
      expect(controller.isChangingPassword.value, isFalse);
    });

    testWidgets('does NOT reauthenticate an OAuth-only (Google) account', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      // Google/Apple sessions DO carry an email, so the guard must key on the
      // auth provider, not the email field.
      final auth = _FakeAuthController(provider: 'google');
      final controller = SettingsController(
        repository: _FakeSettingsRepository(),
        authController: auth,
      );

      await controller.changePassword('anything', 'NewPassw0rd');
      // Assert the snackbar before settling: pumpAndSettle drains the
      // snackbar's dismiss timer, so the feedback would be gone by then.
      await tester.pump();

      expect(
        auth.reauthCalls,
        isEmpty,
        reason: 'an OAuth account has no password to verify',
      );
      expect(auth.updateCalls, isEmpty);
      // The intended guidance surfaces instead of the misleading
      // "Current password is incorrect" from a doomed reauth attempt.
      expect(Get.isSnackbarOpen, isTrue);
      expect(
        find.textContaining('This account signs in with Google or Apple'),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
    });
  });

  group('exportData reports honestly', () {
    testWidgets('opens the link and says so', (tester) async {
      final launcher = _LauncherStub(canLaunch: true)..install();
      addTearDown(launcher.remove);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final repository = _FakeSettingsRepository();
      final controller = SettingsController(
        repository: repository,
        authController: _FakeAuthController(),
      );

      await controller.exportData();
      await tester.pumpAndSettle();

      expect(repository.exportCalls, 1);
      expect(launcher.launched, ['https://example.com/export.json']);
      expect(clipboardWrites, isEmpty);
    });

    testWidgets('copies the link when the browser cannot be opened', (
      tester,
    ) async {
      final launcher = _LauncherStub(canLaunch: false)..install();
      addTearDown(launcher.remove);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final controller = SettingsController(
        repository: _FakeSettingsRepository(),
        authController: _FakeAuthController(),
      );

      await controller.exportData();
      await tester.pumpAndSettle();

      expect(launcher.launched, isEmpty);
      // The URL is short-lived and surfaced nowhere else, so it must not be lost.
      expect(clipboardWrites, ['https://example.com/export.json']);
      expect(controller.isExportingData.value, isFalse);
    });

    testWidgets('copies the link when launch is attempted but fails', (
      tester,
    ) async {
      final launcher = _LauncherStub(canLaunch: true, launchSucceeds: false)
        ..install();
      addTearDown(launcher.remove);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final controller = SettingsController(
        repository: _FakeSettingsRepository(),
        authController: _FakeAuthController(),
      );

      await controller.exportData();
      await tester.pumpAndSettle();

      expect(clipboardWrites, ['https://example.com/export.json']);
    });
  });

  group('preference saves preserve pending mutations', () {
    testWidgets('keeps the latest overlapping preference fetch', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final first = Completer<UserPreferencesModel>();
      final second = Completer<UserPreferencesModel>();
      var fetches = 0;
      final repository = _FakeSettingsRepository()
        ..onGetPreferences = () {
          fetches++;
          return fetches == 1 ? first.future : second.future;
        };
      final controller = SettingsController(
        repository: repository,
        authController: _FakeAuthController(),
        themeService: _FakeThemeService(AppThemeMode.system),
      );

      final oldFetch = controller.fetchPreferences();
      await tester.pump();
      final newestFetch = controller.fetchPreferences();
      await tester.pump();

      first.complete(UserPreferencesModel(themeMode: AppThemeMode.light));
      await oldFetch;
      await tester.pump();

      expect(controller.isLoading.value, isTrue);
      expect(controller.preferences.value, isNull);

      second.complete(UserPreferencesModel(themeMode: AppThemeMode.dark));
      await newestFetch;
      await tester.pump();

      expect(controller.preferences.value?.themeMode, AppThemeMode.dark);
      expect(controller.isLoading.value, isFalse);
      controller.onClose();
    });

    testWidgets('rolls back a rejected latest non-theme preference', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );
      final repository = _FakeSettingsRepository()
        ..onUpdatePreferences = (_) async => throw StateError('write rejected');
      final controller = SettingsController(
        repository: repository,
        authController: _FakeAuthController(),
      );
      controller.preferences.value = UserPreferencesModel(
        notificationsEnabled: true,
      );

      await controller.toggleNotifications(false);

      expect(controller.preferences.value?.notificationsEnabled, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'reverts a failed latest theme change to the last confirmed mode',
      (tester) async {
        await tester.pumpWidget(
          const GetMaterialApp(home: Scaffold(body: SizedBox())),
        );
        final firstWrite = Completer<UserPreferencesModel>();
        final secondWrite = Completer<UserPreferencesModel>();
        var writes = 0;
        final repository = _FakeSettingsRepository()
          ..onUpdatePreferences = (_) {
            writes++;
            return writes == 1 ? firstWrite.future : secondWrite.future;
          };
        final themeService = _FakeThemeService(AppThemeMode.system);
        final controller = SettingsController(
          repository: repository,
          authController: _FakeAuthController(),
          themeService: themeService,
        );
        final initial = UserPreferencesModel(themeMode: AppThemeMode.system);
        controller.preferences.value = initial;

        final chooseLight = controller.updateThemeMode(AppThemeMode.light);
        // Let the first backend write enter its pending state before the next
        // user choice arrives. This preserves the overlapping-write scenario
        // without racing the test's completer setup.
        await tester.pump();
        final chooseDark = controller.updateThemeMode(AppThemeMode.dark);
        expect(themeService.appThemeMode, AppThemeMode.dark);

        firstWrite.complete(initial.copyWith(themeMode: AppThemeMode.light));
        await tester.pump();
        await chooseLight;
        await tester.pump();
        expect(repository.preferenceWrites, hasLength(2));

        secondWrite.completeError(StateError('write rejected'));
        await tester.pump();
        await chooseDark;

        expect(controller.preferences.value?.themeMode, AppThemeMode.light);
        expect(themeService.appThemeMode, AppThemeMode.light);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'serializes rapid style selections with the latest local state',
      (tester) async {
        await tester.pumpWidget(
          const GetMaterialApp(home: Scaffold(body: SizedBox())),
        );
        final repository = _FakeSettingsRepository();
        final controller = SettingsController(
          repository: repository,
          authController: _FakeAuthController(),
        );
        controller.preferences.value = UserPreferencesModel(
          preferredStyles: const [],
        );

        await Future.wait([
          controller.addPreferredStyle('casual'),
          controller.addPreferredStyle('formal'),
        ]);

        expect(
          repository.preferenceWrites
              .map((preferences) => preferences.preferredStyles)
              .toList(),
          const [
            ['casual'],
            ['casual', 'formal'],
          ],
        );
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'serializes rapid color selections with the latest local state',
      (tester) async {
        await tester.pumpWidget(
          const GetMaterialApp(home: Scaffold(body: SizedBox())),
        );
        final repository = _FakeSettingsRepository();
        final controller = SettingsController(
          repository: repository,
          authController: _FakeAuthController(),
        );
        controller.preferences.value = UserPreferencesModel(
          preferredColors: const [],
        );

        await Future.wait([
          controller.addPreferredColor('blue'),
          controller.addPreferredColor('black'),
        ]);

        expect(
          repository.preferenceWrites
              .map((preferences) => preferences.preferredColors)
              .toList(),
          const [
            ['blue'],
            ['blue', 'black'],
          ],
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
