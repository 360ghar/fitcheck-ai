import 'dart:async';

import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/domain/enums/category.dart';
import 'package:fitcheck_ai/domain/enums/condition.dart' as domain;
import 'package:fitcheck_ai/features/recommendations/providers/recommendations_providers.dart';
import 'package:fitcheck_ai/features/recommendations/repositories/recommendations_repository.dart';
import 'package:fitcheck_ai/features/recommendations/widgets/complete_look_tab.dart';
import 'package:fitcheck_ai/features/settings/models/user_preferences_model.dart';
import 'package:fitcheck_ai/features/settings/providers/settings_provider.dart';
import 'package:fitcheck_ai/features/settings/repositories/settings_repository.dart';
import 'package:fitcheck_ai/features/wardrobe/models/item_model.dart';
import 'package:fitcheck_ai/features/wardrobe/providers/wardrobe_providers.dart';
import 'package:fitcheck_ai/features/wardrobe/repositories/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ItemModel piece(String id, [Category c = Category.tops]) => ItemModel(
  id: id,
  userId: 'u',
  name: 'Piece $id',
  category: c,
  condition: domain.Condition.clean,
);

/// Serves [settings] after an optional delay, so a fetch can race the seed.
class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository(this.settings, {this.delay = Duration.zero});

  final Map<String, dynamic> settings;
  final Duration delay;

  @override
  Future<Map<String, dynamic>> getSettings() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return settings;
  }

  @override
  Future<UserPreferencesModel> getPreferences() async =>
      UserPreferencesModel(temperatureUnit: TemperatureUnit.celsius);
}

class FakeItemRepository extends ItemRepository {
  FakeItemRepository([this.items = const []]);

  final List<ItemModel> items;

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
    items: items,
    total: items.length,
    page: page,
    limit: limit,
    hasMore: false,
  );
}

class FakeRecommendationsRepository extends RecommendationsRepository {
  final locations = <String>[];
  final matchRequests = <List<String>>[];
  final lookGates = <Completer<Map<String, dynamic>>>[];

