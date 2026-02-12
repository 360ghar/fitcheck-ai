import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/sse_service.dart';
import '../models/social_import_models.dart';

class SocialImportRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SSEService _sseService = SSEService.instance;

  Future<SocialImportJobStartResponse> startJob({
    required String sourceUrl,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.aiSocialImportJobs,
        data: {'source_url': sourceUrl},
      );
      return SocialImportJobStartResponse.fromJson(
        _extractDataMap(response.data),
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<SocialImportJobData> getStatus(String jobId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.aiSocialImportStatus(jobId),
      );
      return SocialImportJobData.fromJson(_extractDataMap(response.data));
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Stream<SocialImportSSEEvent> subscribeToEvents(
    String jobId, {
    int? lastEventId,
  }) {
    final query = lastEventId != null ? '?last_event_id=$lastEventId' : '';
    final path = '${ApiConstants.aiSocialImportEvents(jobId)}$query';
    return _sseService
        .connect(
          path,
          terminalEvents: const {
            'job_completed',
            'job_failed',
            'job_cancelled',
          },
        )
        .map(
          (event) => SocialImportSSEEvent(
            type: event.type,
            data: event.data ?? const {},
            id: event.id,
          ),
        );
  }

  Future<SocialImportOAuthConnectResponse> getOAuthConnectUrl(
    String jobId, {
    String? mobileRedirectUri,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.aiSocialImportOAuthConnect(jobId),
        queryParameters: {
          if (mobileRedirectUri != null && mobileRedirectUri.isNotEmpty)
            'mobile_redirect_uri': mobileRedirectUri,
        },
      );
      return SocialImportOAuthConnectResponse.fromJson(
        _extractDataMap(response.data),
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> submitScraperLogin(
    String jobId, {
    required String username,
    required String password,
    String? otpCode,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.aiSocialImportScraperLogin(jobId),
        data: {
          'username': username,
          'password': password,
          if (otpCode != null && otpCode.isNotEmpty) 'otp_code': otpCode,
        },
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<SocialImportItem> patchItem(
    String jobId,
    String photoId,
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.aiSocialImportPatchItem(jobId, photoId, itemId),
        data: updates,
      );
      return SocialImportItem.fromJson(_extractDataMap(response.data));
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> approvePhoto(String jobId, String photoId) async {
    try {
      await _apiClient.post(
        ApiConstants.aiSocialImportApprovePhoto(jobId, photoId),
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> rejectPhoto(String jobId, String photoId) async {
    try {
      await _apiClient.post(
        ApiConstants.aiSocialImportRejectPhoto(jobId, photoId),
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> cancelJob(String jobId) async {
    try {
      await _apiClient.post(ApiConstants.aiSocialImportCancel(jobId));
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
