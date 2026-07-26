import 'package:fitcheck_ai/features/recommendations/controllers/astrology_recommendations_controller.dart';
import 'package:fitcheck_ai/features/recommendations/controllers/weather_recommendations_controller.dart';
import 'package:fitcheck_ai/features/recommendations/repositories/recommendations_repository.dart';
import 'package:fitcheck_ai/features/settings/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves whatever the test puts in [settings], after an optional delay so a
/// fetch can be made to race the seed.
class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository(this.settings, {this.delay = Duration.zero});

  final Map<String, dynamic> settings;
  final Duration delay;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> getSettings() async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return settings;
  }
}

class FakeRecommendationsRepository extends RecommendationsRepository {
  final List<String> locationsRequested = [];

  @override
  Future<Map<String, dynamic>> getWeatherRecommendations({
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    locationsRequested.add(location);
    return {'temperature': 60, 'condition': 'Clear'};
  }
}

void main() {
  group('WeatherRecommendationsController', () {
    test('uses the saved default_location, not a hardcoded city', () async {
      final settings = FakeSettingsRepository({'default_location': 'Jaipur'});
      final recs = FakeRecommendationsRepository();
      final c = WeatherRecommendationsController(
        repository: recs,
        settingsRepository: settings,
      )..onInit();

      await c.fetchRecommendations([]);

      expect(c.location.value, 'Jaipur');
      expect(recs.locationsRequested, ['Jaipur']);
      // The saved value must be visible in the field, not just held in state --
      // otherwise the user is searched on a city they never see.
      expect(c.locationInput.text, 'Jaipur');
      c.onClose();
    });

    test('a fetch that races the settings load still resolves, not silently',
        () async {
      final settings = FakeSettingsRepository(
        {'default_location': 'Lisbon'},
        delay: const Duration(milliseconds: 40),
      );
      final recs = FakeRecommendationsRepository();
      final c = WeatherRecommendationsController(
        repository: recs,
        settingsRepository: settings,
      )..onInit();

      // Fire immediately: pre-fix this hit `location.isEmpty` and returned with
      // no spinner, no error and no results -- a blank tab.
      await c.fetchRecommendations([]);

      expect(recs.locationsRequested, ['Lisbon']);
      expect(c.error.value, isEmpty);
      c.onClose();
    });

    test('with no saved location it asks for one instead of returning silently',
        () async {
      final settings = FakeSettingsRepository({});
      final recs = FakeRecommendationsRepository();
      final c = WeatherRecommendationsController(
        repository: recs,
        settingsRepository: settings,
      )..onInit();

      await c.fetchRecommendations([]);

      expect(recs.locationsRequested, isEmpty);
      expect(c.error.value, isNotEmpty,
          reason: 'a user-triggered fetch must never end in silence');
      expect(c.isLoading.value, isFalse);
      c.onClose();
    });
  });

  group('AstrologyRecommendationsController', () {
    test('targetDate is seeded at construction, so no fetch can race it', () {
      final c = AstrologyRecommendationsController();
      final today = DateTime.now().toIso8601String().split('T').first;
      expect(c.targetDate.value, today);
      c.onClose();
    });
  });
}
