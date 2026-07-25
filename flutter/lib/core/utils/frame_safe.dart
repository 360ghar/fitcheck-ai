import 'dart:async';

import 'package:flutter/scheduler.dart';

/// Helpers that keep GetX `Rx` writes out of Flutter's build/layout/paint phase.
///
/// ## Why this exists
///
/// Writing an `Rx` value pushes onto its `GetStream`, which makes every
/// subscribed `Obx` call `setState`. If that happens while Flutter is inside
/// `BuildOwner.buildScope` (`SchedulerPhase.persistentCallbacks`) and the dirty
/// `Obx` is *not* a descendant of the element currently building, the framework
/// throws:
///
/// ```text
/// setState() or markNeedsBuild() called during build.
/// This Obx widget cannot be marked as needing to build because the framework
/// is already in the process of building widgets.
/// ```
///
/// That is easy to hit in this app. `MainShellPage` keeps every visited tab
/// mounted in an `IndexedStack`, and `MainShellBinding` keeps their controllers
/// alive (`permanent` / `fenix`). Meanwhile a newly pushed route runs its
/// `Bindings.dependencies()`, its `page: () => …` closure and the page's
/// `State.initState()` *synchronously inside* the `Builder` that
/// `_ModalScopeState.build` wraps around `route.buildPage(...)` — because
/// `Element.inflateWidget` → `mount` → `_firstBuild` → `initState` all run
/// while the parent (`Builder`) is still the current build target. So a
/// controller fetch kicked off from a binding or an `initState` writes
/// `isLoading` mid-frame and marks a shell tab's `Obx` dirty.
///
/// Use [afterBuildPhase] for a synchronous write, or `await`
/// [settleBuildPhase] as the first statement of an async method whose leading
/// statements write `Rx` state.

bool get _isBuilding =>
    SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks;

/// Runs [action] immediately, unless Flutter is mid-frame, in which case it is
/// deferred to the end of the current frame.
///
/// Pass a disposal check inside [action] itself (e.g. `if (!isClosed)`) when the
/// owner can go away within the frame.
void afterBuildPhase(VoidCallback action) {
  if (_isBuilding) {
    SchedulerBinding.instance.addPostFrameCallback((_) => action());
  } else {
    action();
  }
}

/// Completes immediately unless Flutter is mid-frame, in which case it completes
/// at the end of the current frame.
///
/// Await this as the *first* statement of an async method that writes `Rx` state
/// before its first real `await` — deferring the whole method (rather than just
/// the leading writes) preserves write ordering, so a fast-completing
/// `finally { isLoading.value = false; }` cannot run before a deferred
/// `isLoading.value = true` and leave a stuck spinner.
///
/// Resolves to `false` when [stillAlive] says the owner went away while the
/// frame was finishing — a `GetxController` popped mid-frame would otherwise
/// write to a closed `GetStream`. Callers inside a controller pass
/// `stillAlive: () => !isClosed` and bail on `false`:
///
/// ```dart
/// if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
/// ```
///
/// The future always completes. Leaving it pending would strand the awaiting
/// body forever: its `finally` never runs, and the `Future` it returned to its
/// own caller (a `RefreshIndicator.onRefresh`, say) never completes either, so
/// the spinner turns for good.
Future<bool> settleBuildPhase({bool Function()? stillAlive}) {
  if (!_isBuilding) return Future<bool>.value(true);

  final completer = Completer<bool>();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    completer.complete(stillAlive?.call() ?? true);
  });
  return completer.future;
}
