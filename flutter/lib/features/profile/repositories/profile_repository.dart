import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Repository for user profile API calls
class ProfileRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get('${ApiConstants.users}/me');
      return _extractData(response.data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update user profile (full_name, avatar_url, gender)
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? gender,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (gender != null) data['gender'] = gender;
      if (birthDate != null) data['birth_date'] = birthDate;
      if (birthTime != null) data['birth_time'] = birthTime;
      if (birthPlace != null) data['birth_place'] = birthPlace;

      final response = await _apiClient.put(
        '${ApiConstants.users}/me',
        data: data,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Upload avatar image
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final response = await _apiClient.upload(
        '${ApiConstants.users}/me/avatar',
        imageFile,
      );
      final data = _extractData(response.data);
      return data['avatar_url'] as String;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
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
