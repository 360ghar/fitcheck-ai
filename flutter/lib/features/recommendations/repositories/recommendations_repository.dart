import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Recommendations repository
class RecommendationsRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Map<String, dynamic> _extractDataMap(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) {
      return <String, dynamic>{};
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  /// Find matching items for selected items
  Future<Map<String, dynamic>> findMatchingItems(List<String> itemIds) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.recommendations}/match',
        data: {'item_ids': itemIds},
      );
      return _extractDataMap(response);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get complete look suggestions
  Future<Map<String, dynamic>> getCompleteLookSuggestions({
    required List<String> itemIds,
    String? style,
    String? season,
    String? occasion,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.recommendations}/complete-look',
        data: {
          'item_ids': itemIds,
          if (season != null) 'season': season,
          if (occasion != null) 'occasion': occasion,
        },
        queryParameters: {if (style != null) 'style': style},
      );
      return _extractDataMap(response);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get weather-based recommendations
  Future<Map<String, dynamic>> getWeatherRecommendations({
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.recommendations}/weather',
        queryParameters: {
          'location': location,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
      return _extractDataMap(response);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get shopping recommendations
  Future<List<dynamic>> getShoppingRecommendations({
    String? category,
    String? style,
    double? maxBudget,
    List<String>? brands,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.recommendations}/shopping',
        queryParameters: {
          if (category != null) 'category': category,
          if (style != null) 'style': style,
          if (maxBudget != null) 'budget': maxBudget,
          if (brands != null) 'brands': brands,
        },
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is List) {
        return data;
      }
      return const <dynamic>[];
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get astrology-based color recommendations
  Future<Map<String, dynamic>> getAstrologyRecommendations({
    required String targetDate,
    String mode = 'daily',
    int limitPerCategory = 4,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.recommendations}/astrology',
        queryParameters: {
          'target_date': targetDate,
          'mode': mode,
          'limit_per_category': limitPerCategory,
        },
      );
      return _extractDataMap(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
          'Astrology API is not available on the current backend deployment. Please update the backend service.',
        );
      }
      throw handleDioException(e);
    }
  }
}
