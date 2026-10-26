import 'package:fitcheck_ai/features/subscription/services/trial_eligibility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(TrialEligibilityService.channelName);
  late int calls;

  /// Answers the channel the way `TrialEligibilityChannel.swift` does.
  void answer(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          calls++;
          lastCall = call;
          return handler(call);
        });
  }

  setUp(() {
    calls = 0;
    lastCall = null;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('TrialEligibilityService on iOS', () {
    test('an eligible answer is eligible', () async {
      answer((_) async => true);
      expect(
        await const TrialEligibilityService().check(kProMonthlyProductId),
        TrialEligibility.eligible,
      );
      expect(calls, 1);
    });

    test('a false answer is ineligible, not unknown', () async {
      answer((_) async => false);
      expect(
        await const TrialEligibilityService().check(kProMonthlyProductId),
        TrialEligibility.ineligible,
      );
    });

    // StoreKit 2 is unavailable, the product does not resolve, or the store
    // errored. Every one of those must read as unknown: treating it as
    // ineligible would withdraw the free month from every user during an App
    // Store outage.
    test('a null answer is unknown', () async {
      answer((_) async => null);
      expect(
        await const TrialEligibilityService().check(kProMonthlyProductId),
        TrialEligibility.unknown,
      );
    });

    test('a platform exception is unknown, and does not throw', () async {
      answer((_) async => throw PlatformException(code: 'storekit_error'));
      expect(
        await const TrialEligibilityService().check(kProMonthlyProductId),
        TrialEligibility.unknown,
      );
    });

    test('a missing plugin is unknown, and does not throw', () async {
      // No handler installed at all: the channel answers null, which the
      // service maps to unknown rather than failing the paywall.
      expect(
        await const TrialEligibilityService().check(kProMonthlyProductId),
        TrialEligibility.unknown,
      );
      expect(calls, 0);
    });

    test('an empty product id never reaches the store', () async {
      answer((_) async => true);
      expect(
        await const TrialEligibilityService().check(''),
        TrialEligibility.unknown,
      );
      expect(calls, 0);
    });

    test('the argument is `productId`, spelled as the Swift side expects', () async {
      answer((_) async => true);
      await const TrialEligibilityService().check('pro.monthly.test');
      // Re-read the recorded call.
      expect(lastCall?.method, TrialEligibilityService.methodIsEligible);
      expect(lastCall?.arguments, {'productId': 'pro.monthly.test'});
    });
  });

  group('TrialEligibilityService off iOS', () {
    test('Android answers unknown without touching the channel', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      answer((_) async => true);
      expect(
        await const TrialEligibilityService().check(kProMonthlyProductId),
        TrialEligibility.unknown,
      );
      expect(calls, 0, reason: 'no missing-plugin round trip on Android');
    });

    test('Android reports itself as unsupported', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(const TrialEligibilityService().isSupported, isFalse);
    });
  });

  group('TrialEligibility', () {
    test('only eligible may promise a free month', () {
      expect(TrialEligibility.eligible.canPromiseFreeMonth, isTrue);
      expect(TrialEligibility.ineligible.canPromiseFreeMonth, isFalse);
      expect(TrialEligibility.unknown.canPromiseFreeMonth, isFalse);
    });
  });
}

/// The last call the mocked channel received, for argument assertions.
MethodCall? lastCall;
