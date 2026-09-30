@Tags(['golden'])
library;

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/calendar/models/calendar_connection_model.dart';
import 'package:fitcheck_ai/features/calendar/models/calendar_event_model.dart';
import 'package:fitcheck_ai/features/calendar/providers/calendar_providers.dart';
import 'package:fitcheck_ai/features/calendar/repositories/calendar_repository.dart';
import 'package:fitcheck_ai/features/calendar/views/calendar_page.dart';
import 'package:fitcheck_ai/features/recommendations/providers/recommendations_providers.dart';
import 'package:fitcheck_ai/features/recommendations/repositories/recommendations_repository.dart';
import 'package:fitcheck_ai/features/recommendations/views/recommendations_page.dart';
import 'package:fitcheck_ai/features/settings/models/user_preferences_model.dart';
import 'package:fitcheck_ai/features/settings/providers/settings_provider.dart';
import 'package:fitcheck_ai/features/settings/repositories/settings_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_harness.dart';

ItemModel _piece(String id, String name, Category c) => ItemModel(
  id: id,
  userId: 'u',
  name: name,
  category: c,
  condition: domain.Condition.clean,
);

final _closet = [
  _piece('p1', 'Ecru oxford shirt', Category.tops),
  _piece('p2', 'Charcoal trousers', Category.bottoms),
  _piece('p3', 'Tobacco loafers', Category.shoes),
  _piece('p4', 'Wool overcoat', Category.outerwear),
];

const _serverError = ServerException(message: 'boom', statusCode: 500);

class _Items extends ItemRepository {
  @override
  Future<ItemsListResponse> getItems({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? categories,
    List<String>? colors,
    String? occasion,
    List<String>? conditions,
    bool? isFavorite,
    String? sortBy,
    String? sortOrder,
  }) async => ItemsListResponse(
    items: _closet,
    total: _closet.length,
    page: 1,
    limit: limit,
    hasMore: false,
  );
}

class _Settings extends SettingsRepository {
  @override
  Future<Map<String, dynamic>> getSettings() async => {
    'default_location': 'Lisbon',
  };

  @override
  Future<UserPreferencesModel> getPreferences() async =>
      UserPreferencesModel(temperatureUnit: TemperatureUnit.celsius);
}

class _Recs extends RecommendationsRepository {
  _Recs({this.fail = false});

  final bool fail;

  @override
  Future<Map<String, dynamic>> findMatchingItems(List<String> itemIds) async {
    if (fail) throw _serverError;
    return {
      'matches': [
        for (final (name, category, score) in [
          ('Charcoal trousers', 'bottoms', 92),
          ('Tobacco loafers', 'shoes', 87),
          ('Wool overcoat', 'outerwear', 74),
          ('Linen tote', 'accessories', 66),
        ])
          {
            'item': {'name': name, 'category': category},
            'score': score,
          },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getWeatherRecommendations({
    required String location,
    double? latitude,
    double? longitude,
  }) async => {'temperature': 9.4, 'weather_state': 'light  rain'};
}

class _Seeded extends RecommendationSelection {
  @override
  List<ItemModel> build() => [_closet.first];
}

class _Calendar extends CalendarRepository {
  _Calendar(this.events, {this.fail = false});

  final List<CalendarEventModel> events;
  final bool fail;

  @override
  Future<List<CalendarEventModel>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (fail) throw _serverError;
    return events;
  }

  @override
  Future<List<CalendarConnectionModel>> getConnections() async => [];
}

class _Month extends CalendarMonth {
  @override
  DateTime build() => DateTime(2026, 3);
}

class _Day extends CalendarSelectedDay {
  _Day(this.day);

  final int day;

  @override
  DateTime build() => DateTime(2026, 3, day);
}

CalendarEventModel _event(
  String id,
  String title,
  int day,
  int hour, {
  String? location,
  String? outfitId,
}) => CalendarEventModel(
  id: id,
  title: title,
  startTime: DateTime(2026, 3, day, hour),
  endTime: DateTime(2026, 3, day, hour + 1, 30),
  location: location,
  outfitId: outfitId,
);

final _events = [
  _event('e1', 'Coffee with Priya', 12, 9, location: 'Kaffeine, Fitzrovia'),
  _event(
    'e2',
    'Quarterly review',
    12,
    14,
    location: 'Office, 4th floor',
    outfitId: 'o1',
  ),
  _event('e3', 'Dinner at Lyle’s', 12, 19),
  _event('e4', 'Gallery opening', 18, 18),
  _event('e5', 'Wedding rehearsal', 27, 16),
];

void main() {
  setUpAll(loadAppFonts);

  final common = [
    itemRepositoryProvider.overrideWithValue(_Items()),
    settingsRepositoryProvider.overrideWithValue(_Settings()),
  ];

  final cases = <(String, Widget, List, bool)>[
    (
      'plan_matches',
      const RecommendationsPage(),
      [
        ...common,
        recommendationsRepositoryProvider.overrideWithValue(_Recs()),
        recommendationSelectionProvider.overrideWith(_Seeded.new),
      ],
      true,
    ),
    (
      'plan_matches_error',
      const RecommendationsPage(),
      [
        ...common,
        recommendationsRepositoryProvider.overrideWithValue(_Recs(fail: true)),
        recommendationSelectionProvider.overrideWith(_Seeded.new),
      ],
      false,
    ),
    (
      'plan_complete_look_empty',
      const RecommendationsPage(initialTab: 1),
      [...common, recommendationsRepositoryProvider.overrideWithValue(_Recs())],
      false,
    ),
    (
      'plan_weather',
      const RecommendationsPage(initialTab: 2),
      [...common, recommendationsRepositoryProvider.overrideWithValue(_Recs())],
      true,
    ),
    (
      'plan_calendar',
      const CalendarPage(),
      [
        calendarRepositoryProvider.overrideWithValue(_Calendar(_events)),
        calendarMonthProvider.overrideWith(_Month.new),
        calendarSelectedDayProvider.overrideWith(() => _Day(12)),
      ],
      true,
    ),
    (
      'plan_calendar_empty_day',
      const CalendarPage(),
      [
        calendarRepositoryProvider.overrideWithValue(_Calendar(_events)),
        calendarMonthProvider.overrideWith(_Month.new),
        calendarSelectedDayProvider.overrideWith(() => _Day(10)),
      ],
      false,
    ),
    (
      'plan_calendar_error',
      const CalendarPage(),
      [
        calendarRepositoryProvider.overrideWithValue(
          _Calendar(const [], fail: true),
        ),
        calendarMonthProvider.overrideWith(_Month.new),
        calendarSelectedDayProvider.overrideWith(() => _Day(12)),
      ],
      false,
    ),
  ];

  for (final (name, widget, overrides, withDark) in cases) {
    for (final dark in [false, true]) {
      if (dark && !withDark) continue;
      final file = '${name}_${dark ? 'dark' : 'light'}';
      testWidgets(file, (tester) async {
        await pumpPhone(
          tester,
          MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              disableAnimations: true,
            ),
            child: widget,
          ),
          dark: dark,
          overrides: overrides,
        );
        // Let the find-matches debounce and fake requests finish.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 100));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$file.png'),
        );
      });
    }
  }
}
