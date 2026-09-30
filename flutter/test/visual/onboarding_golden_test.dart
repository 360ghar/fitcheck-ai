@Tags(['golden'])
library;

import 'package:fitcheck_ai/features/onboarding/intro_page.dart';
import 'package:fitcheck_ai/features/onboarding/setup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

/// Lets button, chip and strip transitions and ink splashes finish.
Future<void> settle(WidgetTester tester) async {
  for (var f = 0; f < 40; f++) {
    await tester.pump(const Duration(milliseconds: 25));
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';
    testWidgets('intro sheets $theme', (tester) async {
      await pumpPhone(tester, const IntroPage(), dark: dark);
      for (var page = 1; page <= 3; page++) {
        if (page > 1) {
          await tester.tap(find.text('Next'));
          for (var f = 0; f < 30; f++) {
            await tester.pump(const Duration(milliseconds: 20));
          }
        }
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/intro_${page}_$theme.png'),
        );
      }
    });
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';
    testWidgets('setup steps $theme', (tester) async {
      await pumpPhone(tester, const SetupPage(), dark: dark);
      await tester.tap(find.text('Women'));
      await settle(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/setup_1_$theme.png'),
      );
      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.tap(find.text('Casual'));
      await tester.tap(find.text('Weekend'));
      await settle(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/setup_2_$theme.png'),
      );
      await tester.tap(find.text('Skip'));
      await settle(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/setup_3_$theme.png'),
      );
    });
  }
}
