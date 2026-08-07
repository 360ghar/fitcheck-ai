import 'dart:async';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../utils/error_handler.dart';

/// Shorebird code push (OTA patches).
///
/// The Shorebird updater itself runs *without* this service - `auto_update` in
/// `shorebird.yaml` makes the engine download patches in the background on
/// launch, and the patch is applied on the NEXT launch. This service only adds
/// visibility on top of that:
///
/// - [currentPatchNumber] for Sentry's `dist` and the Settings version row, so
///   a crash can be attributed to the patch that caused it.
/// - [restartRequired] so the UI can offer a non-blocking "restart to apply".
///
/// Every entry point is inert when the updater is unavailable, which is the
/// case in debug builds, in `flutter test`, and in any binary built with
/// `flutter build` instead of `shorebird release`.
///
/// Startup guarantee: constructing a [ShorebirdUpdater] probes the engine over
/// FFI and can block on its config lock while the background auto-updater is
/// active, so the construction probe for the startup patch-number read runs on
/// a background isolate ([loadCurrentPatch]) and can never stall `main()`.
/// The main-isolate updater is built lazily, only when the first background
/// update check runs (post-first-frame), so launch never pays for it.
class CodePushService extends GetxService with WidgetsBindingObserver {
  CodePushService({ShorebirdUpdater Function()? updaterFactory})
      : _updaterFactory = updaterFactory ?? ShorebirdUpdater.new;

  /// Upper bound on the startup patch-number read, construction probe included.
  ///
  /// `readCurrentPatch` is a local FFI read (no network), but the package's own
  /// source warns that the underlying Rust code can block on a config lock if
  /// another thread is calling into Shorebird concurrently - which the
  /// background auto-updater is doing at exactly this moment. `main()` awaits
  /// this read, so it gets a hard ceiling rather than a chance to hang startup.
  static const Duration _readTimeout = Duration(seconds: 3);

  /// The splash owns the first ~900ms and then navigates away. Announcing a
  /// restart on top of it would stack a snackbar over the launch animation.
  static const Duration _announceDelay = Duration(seconds: 3);

  final ShorebirdUpdater Function() _updaterFactory;

  ShorebirdUpdater? _updater;
  bool _updaterInitFailed = false;
  bool _announced = false;

  /// The patch currently running, or `null` on an unpatched release build.
  final RxnInt currentPatchNumber = RxnInt();

  /// True once a patch has finished downloading and needs a relaunch to apply.
  final RxBool restartRequired = false.obs;

  /// Constructed lazily: building the real [ShorebirdUpdater] probes the engine
  /// over FFI and prints a banner when it is missing, so tests and debug runs
  /// that never touch code push should not pay for it. Startup also never pays
  /// for it: [loadCurrentPatch] runs its own probe on a background isolate, and
  /// this main-isolate instance is only built by the first background update
  /// check (post-first-frame) or an [isAvailable] read.
  ShorebirdUpdater? get _updaterOrNull {
    if (_updaterInitFailed) return null;
    try {
      return _updater ??= _updaterFactory();
    } catch (error) {
      _updaterInitFailed = true;
      debugPrint('CodePushService: updater unavailable: $error');
      return null;
    }
  }

  /// Whether this binary was built by `shorebird release` and can be patched.
  bool get isAvailable => _updaterOrNull?.isAvailable ?? false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Start the (network) update check only once the first frame is up, so it
    // can never contend with startup work.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdateInBackground();
    });
    ever<bool>(restartRequired, (value) {
      if (value) _announceRestartRequired();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A patch that lands while the app is backgrounded should surface on
    // return, not only on the next cold start.
    if (state != AppLifecycleState.resumed) return;

    if (restartRequired.value) {
      // `ever` fires on change only, so an announcement that could not be shown
      // (no overlay yet) needs re-driving explicitly.
      _announceRestartRequired();
    } else {
      checkForUpdateInBackground();
    }
  }

  /// Reads the running patch number into [currentPatchNumber].
  ///
  /// Safe to await during startup: the updater construction probe AND the read
  /// both run inside a background isolate (see
  /// [_readCurrentPatchNumberInIsolate]), so even a blocking FFI probe in
  /// ShorebirdUpdaterImpl's constructor cannot stall `main()`; the whole call
  /// is bounded by [_readTimeout], and every failure mode degrades to `null`.
  /// The background isolate's updater instance is discarded - the main-isolate
  /// [_updater] stays lazy and is only built by the first background check.
  Future<void> loadCurrentPatch() async {
    try {
      final patchNumber = await _readCurrentPatchNumberInIsolate(
        _updaterFactory,
      ).timeout(_readTimeout);
      currentPatchNumber.value = patchNumber;
    } catch (error) {
      // A missing patch number must never be fatal - it is diagnostics only.
      debugPrint('CodePushService: failed to read current patch: $error');
    }
  }

  /// Runs the updater construction probe and the patch read on a background
  /// isolate.
  ///
  /// ShorebirdUpdaterImpl's constructor performs a blocking FFI probe that can
  /// wait on the engine's config lock while the background auto-updater is
  /// active at launch - run synchronously on the main isolate it would stall
  /// `main()` before Sentry is even initialized. The updater created here is
  /// NOT transferable back to the main isolate, so only the patch number
  /// crosses the boundary; the main-isolate [_updater] is constructed lazily
  /// by the first background check instead.
  static Future<int?> _readCurrentPatchNumberInIsolate(
    ShorebirdUpdater Function() updaterFactory,
  ) {
    return Isolate.run(() async {
      final updater = updaterFactory();
      if (!updater.isAvailable) return null;
      final patch = await updater.readCurrentPatch();
      return patch?.number;
    });
  }

  /// Checks Shorebird for a newer patch without blocking the caller.
  ///
  /// Deliberately not `async`: the package documents `checkForUpdate` as a
  /// network call that must not be awaited on any path the user is waiting on.
  void checkForUpdateInBackground() {
    final updater = _updaterOrNull;
    if (updater == null || !updater.isAvailable) return;
    if (restartRequired.value) return;

    updater.checkForUpdate().then(
      (status) {
        // `outdated` means the background updater is still fetching - there is
        // nothing for the user to do yet, so stay quiet until it has landed.
        if (status == UpdateStatus.restartRequired) {
          restartRequired.value = true;
        }
      },
      onError: (Object error) {
        debugPrint('CodePushService: update check failed: $error');
      },
    );
  }

  void _announceRestartRequired() {
    if (_announced) return;

    Future<void>.delayed(_announceDelay, () {
      // No overlay yet means no snackbar host. Leave _announced false so the
      // next resume retries rather than swallowing the prompt for the session.
      if (Get.context == null) return;
      if (_announced) return;
      _announced = true;
      // Routed through ErrorHandler rather than Get.snackbar so this toast is
      // styled like every other one. test/core/utils/snackbar_policy_test.dart
      // enforces that NotificationService.present is the only caller.
      ErrorHandler.showInfo(
        'Restart FitCheck AI to apply the latest improvements.',
        title: 'Update ready',
      );
    });
  }
}
