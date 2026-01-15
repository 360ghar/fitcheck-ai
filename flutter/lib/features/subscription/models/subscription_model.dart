import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// Plan types
enum PlanType {
  @JsonValue('free')
  free,
  @JsonValue('pro_monthly')
  proMonthly,
  @JsonValue('pro_yearly')
  proYearly,
}

/// Subscription statuses
enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('trial')
  trial,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('past_due')
  pastDue,
}

/// Subscription model
@freezed
abstract class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'plan_type') @Default(PlanType.free) PlanType planType,
    @Default(SubscriptionStatus.active) SubscriptionStatus status,
    @JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,
    @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
    @JsonKey(name: 'cancel_at_period_end') @Default(false) bool cancelAtPeriodEnd,
    @JsonKey(name: 'trial_end') DateTime? trialEnd,
    @JsonKey(name: 'referral_credit_months') @Default(0) int referralCreditMonths,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}

/// Usage limits model
@freezed
abstract class UsageLimitsModel with _$UsageLimitsModel {
  const factory UsageLimitsModel({
    @JsonKey(name: 'monthly_extractions') @Default(0) int monthlyExtractions,
    @JsonKey(name: 'monthly_extractions_limit') @Default(25) int monthlyExtractionsLimit,
    @JsonKey(name: 'monthly_generations') @Default(0) int monthlyGenerations,
    @JsonKey(name: 'monthly_generations_limit') @Default(50) int monthlyGenerationsLimit,
    @JsonKey(name: 'period_start') DateTime? periodStart,
    @JsonKey(name: 'period_end') DateTime? periodEnd,
  }) = _UsageLimitsModel;

  factory UsageLimitsModel.fromJson(Map<String, dynamic> json) =>
      _$UsageLimitsModelFromJson(json);
}

/// Combined subscription with usage
@freezed
abstract class SubscriptionWithUsage with _$SubscriptionWithUsage {
  const factory SubscriptionWithUsage({
    required SubscriptionModel subscription,
    required UsageLimitsModel usage,
  }) = _SubscriptionWithUsage;

  factory SubscriptionWithUsage.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionWithUsageFromJson(json);
}

/// Referral code model
@freezed
abstract class ReferralCodeModel with _$ReferralCodeModel {
  const factory ReferralCodeModel({
    required String code,
    @JsonKey(name: 'share_url') required String shareUrl,
    @JsonKey(name: 'times_used') @Default(0) int timesUsed,
    @JsonKey(name: 'referrer_name') String? referrerName,
  }) = _ReferralCodeModel;

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralCodeModelFromJson(json);
}

/// Referral stats model
@freezed
abstract class ReferralStatsModel with _$ReferralStatsModel {
  const factory ReferralStatsModel({
    @JsonKey(name: 'total_referrals') @Default(0) int totalReferrals,
    @JsonKey(name: 'successful_referrals') @Default(0) int successfulReferrals,
    @JsonKey(name: 'pending_referrals') @Default(0) int pendingReferrals,
    @JsonKey(name: 'months_earned') @Default(0) int monthsEarned,
  }) = _ReferralStatsModel;

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralStatsModelFromJson(json);
}

/// Plan details model
@freezed
abstract class PlanDetailsModel with _$PlanDetailsModel {
  const factory PlanDetailsModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'price_monthly') @Default(0.0) double priceMonthly,
    @JsonKey(name: 'price_yearly') @Default(0.0) double priceYearly,
    @JsonKey(name: 'monthly_extractions') @Default(25) int monthlyExtractions,
    @JsonKey(name: 'monthly_generations') @Default(50) int monthlyGenerations,
    @Default([]) List<String> features,
  }) = _PlanDetailsModel;

  factory PlanDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$PlanDetailsModelFromJson(json);
}

/// Checkout session model
@freezed
abstract class CheckoutSessionModel with _$CheckoutSessionModel {
  const factory CheckoutSessionModel({
    @JsonKey(name: 'checkout_url') required String checkoutUrl,
    @JsonKey(name: 'session_id') required String sessionId,
  }) = _CheckoutSessionModel;

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) =>
      _$CheckoutSessionModelFromJson(json);
}

/// Validate referral response
@freezed
abstract class ValidateReferralResponse with _$ValidateReferralResponse {
  const factory ValidateReferralResponse({
    @Default(false) bool valid,
    @JsonKey(name: 'referrer_name') String? referrerName,
    String? error,
  }) = _ValidateReferralResponse;

  factory ValidateReferralResponse.fromJson(Map<String, dynamic> json) =>
      _$ValidateReferralResponseFromJson(json);
}
