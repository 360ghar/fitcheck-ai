import 'package:fitcheck_ai/app/routes/app_pages.dart';
import 'package:fitcheck_ai/app/routes/app_routes.dart';
import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google OAuth launch failure propagates to the auth service', () async {
    final service = AuthService(googleSignInLauncher: () async => false);

    await expectLater(
      service.signInWithGoogle(),
      throwsA(isA<AuthException>()),
    );
  });

  test('guest routes use guest middleware to redirect authenticated users', () {
    for (final routeName in [
      Routes.onboarding,
      Routes.login,
      Routes.register,
      Routes.forgotPassword,
    ]) {
      final route = AppPages.routes.firstWhere(
        (page) => page.name == routeName,
      );
      expect(route.middlewares, contains(isA<GuestMiddleware>()));
    }
  });
}
