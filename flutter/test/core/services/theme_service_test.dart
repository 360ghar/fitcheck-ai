import 'dart:async';

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/services/theme_service.dart';
import 'package:fitcheck_ai/features/settings/models/user_preferences_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DelayedPersistence extends PersistenceService {
  final firstWrite = Completer<void>();
  final writes = <String>[];
  String? stored;

  @override
  Future<String?> getString(String key) async => stored;

  @override
  Future<bool> setString(String key, String value) async {
    writes.add(value);
    if (writes.length == 1) await firstWrite.future;
    stored = value;
    return true;
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester, ThemeService service) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: service.currentThemeMode,
        home: const Scaffold(body: Text('Theme probe')),
      ),
    );
    await tester.pumpAndSettle();
  }

  Brightness appearance(WidgetTester tester) =>
      Theme.of(tester.element(find.text('Theme probe'))).brightness;

  for (final mode in AppThemeMode.values) {
    testWidgets('cached $mode is used by the first app frame', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      SharedPreferences.setMockInitialValues({
        'fitcheck_theme_mode': mode.name,
      });
      Get.put(PersistenceService());
      final service = Get.put(ThemeService());
      await service.ready;
      expect(service.appThemeMode, mode);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: service.currentThemeMode,
          home: const Scaffold(body: Text('Theme probe')),
        ),
      );
      expect(
        appearance(tester),
        mode == AppThemeMode.light ? Brightness.light : Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('System follows device changes; explicit modes stay fixed', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final persistence = Get.put(PersistenceService());
    final service = Get.put(ThemeService());
    await service.ready;
    await pumpApp(tester, service);
    await service.setThemeMode(AppThemeMode.system);
    await tester.pumpAndSettle();
    expect(appearance(tester), Brightness.light);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(appearance(tester), Brightness.dark);
    await service.setThemeMode(AppThemeMode.light);
    await tester.pumpAndSettle();
    expect(appearance(tester), Brightness.light);
    await service.setThemeMode(AppThemeMode.dark);
    await tester.pumpAndSettle();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(appearance(tester), Brightness.dark);
    expect(await persistence.getString('fitcheck_theme_mode'), 'dark');
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid theme choices persist in order and restore the latest', (
    tester,
  ) async {
    final persistence = _DelayedPersistence();
    Get.put<PersistenceService>(persistence);
    final service = Get.put(ThemeService());
    await service.ready;
    await pumpApp(tester, service);
    final dark = service.setThemeMode(AppThemeMode.dark);
    await tester.pump();
    final system = service.setThemeMode(AppThemeMode.system);
    expect(service.currentThemeMode, ThemeMode.system);
    expect(persistence.writes, ['dark']);
    persistence.firstWrite.complete();
    await Future.wait([dark, system]);
    expect(persistence.writes, ['dark', 'system']);
    expect(persistence.stored, 'system');
    await Get.delete<ThemeService>();
    final restored = Get.put(ThemeService());
    await restored.ready;
    expect(restored.currentThemeMode, ThemeMode.system);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
