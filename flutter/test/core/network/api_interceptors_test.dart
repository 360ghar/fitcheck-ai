import 'package:fitcheck_ai/core/network/api_interceptors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('only a rejected refresh token counts as a dead session', () {
    expect(
      TokenRefreshInterceptor.isDeadSession(AuthRetryableFetchException()),
      isFalse,
      reason: 'offline refresh must keep the user signed in',
    );
    expect(
      TokenRefreshInterceptor.isDeadSession(
        AuthApiException('Invalid Refresh Token', statusCode: '400'),
      ),
      isTrue,
    );
    expect(
      TokenRefreshInterceptor.isDeadSession(AuthSessionMissingException()),
      isTrue,
    );
    expect(TokenRefreshInterceptor.isDeadSession(Exception('x')), isFalse);
  });
}
