import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/services/persistence_service.dart';
import 'package:fitcheck_ai/core/services/theme_service.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/auth/controllers/auth_controller.dart';
import 'package:fitcheck_ai/features/auth/models/user_model.dart';
import 'package:fitcheck_ai/features/auth/services/auth_service.dart';
import 'package:fitcheck_ai/features/auth/services/referral_service.dart';
import 'package:fitcheck_ai/features/auth/services/user_initialization_service.dart';
import 'package:fitcheck_ai/features/calendar/controllers/calendar_controller.dart';
import 'package:fitcheck_ai/features/calendar/models/calendar_event_model.dart';
import 'package:fitcheck_ai/features/calendar/views/calendar_page.dart';
import 'package:fitcheck_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:fitcheck_ai/features/dashboard/models/dashboard_models.dart';
import 'package:fitcheck_ai/features/gamification/controllers/gamification_controller.dart';
import 'package:fitcheck_ai/features/gamification/models/gamification_model.dart';
import 'package:fitcheck_ai/features/gamification/views/gamification_page.dart';
import 'package:fitcheck_ai/features/profile/controllers/body_profile_controller.dart';
import 'package:fitcheck_ai/features/profile/models/body_profile_model.dart';
import 'package:fitcheck_ai/features/profile/views/body_profiles_page.dart';
import 'package:fitcheck_ai/features/profile/views/profile_content.dart';
import 'package:fitcheck_ai/features/profile/views/profile_edit_page.dart';
import 'package:fitcheck_ai/features/profile/repositories/profile_repository.dart';
import 'package:fitcheck_ai/features/recommendations/controllers/astrology_recommendations_controller.dart';
import 'package:fitcheck_ai/features/recommendations/controllers/complete_look_controller.dart';
import 'package:fitcheck_ai/features/recommendations/controllers/find_matches_controller.dart';
import 'package:fitcheck_ai/features/recommendations/controllers/recommendations_controller.dart';
import 'package:fitcheck_ai/features/recommendations/controllers/shopping_recommendations_controller.dart';
import 'package:fitcheck_ai/features/recommendations/controllers/weather_recommendations_controller.dart';
import 'package:fitcheck_ai/features/recommendations/views/recommendations_page.dart';
import 'package:fitcheck_ai/features/settings/controllers/ai_settings_controller.dart';
import 'package:fitcheck_ai/features/settings/controllers/settings_controller.dart';
import 'package:fitcheck_ai/features/settings/views/ai_settings_page.dart';
import 'package:fitcheck_ai/features/settings/views/settings_page.dart';
import 'package:fitcheck_ai/features/subscription/repositories/subscription_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Suppress startup I/O; exercise the real views and observable state.
class _Auth extends AuthController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Dashboard extends DashboardController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Settings extends SettingsController {
  _Settings() : super(themeService: ThemeService());
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _AiSettings extends AiSettingsController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Profiles extends BodyProfileController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Progress extends GamificationController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _Calendar extends CalendarController {
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> fetchEventsForMonth(DateTime date) async {}
}

class _Recommendations extends RecommendationsController {
  @override
  // ignore: must_call_super
  void onInit() {
    tabController = TabController(length: 5, vsync: this);
  }
}

class _Weather extends WeatherRecommendationsController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _EditProfileRepository extends ProfileRepository {
  @override
  Future<Map<String, dynamic>> getProfile() async => {
    'full_name': 'Alexandra Montgomery',
    'birth_date': '1990-06-15',
    'birth_time': '08:30',
    'birth_place': 'San Francisco, California',
  };
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<AuthService>(AuthService());
    Get.put<ReferralService>(
      ReferralService(
        persistence: PersistenceService(),
        userInitService: UserInitializationService(
          subscriptionRepo: SubscriptionRepository(),
        ),
      ),
    );
    Get.put<AuthController>(_Auth());
    Get.put<DashboardController>(_Dashboard());
    Get.put<SettingsController>(_Settings());
    Get.put<AiSettingsController>(_AiSettings());
    Get.put<BodyProfileController>(_Profiles());
    Get.put<GamificationController>(_Progress());
    Get.put<CalendarController>(_Calendar());
    Get.put<FindMatchesController>(FindMatchesController());
    Get.put<CompleteLookController>(CompleteLookController());
    Get.put<WeatherRecommendationsController>(_Weather());
    Get.put<ShoppingRecommendationsController>(
      ShoppingRecommendationsController(),
    );
    Get.put<AstrologyRecommendationsController>(
      AstrologyRecommendationsController(),
    );
    Get.put<RecommendationsController>(_Recommendations());
  });
  tearDown(Get.reset);

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    bool dark = false,
    double width = 320,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2), disableAnimations: true),
          child: child!,
        ),
        home: page,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '${page.runtimeType}');
  }

  Future<void> scrollAll(WidgetTester tester) async {
    final scrollables = find.byType(Scrollable);
    for (final element in scrollables.evaluate().toList()) {
      final state = (element as StatefulElement).state as ScrollableState;
      if (state.position.axis != Axis.vertical) continue;
      while (state.position.pixels < state.position.maxScrollExtent) {
        state.position.jumpTo(
          (state.position.pixels + 400).clamp(
            0,
            state.position.maxScrollExtent,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
  }

  for (final dark in [false, true]) {
    testWidgets('profile edit fits 320px / 200%, dark=$dark', (tester) async {
      await pump(
        tester,
        ProfileEditPage(repository: _EditProfileRepository()),
        dark: dark,
      );
      await scrollAll(tester);
      expect(find.text('Alexandra Montgomery'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tablet account pages retain readable layouts at 200%', (
    tester,
  ) async {
    for (final page in <Widget>[
      const Scaffold(body: ProfileContent()),
      const SettingsPage(),
      const AiSettingsPage(),
      const BodyProfilesPage(),
      const CalendarPage(),
      const GamificationPage(),
    ]) {
      await pump(tester, page, width: 1024, dark: true);
      await scrollAll(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets(
    'preference and body-profile sheets scroll at 200% with keyboard',
    (tester) async {
      await pump(tester, const SettingsPage());
      for (final title in ['Preferred Styles', 'Preferred Colors']) {
        await tester.scrollUntilVisible(
          find.text(title).hitTestable(),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Done').hitTestable(),
          300,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pump(tester, const BodyProfilesPage(), dark: true);
      await tester.tap(find.text('Add Body Profile'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Save Profile'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    for (final populated in [false, true]) {
      testWidgets(
        'account pages fit 320px / 200%, dark=$dark populated=$populated',
        (tester) async {
          if (populated) {
            Get.find<AuthController>().user.value = const UserModel(
              id: 'user',
              fullName: 'Alexandra Montgomery',
              email: 'alexandra.montgomery@example.com',
            );
            Get.find<DashboardController>().dashboard.value =
                const DashboardData(
                  statistics: DashboardStats(
                    totalItems: 12345,
                    totalOutfits: 12345,
                    itemsAddedThisMonth: 2,
                    outfitsCreatedThisMonth: 2,
                    favoriteItemsCount: 2,
                    favoriteOutfitsCount: 2,
                  ),
                  recentActivity: [],
                  suggestions: DashboardSuggestions(
                    weatherBased: null,
                    outfitOfTheDay: null,
                  ),
                );
            Get.find<BodyProfileController>().profiles.add(
              const BodyProfileModel(
                id: 'body',
                userId: 'user',
                name: 'My everyday measurements',
                heightCm: 173,
                weightKg: 69.5,
                bodyShape: 'Regular',
                skinTone: 'Medium',
                isDefault: true,
              ),
            );
            final progress = Get.find<GamificationController>();
            progress.streak.value = const StreakModel(
              currentStreak: 365,
              longestStreak: 365,
              nextMilestone: 500,
            );
            progress.achievements.add(
              const AchievementModel(
                id: 'year',
                name: 'A full year of personal style',
                progress: 365,
                target: 365,
                isUnlocked: true,
              ),
            );
            progress.leaderboard.add(
              const LeaderboardEntry(
                userId: 'long',
                username: 'Alexandra Montgomery',
                points: 123456,
                rank: 1,
              ),
            );
            final calendar = Get.find<CalendarController>();
            final today = DateTime.now();
            final event = CalendarEventModel(
              id: 'event',
              title: 'Dinner with the design team',
              startTime: today,
              endTime: today.add(const Duration(hours: 2)),
              location: 'San Francisco, California',
              outfitId: 'outfit',
            );
            calendar.eventsByDate[DateTime(
              today.year,
              today.month,
              today.day,
            )] = [
              event,
            ];
          }
          for (final page in <Widget>[
            const Scaffold(body: ProfileContent()),
            const SettingsPage(),
            const AiSettingsPage(),
            const BodyProfilesPage(),
            const CalendarPage(),
            const GamificationPage(),
          ]) {
            await pump(tester, page, dark: dark);
            await scrollAll(tester);
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
          }
        },
      );
    }
    testWidgets('account errors are visible and fit, dark=$dark', (
      tester,
    ) async {
      const failure = 'Connection failed. Check your connection and try again.';
      Get.find<BodyProfileController>().error.value = failure;
      Get.find<SettingsController>().error.value = failure;
      Get.find<AiSettingsController>().error.value = failure;
      Get.find<CalendarController>().error.value = failure;
      Get.find<GamificationController>().error.value = failure;
      for (final page in <Widget>[
        const SettingsPage(),
        const AiSettingsPage(),
        const BodyProfilesPage(),
        const CalendarPage(),
        const GamificationPage(),
      ]) {
        await pump(tester, page, dark: dark);
        await tester.scrollUntilVisible(
          find.text(failure),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.text(failure),
          findsOneWidget,
          reason: '${page.runtimeType}',
        );
        await scrollAll(tester);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    });
  }

  for (final dark in [false, true]) {
    for (final mode in ['empty', 'populated', 'error']) {
      testWidgets(
        'all recommendation tools fit 320px / 200%, dark=$dark mode=$mode',
        (tester) async {
          final controller = Get.find<RecommendationsController>();
          const item = ItemModel(
            id: 'piece',
            userId: 'user',
            name: 'Relaxed cotton shirt',
            category: Category.tops,
            condition: domain.Condition.clean,
          );
          if (mode != 'empty') {
            controller.availableItems.add(item);
            controller.selectedItems.add(item);
          }
          if (mode == 'populated') {
            controller.matchingItems.add({
              'name': 'Relaxed cotton shirt',
              'category': 'tops',
              'score': .98,
              'brand': 'Your wardrobe',
            });
            Get.find<CompleteLookController>().completeLooks.add({
              'description': 'A complete look for your weekend',
              'match_score': 98,
              'items': <ItemModel>[item],
            });
            controller.weatherData.value = {
              'condition': 'partly cloudy',
              'temperature': 24,
            };
            controller.weatherLocation.value = 'San Francisco, California';
            controller.weatherRecommendations.add(item);
            controller.shoppingRecommendations.add({
              'category': 'outerwear',
              'description': 'A comfortable layer for cool mornings',
              'priority': 'high',
              'would_complete': 10,
              'estimated_cpw': 2.4,
            });
            controller.astrologyData.value = {
              'status': 'ready',
              'lucky_colors': [
                {
                  'name': 'Forest green',
                  'reason': 'A calm color for your important meeting',
                },
              ],
              'suggested_outfits': [
                {
                  'description': 'Comfortable clothes for a busy day',
                  'match_score': 98,
                },
              ],
            };
          } else if (mode == 'error') {
            controller.itemsError.value =
                'Your closet could not be loaded. Check your connection and try again.';
            for (final error in [
              controller.matchesError,
              controller.completeLookError,
              controller.weatherError,
              controller.shoppingError,
              controller.astrologyError,
            ]) {
              error.value = 'Connection failed. Please try again.';
            }
          }
          await pump(tester, const RecommendationsPage(), dark: dark);
          for (var tab = 0; tab < 5; tab++) {
            controller.tabController.index = tab;
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await scrollAll(tester);
            if (tab == 1 && mode == 'populated') {
              expect(
                find.text('A complete look for your weekend'),
                findsOneWidget,
              );
            }
          }
        },
      );
    }
  }
}
