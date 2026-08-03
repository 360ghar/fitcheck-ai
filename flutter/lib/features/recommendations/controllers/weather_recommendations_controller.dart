import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/utils/error_handler.dart';
import '../../settings/models/user_preferences_model.dart';
import '../../settings/repositories/settings_repository.dart';
import '../../wardrobe/models/item_model.dart';
import '../repositories/recommendations_repository.dart';
import '../../../core/utils/frame_safe.dart';

/// Controller for Weather-Based Recommendations tab
/// Manages weather data and clothing recommendations
class WeatherRecommendationsController extends GetxController {
  WeatherRecommendationsController({
    RecommendationsRepository? repository,
    SettingsRepository? settingsRepository,
  })  : _repository = repository ?? RecommendationsRepository(),
        _settingsRepository = settingsRepository ?? SettingsRepository();

  final RecommendationsRepository _repository;
  final SettingsRepository _settingsRepository;

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString location = ''.obs;
  final Rx<Map<String, dynamic>?> weatherData = Rx<Map<String, dynamic>?>(null);
  final RxList<String> preferredCategories = <String>[].obs;
  final RxList<ItemModel> recommendations = <ItemModel>[].obs;

  /// Display unit for temperatures. The weather API reports Celsius, so a
  /// Fahrenheit preference is converted on display. Defaults to Celsius,
  /// matching the app's default preference and the API.
  final Rx<TemperatureUnit> temperatureUnit = TemperatureUnit.celsius.obs;

  /// Backs the tab's location field. Owned here so the saved default is
  /// actually visible in the input rather than being an invisible value the
  /// user gets searched on without knowing.
  final TextEditingController locationInput = TextEditingController();

  /// Completes once the saved location has been read, so a fetch triggered
  /// before that lands can wait instead of seeing an empty location.
  Future<void>? _locationSeed;

  @override
  void onInit() {
    super.onInit();
    _locationSeed = _loadUserLocation();
  }

  @override
  void onClose() {
    locationInput.dispose();
    super.onClose();
  }

  Future<void> _loadUserLocation() async {
    // This controller is first resolved from inside an Obx (weather_based_tab),
    // so onInit can run mid-frame. Settle first rather than deferring just the
    // write, so the returned future still means "location is set" — callers
    // (and fetchRecommendations' `location.value.isEmpty` guard) depend on that.
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      final settings = await _settingsRepository.getSettings();
      if (isClosed) return;
      final saved = (settings['default_location'] as String?)?.trim() ?? '';
      if (saved.isNotEmpty) {
        location.value = saved;
        locationInput.text = saved;
      }
    } catch (e) {
      // A missing saved location is not an error worth interrupting the user
      // for — the field simply stays empty and fetchRecommendations asks for
      // one. Report it so the failure is not invisible to us.
      ErrorHandler.reportError(e, 'Failed to load saved weather location');
    }

    // Load the user's temperature-unit preference so the tab renders °C / °F
    // consistently with Settings. Non-fatal: the API reports Celsius, which is
    // the fallback unit.
    try {
      final prefs = await _settingsRepository.getPreferences();
      if (isClosed) return;
      final unit = prefs.temperatureUnit;
      if (unit != null) temperatureUnit.value = unit;
    } catch (e) {
      ErrorHandler.reportError(e, 'Failed to load temperature unit preference');
    }
  }

  /// Update location and fetch recommendations
  void updateLocation(String newLocation) {
    location.value = newLocation;
    fetchRecommendations([]);
  }

  /// Fetch weather-based recommendations
  Future<void> fetchRecommendations(List<ItemModel> availableItems) async {
    // The seed reads user settings over the network, so a tap that beats it
    // used to hit `location.isEmpty` and return silently — no spinner, no
    // error, a blank tab. Wait for it, then ask if there is still nothing.
    await _locationSeed;
    if (isClosed) return;
    if (location.value.trim().isEmpty) {
      error.value = 'Enter your city to get weather-based recommendations.';
      return;
    }

    isLoading.value = true;
    error.value = '';
    recommendations.clear();
    preferredCategories.clear();

    try {
      final result = await _repository.getWeatherRecommendations(
        location: location.value,
      );

      final condition = result['weather_state'] ?? result['condition'];
      weatherData.value = {
        ...result,
        if (condition != null) 'condition': condition,
      };

      // Parse weather data
      final temperature = result['temperature'] as num? ?? 70;

      // Determine preferred categories based on weather
      final recommended = (result['preferred_categories'] as List?)
          ?.map((e) => e.toString())
          .toList();

      // The backend reports Celsius and derives preferred_categories from
      // Celsius thresholds; mirror those thresholds so a client-side fallback
      // agrees with what the server would have returned.
      if (recommended != null && recommended.isNotEmpty) {
        preferredCategories.value = recommended;
      } else if (temperature < 5) {
        preferredCategories.value = [
          'outerwear',
          'tops',
          'bottoms',
          'shoes',
          'accessories',
        ];
      } else if (temperature < 12) {
        preferredCategories.value = ['outerwear', 'tops', 'bottoms', 'shoes'];
      } else if (temperature < 27) {
        preferredCategories.value = ['tops', 'bottoms', 'shoes'];
      } else {
        preferredCategories.value = ['tops', 'bottoms', 'shoes', 'accessories'];
      }

      // Get items from preferred categories
      if (availableItems.isNotEmpty) {
        recommendations.value = availableItems
            .where((item) => preferredCategories.contains(item.category.name))
            .take(10)
            .toList();
      }
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Whether temperatures should render in Fahrenheit (user preference).
  /// The API reports Celsius, so Fahrenheit values are converted on display.
  bool get isFahrenheit => temperatureUnit.value == TemperatureUnit.fahrenheit;

  /// Temperature with its unit, honoring the user's unit preference.
  /// Returns '--' before weather data has loaded.
  String get displayTemperature {
    final raw = weatherData.value?['temperature'];
    if (raw is! num) return '--';
    if (isFahrenheit) {
      return '${(raw * 9 / 5 + 32).round()} F';
    }
    return '${raw.round()} C';
  }

  /// Get weather description
  String get weatherDescription {
    if (weatherData.value == null) return '';

    final condition = weatherData.value!['condition'] ?? 'Unknown';
    final temp = displayTemperature;
    if (temp != '--') {
      return '$condition, $temp';
    }
    return condition.toString();
  }

  /// Get weather icon
  String get weatherIcon {
    final condition =
        weatherData.value?['condition']?.toString().toLowerCase() ?? '';

    if (condition.contains('rain')) return '🌧️';
    if (condition.contains('cloud')) return '☁️';
    if (condition.contains('sun') || condition.contains('clear')) return '☀️';
    if (condition.contains('snow')) return '❄️';
    if (condition.contains('wind')) return '💨';
    return '🌡️';
  }

  /// Clear results
  void clearResults() {
    recommendations.clear();
    weatherData.value = null;
    preferredCategories.clear();
    error.value = '';
  }
}
