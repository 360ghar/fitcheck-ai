import 'dart:async';

import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/widgets/app_ui.dart';
import 'package:fitcheck_ai/features/gamification/models/gamification_model.dart';
import 'package:fitcheck_ai/features/gamification/providers/gamification_providers.dart';
import 'package:fitcheck_ai/features/gamification/repositories/gamification_repository.dart';
import 'package:fitcheck_ai/features/gamification/views/gamification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo extends GamificationRepository {
  _Repo({this.leaderboard, this.fail = false});

  /// Null keeps the leaderboard request pending.
  final List<LeaderboardEntry>? leaderboard;
  final bool fail;
  final _never = Completer<List<LeaderboardEntry>>();

  @override
  Future<StreakModel> getStreak() async {
    if (fail) throw Exception('offline');
    return const StreakModel(currentStreak: 3, longestStreak: 9);
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    if (fail) throw Exception('offline');
    return const [AchievementModel(id: 'a', name: 'First piece')];
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    if (fail) throw Exception('offline');
    return leaderboard ?? _never.future;
  }
}

Future<void> _pump(WidgetTester tester, _Repo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: [gamificationRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: GamificationPage(),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a loading leaderboard shows a skeleton, not the empty text', (
    tester,
  ) async {
    await _pump(tester, _Repo());

    await tester.scrollUntilVisible(
      find.text('Leaderboard'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No one on the board yet'), findsNothing);
    expect(find.byType(SkeletonBox), findsWidgets);
  });

  testWidgets('an empty leaderboard shows the empty state', (tester) async {
    await _pump(tester, _Repo(leaderboard: const []));

    await tester.scrollUntilVisible(
      find.text('No one on the board yet'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No one on the board yet'), findsOneWidget);
  });

  testWidgets('nothing loaded shows one error with retry', (tester) async {
    await _pump(tester, _Repo(fail: true));

    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
