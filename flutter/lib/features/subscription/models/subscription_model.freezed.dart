// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) {
  return _SubscriptionModel.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_type')
  PlanType get planType => throw _privateConstructorUsedError;
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_period_start')
  DateTime? get currentPeriodStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_period_end')
  DateTime? get currentPeriodEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancel_at_period_end')
  bool get cancelAtPeriodEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'trial_end')
  DateTime? get trialEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'referral_credit_months')
  int get referralCreditMonths => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubscriptionModelCopyWith<SubscriptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionModelCopyWith<$Res> {
  factory $SubscriptionModelCopyWith(
          SubscriptionModel value, $Res Function(SubscriptionModel) then) =
      _$SubscriptionModelCopyWithImpl<$Res, SubscriptionModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'plan_type') PlanType planType,
      SubscriptionStatus status,
      @JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,
      @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
      @JsonKey(name: 'cancel_at_period_end') bool cancelAtPeriodEnd,
      @JsonKey(name: 'trial_end') DateTime? trialEnd,
      @JsonKey(name: 'referral_credit_months') int referralCreditMonths});
}

/// @nodoc
class _$SubscriptionModelCopyWithImpl<$Res, $Val extends SubscriptionModel>
    implements $SubscriptionModelCopyWith<$Res> {
  _$SubscriptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? planType = null,
    Object? status = null,
    Object? currentPeriodStart = freezed,
    Object? currentPeriodEnd = freezed,
    Object? cancelAtPeriodEnd = null,
    Object? trialEnd = freezed,
    Object? referralCreditMonths = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as PlanType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      currentPeriodStart: freezed == currentPeriodStart
          ? _value.currentPeriodStart
          : currentPeriodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentPeriodEnd: freezed == currentPeriodEnd
          ? _value.currentPeriodEnd
          : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelAtPeriodEnd: null == cancelAtPeriodEnd
          ? _value.cancelAtPeriodEnd
          : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      trialEnd: freezed == trialEnd
          ? _value.trialEnd
          : trialEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      referralCreditMonths: null == referralCreditMonths
          ? _value.referralCreditMonths
          : referralCreditMonths // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionModelImplCopyWith<$Res>
    implements $SubscriptionModelCopyWith<$Res> {
  factory _$$SubscriptionModelImplCopyWith(_$SubscriptionModelImpl value,
          $Res Function(_$SubscriptionModelImpl) then) =
      __$$SubscriptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'plan_type') PlanType planType,
      SubscriptionStatus status,
      @JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,
      @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
      @JsonKey(name: 'cancel_at_period_end') bool cancelAtPeriodEnd,
      @JsonKey(name: 'trial_end') DateTime? trialEnd,
      @JsonKey(name: 'referral_credit_months') int referralCreditMonths});
}

/// @nodoc
class __$$SubscriptionModelImplCopyWithImpl<$Res>
    extends _$SubscriptionModelCopyWithImpl<$Res, _$SubscriptionModelImpl>
    implements _$$SubscriptionModelImplCopyWith<$Res> {
  __$$SubscriptionModelImplCopyWithImpl(_$SubscriptionModelImpl _value,
      $Res Function(_$SubscriptionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? planType = null,
    Object? status = null,
    Object? currentPeriodStart = freezed,
    Object? currentPeriodEnd = freezed,
    Object? cancelAtPeriodEnd = null,
    Object? trialEnd = freezed,
    Object? referralCreditMonths = null,
  }) {
    return _then(_$SubscriptionModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as PlanType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      currentPeriodStart: freezed == currentPeriodStart
          ? _value.currentPeriodStart
          : currentPeriodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentPeriodEnd: freezed == currentPeriodEnd
          ? _value.currentPeriodEnd
          : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelAtPeriodEnd: null == cancelAtPeriodEnd
          ? _value.cancelAtPeriodEnd
          : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      trialEnd: freezed == trialEnd
          ? _value.trialEnd
          : trialEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      referralCreditMonths: null == referralCreditMonths
          ? _value.referralCreditMonths
          : referralCreditMonths // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionModelImpl implements _SubscriptionModel {
  const _$SubscriptionModelImpl(
      {@JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'plan_type') this.planType = PlanType.free,
      this.status = SubscriptionStatus.active,
      @JsonKey(name: 'current_period_start') this.currentPeriodStart,
      @JsonKey(name: 'current_period_end') this.currentPeriodEnd,
      @JsonKey(name: 'cancel_at_period_end') this.cancelAtPeriodEnd = false,
      @JsonKey(name: 'trial_end') this.trialEnd,
      @JsonKey(name: 'referral_credit_months') this.referralCreditMonths = 0});

  factory _$SubscriptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionModelImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'plan_type')
  final PlanType planType;
  @override
  @JsonKey()
  final SubscriptionStatus status;
  @override
  @JsonKey(name: 'current_period_start')
  final DateTime? currentPeriodStart;
  @override
  @JsonKey(name: 'current_period_end')
  final DateTime? currentPeriodEnd;
  @override
  @JsonKey(name: 'cancel_at_period_end')
  final bool cancelAtPeriodEnd;
  @override
  @JsonKey(name: 'trial_end')
  final DateTime? trialEnd;
  @override
  @JsonKey(name: 'referral_credit_months')
  final int referralCreditMonths;

  @override
  String toString() {
    return 'SubscriptionModel(userId: $userId, planType: $planType, status: $status, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, cancelAtPeriodEnd: $cancelAtPeriodEnd, trialEnd: $trialEnd, referralCreditMonths: $referralCreditMonths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentPeriodStart, currentPeriodStart) ||
                other.currentPeriodStart == currentPeriodStart) &&
            (identical(other.currentPeriodEnd, currentPeriodEnd) ||
                other.currentPeriodEnd == currentPeriodEnd) &&
            (identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) ||
                other.cancelAtPeriodEnd == cancelAtPeriodEnd) &&
            (identical(other.trialEnd, trialEnd) ||
                other.trialEnd == trialEnd) &&
            (identical(other.referralCreditMonths, referralCreditMonths) ||
                other.referralCreditMonths == referralCreditMonths));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      planType,
      status,
      currentPeriodStart,
      currentPeriodEnd,
      cancelAtPeriodEnd,
      trialEnd,
      referralCreditMonths);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      __$$SubscriptionModelImplCopyWithImpl<_$SubscriptionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionModelImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionModel implements SubscriptionModel {
  const factory _SubscriptionModel(
      {@JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'plan_type') final PlanType planType,
      final SubscriptionStatus status,
      @JsonKey(name: 'current_period_start') final DateTime? currentPeriodStart,
      @JsonKey(name: 'current_period_end') final DateTime? currentPeriodEnd,
      @JsonKey(name: 'cancel_at_period_end') final bool cancelAtPeriodEnd,
      @JsonKey(name: 'trial_end') final DateTime? trialEnd,
      @JsonKey(name: 'referral_credit_months')
      final int referralCreditMonths}) = _$SubscriptionModelImpl;

  factory _SubscriptionModel.fromJson(Map<String, dynamic> json) =
      _$SubscriptionModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'plan_type')
  PlanType get planType;
  @override
  SubscriptionStatus get status;
  @override
  @JsonKey(name: 'current_period_start')
  DateTime? get currentPeriodStart;
  @override
  @JsonKey(name: 'current_period_end')
  DateTime? get currentPeriodEnd;
  @override
  @JsonKey(name: 'cancel_at_period_end')
  bool get cancelAtPeriodEnd;
  @override
  @JsonKey(name: 'trial_end')
  DateTime? get trialEnd;
  @override
  @JsonKey(name: 'referral_credit_months')
  int get referralCreditMonths;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UsageLimitsModel _$UsageLimitsModelFromJson(Map<String, dynamic> json) {
  return _UsageLimitsModel.fromJson(json);
}

