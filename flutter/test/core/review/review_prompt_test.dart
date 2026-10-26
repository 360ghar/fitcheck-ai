import 'package:fitcheck_ai/core/review/review_prompt.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersistenceService persistence;
  late List<String> asked;
  DateTime clock = DateTime(2026, 1, 1, 12);

  ReviewPrompt prompt() => ReviewPrompt(
    persistence: persistence,
    requestReview: () async => asked.add('asked'),
    now: () => clock,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    persistence = PersistenceService();
    asked = [];
    clock = DateTime(2026, 1, 1, 12);
  });

  /// Two launches on day one, then a jump past the minimum age. This is the
  /// "returning user" baseline every allow-case starts from.
  Future<void> becomeReturningUser() async {
    await prompt().recordLaunch();
    await prompt().recordLaunch();
    clock = clock.add(ReviewPrompt.minimumAge + const Duration(hours: 1));
  }

  group('Recorded launches', () {
    test('the first launch is stamped once and counted every time', () async {
      await prompt().recordLaunch();
      await prompt().recordLaunch();
      await prompt().recordLaunch();

      expect(await persistence.getInt(ReviewPrompt.launchCountKey), 3);
      expect(
        await persistence.getInt(ReviewPrompt.firstLaunchKey),
        clock.millisecondsSinceEpoch,
        reason: 'the first stamp must not move on later launches',
      );
    });
  });

  group('Never in the first session', () {
    test('a single launch does not ask, and does not spend the milestone', () async {
      await prompt().recordLaunch();
      clock = clock.add(const Duration(days: 30));

      expect(
        await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot),
        isFalse,
      );
      expect(asked, isEmpty);
      expect(
        await persistence.getBool(
          ReviewPrompt.askedKey(ReviewMilestone.firstPhotoshoot),
        ),
        isNull,
        reason: 'the milestone must still be available next launch',
      );
    });

    test('two launches inside the first day do not ask', () async {
      await prompt().recordLaunch();
      await prompt().recordLaunch();
      clock = clock.add(const Duration(hours: 2));

      expect(
        await prompt().maybeRequest(ReviewMilestone.thirdOutfit),
        isFalse,
      );
      expect(asked, isEmpty);
    });

    test('an app with no launch record never asks', () async {
      expect(
        await prompt().maybeRequest(ReviewMilestone.firstFullWardrobe),
        isFalse,
      );
      expect(asked, isEmpty);
    });
  });

  group('Asks once, at a real milestone', () {
    for (final milestone in ReviewMilestone.values) {
      test('$milestone asks a returning user exactly once', () async {
        await becomeReturningUser();

        expect(await prompt().maybeRequest(milestone), isTrue);
        expect(asked, hasLength(1));

        // Same milestone again, even long after the cooldown.
        clock = clock.add(ReviewPrompt.cooldown + const Duration(days: 1));
        expect(await prompt().maybeRequest(milestone), isFalse);
        expect(asked, hasLength(1));
      });
    }

    test('the ask is recorded in persistence, not only in memory', () async {
      await becomeReturningUser();
      await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot);

      // A fresh instance reads the same store: this survives a restart.
      expect(
        await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot),
        isFalse,
      );
      expect(
        await persistence.getBool(
          ReviewPrompt.askedKey(ReviewMilestone.firstPhotoshoot),
        ),
        isTrue,
      );
      expect(await persistence.getInt(ReviewPrompt.lastAskedKey), isNotNull);
    });
  });

  group('Cooldown', () {
    test('a second milestone inside the cooldown does not ask', () async {
      await becomeReturningUser();
      expect(await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot), isTrue);

      clock = clock.add(ReviewPrompt.cooldown - const Duration(days: 1));
      expect(await prompt().maybeRequest(ReviewMilestone.thirdOutfit), isFalse);
      expect(asked, hasLength(1));
    });

    test('a second milestone after the cooldown does ask', () async {
      await becomeReturningUser();
      expect(await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot), isTrue);

      clock = clock.add(ReviewPrompt.cooldown + const Duration(hours: 1));
      expect(await prompt().maybeRequest(ReviewMilestone.thirdOutfit), isTrue);
      expect(asked, hasLength(2));
      // The un-asked milestone is still available later.
      expect(
        await persistence.getBool(
          ReviewPrompt.askedKey(ReviewMilestone.firstFullWardrobe),
        ),
        isNull,
      );
    });
  });

  group('Caller-declared bad moments', () {
    test('onboarding never asks and never spends the milestone', () async {
      await becomeReturningUser();
      expect(
        await prompt().maybeRequest(
          ReviewMilestone.firstPhotoshoot,
          inOnboarding: true,
        ),
        isFalse,
      );
      expect(asked, isEmpty);
      expect(
        await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot),
        isTrue,
        reason: 'the milestone was not spent by the onboarding call',
      );
    });

    test('an error path never asks and never spends the milestone', () async {
      await becomeReturningUser();
      expect(
        await prompt().maybeRequest(
          ReviewMilestone.firstPhotoshoot,
          onErrorPath: true,
        ),
        isFalse,
      );
      expect(asked, isEmpty);
      expect(
        await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot),
        isTrue,
      );
    });
  });

  group('Safety', () {
    test('a disabled prompt writes nothing and asks nothing', () async {
      final disabled = ReviewPrompt.disabled();
      await disabled.recordLaunch();
      clock = clock.add(const Duration(days: 30));

      expect(await disabled.maybeRequest(ReviewMilestone.thirdOutfit), isFalse);
      expect(asked, isEmpty);
      expect(await persistence.getInt(ReviewPrompt.firstLaunchKey), isNull);
      expect(await persistence.getInt(ReviewPrompt.launchCountKey), isNull);
    });

    test('a store failure is swallowed, never surfaced', () async {
      await becomeReturningUser();
      final failing = ReviewPrompt(
        persistence: persistence,
        requestReview: () async => throw Exception('store unavailable'),
        now: () => clock,
      );

      expect(await failing.maybeRequest(ReviewMilestone.thirdOutfit), isFalse);
    });

    test('reset clears every key the prompt writes', () async {
      await becomeReturningUser();
      await prompt().maybeRequest(ReviewMilestone.firstPhotoshoot);
      await prompt().reset();

      expect(await persistence.getInt(ReviewPrompt.firstLaunchKey), isNull);
      expect(await persistence.getInt(ReviewPrompt.launchCountKey), isNull);
      expect(await persistence.getInt(ReviewPrompt.lastAskedKey), isNull);
      for (final milestone in ReviewMilestone.values) {
        expect(
          await persistence.getBool(ReviewPrompt.askedKey(milestone)),
          isNull,
        );
      }
    });
  });
}
