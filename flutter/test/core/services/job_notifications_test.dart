import 'package:fitcheck_ai/core/services/job_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

/// flutter_local_notifications rejects ids outside the signed 32-bit range,
/// and a rejected id silently drops the notification.
void main() {
  const jobIds = [
    'job-1',
    '3f2b8c9e-6a41-4d2e-9b7c-0a1e5d4c7f10',
    'a-much-longer-job-id-that-hashes-to-something-large',
  ];

  test('notification ids fit in 31 bits', () {
    for (final id in jobIds) {
      for (final away in [false, true]) {
        final value = JobNotifications.idFor(id, away: away);
        expect(
          value,
          inInclusiveRange(0, 0x7fffffff),
          reason: '$id away=$away',
        );
      }
    }
  });

  test('the away id differs from the live id', () {
    for (final id in jobIds) {
      expect(
        JobNotifications.idFor(id, away: true),
        isNot(JobNotifications.idFor(id)),
      );
    }
  });
}
