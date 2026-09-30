@Tags(['golden'])
library;

import 'dart:io';

import 'package:fitcheck_ai/core/services/theme_service.dart';
import 'package:fitcheck_ai/core/widgets/paper.dart';
import 'package:fitcheck_ai/features/auth/models/user_model.dart';
import 'package:fitcheck_ai/features/auth/providers/auth_provider.dart';
import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/dashboard/providers/dashboard_provider.dart';
import 'package:fitcheck_ai/features/dashboard/repositories/dashboard_repository.dart';
import 'package:fitcheck_ai/features/feedback/models/feedback_model.dart';
import 'package:fitcheck_ai/features/feedback/providers/feedback_provider.dart';
import 'package:fitcheck_ai/features/feedback/repositories/feedback_repository.dart';
import 'package:fitcheck_ai/features/feedback/views/feedback_page.dart';
import 'package:fitcheck_ai/features/gamification/models/gamification_model.dart';
import 'package:fitcheck_ai/features/gamification/providers/gamification_providers.dart';
import 'package:fitcheck_ai/features/gamification/repositories/gamification_repository.dart';
import 'package:fitcheck_ai/features/gamification/views/gamification_page.dart';
import 'package:fitcheck_ai/features/profile/models/body_profile_model.dart';
import 'package:fitcheck_ai/features/profile/providers/body_profiles_provider.dart';
import 'package:fitcheck_ai/features/profile/repositories/body_profile_repository.dart';
import 'package:fitcheck_ai/features/profile/views/body_profiles_page.dart';
import 'package:fitcheck_ai/features/profile/views/profile_content.dart';
import 'package:fitcheck_ai/features/settings/models/user_preferences_model.dart';
import 'package:fitcheck_ai/features/settings/providers/settings_provider.dart';
import 'package:fitcheck_ai/features/settings/repositories/settings_repository.dart';
import 'package:fitcheck_ai/features/settings/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

class _Auth extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
    user: UserModel(
      id: 'u',
      email: 'maya.rao@example.com',
      fullName: 'Maya Rao',
    ),
  );
}

class _Dashboard extends DashboardRepository {
  @override
  Future<DashboardData> fetchDashboard() async => const DashboardData(
    statistics: DashboardStats(
      totalItems: 42,
      totalOutfits: 12,
      itemsAddedThisMonth: 5,
      outfitsCreatedThisMonth: 3,
      favoriteItemsCount: 8,
      favoriteOutfitsCount: 4,
      mostWornItem: MostWornItem(name: 'Ecru oxford shirt', timesWorn: 14),
    ),
    recentActivity: [],
    suggestions: DashboardSuggestions(weatherBased: null, outfitOfTheDay: null),
  );

  @override
  Future<StreakData> fetchStreak() async => const StreakData(
    currentStreak: 6,
    longestStreak: 11,
    streakFreezesRemaining: 1,
    streakSkipsRemaining: 1,
    nextMilestone: null,
  );
}

class _Settings implements SettingsRepository {
  _Settings({this.fail = false});

  final bool fail;

  @override
  Future<UserPreferencesModel> getPreferences() async {
    if (fail) throw const SocketException('offline');
    return UserPreferencesModel(
      themeMode: AppThemeMode.system,
      temperatureUnit: TemperatureUnit.celsius,
      emailNotificationsEnabled: true,
      outfitRemindersEnabled: false,
      weeklySummaryEnabled: true,
      preferredStyles: const ['Minimalist', 'Casual'],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Never touches Get's theme mode, so each golden keeps its own brightness.
class _Theme extends ThemeService {
  @override
  AppThemeMode get appThemeMode => AppThemeMode.system;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {}

  @override
  void syncFromBackend(AppThemeMode? backendMode) {}
}

class _BodyProfiles extends BodyProfileRepository {
  @override
  Future<List<BodyProfileModel>> getBodyProfiles() async => const [];
}

class _Feedback extends FeedbackRepository {
  @override
  Future<List<TicketListItem>> getMyTickets({
    int limit = 20,
    int offset = 0,
  }) async => [
    TicketListItem(
      id: 't1',
      category: TicketCategory.bugReport,
      subject: 'Try-on photo stays blank',
      status: TicketStatus.inProgress,
      createdAt: DateTime(2026, 9, 12),
    ),
    TicketListItem(
      id: 't2',
      category: TicketCategory.featureRequest,
      subject: 'Pack a suitcase from my closet',
      status: TicketStatus.resolved,
      createdAt: DateTime(2026, 8, 30),
    ),
  ];
}

class _Rewards extends GamificationRepository {
  @override
  Future<StreakModel> getStreak() async =>
      const StreakModel(currentStreak: 6, longestStreak: 11, nextMilestone: 10);

  @override
  Future<List<AchievementModel>> getAchievements() async => const [
    AchievementModel(
      id: 'first_upload',
      name: 'First piece',
      iconName: 'photo_camera',
      isUnlocked: true,
    ),
    AchievementModel(
      id: 'first_outfit',
      name: 'First outfit',
      iconName: 'checkroom',
      isUnlocked: true,
    ),
    AchievementModel(
      id: 'streak_7',
      name: 'Seven-day streak',
      iconName: 'local_fire_department',
      progress: 6,
      target: 7,
    ),
    AchievementModel(
      id: 'closet_50',
      name: 'Fifty pieces',
      progress: 42,
      target: 50,
    ),
    AchievementModel(
      id: 'planner',
      name: 'Plan a full week',
      progress: 3,
      target: 7,
    ),
    AchievementModel(
      id: 'sharer',
      name: 'Share an outfit',
      progress: 0,
      target: 1,
    ),
  ];

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async => const [
    LeaderboardEntry(userId: 'a', username: 'Anika', points: 1240, rank: 1),
    LeaderboardEntry(userId: 'b', username: 'Jonah', points: 1105, rank: 2),
    LeaderboardEntry(userId: 'u', username: 'Maya Rao', points: 980, rank: 3),
    LeaderboardEntry(
      userId: 'c',
      username: 'Priyanka Venkataraman',
      points: 760,
      rank: 4,
    ),
  ];
}

final _common = [
  authProvider.overrideWith(_Auth.new),
  themeServiceProvider.overrideWithValue(_Theme()),
];

void main() {
  setUpAll(loadAppFonts);

  final cases = <(String, Widget, List, List<bool>)>[
    (
      'more',
      const PaperStockScope(
        stock: PaperStockId.stone,
        child: Scaffold(body: ProfileContent()),
      ),
      [dashboardRepositoryProvider.overrideWithValue(_Dashboard())],
      [false, true],
    ),
    (
      'settings',
      const SettingsPage(),
      [settingsRepositoryProvider.overrideWithValue(_Settings())],
      [false, true],
    ),
    (
      'settings_error',
      const SettingsPage(),
      [settingsRepositoryProvider.overrideWithValue(_Settings(fail: true))],
      [false],
    ),
    (
      'body_profiles_empty',
      const BodyProfilesPage(),
      [bodyProfileRepositoryProvider.overrideWithValue(_BodyProfiles())],
      [false],
    ),
    (
      'feedback',
      const FeedbackPage(),
      [feedbackRepositoryProvider.overrideWithValue(_Feedback())],
      [false],
    ),
    (
      'rewards',
      const GamificationPage(),
      [gamificationRepositoryProvider.overrideWithValue(_Rewards())],
      [false, true],
    ),
  ];

  for (final (name, page, overrides, modes) in cases) {
    for (final dark in modes) {
      final file = '${name}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpPhone(
          tester,
          page,
          dark: dark,
          overrides: [..._common, ...overrides],
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
