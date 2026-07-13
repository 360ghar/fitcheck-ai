import 'package:flutter_test/flutter_test.dart';
import 'package:fitcheck_ai/core/utils/error_handler.dart';

void main() {
  // Regression test: caught errors previously only ever reached the user via
  // a snackbar and were never reported to Sentry/PostHog, so a production
  // regression in any caught path was invisible until a user complained.
  // reportError() is the extracted telemetry path (no snackbar/Get context
  // needed), so it's testable without a full widget harness.
  test('reportError does not throw when analytics/Sentry are uninitialized', () {
    expect(
      () => ErrorHandler.reportError(
        Exception('boom'),
        'boom',
        stackTrace: StackTrace.current,
      ),
      returnsNormally,
    );
  });

  test('reportError does not throw without a stack trace', () {
    expect(
      () => ErrorHandler.reportError('a plain string error', 'a plain string error'),
      returnsNormally,
    );
  });
}
