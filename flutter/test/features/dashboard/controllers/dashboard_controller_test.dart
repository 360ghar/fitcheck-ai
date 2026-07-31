import 'package:fitcheck_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/dashboard/repositories/dashboard_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDashboardRepository extends DashboardRepository {
  bool failStreak = false;

  @override
  Future<DashboardData> fetchDashboard() async => const DashboardData(
    statistics: DashboardStats(
      totalItems: 3,
      totalOutfits: 1,
      itemsAddedThisMonth: 1,
      outfitsCreatedThisMonth: 1,
      favoriteItemsCount: 0,
      favoriteOutfitsCount: 0,
    ),
    recentActivity: [],
    suggestions: DashboardSuggestions(weatherBased: null, outfitOfTheDay: null),
  );

  @override
  Future<StreakData> fetchStreak() async {
    if (failStreak) throw Exception('streak unavailable');
    return const StreakData(
      currentStreak: 2,
      longestStreak: 4,
      streakFreezesRemaining: 0,
      streakSkipsRemaining: 0,
      nextMilestone: null,
    );
  }
}

void main() {
  testWidgets('dashboard remains usable when optional streak fetch fails', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final repository = FakeDashboardRepository()..failStreak = true;
    final controller = DashboardController(repository: repository);

    await controller.fetchDashboard();

    expect(controller.dashboard.value, isNotNull);
    expect(controller.dashboard.value!.statistics.totalItems, 3);
    expect(controller.streak.value, isNull);
    expect(controller.error.value, isEmpty);

    controller.onClose();
  });
}
