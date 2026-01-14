// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionModelImpl(
      userId: json['user_id'] as String,
      planType: $enumDecodeNullable(_$PlanTypeEnumMap, json['plan_type']) ??
          PlanType.free,
      status:
          $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']) ??
              SubscriptionStatus.active,
      currentPeriodStart: json['current_period_start'] == null
          ? null
          : DateTime.parse(json['current_period_start'] as String),
      currentPeriodEnd: json['current_period_end'] == null
          ? null
          : DateTime.parse(json['current_period_end'] as String),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      trialEnd: json['trial_end'] == null
          ? null
          : DateTime.parse(json['trial_end'] as String),
      referralCreditMonths:
          (json['referral_credit_months'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SubscriptionModelImplToJson(
        _$SubscriptionModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'plan_type': _$PlanTypeEnumMap[instance.planType]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'current_period_start': instance.currentPeriodStart?.toIso8601String(),
      'current_period_end': instance.currentPeriodEnd?.toIso8601String(),
      'cancel_at_period_end': instance.cancelAtPeriodEnd,
      'trial_end': instance.trialEnd?.toIso8601String(),
      'referral_credit_months': instance.referralCreditMonths,
    };

const _$PlanTypeEnumMap = {
  PlanType.free: 'free',
  PlanType.proMonthly: 'pro_monthly',
  PlanType.proYearly: 'pro_yearly',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.trial: 'trial',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.pastDue: 'past_due',
};

_$UsageLimitsModelImpl _$$UsageLimitsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UsageLimitsModelImpl(
      monthlyExtractions: (json['monthly_extractions'] as num?)?.toInt() ?? 0,
      monthlyExtractionsLimit:
          (json['monthly_extractions_limit'] as num?)?.toInt() ?? 25,
      monthlyGenerations: (json['monthly_generations'] as num?)?.toInt() ?? 0,
      monthlyGenerationsLimit:
          (json['monthly_generations_limit'] as num?)?.toInt() ?? 50,
      periodStart: json['period_start'] == null
          ? null
          : DateTime.parse(json['period_start'] as String),
      periodEnd: json['period_end'] == null
          ? null
          : DateTime.parse(json['period_end'] as String),
    );

Map<String, dynamic> _$$UsageLimitsModelImplToJson(
        _$UsageLimitsModelImpl instance) =>
    <String, dynamic>{
      'monthly_extractions': instance.monthlyExtractions,
      'monthly_extractions_limit': instance.monthlyExtractionsLimit,
      'monthly_generations': instance.monthlyGenerations,
      'monthly_generations_limit': instance.monthlyGenerationsLimit,
      'period_start': instance.periodStart?.toIso8601String(),
      'period_end': instance.periodEnd?.toIso8601String(),
    };

_$SubscriptionWithUsageImpl _$$SubscriptionWithUsageImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionWithUsageImpl(
      subscription: SubscriptionModel.fromJson(
          json['subscription'] as Map<String, dynamic>),
      usage: UsageLimitsModel.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SubscriptionWithUsageImplToJson(
        _$SubscriptionWithUsageImpl instance) =>
    <String, dynamic>{
      'subscription': instance.subscription,
      'usage': instance.usage,
    };

_$ReferralCodeModelImpl _$$ReferralCodeModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralCodeModelImpl(
      code: json['code'] as String,
      shareUrl: json['share_url'] as String,
      timesUsed: (json['times_used'] as num?)?.toInt() ?? 0,
      referrerName: json['referrer_name'] as String?,
    );

Map<String, dynamic> _$$ReferralCodeModelImplToJson(
        _$ReferralCodeModelImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'share_url': instance.shareUrl,
      'times_used': instance.timesUsed,
      'referrer_name': instance.referrerName,
    };

_$ReferralStatsModelImpl _$$ReferralStatsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralStatsModelImpl(
      totalReferrals: (json['total_referrals'] as num?)?.toInt() ?? 0,
      successfulReferrals: (json['successful_referrals'] as num?)?.toInt() ?? 0,
      pendingReferrals: (json['pending_referrals'] as num?)?.toInt() ?? 0,
      monthsEarned: (json['months_earned'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ReferralStatsModelImplToJson(
        _$ReferralStatsModelImpl instance) =>
    <String, dynamic>{
      'total_referrals': instance.totalReferrals,
      'successful_referrals': instance.successfulReferrals,
      'pending_referrals': instance.pendingReferrals,
      'months_earned': instance.monthsEarned,
    };

_$PlanDetailsModelImpl _$$PlanDetailsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PlanDetailsModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceMonthly: (json['price_monthly'] as num?)?.toDouble() ?? 0.0,
      priceYearly: (json['price_yearly'] as num?)?.toDouble() ?? 0.0,
      monthlyExtractions: (json['monthly_extractions'] as num?)?.toInt() ?? 25,
      monthlyGenerations: (json['monthly_generations'] as num?)?.toInt() ?? 50,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PlanDetailsModelImplToJson(
        _$PlanDetailsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price_monthly': instance.priceMonthly,
      'price_yearly': instance.priceYearly,
      'monthly_extractions': instance.monthlyExtractions,
      'monthly_generations': instance.monthlyGenerations,
      'features': instance.features,
    };

_$CheckoutSessionModelImpl _$$CheckoutSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CheckoutSessionModelImpl(
      checkoutUrl: json['checkout_url'] as String,
      sessionId: json['session_id'] as String,
    );

Map<String, dynamic> _$$CheckoutSessionModelImplToJson(
        _$CheckoutSessionModelImpl instance) =>
    <String, dynamic>{
      'checkout_url': instance.checkoutUrl,
      'session_id': instance.sessionId,
    };

_$ValidateReferralResponseImpl _$$ValidateReferralResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ValidateReferralResponseImpl(
      valid: json['valid'] as bool? ?? false,
      referrerName: json['referrer_name'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ValidateReferralResponseImplToJson(
        _$ValidateReferralResponseImpl instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'referrer_name': instance.referrerName,
      'error': instance.error,
    };
