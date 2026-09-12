import 'package:fitcheck_ai/core/network/auth_url_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('urlAcceptsAuthToken', () {
    test('our API and image origins are eligible', () {
      expect(urlAcceptsAuthToken('http://localhost:8000/api/v1/items'), isTrue);
      expect(
        urlAcceptsAuthToken('https://api.fitcheckaiapp.com/api/v1/items'),
        isTrue,
      );
      expect(
        urlAcceptsAuthToken('https://images.fitcheckaiapp.com/img.png'),
        isTrue,
      );
    });

    test('foreign hosts and non-https are never eligible', () {
      expect(urlAcceptsAuthToken('https://external.example/img.png'), isFalse);
      // A suffix match must not pass: the host has to be exact.
      expect(
        urlAcceptsAuthToken(
          'https://fitcheckaiapp.com.external.example/img.png',
        ),
        isFalse,
      );
      expect(
        urlAcceptsAuthToken('http://images.fitcheckaiapp.com/img.png'),
        isFalse,
      );
    });

    test('presigned URLs are rejected without decoding the query', () {
      expect(
        urlAcceptsAuthToken(
          'https://images.fitcheckaiapp.com/img.png?X-Amz-Signature=abc',
        ),
        isFalse,
      );
      expect(
        urlAcceptsAuthToken(
          'https://images.fitcheckaiapp.com/img.png?x-amz-signature=abc',
        ),
        isFalse,
      );
      expect(
        urlAcceptsAuthToken(
          'https://images.fitcheckaiapp.com/img.png?f=1&X-Amz-Date=20260912',
        ),
        isFalse,
      );
    });

    test('a valid-hex but non-UTF-8 escape cannot throw', () {
      // `uri.queryParameters` utf8-decodes the query and throws
      // FormatException on such escapes; the policy only scans the raw query.
      const latin1Name =
          'https://images.fitcheckaiapp.com/img.png?f=caf%E9.jpg';
      expect(() => urlAcceptsAuthToken(latin1Name), returnsNormally);
      expect(urlAcceptsAuthToken(latin1Name), isTrue);

      const signedLatin1 =
          'https://images.fitcheckaiapp.com/img.png?X-Amz-Signature=abc&f=caf%E9.jpg';
      expect(() => urlAcceptsAuthToken(signedLatin1), returnsNormally);
      expect(urlAcceptsAuthToken(signedLatin1), isFalse);
    });
  });
}
