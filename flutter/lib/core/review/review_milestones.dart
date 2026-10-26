import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_prompt.dart';

/// Translates "the user just crossed a meaningful line" into a review ask.
///
/// Deliberately **pull, not watch**. Watching `wardrobeProvider` and
/// `outfitsProvider` from here would force both paged lists to load on every
/// cold start (two API calls before the user has opened a tab), so the owning
/// features push the observation instead:
///
/// ```dart
/// // wardrobe_content.dart, after a successful load:
/// if (items.length >= 10) {
///   ref.read(reviewMilestonesProvider)
///      .wardrobeReachedTenItems(itemCount: items.length);
/// }
///
/// // outfit_providers.dart or the outfit builder, after a create succeeds:
/// ref.read(reviewMilestonesProvider).outfitGenerated(totalOutfits: total);
///
/// // photoshoot_results_step.dart, when results first render:
/// ref.read(reviewMilestonesProvider).photoshootFinished(
///   imageCount: state.images.length,
///   onErrorPath: state.error != null,
/// );
/// ```
///
/// Each method is cheap, idempotent across the app's lifetime (the prompt
/// itself remembers), and safe to call from `build`: [ReviewPrompt] claims the
/// milestone before awaiting anything, so a `build` that runs three times in a
/// frame cannot produce three sheets.
class ReviewMilestones {
  ReviewMilestones(this._prompt);

  final ReviewPrompt _prompt;

  /// Set once per process so a repeated `build` does not re-enter the ask.
  final Set<ReviewMilestone> _attemptedThisProcess = {};

  /// The wardrobe crossed ten items for the first time.
  Future<bool> wardrobeReachedTenItems({required int itemCount}) {
    if (itemCount < 10) return Future.value(false);
    return _ask(ReviewMilestone.firstFullWardrobe);
  }

  /// The user now has three outfits.
  Future<bool> outfitGenerated({required int totalOutfits}) {
    if (totalOutfits < 3) return Future.value(false);
    return _ask(ReviewMilestone.thirdOutfit);
  }

  /// A photoshoot produced its first images. [onErrorPath] must be true while
  /// a failure banner is on screen: an ask stacked on a failure reads as
  /// opportunism.
  Future<bool> photoshootFinished({
    required int imageCount,
    bool onErrorPath = false,
    bool partialSuccess = false,
  }) {
    if (imageCount == 0 || onErrorPath) return Future.value(false);
    // A partial success is still a win (some images landed), but it is not a
    // *good* moment: the user is looking at missing slots.
    return _ask(ReviewMilestone.firstPhotoshoot, onErrorPath: partialSuccess);
  }

  Future<bool> _ask(
    ReviewMilestone milestone, {
    bool onErrorPath = false,
  }) {
    // Cheap in-process guard before touching storage.
    if (!_attemptedThisProcess.add(milestone)) return Future.value(false);
    return _prompt.maybeRequest(milestone, onErrorPath: onErrorPath);
  }

  /// Clears the process-level guard. Tests only: a widget test that pumps the
  /// same milestone twice needs the second call to reach the prompt.
  @visibleForTesting
  void debugResetProcessGuard() => clearProcessGuard();

  void clearProcessGuard() => _attemptedThisProcess.clear();
}

/// The milestone API the feature owners call. See [ReviewMilestones].
final reviewMilestonesProvider = Provider<ReviewMilestones>(
  (ref) => ReviewMilestones(ref.watch(reviewPromptProvider)),
);
