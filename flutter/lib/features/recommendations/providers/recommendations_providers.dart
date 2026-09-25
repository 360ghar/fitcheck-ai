import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../domain/enums/category.dart';
import '../../settings/models/user_preferences_model.dart';
import '../../settings/providers/settings_provider.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/providers/wardrobe_providers.dart';
import '../repositories/recommendations_repository.dart';
import '../utils/item_json.dart';

final recommendationsRepositoryProvider = Provider<RecommendationsRepository>(
  (ref) => RecommendationsRepository(),
);

/// Closet pieces for the "pick a piece" sheet: at most [_maxPickerPages]
/// pages of 100, loaded once per page session. `ref.invalidate` retries.
// ponytail: capped at 300 pieces; add search in the sheet if closets grow past it.
const _maxPickerPages = 3;

final recommendationPickerItemsProvider =
    FutureProvider.autoDispose<List<ItemModel>>((ref) async {
      final repository = ref.read(itemRepositoryProvider);
      final items = <ItemModel>[];
      for (var page = 1; page <= _maxPickerPages; page++) {
        final response = await repository.getItems(page: page, limit: 100);
        items.addAll(response.items);
        if (!response.hasMore) break;
      }
      return items;
    });

/// Up to [maxPieces] closet pieces that Find matches and Complete a look
/// start from.
final recommendationSelectionProvider =
    NotifierProvider.autoDispose<RecommendationSelection, List<ItemModel>>(
      RecommendationSelection.new,
    );

class RecommendationSelection extends Notifier<List<ItemModel>> {
  static const maxPieces = 3;

  @override
  List<ItemModel> build() => const [];

  bool contains(String id) => state.any((i) => i.id == id);

  /// Adds or removes [item]. Returns false when the selection is full.
  bool toggle(ItemModel item) {
    if (contains(item.id)) {
      state = [
        for (final i in state)
          if (i.id != item.id) i,
      ];
      return true;
    }
    if (state.length >= maxPieces) return false;
    state = [...state, item];
    return true;
  }

  void clear() => state = const [];
}

