import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/gift_models.dart';

class GiftRepository {
  GiftRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<GiftDashboardSummary> getSummary() async {
    try {
      final response = await _apiClient.get('${ApiConstants.gifts}/summary');
      return GiftDashboardSummary.fromJson(_dataMap(response.data));
    } on DioException catch (error) {
      throw handleDioException(error);
    }
  }

  Future<GiftVoucher> createComplimentary({
    required int durationMonths,
    required String fromName,
    required String toName,
    required String recipientEmail,
    required String clientRequestId,
    String? message,
    GiftOccasion? occasion,
    String? occasionGreeting,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.gifts}/complimentary',
        data: {
          'duration_months': durationMonths,
          'from_name': fromName,
          'to_name': toName,
          'recipient_email': recipientEmail,
          'client_request_id': clientRequestId,
          if (message != null && message.isNotEmpty) 'message': message,
          if (occasion != null) 'occasion': occasion.name,
          if (occasionGreeting != null && occasionGreeting.isNotEmpty)
            'occasion_greeting': occasionGreeting,
        },
      );
      return GiftVoucher.fromJson(_dataMap(response.data));
    } on DioException catch (error) {
      throw handleDioException(error);
    }
  }

  Future<GiftClaimResult> claimAssigned(String voucherId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.gifts}/$voucherId/claim-assigned',
      );
      return GiftClaimResult.fromJson(_dataMap(response.data));
    } on DioException catch (error) {
      throw handleDioException(error);
    }
  }

  Map<String, dynamic> _dataMap(dynamic payload) {
    if (payload is! Map) return const <String, dynamic>{};
    final data = payload['data'];
    if (data is! Map) return const <String, dynamic>{};
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
}
