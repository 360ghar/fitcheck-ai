import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/subscription_model.dart';

/// Subscription repository for API interactions
class SubscriptionRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get subscription with usage
  Future<SubscriptionWithUsage> getSubscription() async {
    try {
      final response = await _apiClient.get(ApiConstants.subscription);
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final subscription = SubscriptionModel.fromJson(
        data['subscription'] as Map<String, dynamic>? ?? <String, dynamic>{},
      );
      final usage = UsageLimitsModel.fromJson(
        data['usage'] as Map<String, dynamic>? ?? <String, dynamic>{},
      );

      return SubscriptionWithUsage(subscription: subscription, usage: usage);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get usage details
  Future<UsageLimitsModel> getUsage() async {
    try {
      final response = await _apiClient.get('${ApiConstants.subscription}/usage');
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return UsageLimitsModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get available plans
  Future<List<PlanDetailsModel>> getPlans() async {
    try {
      final response = await _apiClient.get('${ApiConstants.subscription}/plans');
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final plans = (data['plans'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];
      return plans.map((p) => PlanDetailsModel.fromJson(p)).toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create checkout session for upgrade
  Future<CheckoutSessionModel> createCheckoutSession({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.subscription}/checkout',
        data: {
          'plan_type': planType,
          if (successUrl != null) 'success_url': successUrl,
          if (cancelUrl != null) 'cancel_url': cancelUrl,
        },
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return CheckoutSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      await _apiClient.post('${ApiConstants.subscription}/cancel');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get user's referral code
  Future<ReferralCodeModel> getReferralCode() async {
    try {
      final response = await _apiClient.get('${ApiConstants.referral}/code');
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return ReferralCodeModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get referral stats
  Future<ReferralStatsModel> getReferralStats() async {
    try {
      final response = await _apiClient.get('${ApiConstants.referral}/stats');
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return ReferralStatsModel.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Validate a referral code
  Future<ValidateReferralResponse> validateReferralCode(String code) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.referral}/validate',
        data: {'code': code},
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return ValidateReferralResponse.fromJson(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Redeem a referral code
  Future<void> redeemReferralCode(String code) async {
    try {
      await _apiClient.post(
        '${ApiConstants.referral}/redeem',
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
