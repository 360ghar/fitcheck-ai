import 'dart:io';

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/i18n/l10n.dart';
import 'package:fitcheck_ai/core/i18n/locale_registry.dart';
import 'package:fitcheck_ai/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'store_capture.dart';

/// Loads the bundled display face plus the SDK's Roboto and Material Icons,
/// so goldens show real glyphs instead of test boxes.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = await File(path).readAsBytes();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  final fonts =
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  // Store capture in a non-Latin locale replaces the app's Latin faces with one
  // face that also covers the script, standing in for the platform fallback iOS
  // performs at runtime (the test shell has none). English and the Latin-script
  // locales get null here and render exactly as the regression suite does.
  final scriptFallback =
      isStoreCapture ? scriptFallbackFontFor(storeCaptureLocale) : null;

  if (scriptFallback != null) {
    await load('Basteleur', [scriptFallback]);
    await load('Roboto', [scriptFallback]);
  } else {
    await load('Basteleur', [
      'assets/fonts/Basteleur-Moonlight.otf',
      'assets/fonts/Basteleur-Bold.otf',
    ]);
    await load('Roboto', [
      '$fonts/Roboto-Regular.ttf',
      '$fonts/Roboto-Medium.ttf',
      '$fonts/Roboto-Bold.ttf',
    ]);
  }
  await load('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
}

/// Pumps [child] on a 390x844 phone in the app theme.
Future<void> pumpPhone(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  List overrides = const [],
  Duration settle = const Duration(milliseconds: 300),
}) async {
  installStoreCaptureComparator();
  final captureLocale = isStoreCapture
      ? LocaleRegistry.byAsc(storeCaptureLocale)?.locale ?? const Locale('en')
      : const Locale('en');
  tester.view.physicalSize = const Size(390 * 2, 844 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: [...overrides],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        // The real delegates: any screen that reads `context.l10n` (the
        // paywall's trial copy does) would otherwise hit a null localizations
        // lookup. Pinned to English so goldens are stable, unless a store
        // capture run asked for another locale.
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: captureLocale,
        home: child,
      ),
    ),
  );
  // Precache the grain texture and the brand mark, then let images and
  // first frames land.
  await tester.runAsync(() async {
    final ctx = tester.element(find.byWidget(child));
    for (final asset in [
      'assets/textures/paper_grain.png',
      'assets/images/brand_mark.png',
    ]) {
      await precacheImage(AssetImage(asset), ctx);
    }
  });
  await tester.pump(settle);
}
