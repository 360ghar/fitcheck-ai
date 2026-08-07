import 'dart:async';

import 'package:fitcheck_ai/core/services/code_push_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Stand-in for the real updater, which can only exist inside a binary built by
/// `shorebird release`. `ShorebirdUpdater` is an abstract class with a factory,
/// so it can be implemented directly.
class _FakeUpdater implements ShorebirdUpdater {
  _FakeUpdater({
    this.isAvailable = true,
    this.currentPatch,
    this.status = UpdateStatus.upToDate,
    this.readThrows = false,
    this.checkThrows = false,
    this.readHangs = false,
  });

  @override
  final bool isAvailable;

  final Patch? currentPatch;
  final UpdateStatus status;
  final bool readThrows;
  final bool checkThrows;

  /// When true, `readCurrentPatch` never completes - simulates the blocking
  /// config lock the Shorebird package warns about.
  final bool readHangs;

  int checkForUpdateCalls = 0;

  @override
  Future<Patch?> readCurrentPatch() async {
    if (readHangs) {
      // Never completes.
      await Completer<Patch?>().future;
    }
    if (readThrows) {
      throw const ReadPatchException(message: 'boom');
    }
    return currentPatch;
  }

  @override
  Future<Patch?> readNextPatch() async => currentPatch;

  @override
  Future<UpdateStatus> checkForUpdate({UpdateTrack? track}) async {
    checkForUpdateCalls++;
    if (checkThrows) {
      throw const UpdateException(
        message: 'boom',
        reason: UpdateFailureReason.unknown,
      );
    }
    return status;
  }

  @override
  Future<void> update({UpdateTrack? track}) async {}
}

/// Settles the microtasks that `checkForUpdateInBackground` deliberately does
/// not await.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('CodePushService', () {
    test('is inert when the updater is unavailable', () async {
      // This is the state of every `flutter test`, `flutter run`, and
      // `flutter build` binary, so it must be completely silent.
      final fake = _FakeUpdater(isAvailable: false, currentPatch: null);
      final service = CodePushService(updaterFactory: () => fake);

      expect(service.isAvailable, isFalse);

      await service.loadCurrentPatch();
      service.checkForUpdateInBackground();
      await _settle();

      expect(service.currentPatchNumber.value, isNull);
      expect(service.restartRequired.value, isFalse);
      expect(fake.checkForUpdateCalls, 0);
    });

    test('survives an updater that cannot be constructed', () async {
      final service = CodePushService(
        updaterFactory: () => throw StateError('no engine'),
      );

      expect(service.isAvailable, isFalse);
      // The construction probe runs off the main isolate; even when it throws,
      // the startup read must still complete (degrading to null) within a
      // bounded time instead of stalling main().
      await service.loadCurrentPatch().timeout(const Duration(seconds: 10));
      service.checkForUpdateInBackground();
      await _settle();

      expect(service.currentPatchNumber.value, isNull);
    });

    test('a hanging construction/read cannot stall startup beyond the timeout',
        () async {
      // Simulates ShorebirdUpdaterImpl's constructor/read blocking on the
      // engine's config lock at launch: the whole startup read is bounded by
      // the service's internal timeout and degrades to null instead of
      // hanging main() forever.
      final service = CodePushService(
        updaterFactory: () => _FakeUpdater(readHangs: true),
      );

      final stopwatch = Stopwatch()..start();
      await service.loadCurrentPatch();
      stopwatch.stop();

      expect(service.currentPatchNumber.value, isNull);
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
    });

    test('reads the current patch number', () async {
      final service = CodePushService(
        updaterFactory: () => _FakeUpdater(currentPatch: const Patch(number: 3)),
      );

      await service.loadCurrentPatch();

      expect(service.currentPatchNumber.value, 3);
    });

    test('leaves the patch number null on a release with no patch', () async {
      final service = CodePushService(
        updaterFactory: () => _FakeUpdater(currentPatch: null),
      );

      await service.loadCurrentPatch();

      expect(service.currentPatchNumber.value, isNull);
    });

    test('swallows a failed patch read', () async {
      final service = CodePushService(
        updaterFactory: () => _FakeUpdater(readThrows: true),
      );

      // Must not throw: main() awaits this on the startup path.
      await service.loadCurrentPatch();

      expect(service.currentPatchNumber.value, isNull);
    });

    test('flags restartRequired only once a patch is downloaded', () async {
      final service = CodePushService(
        updaterFactory: () =>
            _FakeUpdater(status: UpdateStatus.restartRequired),
      );

      service.checkForUpdateInBackground();
      await _settle();

      expect(service.restartRequired.value, isTrue);
    });

    test('stays quiet while a patch is still downloading', () async {
      // `outdated` means the background updater has not finished yet - there is
      // nothing the user can act on, so no prompt.
      final service = CodePushService(
        updaterFactory: () => _FakeUpdater(status: UpdateStatus.outdated),
      );

      service.checkForUpdateInBackground();
      await _settle();

      expect(service.restartRequired.value, isFalse);
    });

    test('swallows a failed update check', () async {
      final service = CodePushService(
        updaterFactory: () => _FakeUpdater(checkThrows: true),
      );

      service.checkForUpdateInBackground();
      await _settle();

      expect(service.restartRequired.value, isFalse);
    });

    test('stops checking once a restart is already pending', () async {
      final fake = _FakeUpdater(status: UpdateStatus.restartRequired);
      final service = CodePushService(updaterFactory: () => fake);

      service.checkForUpdateInBackground();
      await _settle();
      // A lifecycle resume fires this again; it should short-circuit.
      service.checkForUpdateInBackground();
      await _settle();

      expect(fake.checkForUpdateCalls, 1);
    });
  });
}
