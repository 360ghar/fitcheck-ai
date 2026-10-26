import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../services/persistence_service.dart';

/// The moments worth asking for a rating.
///
/// Each one is a point where the user has just received the thing they
/// downloaded the app for. Launches, onboarding steps and error paths are
/// absent on purpose: a rating request stacked on a failure reads as
/// opportunism, and iOS shows the sheet at most three times a year per user
/// anyway, so wasting one on a bad moment is permanent.
enum ReviewMilestone {
  /// The first AI photoshoot finished and the results are on screen.
  firstPhotoshoot,

  /// The third outfit the user generated. One outfit can be luck; three is a
  /// wardrobe that works.
  thirdOutfit,

  /// The wardrobe crossed ten items: the user has committed real effort.
  firstFullWardrobe,
}

/// Asks for an App Store rating at a genuine moment of delight, at most once
/// per milestone and no more than once every [cooldown].
///
/// Everything it decides is persisted through [PersistenceService], so the
/// answer survives reinstalls of the process (not reinstalls of the app — that
/// is Apple's counter, and the reason [cooldown] also has to exist here).
///
/// Design rules, each enforced below rather than left to the caller:
///  * Never in the user's first session: one full day and a second launch.
///  * Never during onboarding or on an error path: the caller states both, and
///    a false from either cancels the ask without spending the milestone.
///  * Never twice for the same milestone.
///  * Never twice within [cooldown], whatever the milestone.
///  * Never blocks, never throws: it is fire-and-forget from the feature that
///    just succeeded.
///
/// The surrounding copy is empty by design: `in_app_review` shows the system
/// sheet, whose text belongs to iOS. Nothing here needs a translation.
class ReviewPrompt {
  ReviewPrompt({
    PersistenceService? persistence,
    Future<void> Function()? requestReview,
    DateTime Function()? now,
    this.enabled = true,
  }) : _persistence = persistence ?? PersistenceService.instance,
       _requestReview = requestReview ?? _defaultRequestReview,
       _now = now ?? DateTime.now;

  /// A no-op prompt, for tests and for builds that must never ask.
  factory ReviewPrompt.disabled() =>
      ReviewPrompt(enabled: false, requestReview: () async {});

  /// First launch, in epoch milliseconds. Written on first use.
  static const String firstLaunchKey = 'review.first_launch_ms';

  /// Launch counter. The first session must not ask.
  static const String launchCountKey = 'review.launch_count';

  /// Last successful ask, in epoch milliseconds.
  static const String lastAskedKey = 'review.last_asked_ms';

  /// Per-mileage flags: `review.asked.<milestone name>`.
  static String askedKey(ReviewMilestone milestone) =>
      'review.asked.${milestone.name}';

  /// Minimum time between two asks. Apple's own limit is three sheets a year;
  /// asking every quarter is already generous and this leaves headroom for
  /// macOS/web if they are ever added.
  static const Duration cooldown = Duration(days: 120);

  /// The app must be at least this old before the first ask.
  static const Duration minimumAge = Duration(days: 1);

  /// The second launch, at the earliest.
  static const int minimumLaunches = 2;

  final PersistenceService _persistence;
  final Future<void> Function() _requestReview;
  final DateTime Function() _now;

  /// False makes [maybeRequest] a no-op that also writes nothing.
  final bool enabled;

  static Future<void> _defaultRequestReview() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }

  /// Records a launch. Call once from app start, before anything can ask.
  ///
  /// Never throws: launch bookkeeping must not be able to stop an app from
  /// starting, and a test host without a preferences plugin must not fail
  /// because a rating counter could not be written.
  Future<void> recordLaunch() async {
    if (!enabled) return;
    try {
      final now = _now().millisecondsSinceEpoch;
      final first = await _persistence.getInt(firstLaunchKey);
      if (first == null) await _persistence.setInt(firstLaunchKey, now);
      final count = await _persistence.getInt(launchCountKey) ?? 0;
      await _persistence.setInt(launchCountKey, count + 1);
    } catch (error) {
      if (kDebugMode) debugPrint('ReviewPrompt: launch not recorded ($error)');
    }
  }

  /// Asks, if allowed. Returns true only when the store sheet was requested.
  ///
  /// [inOnboarding] and [onErrorPath] are the caller's honest statement about
  /// where the user is. Neither is inferable here, and guessing is how an app
  /// ends up asking in the middle of a failed upload.
  Future<bool> maybeRequest(
    ReviewMilestone milestone, {
    bool inOnboarding = false,
    bool onErrorPath = false,
  }) async {
    if (!enabled) return false;
    if (inOnboarding || onErrorPath) return false;

    try {
      if (await _persistence.getBool(askedKey(milestone)) ?? false) {
        return false;
      }

      final first = await _persistence.getInt(firstLaunchKey);
      // No first launch on record means nothing has proven the app is past its
      // first session. Do not ask, and do not spend the milestone.
      if (first == null) return false;
      final now = _now();
      final age = now.difference(
        DateTime.fromMillisecondsSinceEpoch(first),
      );
      if (age < minimumAge) return false;
      final launches = await _persistence.getInt(launchCountKey) ?? 0;
      if (launches < minimumLaunches) return false;

      final last = await _persistence.getInt(lastAskedKey);
      if (last != null) {
        final since = now.difference(
          DateTime.fromMillisecondsSinceEpoch(last),
        );
        if (since < cooldown) return false;
      }

      // Claim before the await, so a second milestone firing in the same frame
      // cannot race this one into two sheets.
      await _persistence.setBool(askedKey(milestone), true);
      await _persistence.setInt(lastAskedKey, now.millisecondsSinceEpoch);
      await _requestReview();
      return true;
    } catch (error) {
      // A rating prompt must never surface an error to the user or break the
      // flow that just succeeded.
      if (kDebugMode) debugPrint('ReviewPrompt: skipped ($error)');
      return false;
    }
  }

  /// Clears every key this class writes. Tests and a debug "reset" affordance.
  @visibleForTesting
  Future<void> reset() async {
    await _persistence.remove(firstLaunchKey);
    await _persistence.remove(launchCountKey);
    await _persistence.remove(lastAskedKey);
    for (final milestone in ReviewMilestone.values) {
      await _persistence.remove(askedKey(milestone));
    }
  }
}

/// The app-wide prompt. Features call
/// `ref.read(reviewPromptProvider).maybeRequest(...)` fire-and-forget from the
/// success path of the moment they own.
final reviewPromptProvider = Provider<ReviewPrompt>((ref) => ReviewPrompt());
