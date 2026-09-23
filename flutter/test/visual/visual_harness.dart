import 'dart:io';

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  await load('Basteleur', [
    'assets/fonts/Basteleur-Moonlight.otf',
    'assets/fonts/Basteleur-Bold.otf',
  ]);
  final fonts =
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  await load('Roboto', [
    '$fonts/Roboto-Regular.ttf',
    '$fonts/Roboto-Medium.ttf',
    '$fonts/Roboto-Bold.ttf',
  ]);
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
        home: child,
      ),
    ),
  );
  // Precache the grain texture, then let images and first frames land.
  await tester.runAsync(() async {
    final ctx = tester.element(find.byWidget(child));
    await precacheImage(
      const AssetImage('assets/textures/paper_grain.png'),
      ctx,
    );
  });
  await tester.pump(settle);
}
