import 'package:dio/dio.dart';
import '../models/body_profile_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Repository for body profile API calls
class BodyProfileRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all body profiles
  Future<List<BodyProfileModel>> getBodyProfiles() async {
    try {
      final response = await _apiClient.get('${ApiConstants.users}/body-profiles');
      final data = _extractData(response.data);
      final profiles = data['body_profiles'] as List? ?? [];
      return profiles
          .whereType<Map<String, dynamic>>()
          .map(BodyProfileModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create body profile
  Future<BodyProfileModel> createBodyProfile(CreateBodyProfileRequest request) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.users}/body-profiles',
        data: request.toJson(),
      );
      final data = _extractData(response.data);
      return BodyProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update body profile
  Future<BodyProfileModel> updateBodyProfile(
    String profileId,
    UpdateBodyProfileRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.users}/body-profiles/$profileId',
        data: request.toJson(),
      );
      final data = _extractData(response.data);
      return BodyProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Delete body profile
  Future<void> deleteBodyProfile(String profileId) async {
    try {
      await _apiClient.delete('${ApiConstants.users}/body-profiles/$profileId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Set profile as default
  Future<BodyProfileModel> setDefaultProfile(String profileId) async {
    return updateBodyProfile(profileId, const UpdateBodyProfileRequest(isDefault: true));
  }

  Map<String, dynamic> _extractData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    return <String, dynamic>{};
  }
}