  @override
  Future<Map<String, dynamic>> getWeatherRecommendations({
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    locations.add(location);
    return {'temperature': 16, 'weather_state': 'clear  sky'};
  }

  @override
  Future<Map<String, dynamic>> findMatchingItems(List<String> itemIds) async {
    matchRequests.add(itemIds);
    return {
      'matches': [
        {
          'item': {'name': 'Grey trousers', 'category': 'bottoms'},
          'score': 88,
          'reasons': ['Neutral base'],
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getCompleteLookSuggestions({
    required List<String> itemIds,
    String? style,
    String? season,
    String? occasion,
  }) {
    if (lookGates.isNotEmpty) return lookGates.removeAt(0).future;
    return Future.value(look('Weekend in the park'));
  }

  static Map<String, dynamic> look(String description) => {
    'complete_looks': [
      {
        'description': description,
        'match_score': 81,
        'items': [
          {'id': 'x', 'name': 'White sneakers', 'category': 'shoes'},
        ],
      },
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeRecommendationsRepository recs;

  ProviderContainer make({
    Map<String, dynamic> settings = const {},
    Duration delay = Duration.zero,
  }) {
    recs = FakeRecommendationsRepository();
    final container = ProviderContainer(
      retry: noRetry,
      overrides: [
        recommendationsRepositoryProvider.overrideWithValue(recs),
        itemRepositoryProvider.overrideWithValue(
          FakeItemRepository([piece('a'), piece('b', Category.bottoms)]),
        ),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(settings, delay: delay),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('capitalizeWords', () {
    test('handles empty and repeated spaces without a RangeError', () {
      expect(capitalizeWords(''), '');
      expect(capitalizeWords('  '), '');
      expect(capitalizeWords('light  rain'), 'Light Rain');
      expect(capitalizeWords(' partly cloudy '), 'Partly Cloudy');
      expect(capitalizeWords('rain_jacket'), 'Rain Jacket');
    });
  });

  group('weather', () {
    test('uses the saved default_location, not a hardcoded city', () async {
      final c = make(settings: {'default_location': 'Jaipur'});
      c.listen(weatherProvider, (_, _) {});
      final report = await c.read(weatherProvider.future);

      expect(recs.locations, ['Jaipur']);
      expect(report!.location, 'Jaipur');
      expect(report.displayTemperature, 16);
      // Only tops, bottoms and shoes suit 16 C.
      expect(report.items.map((i) => i.id), ['a', 'b']);
    });

    test('a search that races the settings load still resolves', () async {
      final c = make(
        settings: {'default_location': 'Lisbon'},
        delay: const Duration(milliseconds: 40),
      );
      c.listen(weatherProvider, (_, _) {});
      final sent = await c.read(weatherProvider.notifier).search('Porto');
      await c.read(weatherProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(sent, isTrue);
      expect(recs.locations, containsAll(['Porto', 'Lisbon']));
      expect(c.read(weatherProvider).hasError, isFalse);
    });

    test('with no city it sends nothing and asks for one', () async {
      final c = make();
      c.listen(weatherProvider, (_, _) {});
      expect(await c.read(weatherProvider.future), isNull);

      final sent = await c.read(weatherProvider.notifier).search('  ');

      expect(sent, isFalse);
      expect(recs.locations, isEmpty);
      expect(c.read(weatherProvider).isLoading, isFalse);
    });
  });

  group('find matches', () {
    test('quick selection changes send one request', () async {
      final c = make();
      c.listen(findMatchesProvider, (_, _) {});
      final selection = c.read(recommendationSelectionProvider.notifier);
      selection.toggle(piece('a'));
      selection.toggle(piece('b'));
      selection.toggle(piece('c'));

      final matches = await c.read(findMatchesProvider.future);

      expect(recs.matchRequests, [
        ['a', 'b', 'c'],
      ]);
      expect(matches.single.name, 'Grey trousers');
      expect(matches.single.score, closeTo(0.88, 0.001));
    });

    test('a fourth piece is refused', () {
      final c = make();
      c.listen(recommendationSelectionProvider, (_, _) {});
      final selection = c.read(recommendationSelectionProvider.notifier);
      for (final id in ['a', 'b', 'c']) {
        expect(selection.toggle(piece(id)), isTrue);
      }
      expect(selection.toggle(piece('d')), isFalse);
      expect(c.read(recommendationSelectionProvider), hasLength(3));
    });
  });

  group('complete look', () {
    test('an older response never overwrites a newer one', () async {
      final c = make();
      c.listen(completeLookProvider, (_, _) {});
      await c.read(completeLookProvider.future);
      c.read(recommendationSelectionProvider.notifier).toggle(piece('a'));
      final first = Completer<Map<String, dynamic>>();
      final second = Completer<Map<String, dynamic>>();
      recs.lookGates.addAll([first, second]);
      final notifier = c.read(completeLookProvider.notifier);

      final a = notifier.generate(style: 'casual');
      final b = notifier.generate(style: 'formal');
      second.complete(FakeRecommendationsRepository.look('Formal'));
      await b;
      first.complete(FakeRecommendationsRepository.look('Casual'));
      await a;

      expect(c.read(completeLookProvider).value!.single.description, 'Formal');
    });

    testWidgets('the Complete a look tab shows the looks it generates', (
      tester,
    ) async {
      final c = make();
      c.listen(recommendationSelectionProvider, (_, _) {});
      c.read(recommendationSelectionProvider.notifier).toggle(piece('a'));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: Scaffold(body: CompleteLookTab()),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Generate'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Weekend in the park'), findsOneWidget);
      expect(find.text('81% match'), findsOneWidget);
      expect(find.text('White sneakers'), findsOneWidget);
    });
  });
}
