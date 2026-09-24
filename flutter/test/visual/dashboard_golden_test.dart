@Tags(['golden'])
library;

import 'dart:io';

import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/dashboard/providers/dashboard_provider.dart';
import 'package:fitcheck_ai/features/dashboard/repositories/dashboard_repository.dart';
import 'package:fitcheck_ai/features/dashboard/views/dashboard_content.dart';
import 'package:fitcheck_ai/features/gifts/models/gift_models.dart';
import 'package:fitcheck_ai/features/gifts/providers/gift_providers.dart';
import 'package:fitcheck_ai/features/subscription/providers/subscription_providers.dart';
import 'package:fitcheck_ai/core/widgets/paper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/gifts/gift_fakes.dart';
import '../features/subscription/subscription_fakes.dart';
import 'visual_harness.dart';

class _Repo extends DashboardRepository {
  _Repo({this.items = 42, this.fail = false});

  final int items;
  final bool fail;

  @override
  Future<DashboardData> fetchDashboard() async {
    if (fail) throw const SocketException('offline');
    return DashboardData(
      statistics: DashboardStats(
        totalItems: items,
        totalOutfits: 12,
        itemsAddedThisMonth: 5,
        outfitsCreatedThisMonth: 3,
        favoriteItemsCount: 8,
        favoriteOutfitsCount: 4,
        mostWornItem: const MostWornItem(name: 'Ecru oxford shirt', timesWorn: 14),
      ),
      recentActivity: [
        DashboardActivity(
          type: 'item_created',
          description: 'Added Charcoal wool trousers',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        DashboardActivity(
          type: 'outfit_created',
          description: 'Created The weekend edit',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      suggestions: const DashboardSuggestions(
        weatherBased: DashboardWeatherSuggestion(
          temperature: 24,
          recommendation: 'Light layers. A linen overshirt works well.',
        ),
        outfitOfTheDay: null,
      ),
    );
  }

  @override
  Future<StreakData> fetchStreak() async => const StreakData(
    currentStreak: 6,
    longestStreak: 11,
    streakFreezesRemaining: 1,
    streakSkipsRemaining: 1,
    nextMilestone: null,
  );
}

void main() {
  setUpAll(loadAppFonts);
  setUp(() {
  });

  for (final (name, repo) in [
    ('dashboard', _Repo()),
    ('dashboard_empty', _Repo(items: 0)),
    ('dashboard_error', _Repo(fail: true)),
  ]) {
    for (final dark in [false, true]) {
      final file = '${name}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpPhone(
          tester,
          const PaperStockScope(
            stock: PaperStockId.ink,
            child: Scaffold(body: DashboardContent()),
          ),
          dark: dark,
          overrides: [
            dashboardRepositoryProvider.overrideWithValue(repo),
            // Goldens were captured in the evening; pin the greeting bucket
            // so the wall clock can't flip the screenshot text.
            dashboardGreetingHourProvider.overrideWithValue(18),
            giftRepositoryProvider.overrideWithValue(
              FakeGiftRepository(
                summary: const GiftDashboardSummary(
                  allowances: [],
                  incoming: [],
                ),
              ),
            ),
            subscriptionRepositoryProvider.overrideWithValue(
              FakeSubscriptionRepository(),
            ),
          ],
        );
        await tester.pump(const Duration(milliseconds: 100));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$file.png'),
        );
      });
    }
  }
}
