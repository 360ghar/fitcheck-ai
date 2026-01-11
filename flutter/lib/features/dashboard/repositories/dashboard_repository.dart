import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<DashboardData> fetchDashboard() async {
    try {
      final response = await _apiClient.get('${ApiConstants.users}/dashboard');
      final data = _extractDataMap(response.data);
      return DashboardData.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<StreakData> fetchStreak() async {
    try {
      final response = await _apiClient.get('${ApiConstants.gamification}/streak');
      final data = _extractDataMap(response.data);
      return StreakData.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Map<String, dynamic> _extractDataMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return const <String, dynamic>{};
  }

}
