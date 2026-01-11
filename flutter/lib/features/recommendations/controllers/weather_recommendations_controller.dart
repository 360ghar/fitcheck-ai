import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../wardrobe/models/item_model.dart';
import '../repositories/recommendations_repository.dart';

/// Controller for Weather-Based Recommendations tab
/// Manages weather data and clothing recommendations
class WeatherRecommendationsController extends GetxController {
  final RecommendationsRepository _repository = RecommendationsRepository();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString location = ''.obs;
  final Rx<Map<String, dynamic>?> weatherData = Rx<Map<String, dynamic>?>(null);
  final RxList<String> preferredCategories = <String>[].obs;
  final RxList<ItemModel> recommendations = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    // Try to get user's saved location from settings
    location.value = 'San Francisco'; // Default
  }

  /// Update location and fetch recommendations
  void updateLocation(String newLocation) {
    location.value = newLocation;
    fetchRecommendations([]);
  }

  /// Fetch weather-based recommendations
  Future<void> fetchRecommendations(List<ItemModel> availableItems) async {
    if (location.value.isEmpty) return;

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

      if (recommended != null && recommended.isNotEmpty) {
        preferredCategories.value = recommended;
      } else if (temperature < 50) {
        preferredCategories.value = ['outerwear', 'tops', 'bottoms'];
      } else if (temperature < 70) {
        preferredCategories.value = ['tops', 'bottoms', 'outerwear'];
      } else if (temperature < 85) {
        preferredCategories.value = ['tops', 'bottoms', 'shoes', 'accessories'];
      } else {
        preferredCategories.value = ['tops', 'bottoms', 'shoes', 'activewear'];
      }

      // Get items from preferred categories
      if (availableItems.isNotEmpty) {
        recommendations.value = availableItems
            .where((item) => preferredCategories.contains(item.category.name))
            .take(10)
            .toList();
      }
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      NotificationService.instance.showError(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get weather description
  String get weatherDescription {
    if (weatherData.value == null) return '';

    final temp = weatherData.value!['temperature'];
    final condition = weatherData.value!['condition'] ?? 'Unknown';

    if (temp != null) {
      return '$condition, ${temp}°';
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