/// Capitalises each word. Safe for empty strings and repeated spaces.
String capitalizeWords(String value) => value
    .split(RegExp(r'[\s_]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

// ---------------------------------------------------------------------------
// Find matches

@immutable
class RecommendationMatch {
  const RecommendationMatch({
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.storagePath,
    this.score = 0,
    this.reason,
  });

  final String name;
  final String? brand;
  final Category? category;
  final String? imageUrl;
  final String? storagePath;

  /// 0 to 1.
  final double score;
  final String? reason;

  factory RecommendationMatch.fromJson(Map<String, dynamic> match) {
    final item = match['item'] is Map
        ? Map<String, dynamic>.from(match['item'] as Map)
        : <String, dynamic>{};
    final image = _imageOf(item);
    final raw = match['score'];
    final score = raw is num ? raw : num.tryParse('$raw') ?? 0;
    final reasons = match['reasons'];
    final category = item['category']?.toString().toLowerCase();
    return RecommendationMatch(
      name: item['name']?.toString() ?? 'Unnamed piece',
      brand: item['brand']?.toString(),
      category: category == null ? null : Category.fromString(category),
      imageUrl: image.$1,
      storagePath: image.$2,
      score: (score / 100).clamp(0.0, 1.0).toDouble(),
      reason: reasons is List && reasons.isNotEmpty
          ? reasons.first.toString()
          : null,
    );
  }

  /// Full-size URL first: a derived `_thumb` URL is not guaranteed to exist.
  static (String?, String?) _imageOf(Map<String, dynamic> item) {
    for (final key in ['images', 'item_images']) {
      final images = item[key];
      if (images is! List || images.isEmpty) continue;
      final maps = images.whereType<Map>().toList();
      if (maps.isEmpty) continue;
      final first = maps.firstWhere(
        (m) => m['is_primary'] == true,
        orElse: () => maps.first,
      );
      final url =
          first['image_url']?.toString() ??
          first['url']?.toString() ??
          first['thumbnail_url']?.toString();
      if (url != null && url.isNotEmpty) {
        return (url, first['storage_path']?.toString());
      }
    }
    final flat = item['image_url']?.toString();
    return (flat == null || flat.isEmpty ? null : flat, null);
  }
}

/// Matches for the current selection. A selection change waits
/// [AppConstants.searchDebounceDuration] before it sends a request, so quick
/// taps send one request; a newer selection drops older results.
final findMatchesProvider =
    FutureProvider.autoDispose<List<RecommendationMatch>>((ref) async {
      final selection = ref.watch(recommendationSelectionProvider);
      if (selection.isEmpty) return const [];
      await Future<void>.delayed(AppConstants.searchDebounceDuration);
      if (!ref.mounted) return const [];
      final result = await ref
          .read(recommendationsRepositoryProvider)
          .findMatchingItems([for (final i in selection) i.id]);
      return [
        for (final m in (result['matches'] as List? ?? const []))
          if (m is Map)
            RecommendationMatch.fromJson(Map<String, dynamic>.from(m)),
      ];
    });

// ---------------------------------------------------------------------------
// Request-driven tabs

/// A tab whose results come from an explicit action. State is null until the
/// first request. A newer request, or a rebuild, drops the result of an
/// older one; a failed request keeps the previous results for a banner.
abstract class RequestNotifier<T> extends AsyncNotifier<T?> {
  int _request = 0;
  Future<T> Function()? _last;

  @override
  Future<T?> build() async {
    _request++;
    _last = null;
    return null;
  }

  @protected
  Future<void> run(Future<T> Function() load) async {
    final id = ++_request;
    _last = load;
    state = const AsyncLoading();
    final next = await AsyncValue.guard(load);
    if (!ref.mounted || id != _request) return;
    state = next;
  }

  /// Repeats the last request, or reruns [build] before the first one.
  Future<void> retry() async {
    final last = _last;
    if (last != null) return run(last);
    ref.invalidateSelf();
    await future;
  }
}

@immutable
class CompleteLook {
  const CompleteLook({required this.items, this.score, this.description});

  final List<ItemModel> items;
  final num? score;
  final String? description;
}

/// Looks that complete the current selection. A selection change clears
/// them.
final completeLookProvider =
    AsyncNotifierProvider.autoDispose<
      CompleteLookNotifier,
      List<CompleteLook>?
    >(CompleteLookNotifier.new);

class CompleteLookNotifier extends RequestNotifier<List<CompleteLook>> {
  @override
  Future<List<CompleteLook>?> build() {
    ref.watch(recommendationSelectionProvider);
    return super.build();
  }

  Future<void> generate({String? style}) async {
    final ids = [
      for (final i in ref.read(recommendationSelectionProvider)) i.id,
    ];
    if (ids.isEmpty) return;
    final repository = ref.read(recommendationsRepositoryProvider);
    await run(() async {
      final result = await repository.getCompleteLookSuggestions(
        itemIds: ids,
        style: style,
      );
      return [
        for (final look in (result['complete_looks'] as List? ?? const []))
          if (look is Map)
            CompleteLook(
              items: [
                for (final item in (look['items'] as List? ?? const []))
                  if (item is Map)
                    itemModelFromRecommendationJson(
                      Map<String, dynamic>.from(item),
                    ),
              ],
              score: look['match_score'] as num?,
              description: look['description']?.toString(),
            ),
      ];
    });
  }
}

@immutable
class WeatherReport {
  const WeatherReport({
    required this.location,
    required this.condition,
    required this.categories,
    required this.items,
    this.temperature,
    this.unit = TemperatureUnit.celsius,
  });

  final String location;
  final String condition;

  /// Celsius, as the API reports it.
  final num? temperature;
  final TemperatureUnit unit;
  final List<String> categories;
  final List<ItemModel> items;

  /// Rounded temperature in the user's unit.
  int? get displayTemperature {
    final t = temperature;
    if (t == null) return null;
    return unit == TemperatureUnit.fahrenheit
        ? (t * 9 / 5 + 32).round()
        : t.round();
  }

  String get unitLabel => unit == TemperatureUnit.fahrenheit ? '°F' : '°C';
}

/// The saved city and temperature unit. Each part falls back quietly.
final weatherSetupProvider =
    FutureProvider.autoDispose<({String location, TemperatureUnit unit})>((
      ref,
    ) async {
      final settings = ref.read(settingsRepositoryProvider);
      var location = '';
      var unit = TemperatureUnit.celsius;
      try {
        final saved = await settings.getSettings();
        location = (saved['default_location'] as String?)?.trim() ?? '';
      } catch (e, stack) {
        ErrorHandler.reportError(
          e,
          'Weather location not loaded',
          stackTrace: stack,
        );
      }
      try {
        unit = (await settings.getPreferences()).temperatureUnit ?? unit;
      } catch (e, stack) {
        ErrorHandler.reportError(
          e,
          'Temperature unit not loaded',
          stackTrace: stack,
        );
      }
      return (location: location, unit: unit);
    });

/// Weather and pieces for it. Loads for the saved city on open; [search]
/// checks another city.
final weatherProvider =
    AsyncNotifierProvider.autoDispose<WeatherNotifier, WeatherReport?>(
      WeatherNotifier.new,
    );

class WeatherNotifier extends RequestNotifier<WeatherReport> {
  @override
  Future<WeatherReport?> build() async {
    await super.build();
    final setup = await ref.watch(weatherSetupProvider.future);
    if (setup.location.isEmpty) return null;
    return _load(setup.location);
  }

  /// Returns false, and sends nothing, when [location] is blank.
  Future<bool> search(String location) async {
    final city = location.trim();
    if (city.isEmpty) {
      ErrorHandler.showValidation(
        'Enter your city to get picks for the weather.',
        title: 'Which city?',
      );
      return false;
    }
    await run(() => _load(city));
    return true;
  }

  Future<WeatherReport> _load(String location) async {
    final repository = ref.read(recommendationsRepositoryProvider);
    final setup = await ref.read(weatherSetupProvider.future);
    final result = await repository.getWeatherRecommendations(
      location: location,
    );
    final temperature = result['temperature'] as num?;
    final categories = [
      for (final c in (result['preferred_categories'] as List? ?? const []))
        c.toString(),
    ];
    if (categories.isEmpty) categories.addAll(_fallbackCategories(temperature));

    // The closet is optional here: without it the tab still shows weather.
    var closet = const <ItemModel>[];
    try {
      closet = await ref.read(recommendationPickerItemsProvider.future);
    } catch (e, stack) {
      ErrorHandler.reportError(
        e,
        'Closet not loaded for weather',
        stackTrace: stack,
      );
    }
    return WeatherReport(
      location: location,
      condition: (result['weather_state'] ?? result['condition'] ?? '')
          .toString(),
      temperature: temperature,
      unit: setup.unit,
      categories: categories,
      items: closet
          .where((i) => categories.contains(i.category.name))
          .take(10)
          .toList(),
    );
  }

  /// Mirrors the backend's Celsius thresholds.
  static List<String> _fallbackCategories(num? celsius) {
    final t = celsius ?? 20;
    if (t < 5) return ['outerwear', 'tops', 'bottoms', 'shoes', 'accessories'];
    if (t < 12) return ['outerwear', 'tops', 'bottoms', 'shoes'];
    if (t < 27) return ['tops', 'bottoms', 'shoes'];
    return ['tops', 'bottoms', 'shoes', 'accessories'];
  }
}

/// Pieces to buy for gaps in the closet.
final shoppingProvider =
    AsyncNotifierProvider.autoDispose<
      ShoppingNotifier,
      List<Map<String, dynamic>>?
    >(ShoppingNotifier.new);

class ShoppingNotifier extends RequestNotifier<List<Map<String, dynamic>>> {
  Future<void> fetch({
    String? category,
    String? style,
    required double budget,
  }) {
    final repository = ref.read(recommendationsRepositoryProvider);
    final analytics = AnalyticsService.instance;
    return run(() async {
      analytics.track(
        'shopping_recommendations_requested',
        properties: {
          'category': category ?? 'all',
          'style': style ?? 'all',
          'max_budget': budget,
          'source': 'flutter_app',
        },
      );
      try {
        final result = await repository.getShoppingRecommendations(
          category: category,
          style: style,
          maxBudget: budget,
        );
        final list = result.whereType<Map<String, dynamic>>().toList();
        analytics.track(
          'shopping_recommendations_loaded',
          properties: {
            'recommendation_count': list.length,
            'category': category ?? 'all',
            'source': 'flutter_app',
          },
        );
        return list;
      } catch (e) {
        analytics.track(
          'shopping_recommendations_failed',
          properties: {
            'error_message': ErrorHandler.extractMessage(e),
            'source': 'flutter_app',
          },
        );
        rethrow;
      }
    });
  }
}

/// Lucky colours and closet picks for a day.
final astrologyProvider =
    AsyncNotifierProvider.autoDispose<AstrologyNotifier, Map<String, dynamic>?>(
      AstrologyNotifier.new,
    );

class AstrologyNotifier extends RequestNotifier<Map<String, dynamic>> {
  Future<void> fetch({required String mode, required DateTime date}) {
    final repository = ref.read(recommendationsRepositoryProvider);
    return run(
      () => repository.getAstrologyRecommendations(
        targetDate: date.toIso8601String().split('T').first,
        mode: mode,
      ),
    );
  }
}
