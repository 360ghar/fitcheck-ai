import 'dart:async';

// SettingsNotifier guards:
//
// changePassword re-authenticates with the current password first. Supabase's
// updateUser needs only a live session, so without it a wrong current
// password changed the password.
//
// exportData reports honestly: when no browser opens, the short-lived link is
// copied instead of being thrown away behind a "ready" message.
//
// A failed preference load keeps preferences null. Falling back to defaults
// let the next toggle PUT the whole default model over saved preferences.

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart'
    show NetworkException, NotFoundException;
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/core/services/theme_service.dart';
import 'package:fitcheck_ai/features/auth/providers/auth_provider.dart';
import 'package:fitcheck_ai/features/settings/models/user_preferences_model.dart';
import 'package:fitcheck_ai/features/settings/providers/settings_provider.dart';
import 'package:fitcheck_ai/features/settings/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, User;

class _FakeAuth extends AuthNotifier {
  _FakeAuth({
    this.wrongPassword = false,
    this.updateFails = false,
    this.provider,
  });

  final String email = 'user@example.com';

  /// Auth provider in the session's app metadata. Null: no session user.
  final String? provider;
  final bool wrongPassword;
  final bool updateFails;

  final List<String> reauthCalls = [];
  final List<String> updateCalls = [];
  int logoutCalls = 0;

  @override
  AuthState build() => const AuthState();

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
    if (wrongPassword) throw const AuthException('Invalid login credentials');
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    updateCalls.add(newPassword);
    // The real notifier shows its own message, then rethrows.
    if (updateFails) throw const AuthException('Password too weak');
  }

  @override
  Future<void> logout() async => logoutCalls++;
}

class _FakeRepo implements SettingsRepository {
  static const exportUrl = 'https://example.com/export.json';

  int exportCalls = 0;
  int deleteCalls = 0;
  final List<UserPreferencesModel> writes = [];
  Future<UserPreferencesModel> Function()? onGet;
  Future<UserPreferencesModel> Function(UserPreferencesModel p)? onUpdate;

  @override
  Future<UserPreferencesModel> getPreferences() =>
      onGet?.call() ?? Future.value(UserPreferencesModel());

  @override
  Future<UserPreferencesModel> updatePreferences(UserPreferencesModel p) {
    writes.add(p);
    return onUpdate?.call(p) ?? Future.value(p);
  }

  @override
  Future<String> requestDataExport() async {
    exportCalls++;
    return exportUrl;
  }

  @override
  Future<void> deleteAccount() async => deleteCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTheme extends ThemeService {
  AppThemeMode _mode = AppThemeMode.system;

  @override
  AppThemeMode get appThemeMode => _mode;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async => _mode = mode;

  @override
  void syncFromBackend(AppThemeMode? backendMode) {
    if (backendMode != null) _mode = backendMode;
  }
}

/// Captures url_launcher platform calls so a launch can be made to fail.
class _LauncherStub {
  _LauncherStub({required this.canLaunch, this.launchSucceeds = true});

  final bool canLaunch;
  final bool launchSucceeds;
  final List<String> launched = [];