/// @nodoc
mixin _$UsageLimitsModel {
  @JsonKey(name: 'monthly_extractions')
  int get monthlyExtractions => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_extractions_limit')
  int get monthlyExtractionsLimit => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_generations')
  int get monthlyGenerations => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_generations_limit')
  int get monthlyGenerationsLimit => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_start')
  DateTime? get periodStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_end')
  DateTime? get periodEnd => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UsageLimitsModelCopyWith<UsageLimitsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsageLimitsModelCopyWith<$Res> {
  factory $UsageLimitsModelCopyWith(
          UsageLimitsModel value, $Res Function(UsageLimitsModel) then) =
      _$UsageLimitsModelCopyWithImpl<$Res, UsageLimitsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'monthly_extractions') int monthlyExtractions,
      @JsonKey(name: 'monthly_extractions_limit') int monthlyExtractionsLimit,
      @JsonKey(name: 'monthly_generations') int monthlyGenerations,
      @JsonKey(name: 'monthly_generations_limit') int monthlyGenerationsLimit,
      @JsonKey(name: 'period_start') DateTime? periodStart,
      @JsonKey(name: 'period_end') DateTime? periodEnd});
}

/// @nodoc
class _$UsageLimitsModelCopyWithImpl<$Res, $Val extends UsageLimitsModel>
    implements $UsageLimitsModelCopyWith<$Res> {
  _$UsageLimitsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyExtractions = null,
    Object? monthlyExtractionsLimit = null,
    Object? monthlyGenerations = null,
    Object? monthlyGenerationsLimit = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
  }) {
    return _then(_value.copyWith(
      monthlyExtractions: null == monthlyExtractions
          ? _value.monthlyExtractions
          : monthlyExtractions // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyExtractionsLimit: null == monthlyExtractionsLimit
          ? _value.monthlyExtractionsLimit
          : monthlyExtractionsLimit // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGenerations: null == monthlyGenerations
          ? _value.monthlyGenerations
          : monthlyGenerations // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGenerationsLimit: null == monthlyGenerationsLimit
          ? _value.monthlyGenerationsLimit
          : monthlyGenerationsLimit // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UsageLimitsModelImplCopyWith<$Res>
    implements $UsageLimitsModelCopyWith<$Res> {
  factory _$$UsageLimitsModelImplCopyWith(_$UsageLimitsModelImpl value,
          $Res Function(_$UsageLimitsModelImpl) then) =
      __$$UsageLimitsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'monthly_extractions') int monthlyExtractions,
      @JsonKey(name: 'monthly_extractions_limit') int monthlyExtractionsLimit,
      @JsonKey(name: 'monthly_generations') int monthlyGenerations,
      @JsonKey(name: 'monthly_generations_limit') int monthlyGenerationsLimit,
      @JsonKey(name: 'period_start') DateTime? periodStart,
      @JsonKey(name: 'period_end') DateTime? periodEnd});
}

