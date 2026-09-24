import 'package:fitcheck_ai/features/dashboard/providers/dashboard_provider.dart';
import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/dashboard/repositories/dashboard_repository.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _FailingRepository extends FakeDashboardRepository {
  int calls = 0;
  bool fail = false;

  @override
  Future<DashboardData> fetchDashboard() async {
    calls++;
    if (fail) throw Exception('offline');
    return super.fetchDashboard();
  }
}

void main() {
  ProviderContainer containerWith(DashboardRepository repository) {
    final container = ProviderContainer(
      retry: noRetry,
      overrides: [dashboardRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('dashboard loads when the optional streak fails', () async {
    final container = containerWith(FakeDashboardRepository()..failStreak = true);

    final snapshot = await container.read(dashboardProvider.future);

    expect(snapshot.data.statistics.totalItems, 3);
    expect(snapshot.streak, isNull);
  });

  test('a failed refresh keeps the old data and exposes the error', () async {
    final repository = _FailingRepository();
    final container = containerWith(repository);
    // The screen listens in the app; a rebuild after invalidation needs one.
    container.listen(dashboardProvider, (_, _) {});
    await container.read(dashboardProvider.future);

    repository.fail = true;
    await container.read(dashboardProvider.notifier).refresh();
    // Refresh is fire-and-forget; observe the rebuild from outside.
    await expectLater(
      container.read(dashboardProvider.future),
      throwsException,
    );

    final state = container.read(dashboardProvider);
    expect(state.hasError, isTrue);
    expect(state.value?.data.statistics.totalItems, 3);
    expect(repository.calls, 2);
  });
}
