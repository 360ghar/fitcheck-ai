@Tags(['golden'])
library;

import 'package:fitcheck_ai/features/auth/views/auth_entry_page.dart';
import 'package:fitcheck_ai/features/auth/views/forgot_password_page.dart';
import 'package:fitcheck_ai/features/auth/views/login_page.dart';
import 'package:fitcheck_ai/features/auth/views/register_page.dart';
import 'package:fitcheck_ai/features/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  final screens = <String, Widget Function()>{
    'auth_entry': () => const AuthEntryPage(),
    'login': () => const LoginPage(),
    'register': () => const RegisterPage(),
    'forgot_password': () => const ForgotPasswordPage(),
  };

  for (final dark in [false, true]) {
    for (final e in screens.entries) {
      final name = '${e.key}_${dark ? 'dark' : 'light'}';
      testWidgets(name, (tester) async {
        await pumpPhone(tester, e.value(), dark: dark);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$name.png'),
        );
      });
    }
  }

  // Splash starts session restore; only its first frame matters here.
  testWidgets('splash_light', (tester) async {
    await pumpPhone(tester, const SplashPage());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/splash_light.png'),
    );
  }, skip: true);
}