/// @nodoc
class __$$UsageLimitsModelImplCopyWithImpl<$Res>
    extends _$UsageLimitsModelCopyWithImpl<$Res, _$UsageLimitsModelImpl>
    implements _$$UsageLimitsModelImplCopyWith<$Res> {
  __$$UsageLimitsModelImplCopyWithImpl(_$UsageLimitsModelImpl _value,
      $Res Function(_$UsageLimitsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyExtractions = null,
    Object? monthlyExtractionsLimit = null,
    Object? monthlyGenerations = null,
    Object? monthlyGenerationsLimit = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
  }) {
    return _then(_$UsageLimitsModelImpl(
      monthlyExtractions: null == monthlyExtractions
          ? _value.monthlyExtractions
          : monthlyExtractions // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyExtractionsLimit: null == monthlyExtractionsLimit
          ? _value.monthlyExtractionsLimit
          : monthlyExtractionsLimit // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGenerations: null == monthlyGenerations
          ? _value.monthlyGenerations
          : monthlyGenerations // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGenerationsLimit: null == monthlyGenerationsLimit
          ? _value.monthlyGenerationsLimit
          : monthlyGenerationsLimit // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UsageLimitsModelImpl implements _UsageLimitsModel {
  const _$UsageLimitsModelImpl(
      {@JsonKey(name: 'monthly_extractions') this.monthlyExtractions = 0,
      @JsonKey(name: 'monthly_extractions_limit')
      this.monthlyExtractionsLimit = 25,
      @JsonKey(name: 'monthly_generations') this.monthlyGenerations = 0,
      @JsonKey(name: 'monthly_generations_limit')
      this.monthlyGenerationsLimit = 50,
      @JsonKey(name: 'period_start') this.periodStart,
      @JsonKey(name: 'period_end') this.periodEnd});

  factory _$UsageLimitsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UsageLimitsModelImplFromJson(json);

  @override
  @JsonKey(name: 'monthly_extractions')
  final int monthlyExtractions;
  @override
  @JsonKey(name: 'monthly_extractions_limit')
  final int monthlyExtractionsLimit;
  @override
  @JsonKey(name: 'monthly_generations')
  final int monthlyGenerations;
  @override
  @JsonKey(name: 'monthly_generations_limit')
  final int monthlyGenerationsLimit;
  @override
  @JsonKey(name: 'period_start')
  final DateTime? periodStart;
  @override
  @JsonKey(name: 'period_end')
  final DateTime? periodEnd;

  @override
  String toString() {
    return 'UsageLimitsModel(monthlyExtractions: $monthlyExtractions, monthlyExtractionsLimit: $monthlyExtractionsLimit, monthlyGenerations: $monthlyGenerations, monthlyGenerationsLimit: $monthlyGenerationsLimit, periodStart: $periodStart, periodEnd: $periodEnd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsageLimitsModelImpl &&
            (identical(other.monthlyExtractions, monthlyExtractions) ||
                other.monthlyExtractions == monthlyExtractions) &&
            (identical(
                    other.monthlyExtractionsLimit, monthlyExtractionsLimit) ||
                other.monthlyExtractionsLimit == monthlyExtractionsLimit) &&
            (identical(other.monthlyGenerations, monthlyGenerations) ||
                other.monthlyGenerations == monthlyGenerations) &&
            (identical(
                    other.monthlyGenerationsLimit, monthlyGenerationsLimit) ||
                other.monthlyGenerationsLimit == monthlyGenerationsLimit) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      monthlyExtractions,
      monthlyExtractionsLimit,
      monthlyGenerations,
      monthlyGenerationsLimit,
      periodStart,
      periodEnd);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UsageLimitsModelImplCopyWith<_$UsageLimitsModelImpl> get copyWith =>
      __$$UsageLimitsModelImplCopyWithImpl<_$UsageLimitsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UsageLimitsModelImplToJson(
      this,
    );
  }
}

abstract class _UsageLimitsModel implements UsageLimitsModel {
  const factory _UsageLimitsModel(
          {@JsonKey(name: 'monthly_extractions') final int monthlyExtractions,
          @JsonKey(name: 'monthly_extractions_limit')
          final int monthlyExtractionsLimit,
          @JsonKey(name: 'monthly_generations') final int monthlyGenerations,
          @JsonKey(name: 'monthly_generations_limit')
          final int monthlyGenerationsLimit,
          @JsonKey(name: 'period_start') final DateTime? periodStart,
          @JsonKey(name: 'period_end') final DateTime? periodEnd}) =
      _$UsageLimitsModelImpl;

  factory _UsageLimitsModel.fromJson(Map<String, dynamic> json) =
      _$UsageLimitsModelImpl.fromJson;

  @override
  @JsonKey(name: 'monthly_extractions')
  int get monthlyExtractions;
  @override
  @JsonKey(name: 'monthly_extractions_limit')
  int get monthlyExtractionsLimit;
  @override
  @JsonKey(name: 'monthly_generations')
  int get monthlyGenerations;
  @override
  @JsonKey(name: 'monthly_generations_limit')
  int get monthlyGenerationsLimit;
  @override
  @JsonKey(name: 'period_start')
  DateTime? get periodStart;
  @override
  @JsonKey(name: 'period_end')
  DateTime? get periodEnd;
  @override
  @JsonKey(ignore: true)
  _$$UsageLimitsModelImplCopyWith<_$UsageLimitsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionWithUsage _$SubscriptionWithUsageFromJson(
    Map<String, dynamic> json) {
  return _SubscriptionWithUsage.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionWithUsage {
  SubscriptionModel get subscription => throw _privateConstructorUsedError;
  UsageLimitsModel get usage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubscriptionWithUsageCopyWith<SubscriptionWithUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionWithUsageCopyWith<$Res> {
  factory $SubscriptionWithUsageCopyWith(SubscriptionWithUsage value,
          $Res Function(SubscriptionWithUsage) then) =
      _$SubscriptionWithUsageCopyWithImpl<$Res, SubscriptionWithUsage>;
  @useResult
  $Res call({SubscriptionModel subscription, UsageLimitsModel usage});

  $SubscriptionModelCopyWith<$Res> get subscription;
  $UsageLimitsModelCopyWith<$Res> get usage;
}

/// @nodoc
class _$SubscriptionWithUsageCopyWithImpl<$Res,
        $Val extends SubscriptionWithUsage>
    implements $SubscriptionWithUsageCopyWith<$Res> {
  _$SubscriptionWithUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscription = null,
    Object? usage = null,
  }) {
    return _then(_value.copyWith(
      subscription: null == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscriptionModel,
      usage: null == usage
          ? _value.usage
          : usage // ignore: cast_nullable_to_non_nullable
              as UsageLimitsModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SubscriptionModelCopyWith<$Res> get subscription {
    return $SubscriptionModelCopyWith<$Res>(_value.subscription, (value) {
      return _then(_value.copyWith(subscription: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UsageLimitsModelCopyWith<$Res> get usage {
    return $UsageLimitsModelCopyWith<$Res>(_value.usage, (value) {
      return _then(_value.copyWith(usage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubscriptionWithUsageImplCopyWith<$Res>
    implements $SubscriptionWithUsageCopyWith<$Res> {
  factory _$$SubscriptionWithUsageImplCopyWith(
          _$SubscriptionWithUsageImpl value,
          $Res Function(_$SubscriptionWithUsageImpl) then) =
      __$$SubscriptionWithUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SubscriptionModel subscription, UsageLimitsModel usage});

  @override
  $SubscriptionModelCopyWith<$Res> get subscription;
  @override
  $UsageLimitsModelCopyWith<$Res> get usage;
}

/// @nodoc
class __$$SubscriptionWithUsageImplCopyWithImpl<$Res>
    extends _$SubscriptionWithUsageCopyWithImpl<$Res,
        _$SubscriptionWithUsageImpl>
    implements _$$SubscriptionWithUsageImplCopyWith<$Res> {
  __$$SubscriptionWithUsageImplCopyWithImpl(_$SubscriptionWithUsageImpl _value,
      $Res Function(_$SubscriptionWithUsageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscription = null,
    Object? usage = null,
  }) {
    return _then(_$SubscriptionWithUsageImpl(
      subscription: null == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscriptionModel,
      usage: null == usage
          ? _value.usage
          : usage // ignore: cast_nullable_to_non_nullable
              as UsageLimitsModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionWithUsageImpl implements _SubscriptionWithUsage {
  const _$SubscriptionWithUsageImpl(
      {required this.subscription, required this.usage});

  factory _$SubscriptionWithUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionWithUsageImplFromJson(json);

  @override
  final SubscriptionModel subscription;
  @override
  final UsageLimitsModel usage;

  @override
  String toString() {
    return 'SubscriptionWithUsage(subscription: $subscription, usage: $usage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionWithUsageImpl &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription) &&
            (identical(other.usage, usage) || other.usage == usage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, subscription, usage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionWithUsageImplCopyWith<_$SubscriptionWithUsageImpl>
      get copyWith => __$$SubscriptionWithUsageImplCopyWithImpl<
          _$SubscriptionWithUsageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionWithUsageImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionWithUsage implements SubscriptionWithUsage {
  const factory _SubscriptionWithUsage(
      {required final SubscriptionModel subscription,
      required final UsageLimitsModel usage}) = _$SubscriptionWithUsageImpl;

  factory _SubscriptionWithUsage.fromJson(Map<String, dynamic> json) =
      _$SubscriptionWithUsageImpl.fromJson;

  @override
  SubscriptionModel get subscription;
  @override
  UsageLimitsModel get usage;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionWithUsageImplCopyWith<_$SubscriptionWithUsageImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ReferralCodeModel _$ReferralCodeModelFromJson(Map<String, dynamic> json) {
  return _ReferralCodeModel.fromJson(json);
}

/// @nodoc
mixin _$ReferralCodeModel {
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'share_url')
  String get shareUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'times_used')
  int get timesUsed => throw _privateConstructorUsedError;
  @JsonKey(name: 'referrer_name')
  String? get referrerName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralCodeModelCopyWith<ReferralCodeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralCodeModelCopyWith<$Res> {
  factory $ReferralCodeModelCopyWith(
          ReferralCodeModel value, $Res Function(ReferralCodeModel) then) =
      _$ReferralCodeModelCopyWithImpl<$Res, ReferralCodeModel>;
  @useResult
  $Res call(
      {String code,
      @JsonKey(name: 'share_url') String shareUrl,
      @JsonKey(name: 'times_used') int timesUsed,
      @JsonKey(name: 'referrer_name') String? referrerName});
}

/// @nodoc
class _$ReferralCodeModelCopyWithImpl<$Res, $Val extends ReferralCodeModel>
    implements $ReferralCodeModelCopyWith<$Res> {
  _$ReferralCodeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? shareUrl = null,
    Object? timesUsed = null,
    Object? referrerName = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      shareUrl: null == shareUrl
          ? _value.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String,
      timesUsed: null == timesUsed
          ? _value.timesUsed
          : timesUsed // ignore: cast_nullable_to_non_nullable
              as int,
      referrerName: freezed == referrerName
          ? _value.referrerName
          : referrerName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralCodeModelImplCopyWith<$Res>
    implements $ReferralCodeModelCopyWith<$Res> {
  factory _$$ReferralCodeModelImplCopyWith(_$ReferralCodeModelImpl value,
          $Res Function(_$ReferralCodeModelImpl) then) =
      __$$ReferralCodeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      @JsonKey(name: 'share_url') String shareUrl,
      @JsonKey(name: 'times_used') int timesUsed,
      @JsonKey(name: 'referrer_name') String? referrerName});
}

/// @nodoc
class __$$ReferralCodeModelImplCopyWithImpl<$Res>
    extends _$ReferralCodeModelCopyWithImpl<$Res, _$ReferralCodeModelImpl>
    implements _$$ReferralCodeModelImplCopyWith<$Res> {
  __$$ReferralCodeModelImplCopyWithImpl(_$ReferralCodeModelImpl _value,
      $Res Function(_$ReferralCodeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? shareUrl = null,
    Object? timesUsed = null,
    Object? referrerName = freezed,
  }) {
    return _then(_$ReferralCodeModelImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      shareUrl: null == shareUrl
          ? _value.shareUrl
          : shareUrl // ignore: cast_nullable_to_non_nullable
              as String,
      timesUsed: null == timesUsed
          ? _value.timesUsed
          : timesUsed // ignore: cast_nullable_to_non_nullable
              as int,
      referrerName: freezed == referrerName
          ? _value.referrerName
          : referrerName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralCodeModelImpl implements _ReferralCodeModel {
  const _$ReferralCodeModelImpl(
      {required this.code,
      @JsonKey(name: 'share_url') required this.shareUrl,
      @JsonKey(name: 'times_used') this.timesUsed = 0,
      @JsonKey(name: 'referrer_name') this.referrerName});

  factory _$ReferralCodeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralCodeModelImplFromJson(json);

  @override
  final String code;
  @override
  @JsonKey(name: 'share_url')
  final String shareUrl;
  @override
  @JsonKey(name: 'times_used')
  final int timesUsed;
  @override
  @JsonKey(name: 'referrer_name')
  final String? referrerName;

  @override
  String toString() {
    return 'ReferralCodeModel(code: $code, shareUrl: $shareUrl, timesUsed: $timesUsed, referrerName: $referrerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralCodeModelImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.shareUrl, shareUrl) ||
                other.shareUrl == shareUrl) &&
            (identical(other.timesUsed, timesUsed) ||
                other.timesUsed == timesUsed) &&
            (identical(other.referrerName, referrerName) ||
                other.referrerName == referrerName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, code, shareUrl, timesUsed, referrerName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralCodeModelImplCopyWith<_$ReferralCodeModelImpl> get copyWith =>
      __$$ReferralCodeModelImplCopyWithImpl<_$ReferralCodeModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralCodeModelImplToJson(
      this,
    );
  }
}

abstract class _ReferralCodeModel implements ReferralCodeModel {
  const factory _ReferralCodeModel(
          {required final String code,
          @JsonKey(name: 'share_url') required final String shareUrl,
          @JsonKey(name: 'times_used') final int timesUsed,
          @JsonKey(name: 'referrer_name') final String? referrerName}) =
      _$ReferralCodeModelImpl;

  factory _ReferralCodeModel.fromJson(Map<String, dynamic> json) =
      _$ReferralCodeModelImpl.fromJson;

  @override
  String get code;
  @override
  @JsonKey(name: 'share_url')
  String get shareUrl;
  @override
  @JsonKey(name: 'times_used')
  int get timesUsed;
  @override
  @JsonKey(name: 'referrer_name')
  String? get referrerName;
  @override
  @JsonKey(ignore: true)
  _$$ReferralCodeModelImplCopyWith<_$ReferralCodeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralStatsModel _$ReferralStatsModelFromJson(Map<String, dynamic> json) {
  return _ReferralStatsModel.fromJson(json);
}

/// @nodoc
mixin _$ReferralStatsModel {
  @JsonKey(name: 'total_referrals')
  int get totalReferrals => throw _privateConstructorUsedError;
  @JsonKey(name: 'successful_referrals')
  int get successfulReferrals => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_referrals')
  int get pendingReferrals => throw _privateConstructorUsedError;
  @JsonKey(name: 'months_earned')
  int get monthsEarned => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralStatsModelCopyWith<ReferralStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralStatsModelCopyWith<$Res> {
  factory $ReferralStatsModelCopyWith(
          ReferralStatsModel value, $Res Function(ReferralStatsModel) then) =
      _$ReferralStatsModelCopyWithImpl<$Res, ReferralStatsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_referrals') int totalReferrals,
      @JsonKey(name: 'successful_referrals') int successfulReferrals,
      @JsonKey(name: 'pending_referrals') int pendingReferrals,
      @JsonKey(name: 'months_earned') int monthsEarned});
}

/// @nodoc
class _$ReferralStatsModelCopyWithImpl<$Res, $Val extends ReferralStatsModel>
    implements $ReferralStatsModelCopyWith<$Res> {
  _$ReferralStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReferrals = null,
    Object? successfulReferrals = null,
    Object? pendingReferrals = null,
    Object? monthsEarned = null,
  }) {
    return _then(_value.copyWith(
      totalReferrals: null == totalReferrals
          ? _value.totalReferrals
          : totalReferrals // ignore: cast_nullable_to_non_nullable
              as int,
      successfulReferrals: null == successfulReferrals
          ? _value.successfulReferrals
          : successfulReferrals // ignore: cast_nullable_to_non_nullable
              as int,
      pendingReferrals: null == pendingReferrals
          ? _value.pendingReferrals
          : pendingReferrals // ignore: cast_nullable_to_non_nullable
              as int,
      monthsEarned: null == monthsEarned
          ? _value.monthsEarned
          : monthsEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralStatsModelImplCopyWith<$Res>
    implements $ReferralStatsModelCopyWith<$Res> {
  factory _$$ReferralStatsModelImplCopyWith(_$ReferralStatsModelImpl value,
          $Res Function(_$ReferralStatsModelImpl) then) =
      __$$ReferralStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_referrals') int totalReferrals,
      @JsonKey(name: 'successful_referrals') int successfulReferrals,
      @JsonKey(name: 'pending_referrals') int pendingReferrals,
      @JsonKey(name: 'months_earned') int monthsEarned});
}

/// @nodoc
class __$$ReferralStatsModelImplCopyWithImpl<$Res>
    extends _$ReferralStatsModelCopyWithImpl<$Res, _$ReferralStatsModelImpl>
    implements _$$ReferralStatsModelImplCopyWith<$Res> {
  __$$ReferralStatsModelImplCopyWithImpl(_$ReferralStatsModelImpl _value,
      $Res Function(_$ReferralStatsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReferrals = null,
    Object? successfulReferrals = null,
    Object? pendingReferrals = null,
    Object? monthsEarned = null,
  }) {
    return _then(_$ReferralStatsModelImpl(
      totalReferrals: null == totalReferrals
          ? _value.totalReferrals
          : totalReferrals // ignore: cast_nullable_to_non_nullable
              as int,
      successfulReferrals: null == successfulReferrals
          ? _value.successfulReferrals
          : successfulReferrals // ignore: cast_nullable_to_non_nullable
              as int,
      pendingReferrals: null == pendingReferrals
          ? _value.pendingReferrals
          : pendingReferrals // ignore: cast_nullable_to_non_nullable
              as int,
      monthsEarned: null == monthsEarned
          ? _value.monthsEarned
          : monthsEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralStatsModelImpl implements _ReferralStatsModel {
  const _$ReferralStatsModelImpl(
      {@JsonKey(name: 'total_referrals') this.totalReferrals = 0,
      @JsonKey(name: 'successful_referrals') this.successfulReferrals = 0,
      @JsonKey(name: 'pending_referrals') this.pendingReferrals = 0,
      @JsonKey(name: 'months_earned') this.monthsEarned = 0});

  factory _$ReferralStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralStatsModelImplFromJson(json);

  @override
  @JsonKey(name: 'total_referrals')
  final int totalReferrals;
  @override
  @JsonKey(name: 'successful_referrals')
  final int successfulReferrals;
  @override
  @JsonKey(name: 'pending_referrals')
  final int pendingReferrals;
  @override
  @JsonKey(name: 'months_earned')
  final int monthsEarned;

  @override
  String toString() {
    return 'ReferralStatsModel(totalReferrals: $totalReferrals, successfulReferrals: $successfulReferrals, pendingReferrals: $pendingReferrals, monthsEarned: $monthsEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralStatsModelImpl &&
            (identical(other.totalReferrals, totalReferrals) ||
                other.totalReferrals == totalReferrals) &&
            (identical(other.successfulReferrals, successfulReferrals) ||
                other.successfulReferrals == successfulReferrals) &&
            (identical(other.pendingReferrals, pendingReferrals) ||
                other.pendingReferrals == pendingReferrals) &&
            (identical(other.monthsEarned, monthsEarned) ||
                other.monthsEarned == monthsEarned));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalReferrals,
      successfulReferrals, pendingReferrals, monthsEarned);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralStatsModelImplCopyWith<_$ReferralStatsModelImpl> get copyWith =>
      __$$ReferralStatsModelImplCopyWithImpl<_$ReferralStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralStatsModelImplToJson(
      this,
    );
  }
}

abstract class _ReferralStatsModel implements ReferralStatsModel {
  const factory _ReferralStatsModel(
          {@JsonKey(name: 'total_referrals') final int totalReferrals,
          @JsonKey(name: 'successful_referrals') final int successfulReferrals,
          @JsonKey(name: 'pending_referrals') final int pendingReferrals,
          @JsonKey(name: 'months_earned') final int monthsEarned}) =
      _$ReferralStatsModelImpl;

  factory _ReferralStatsModel.fromJson(Map<String, dynamic> json) =
      _$ReferralStatsModelImpl.fromJson;

  @override
  @JsonKey(name: 'total_referrals')
  int get totalReferrals;
  @override
  @JsonKey(name: 'successful_referrals')
  int get successfulReferrals;
  @override
  @JsonKey(name: 'pending_referrals')
  int get pendingReferrals;
  @override
  @JsonKey(name: 'months_earned')
  int get monthsEarned;
  @override
  @JsonKey(ignore: true)
  _$$ReferralStatsModelImplCopyWith<_$ReferralStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanDetailsModel _$PlanDetailsModelFromJson(Map<String, dynamic> json) {
  return _PlanDetailsModel.fromJson(json);
}

/// @nodoc
mixin _$PlanDetailsModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_monthly')
  double get priceMonthly => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_yearly')
  double get priceYearly => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_extractions')
  int get monthlyExtractions => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_generations')
  int get monthlyGenerations => throw _privateConstructorUsedError;
  List<String> get features => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlanDetailsModelCopyWith<PlanDetailsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanDetailsModelCopyWith<$Res> {
  factory $PlanDetailsModelCopyWith(
          PlanDetailsModel value, $Res Function(PlanDetailsModel) then) =
      _$PlanDetailsModelCopyWithImpl<$Res, PlanDetailsModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'price_monthly') double priceMonthly,
      @JsonKey(name: 'price_yearly') double priceYearly,
      @JsonKey(name: 'monthly_extractions') int monthlyExtractions,
      @JsonKey(name: 'monthly_generations') int monthlyGenerations,
      List<String> features});
}

/// @nodoc
class _$PlanDetailsModelCopyWithImpl<$Res, $Val extends PlanDetailsModel>
    implements $PlanDetailsModelCopyWith<$Res> {
  _$PlanDetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? priceMonthly = null,
    Object? priceYearly = null,
    Object? monthlyExtractions = null,
    Object? monthlyGenerations = null,
    Object? features = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      priceMonthly: null == priceMonthly
          ? _value.priceMonthly
          : priceMonthly // ignore: cast_nullable_to_non_nullable
              as double,
      priceYearly: null == priceYearly
          ? _value.priceYearly
          : priceYearly // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyExtractions: null == monthlyExtractions
          ? _value.monthlyExtractions
          : monthlyExtractions // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGenerations: null == monthlyGenerations
          ? _value.monthlyGenerations
          : monthlyGenerations // ignore: cast_nullable_to_non_nullable
              as int,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanDetailsModelImplCopyWith<$Res>
    implements $PlanDetailsModelCopyWith<$Res> {
  factory _$$PlanDetailsModelImplCopyWith(_$PlanDetailsModelImpl value,
          $Res Function(_$PlanDetailsModelImpl) then) =
      __$$PlanDetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'price_monthly') double priceMonthly,
      @JsonKey(name: 'price_yearly') double priceYearly,
      @JsonKey(name: 'monthly_extractions') int monthlyExtractions,
      @JsonKey(name: 'monthly_generations') int monthlyGenerations,
      List<String> features});
}

/// @nodoc
class __$$PlanDetailsModelImplCopyWithImpl<$Res>
    extends _$PlanDetailsModelCopyWithImpl<$Res, _$PlanDetailsModelImpl>
    implements _$$PlanDetailsModelImplCopyWith<$Res> {
  __$$PlanDetailsModelImplCopyWithImpl(_$PlanDetailsModelImpl _value,
      $Res Function(_$PlanDetailsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? priceMonthly = null,
    Object? priceYearly = null,
    Object? monthlyExtractions = null,
    Object? monthlyGenerations = null,
    Object? features = null,
  }) {
    return _then(_$PlanDetailsModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      priceMonthly: null == priceMonthly
          ? _value.priceMonthly
          : priceMonthly // ignore: cast_nullable_to_non_nullable
              as double,
      priceYearly: null == priceYearly
          ? _value.priceYearly
          : priceYearly // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyExtractions: null == monthlyExtractions
          ? _value.monthlyExtractions
          : monthlyExtractions // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGenerations: null == monthlyGenerations
          ? _value.monthlyGenerations
          : monthlyGenerations // ignore: cast_nullable_to_non_nullable
              as int,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanDetailsModelImpl implements _PlanDetailsModel {
  const _$PlanDetailsModelImpl(
      {required this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'price_monthly') this.priceMonthly = 0.0,
      @JsonKey(name: 'price_yearly') this.priceYearly = 0.0,
      @JsonKey(name: 'monthly_extractions') this.monthlyExtractions = 25,
      @JsonKey(name: 'monthly_generations') this.monthlyGenerations = 50,
      final List<String> features = const []})
      : _features = features;

  factory _$PlanDetailsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanDetailsModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'price_monthly')
  final double priceMonthly;
  @override
  @JsonKey(name: 'price_yearly')
  final double priceYearly;
  @override
  @JsonKey(name: 'monthly_extractions')
  final int monthlyExtractions;
  @override
  @JsonKey(name: 'monthly_generations')
  final int monthlyGenerations;
  final List<String> _features;
  @override
  @JsonKey()
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  String toString() {
    return 'PlanDetailsModel(id: $id, name: $name, description: $description, priceMonthly: $priceMonthly, priceYearly: $priceYearly, monthlyExtractions: $monthlyExtractions, monthlyGenerations: $monthlyGenerations, features: $features)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanDetailsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priceMonthly, priceMonthly) ||
                other.priceMonthly == priceMonthly) &&
            (identical(other.priceYearly, priceYearly) ||
                other.priceYearly == priceYearly) &&
            (identical(other.monthlyExtractions, monthlyExtractions) ||
                other.monthlyExtractions == monthlyExtractions) &&
            (identical(other.monthlyGenerations, monthlyGenerations) ||
                other.monthlyGenerations == monthlyGenerations) &&
            const DeepCollectionEquality().equals(other._features, _features));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      priceMonthly,
      priceYearly,
      monthlyExtractions,
      monthlyGenerations,
      const DeepCollectionEquality().hash(_features));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanDetailsModelImplCopyWith<_$PlanDetailsModelImpl> get copyWith =>
      __$$PlanDetailsModelImplCopyWithImpl<_$PlanDetailsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanDetailsModelImplToJson(
      this,
    );
  }
}

abstract class _PlanDetailsModel implements PlanDetailsModel {
  const factory _PlanDetailsModel(
      {required final String id,
      required final String name,
      final String? description,
      @JsonKey(name: 'price_monthly') final double priceMonthly,
      @JsonKey(name: 'price_yearly') final double priceYearly,
      @JsonKey(name: 'monthly_extractions') final int monthlyExtractions,
      @JsonKey(name: 'monthly_generations') final int monthlyGenerations,
      final List<String> features}) = _$PlanDetailsModelImpl;

  factory _PlanDetailsModel.fromJson(Map<String, dynamic> json) =
      _$PlanDetailsModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'price_monthly')
  double get priceMonthly;
  @override
  @JsonKey(name: 'price_yearly')
  double get priceYearly;
  @override
  @JsonKey(name: 'monthly_extractions')
  int get monthlyExtractions;
  @override
  @JsonKey(name: 'monthly_generations')
  int get monthlyGenerations;
  @override
  List<String> get features;
  @override
  @JsonKey(ignore: true)
  _$$PlanDetailsModelImplCopyWith<_$PlanDetailsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CheckoutSessionModel _$CheckoutSessionModelFromJson(Map<String, dynamic> json) {
  return _CheckoutSessionModel.fromJson(json);
}

/// @nodoc
mixin _$CheckoutSessionModel {
  @JsonKey(name: 'checkout_url')
  String get checkoutUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckoutSessionModelCopyWith<CheckoutSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutSessionModelCopyWith<$Res> {
  factory $CheckoutSessionModelCopyWith(CheckoutSessionModel value,
          $Res Function(CheckoutSessionModel) then) =
      _$CheckoutSessionModelCopyWithImpl<$Res, CheckoutSessionModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'checkout_url') String checkoutUrl,
      @JsonKey(name: 'session_id') String sessionId});
}

/// @nodoc
class _$CheckoutSessionModelCopyWithImpl<$Res,
        $Val extends CheckoutSessionModel>
    implements $CheckoutSessionModelCopyWith<$Res> {
  _$CheckoutSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkoutUrl = null,
    Object? sessionId = null,
  }) {
    return _then(_value.copyWith(
      checkoutUrl: null == checkoutUrl
          ? _value.checkoutUrl
          : checkoutUrl // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckoutSessionModelImplCopyWith<$Res>
    implements $CheckoutSessionModelCopyWith<$Res> {
  factory _$$CheckoutSessionModelImplCopyWith(_$CheckoutSessionModelImpl value,
          $Res Function(_$CheckoutSessionModelImpl) then) =
      __$$CheckoutSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'checkout_url') String checkoutUrl,
      @JsonKey(name: 'session_id') String sessionId});
}

/// @nodoc
class __$$CheckoutSessionModelImplCopyWithImpl<$Res>
    extends _$CheckoutSessionModelCopyWithImpl<$Res, _$CheckoutSessionModelImpl>
    implements _$$CheckoutSessionModelImplCopyWith<$Res> {
  __$$CheckoutSessionModelImplCopyWithImpl(_$CheckoutSessionModelImpl _value,
      $Res Function(_$CheckoutSessionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkoutUrl = null,
    Object? sessionId = null,
  }) {
    return _then(_$CheckoutSessionModelImpl(
      checkoutUrl: null == checkoutUrl
          ? _value.checkoutUrl
          : checkoutUrl // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckoutSessionModelImpl implements _CheckoutSessionModel {
  const _$CheckoutSessionModelImpl(
      {@JsonKey(name: 'checkout_url') required this.checkoutUrl,
      @JsonKey(name: 'session_id') required this.sessionId});

  factory _$CheckoutSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckoutSessionModelImplFromJson(json);

  @override
  @JsonKey(name: 'checkout_url')
  final String checkoutUrl;
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  @override
  String toString() {
    return 'CheckoutSessionModel(checkoutUrl: $checkoutUrl, sessionId: $sessionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckoutSessionModelImpl &&
            (identical(other.checkoutUrl, checkoutUrl) ||
                other.checkoutUrl == checkoutUrl) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, checkoutUrl, sessionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckoutSessionModelImplCopyWith<_$CheckoutSessionModelImpl>
      get copyWith =>
          __$$CheckoutSessionModelImplCopyWithImpl<_$CheckoutSessionModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckoutSessionModelImplToJson(
      this,
    );
  }
}

abstract class _CheckoutSessionModel implements CheckoutSessionModel {
  const factory _CheckoutSessionModel(
          {@JsonKey(name: 'checkout_url') required final String checkoutUrl,
          @JsonKey(name: 'session_id') required final String sessionId}) =
      _$CheckoutSessionModelImpl;

  factory _CheckoutSessionModel.fromJson(Map<String, dynamic> json) =
      _$CheckoutSessionModelImpl.fromJson;

  @override
  @JsonKey(name: 'checkout_url')
  String get checkoutUrl;
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  @JsonKey(ignore: true)
  _$$CheckoutSessionModelImplCopyWith<_$CheckoutSessionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ValidateReferralResponse _$ValidateReferralResponseFromJson(
    Map<String, dynamic> json) {
  return _ValidateReferralResponse.fromJson(json);
}

/// @nodoc
mixin _$ValidateReferralResponse {
  bool get valid => throw _privateConstructorUsedError;
  @JsonKey(name: 'referrer_name')
  String? get referrerName => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValidateReferralResponseCopyWith<ValidateReferralResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidateReferralResponseCopyWith<$Res> {
  factory $ValidateReferralResponseCopyWith(ValidateReferralResponse value,
          $Res Function(ValidateReferralResponse) then) =
      _$ValidateReferralResponseCopyWithImpl<$Res, ValidateReferralResponse>;
  @useResult
  $Res call(
      {bool valid,
      @JsonKey(name: 'referrer_name') String? referrerName,
      String? error});
}

/// @nodoc
class _$ValidateReferralResponseCopyWithImpl<$Res,
        $Val extends ValidateReferralResponse>
    implements $ValidateReferralResponseCopyWith<$Res> {
  _$ValidateReferralResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valid = null,
    Object? referrerName = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      valid: null == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool,
      referrerName: freezed == referrerName
          ? _value.referrerName
          : referrerName // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidateReferralResponseImplCopyWith<$Res>
    implements $ValidateReferralResponseCopyWith<$Res> {
  factory _$$ValidateReferralResponseImplCopyWith(
          _$ValidateReferralResponseImpl value,
          $Res Function(_$ValidateReferralResponseImpl) then) =
      __$$ValidateReferralResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool valid,
      @JsonKey(name: 'referrer_name') String? referrerName,
      String? error});
}

/// @nodoc
class __$$ValidateReferralResponseImplCopyWithImpl<$Res>
    extends _$ValidateReferralResponseCopyWithImpl<$Res,
        _$ValidateReferralResponseImpl>
    implements _$$ValidateReferralResponseImplCopyWith<$Res> {
  __$$ValidateReferralResponseImplCopyWithImpl(
      _$ValidateReferralResponseImpl _value,
      $Res Function(_$ValidateReferralResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valid = null,
    Object? referrerName = freezed,
    Object? error = freezed,
  }) {
    return _then(_$ValidateReferralResponseImpl(
      valid: null == valid
          ? _value.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as bool,
      referrerName: freezed == referrerName
          ? _value.referrerName
          : referrerName // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidateReferralResponseImpl implements _ValidateReferralResponse {
  const _$ValidateReferralResponseImpl(
      {this.valid = false,
      @JsonKey(name: 'referrer_name') this.referrerName,
      this.error});

  factory _$ValidateReferralResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidateReferralResponseImplFromJson(json);

  @override
  @JsonKey()
  final bool valid;
  @override
  @JsonKey(name: 'referrer_name')
  final String? referrerName;
  @override
  final String? error;

  @override
  String toString() {
    return 'ValidateReferralResponse(valid: $valid, referrerName: $referrerName, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidateReferralResponseImpl &&
            (identical(other.valid, valid) || other.valid == valid) &&
            (identical(other.referrerName, referrerName) ||
                other.referrerName == referrerName) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, valid, referrerName, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidateReferralResponseImplCopyWith<_$ValidateReferralResponseImpl>
      get copyWith => __$$ValidateReferralResponseImplCopyWithImpl<
          _$ValidateReferralResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidateReferralResponseImplToJson(
      this,
    );
  }
}

abstract class _ValidateReferralResponse implements ValidateReferralResponse {
  const factory _ValidateReferralResponse(
      {final bool valid,
      @JsonKey(name: 'referrer_name') final String? referrerName,
      final String? error}) = _$ValidateReferralResponseImpl;

  factory _ValidateReferralResponse.fromJson(Map<String, dynamic> json) =
      _$ValidateReferralResponseImpl.fromJson;

  @override
  bool get valid;
  @override
  @JsonKey(name: 'referrer_name')
  String? get referrerName;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ValidateReferralResponseImplCopyWith<_$ValidateReferralResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
