import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target
// `@JsonKey` on freezed constructor params is the idiomatic, supported usage
// (freezed FAQ); the analyzer emits a false-positive warning for it.
part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// Plan types
///
/// `plus_*` and `pro_*` are paid plans with identical feature entitlement;
/// only the usage limits differ (see backend `SubscriptionService`).
enum PlanType {
  @JsonValue('free')
  free,
  @JsonValue('plus_monthly')
  plusMonthly,
  @JsonValue('plus_yearly')
  plusYearly,
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
    /// Which billing rail owns this subscription: "stripe" (web checkout),
    /// "apple" (App Store IAP) or "google" (Play Billing IAP).
    @JsonKey(name: 'billing_provider') @Default('stripe') String billingProvider,
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

/// Per-variant store product IDs from the `/plans` endpoint.
///
/// Keys are plan types ("plus_monthly", "plus_yearly", "pro_monthly",
/// "pro_yearly"); values are the store product IDs the mobile clients pass
/// to StoreKit / Play Billing. Product IDs are never hardcoded in the app.
@freezed
abstract class StoreProductsModel with _$StoreProductsModel {
  const factory StoreProductsModel({
    @Default({}) Map<String, String?> apple,
    @Default({}) Map<String, String?> google,
  }) = _StoreProductsModel;

  factory StoreProductsModel.fromJson(Map<String, dynamic> json) =>
      _$StoreProductsModelFromJson(json);
}

extension StoreProductsModelX on StoreProductsModel {
  /// The store product ID for a plan type on the given store
  /// ("apple" | "google").
  ///
  /// Falls back to the plan type itself when the backend published no store
  /// product map for this store at all (every entry null/empty) — dev /
  /// sandbox environments where store products are exercised via an Xcode
  /// StoreKit configuration file or a store that mirrors the plan type.
  /// Note the backend always sends the full map (with null values when the
  /// store rail is unconfigured), so "no map" must mean "all values
  /// null/empty", not "empty map".
  String? productIdFor(String store, String planType) {
    final map = store == 'google' ? google : apple;
    final id = map[planType];
    if (id != null && id.isNotEmpty) return id;
    final hasAnyConfigured = map.values.any((v) => v != null && v.isNotEmpty);
    return hasAnyConfigured ? null : planType;
  }
}

/// The `/plans` response: display plans, web-billing readiness, and store
/// product ID maps.
@freezed
abstract class PlansResponse with _$PlansResponse {
  const factory PlansResponse({
    @Default([]) List<PlanDetailsModel> plans,
    @JsonKey(name: 'store_products') @Default(StoreProductsModel()) StoreProductsModel storeProducts,
    /// True only when web (Stripe) billing is fully configured server-side.
    /// When false, web checkout/portal fail closed by design, so web clients
    /// must not offer upgrade CTAs that only produce error toasts.
    @JsonKey(name: 'billing_configured') @Default(false) bool billingConfigured,
  }) = _PlansResponse;

  factory PlansResponse.fromJson(Map<String, dynamic> json) =>
      _$PlansResponseFromJson(json);
}

/// Checkout session model
@freezed
abstract class CheckoutSessionModel with _$CheckoutSessionModel {
  const factory CheckoutSessionModel({
    @JsonKey(name: 'checkout_url') String? checkoutUrl,
    @JsonKey(name: 'session_id') String? sessionId,
    @Default(false) bool updated,
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