  static const _channel = MethodChannel('plugins.flutter.io/url_launcher');

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          switch (call.method) {
            case 'canLaunch':
              return canLaunch;
            case 'launch':
              launched.add(call.arguments['url']?.toString() ?? '');
              return launchSucceeds;
          }
          return null;
        });
  }

  void remove() => TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clipboardWrites = <String>[];
  late _FakeRepo repo;
  late _FakeAuth auth;
  late _FakeTheme theme;

  setUp(() {
    repo = _FakeRepo();
    auth = _FakeAuth();
    theme = _FakeTheme();
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
  });

  /// A container whose settings provider stays alive, loaded once.
  Future<ProviderContainer> start(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    final container = ProviderContainer(
      retry: noRetry,
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        themeServiceProvider.overrideWithValue(theme),
        authProvider.overrideWith(() => auth),
      ],
    );
    addTearDown(container.dispose);
    container.listen(settingsProvider, (_, _) {});
    await tester.pump();
    return container;
  }

  SettingsNotifier notifier(ProviderContainer c) =>
      c.read(settingsProvider.notifier);

  group('loading preferences', () {
    testWidgets('a network failure keeps preferences null', (tester) async {
      repo.onGet = () async => throw const NetworkException(
        message: 'No connection',
        errorCode: 'NO_CONNECTION',
      );
      final c = await start(tester);

      final state = c.read(settingsProvider);
      expect(state.preferences, isNull);
      expect(state.loadError, isA<NetworkException>());
      expect(state.isLoading, isFalse);

      // A toggle now must not PUT defaults over the saved preferences.
      await notifier(c).toggleWeeklySummary(false);
      await notifier(c).updateThemeMode(AppThemeMode.dark);
      expect(repo.writes, isEmpty);
      expect(theme.appThemeMode, AppThemeMode.dark, reason: 'applied locally');
    });

    testWidgets('no saved row yet uses defaults', (tester) async {
      repo.onGet = () async =>
          throw const NotFoundException(message: 'No preferences');
      final c = await start(tester);

      expect(c.read(settingsProvider).preferences, isNotNull);
      expect(c.read(settingsProvider).loadError, isNull);
    });

    testWidgets('keeps the latest overlapping fetch', (tester) async {
      final first = Completer<UserPreferencesModel>();
      final second = Completer<UserPreferencesModel>();
      var fetches = 0;
      repo.onGet = () => ++fetches == 1 ? first.future : second.future;
      final c = await start(tester);

      final newest = notifier(c).fetchPreferences();
      await tester.pump();

      first.complete(UserPreferencesModel(themeMode: AppThemeMode.light));
      await tester.pump();
      expect(c.read(settingsProvider).isLoading, isTrue);
      expect(c.read(settingsProvider).preferences, isNull);

      second.complete(UserPreferencesModel(themeMode: AppThemeMode.dark));
      await newest;
      expect(
        c.read(settingsProvider).preferences?.themeMode,
        AppThemeMode.dark,
      );
      expect(c.read(settingsProvider).isLoading, isFalse);
    });
  });

  group('changePassword re-authenticates', () {
    testWidgets('verifies the current password before updating', (
      tester,
    ) async {
      final c = await start(tester);

      final changed = await notifier(
        c,
      ).changePassword('current-pw', 'NewPassw0rd');
      await tester.pump();

      expect(changed, isTrue);
      expect(auth.reauthCalls, ['current-pw']);
      expect(auth.updateCalls, ['NewPassw0rd']);
      // AuthNotifier.updatePassword shows the result; no second message.
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('does NOT update when the current password is wrong', (
      tester,
    ) async {
      auth = _FakeAuth(wrongPassword: true);
      final c = await start(tester);

      final changed = await notifier(
        c,
      ).changePassword('wrong-pw', 'NewPassw0rd');
      await tester.pump();

      expect(changed, isFalse);
      expect(auth.reauthCalls, ['wrong-pw']);
      expect(auth.updateCalls, isEmpty);
      expect(find.text('Current password is incorrect.'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('a failed update adds no second error message', (tester) async {
      auth = _FakeAuth(updateFails: true);
      final c = await start(tester);

      final changed = await notifier(
        c,
      ).changePassword('current-pw', 'weakpass');
      await tester.pump();

      expect(changed, isFalse, reason: 'the dialog must stay open');
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('does NOT reauthenticate an OAuth-only (Google) account', (
      tester,
    ) async {
      auth = _FakeAuth(provider: 'google');
      final c = await start(tester);

      final changed = await notifier(
        c,
      ).changePassword('anything', 'NewPassw0rd');
      await tester.pump();

      expect(changed, isFalse);
      expect(auth.reauthCalls, isEmpty);
      expect(auth.updateCalls, isEmpty);
      expect(
        find.textContaining('This account signs in with Google or Apple'),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  group('exportData reports honestly', () {
    testWidgets('opens the link', (tester) async {
      final launcher = _LauncherStub(canLaunch: true)..install();
      addTearDown(launcher.remove);
      final c = await start(tester);

      await notifier(c).exportData();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(repo.exportCalls, 1);
      expect(launcher.launched, [_FakeRepo.exportUrl]);
      expect(clipboardWrites, isEmpty);
    });

    testWidgets('copies the link when the browser cannot be opened', (
      tester,
    ) async {
      final launcher = _LauncherStub(canLaunch: false)..install();
      addTearDown(launcher.remove);
      final c = await start(tester);

      await notifier(c).exportData();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(launcher.launched, isEmpty);
      expect(clipboardWrites, [_FakeRepo.exportUrl]);
    });

    testWidgets('copies the link when launch is attempted but fails', (
      tester,
    ) async {
      final launcher = _LauncherStub(canLaunch: true, launchSucceeds: false)
        ..install();
      addTearDown(launcher.remove);
      final c = await start(tester);

      await notifier(c).exportData();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(clipboardWrites, [_FakeRepo.exportUrl]);
    });
  });

  testWidgets('deleteAccount signs out after the delete succeeds', (
    tester,
  ) async {
    final c = await start(tester);

    expect(await notifier(c).deleteAccount(), isTrue);
    expect(repo.deleteCalls, 1);
    expect(auth.logoutCalls, 1);
  });

  group('preference saves preserve pending mutations', () {
    testWidgets('rolls back a rejected latest non-theme preference', (
      tester,
    ) async {
      repo.onGet = () async => UserPreferencesModel(notificationsEnabled: true);
      repo.onUpdate = (_) async => throw StateError('write rejected');
      final c = await start(tester);

      await notifier(c).toggleNotifications(false);

      expect(
        c.read(settingsProvider).preferences?.notificationsEnabled,
        isTrue,
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets(
      'reverts a failed latest theme change to the last confirmed mode',
      (tester) async {
        final initial = UserPreferencesModel(themeMode: AppThemeMode.system);
        final firstWrite = Completer<UserPreferencesModel>();
        final secondWrite = Completer<UserPreferencesModel>();
        var writes = 0;
        repo.onGet = () async => initial;
        repo.onUpdate = (_) =>
            ++writes == 1 ? firstWrite.future : secondWrite.future;
        final c = await start(tester);

        final chooseLight = notifier(c).updateThemeMode(AppThemeMode.light);
        // Let the first write go pending before the next choice arrives.
        await tester.pump();
        final chooseDark = notifier(c).updateThemeMode(AppThemeMode.dark);
        expect(theme.appThemeMode, AppThemeMode.dark);

        firstWrite.complete(initial.copyWith(themeMode: AppThemeMode.light));
        await tester.pump();
        await chooseLight;
        await tester.pump();
        expect(repo.writes, hasLength(2));

        secondWrite.completeError(StateError('write rejected'));
        await tester.pump();
        await chooseDark;

        expect(
          c.read(settingsProvider).preferences?.themeMode,
          AppThemeMode.light,
        );
        expect(theme.appThemeMode, AppThemeMode.light);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      },
    );

    testWidgets('serializes rapid style selections with the latest state', (
      tester,
    ) async {
      repo.onGet = () async => UserPreferencesModel(preferredStyles: const []);
      final c = await start(tester);

      await Future.wait([
        notifier(c).addPreferredStyle('casual'),
        notifier(c).addPreferredStyle('formal'),
      ]);

      expect(repo.writes.map((p) => p.preferredStyles).toList(), const [
        ['casual'],
        ['casual', 'formal'],
      ]);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('serializes rapid color selections with the latest state', (
      tester,
    ) async {
      repo.onGet = () async => UserPreferencesModel(preferredColors: const []);
      final c = await start(tester);

      await Future.wait([
        notifier(c).addPreferredColor('blue'),
        notifier(c).addPreferredColor('black'),
      ]);

      expect(repo.writes.map((p) => p.preferredColors).toList(), const [
        ['blue'],
        ['blue', 'black'],
      ]);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('keeps client-only settings the server echo drops', (
      tester,
    ) async {
      // The backend persists only preferred_styles and echoes null for the
      // rest; storing the echo verbatim reverted each saved setting.
      repo.onGet = () async => UserPreferencesModel(
        themeMode: AppThemeMode.dark,
        temperatureUnit: TemperatureUnit.celsius,
        notificationsEnabled: false,
        preferredStyles: const [],
      );
      repo.onUpdate = (_) async =>
          UserPreferencesModel(preferredStyles: const ['casual']);
      final c = await start(tester);

      final saved = await notifier(c).savePreferences(
        c
            .read(settingsProvider)
            .preferences!
            .copyWith(preferredStyles: const ['casual']),
      );

      final prefs = c.read(settingsProvider).preferences;
      expect(saved, isTrue);
      expect(prefs?.themeMode, AppThemeMode.dark);
      expect(prefs?.temperatureUnit, TemperatureUnit.celsius);
      expect(prefs?.notificationsEnabled, isFalse);
      expect(prefs?.preferredStyles, const ['casual']);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}
