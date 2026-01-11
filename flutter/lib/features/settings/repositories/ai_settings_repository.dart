import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/ai_settings_model.dart';

class AiSettingsRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<AiSettingsModel> getSettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.aiSettings);
      final data = _extractDataMap(response.data);
      return AiSettingsModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<AiSettingsModel> updateSettings({
    String? defaultProvider,
    Map<String, dynamic>? providerConfigs,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (defaultProvider != null && defaultProvider.isNotEmpty) {
        payload['default_provider'] = defaultProvider;
      }
      if (providerConfigs != null && providerConfigs.isNotEmpty) {
        payload['provider_configs'] = providerConfigs;
      }
      final response = await _apiClient.put(
        ApiConstants.aiSettings,
        data: payload,
      );
      final data = _extractDataMap(response.data);
      return AiSettingsModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<AiProviderTestResult> testProvider({
    required String apiUrl,
    required String apiKey,
    required String model,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.aiSettings}/test',
        data: {
          'api_url': apiUrl,
          'api_key': apiKey,
          'model': model,
        },
      );
      final data = _extractDataMap(response.data);
      return AiProviderTestResult.fromJson(data);
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
      return payload;
    }
    return <String, dynamic>{};
  }
}
