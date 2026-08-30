import 'package:flutter_test/flutter_test.dart';
import 'package:fitcheck_ai/core/constants/api_constants.dart';

void main() {
  test('isPublicEndpoint matches public endpoints segment-wise', () {
    expect(ApiConstants.isPublicEndpoint('/api/v1/auth/login'), isTrue);
    expect(ApiConstants.isPublicEndpoint('/auth/login'), isTrue);
    expect(ApiConstants.isPublicEndpoint('/api/v1/waitlist'), isTrue);
    expect(ApiConstants.isPublicEndpoint('/waitlist?x=1'), isTrue);
    expect(ApiConstants.isPublicEndpoint('/api/v1/auth/register'), isTrue);
  });

  test('isPublicEndpoint does not substring-match non-public paths', () {
    // Substring contains() would match '/auth/login' inside these; the
    // segment-aware check must not.
    expect(ApiConstants.isPublicEndpoint('/users/auth/login-history'), isFalse);
    expect(ApiConstants.isPublicEndpoint('/api/v1/items'), isFalse);
    expect(
      ApiConstants.isPublicEndpoint('/api/v1/auth/login-history'),
      isFalse,
    );
    expect(ApiConstants.isPublicEndpoint('/api/v1/subscription'), isFalse);
  });
}
