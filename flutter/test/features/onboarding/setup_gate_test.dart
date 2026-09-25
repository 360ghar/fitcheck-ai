import 'package:fitcheck_ai/features/onboarding/setup_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 9, 25);

  test('a new account that has not finished setup gets it', () {
    expect(
      isNewAccountForSetup(
        createdAt: now.subtract(const Duration(days: 1)),
        done: false,
        now: now,
      ),
      isTrue,
    );
  });

  test('finished, old or unknown accounts do not', () {
    expect(
      isNewAccountForSetup(createdAt: now, done: true, now: now),
      isFalse,
    );
    expect(
      isNewAccountForSetup(
        createdAt: now.subtract(const Duration(days: 8)),
        done: false,
        now: now,
      ),
      isFalse,
    );
    expect(
      isNewAccountForSetup(createdAt: null, done: false, now: now),
      isFalse,
    );
  });

  test('shouldShowSetup gates on styles when gender is unknown', () {
    final createdAt = now.subtract(const Duration(days: 1));
    expect(
      shouldShowSetup(createdAt: createdAt, styles: const [], done: false, now: now),
      isTrue,
    );
    expect(
      shouldShowSetup(
        createdAt: createdAt,
        styles: const ['Casual'],
        done: false,
        now: now,
      ),
      isFalse,
    );
  });

  test('shouldShowSetup never traps on unknown profile data', () {
    final createdAt = now.subtract(const Duration(days: 1));
    expect(
      shouldShowSetup(createdAt: createdAt, done: false, now: now),
      isFalse,
    );
    expect(
      shouldShowSetup(
        createdAt: createdAt,
        gender: 'female',
        styles: const ['Casual'],
        done: false,
        now: now,
      ),
      isFalse,
    );
  });
}
