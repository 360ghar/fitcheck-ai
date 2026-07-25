import 'package:dio/dio.dart';
import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/services/network_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Use tiny delays so the test suite runs fast.
  const baseDelay = Duration(milliseconds: 1);
  const maxDelay = Duration(milliseconds: 5);

  group('RetryHelper.execute', () {
    test('returns immediately on first-try success', () async {
      var calls = 0;
      final result = await RetryHelper.execute<String>(
        operation: () async {
          calls++;
          return 'ok';
        },
        baseDelay: baseDelay,
        maxDelay: maxDelay,
      );

      expect(result, 'ok');
      expect(calls, 1);
    });

    test('retries and succeeds after transient failures', () async {
      var calls = 0;
      final result = await RetryHelper.execute<String>(
        operation: () async {
          calls++;
          if (calls < 3) {
            throw NetworkException.noConnection();
          }
          return 'recovered';
        },
        maxAttempts: 3,
        baseDelay: baseDelay,
        maxDelay: maxDelay,
      );

      expect(result, 'recovered');
      expect(calls, 3);
    });

    test('throws after exhausting max attempts for retryable errors', () async {
      var calls = 0;
      await expectLater(
        RetryHelper.execute<String>(
          operation: () async {
            calls++;
            throw NetworkException.timeout();
          },
          maxAttempts: 3,
          baseDelay: baseDelay,
          maxDelay: maxDelay,
        ),
        throwsA(isA<NetworkException>()),
      );

      // Should attempt exactly maxAttempts times then give up.
      expect(calls, 3);
    });

    test('non-retryable error fails fast without retrying', () async {
      var calls = 0;
      await expectLater(
        RetryHelper.execute<String>(
          operation: () async {
            calls++;
            // Auth errors are not retryable.
            throw AuthException.unauthorized();
          },
          maxAttempts: 3,
          baseDelay: baseDelay,
          maxDelay: maxDelay,
        ),
        throwsA(isA<AuthException>()),
      );

      expect(calls, 1);
    });

    test('retries DioException connection errors', () async {
      var calls = 0;
      final result = await RetryHelper.execute<String>(
        operation: () async {
          calls++;
          if (calls == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: '/x'),
              type: DioExceptionType.connectionError,
            );
          }
          return 'back';
        },
        maxAttempts: 3,
        baseDelay: baseDelay,
        maxDelay: maxDelay,
      );

      expect(result, 'back');
      expect(calls, 2);
    });

    test('does not retry DioException badResponse (non-transient)', () async {
      var calls = 0;
      await expectLater(
        RetryHelper.execute<String>(
          operation: () async {
            calls++;
            throw DioException(
              requestOptions: RequestOptions(path: '/x'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/x'),
                statusCode: 500,
              ),
            );
          },
          maxAttempts: 3,
          baseDelay: baseDelay,
          maxDelay: maxDelay,
        ),
        throwsA(isA<DioException>()),
      );

      expect(calls, 1);
    });

    test('custom retryIf predicate controls retries', () async {
      var calls = 0;
      // Only retry when the error message contains 'transient'.
      await expectLater(
        RetryHelper.execute<String>(
          operation: () async {
            calls++;
            throw StateError('fatal');
          },
          maxAttempts: 3,
          baseDelay: baseDelay,
          maxDelay: maxDelay,
          retryIf: (e) => e.toString().contains('transient'),
        ),
        throwsA(isA<StateError>()),
      );

      // Predicate returns false, so no retry.
      expect(calls, 1);
    });

    test('custom retryIf predicate allows retries', () async {
      var calls = 0;
      final result = await RetryHelper.execute<String>(
        operation: () async {
          calls++;
          if (calls < 2) {
            throw StateError('transient failure');
          }
          return 'done';
        },
        maxAttempts: 3,
        baseDelay: baseDelay,
        maxDelay: maxDelay,
        retryIf: (e) => e.toString().contains('transient'),
      );

      expect(result, 'done');
      expect(calls, 2);
    });

    test('maxAttempts of 1 means no retries', () async {
      var calls = 0;
      await expectLater(
        RetryHelper.execute<String>(
          operation: () async {
            calls++;
            throw NetworkException.noConnection();
          },
          maxAttempts: 1,
          baseDelay: baseDelay,
          maxDelay: maxDelay,
        ),
        throwsA(isA<NetworkException>()),
      );

      expect(calls, 1);
    });

    test('respects errorCode-based retry decisions', () async {
      // An AppException with a retryable errorCode (TIMEOUT) but that is not a
      // NetworkException should still be retried.
      var calls = 0;
      final result = await RetryHelper.execute<String>(
        operation: () async {
          calls++;
          if (calls < 2) {
            throw const NetworkException(
              message: 'slow',
              errorCode: 'TIMEOUT',
            );
          }
          return 'ok';
        },
        maxAttempts: 3,
        baseDelay: baseDelay,
        maxDelay: maxDelay,
      );

      expect(result, 'ok');
      expect(calls, 2);
    });
  });
}
