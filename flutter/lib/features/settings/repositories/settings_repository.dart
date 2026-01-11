import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/user_preferences_model.dart';

/// Settings repository - handles all settings and preferences API calls
class SettingsRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get user preferences
  Future<UserPreferencesModel> getPreferences() async {
    try {
      final response = await _apiClient.get('${ApiConstants.users}/preferences');
      final data = _extractPreferenceData(response.data);
      return UserPreferencesModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update user preferences
  Future<UserPreferencesModel> updatePreferences(UserPreferencesModel preferences) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.users}/preferences',
        data: preferences.toJson(),
      );
      final data = _extractPreferenceData(response.data);
      return UserPreferencesModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get user settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _apiClient.get('${ApiConstants.users}/settings');
      final data = _extractSettingsData(response.data);
      return data;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update user settings
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.users}/settings',
        data: settings,
      );
      final data = _extractSettingsData(response.data);
      return data;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Map<String, dynamic> _extractPreferenceData(dynamic payload) {
    if (payload is Map) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      final preferences = payload['preferences'];
      if (preferences is Map<String, dynamic>) {
        return preferences;
      }
      if (payload is Map<String, dynamic>) {
        return payload;
      }
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractSettingsData(dynamic payload) {
    if (payload is Map) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      final settings = payload['settings'];
      if (settings is Map<String, dynamic>) {
        return settings;
      }
      if (payload is Map<String, dynamic>) {
        return payload;
      }
    }
    return <String, dynamic>{};
  }

  /// Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      await _apiClient.post(
        '${ApiConstants.users}/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('${ApiConstants.users}/me');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Request data export
  Future<String> requestDataExport() async {
    try {
      final response = await _apiClient.post('${ApiConstants.users}/export');
      return response.data['export_url'] as String;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

}
