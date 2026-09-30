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
}
