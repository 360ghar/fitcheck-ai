import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/feedback_model.dart';

/// Repository for feedback API operations
class FeedbackRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Submit feedback with optional attachments
  Future<FeedbackResponse> submitFeedback({
    required TicketCategory category,
    required String subject,
    required String description,
    String? contactEmail,
    List<File>? attachments,
  }) async {
    try {
      // Gather device info
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();

      final formData = FormData.fromMap({
        'category': _categoryToString(category),
        'subject': subject,
        'description': description,
        if (contactEmail != null) 'contact_email': contactEmail,
        'device_info': deviceInfo.toJson().toString(),
        'app_version': packageInfo.version,
        'app_platform': Platform.isIOS ? 'ios' : 'android',
      });

      // Add attachments
      if (attachments != null) {
        for (final file in attachments) {
          formData.files.add(MapEntry(
            'attachments',
            await MultipartFile.fromFile(file.path),
          ));
        }
      }

      final response = await _apiClient.post(
        ApiConstants.feedback,
        data: formData,
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      return FeedbackResponse.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get user's tickets
  Future<List<TicketListItem>> getMyTickets({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.feedback}/my-tickets',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      final tickets = (data['tickets'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((t) => TicketListItem.fromJson(t))
              .toList() ??
          [];
      return tickets;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<DeviceInfo> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfoPlugin.androidInfo;
      return DeviceInfo(
        platform: 'android',
        osVersion: info.version.release,
        deviceModel: '${info.manufacturer} ${info.model}',
      );
    } else if (Platform.isIOS) {
      final info = await deviceInfoPlugin.iosInfo;
      return DeviceInfo(
        platform: 'ios',
        osVersion: info.systemVersion,
        deviceModel: info.model,
      );
    }

    return const DeviceInfo(platform: 'unknown');
  }

  String _categoryToString(TicketCategory category) {
    switch (category) {
      case TicketCategory.bugReport:
        return 'bug_report';
      case TicketCategory.featureRequest:
        return 'feature_request';
      case TicketCategory.generalFeedback:
        return 'general_feedback';
      case TicketCategory.supportRequest:
        return 'support_request';
    }
  }
}
