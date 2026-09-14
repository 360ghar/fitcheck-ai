import 'package:fitcheck_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/dashboard/repositories/dashboard_repository.dart';
import 'package:fitcheck_ai/features/outfits/models/outfit_model.dart';
import 'package:fitcheck_ai/features/outfits/repositories/outfit_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDashboardRepository extends DashboardRepository {
  bool failStreak = false;
  String? ootdId;

  @override
  Future<DashboardData> fetchDashboard() async => DashboardData(
    statistics: const DashboardStats(
      totalItems: 3,
      totalOutfits: 1,
      itemsAddedThisMonth: 1,
      outfitsCreatedThisMonth: 1,
      favoriteItemsCount: 0,
      favoriteOutfitsCount: 0,
    ),
    recentActivity: const [],
    suggestions: DashboardSuggestions(
      weatherBased: null,
      outfitOfTheDay: ootdId == null
          ? null
          : DashboardOutfitOfTheDay(
              id: ootdId,
              name: 'Weekend edit',
              imageUrl: 'https://example.com/outfit.png',
            ),
    ),
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

  testWidgets('outfit of the day detail loads once per suggestion', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final outfits = FakeOutfitRepository();
    final controller = DashboardController(
      repository: FakeDashboardRepository()..ootdId = 'o1',
      outfitRepository: outfits,
    );

    await controller.fetchDashboard();
    await controller.fetchOutfitOfTheDay();

    expect(controller.outfitOfTheDayDetail.value?.id, 'o1');
    expect(outfits.calls, 1);

    // Repeat calls (and refreshes with the same suggestion) reuse the cache.
    await controller.fetchOutfitOfTheDay();
    await controller.fetchDashboard();
    await controller.fetchOutfitOfTheDay();
    expect(outfits.calls, 1);
    expect(controller.error.value, isEmpty);

    controller.onClose();
  });

  testWidgets('outfit of the day failure keeps the image fallback', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final outfits = FakeOutfitRepository()..fail = true;
    final controller = DashboardController(
      repository: FakeDashboardRepository()..ootdId = 'o1',
      outfitRepository: outfits,
    );

    await controller.fetchDashboard();
    await controller.fetchOutfitOfTheDay();

    // Silent enrichment failure: no detail, and crucially no page error —
    // Home renders the suggestion image instead.
    expect(controller.outfitOfTheDayDetail.value, isNull);
    expect(controller.error.value, isEmpty);

    controller.onClose();
  });
}

const _pixel =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=';

class FakeOutfitRepository extends OutfitRepository {
  int calls = 0;
  bool fail = false;

  @override
  Future<OutfitModel> getOutfit(String outfitId) async {
    calls++;
    if (fail) throw Exception('offline');
    return const OutfitModel(
      id: 'o1',
      userId: 'user',
      name: 'Weekend edit',
      itemIds: ['shirt'],
      items: [
        ItemModel(
          id: 'shirt',
          userId: 'user',
          name: 'Cotton shirt',
          category: Category.tops,
          condition: domain.Condition.clean,
          itemImages: [ItemImage(id: 'photo', url: _pixel)],
        ),
      ],
    );
  }
}
