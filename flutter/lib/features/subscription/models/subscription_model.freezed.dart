// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionModel {

@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'plan_type') PlanType get planType; SubscriptionStatus get status;@JsonKey(name: 'current_period_start') DateTime? get currentPeriodStart;@JsonKey(name: 'current_period_end') DateTime? get currentPeriodEnd;@JsonKey(name: 'cancel_at_period_end') bool get cancelAtPeriodEnd;@JsonKey(name: 'trial_end') DateTime? get trialEnd;@JsonKey(name: 'referral_credit_months') int get referralCreditMonths;
/// Create a copy of SubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionModelCopyWith<SubscriptionModel> get copyWith => _$SubscriptionModelCopyWithImpl<SubscriptionModel>(this as SubscriptionModel, _$identity);

  /// Serializes this SubscriptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.trialEnd, trialEnd) || other.trialEnd == trialEnd)&&(identical(other.referralCreditMonths, referralCreditMonths) || other.referralCreditMonths == referralCreditMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,planType,status,currentPeriodStart,currentPeriodEnd,cancelAtPeriodEnd,trialEnd,referralCreditMonths);

@override
String toString() {
  return 'SubscriptionModel(userId: $userId, planType: $planType, status: $status, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, cancelAtPeriodEnd: $cancelAtPeriodEnd, trialEnd: $trialEnd, referralCreditMonths: $referralCreditMonths)';
}


}

/// @nodoc
abstract mixin class $SubscriptionModelCopyWith<$Res>  {
  factory $SubscriptionModelCopyWith(SubscriptionModel value, $Res Function(SubscriptionModel) _then) = _$SubscriptionModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'plan_type') PlanType planType, SubscriptionStatus status,@JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'cancel_at_period_end') bool cancelAtPeriodEnd,@JsonKey(name: 'trial_end') DateTime? trialEnd,@JsonKey(name: 'referral_credit_months') int referralCreditMonths
});




}
/// @nodoc
class _$SubscriptionModelCopyWithImpl<$Res>
    implements $SubscriptionModelCopyWith<$Res> {
  _$SubscriptionModelCopyWithImpl(this._self, this._then);

  final SubscriptionModel _self;
  final $Res Function(SubscriptionModel) _then;

/// Create a copy of SubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? planType = null,Object? status = null,Object? currentPeriodStart = freezed,Object? currentPeriodEnd = freezed,Object? cancelAtPeriodEnd = null,Object? trialEnd = freezed,Object? referralCreditMonths = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,currentPeriodStart: freezed == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,trialEnd: freezed == trialEnd ? _self.trialEnd : trialEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,referralCreditMonths: null == referralCreditMonths ? _self.referralCreditMonths : referralCreditMonths // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionModel].
extension SubscriptionModelPatterns on SubscriptionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionModel value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'plan_type')  PlanType planType,  SubscriptionStatus status, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'cancel_at_period_end')  bool cancelAtPeriodEnd, @JsonKey(name: 'trial_end')  DateTime? trialEnd, @JsonKey(name: 'referral_credit_months')  int referralCreditMonths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionModel() when $default != null:
return $default(_that.userId,_that.planType,_that.status,_that.currentPeriodStart,_that.currentPeriodEnd,_that.cancelAtPeriodEnd,_that.trialEnd,_that.referralCreditMonths);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'plan_type')  PlanType planType,  SubscriptionStatus status, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'cancel_at_period_end')  bool cancelAtPeriodEnd, @JsonKey(name: 'trial_end')  DateTime? trialEnd, @JsonKey(name: 'referral_credit_months')  int referralCreditMonths)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionModel():
return $default(_that.userId,_that.planType,_that.status,_that.currentPeriodStart,_that.currentPeriodEnd,_that.cancelAtPeriodEnd,_that.trialEnd,_that.referralCreditMonths);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'plan_type')  PlanType planType,  SubscriptionStatus status, @JsonKey(name: 'current_period_start')  DateTime? currentPeriodStart, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'cancel_at_period_end')  bool cancelAtPeriodEnd, @JsonKey(name: 'trial_end')  DateTime? trialEnd, @JsonKey(name: 'referral_credit_months')  int referralCreditMonths)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionModel() when $default != null:
return $default(_that.userId,_that.planType,_that.status,_that.currentPeriodStart,_that.currentPeriodEnd,_that.cancelAtPeriodEnd,_that.trialEnd,_that.referralCreditMonths);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionModel implements SubscriptionModel {
  const _SubscriptionModel({@JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'plan_type') this.planType = PlanType.free, this.status = SubscriptionStatus.active, @JsonKey(name: 'current_period_start') this.currentPeriodStart, @JsonKey(name: 'current_period_end') this.currentPeriodEnd, @JsonKey(name: 'cancel_at_period_end') this.cancelAtPeriodEnd = false, @JsonKey(name: 'trial_end') this.trialEnd, @JsonKey(name: 'referral_credit_months') this.referralCreditMonths = 0});
  factory _SubscriptionModel.fromJson(Map<String, dynamic> json) => _$SubscriptionModelFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'plan_type') final  PlanType planType;
@override@JsonKey() final  SubscriptionStatus status;
@override@JsonKey(name: 'current_period_start') final  DateTime? currentPeriodStart;
@override@JsonKey(name: 'current_period_end') final  DateTime? currentPeriodEnd;
@override@JsonKey(name: 'cancel_at_period_end') final  bool cancelAtPeriodEnd;
@override@JsonKey(name: 'trial_end') final  DateTime? trialEnd;
@override@JsonKey(name: 'referral_credit_months') final  int referralCreditMonths;

/// Create a copy of SubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionModelCopyWith<_SubscriptionModel> get copyWith => __$SubscriptionModelCopyWithImpl<_SubscriptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.trialEnd, trialEnd) || other.trialEnd == trialEnd)&&(identical(other.referralCreditMonths, referralCreditMonths) || other.referralCreditMonths == referralCreditMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,planType,status,currentPeriodStart,currentPeriodEnd,cancelAtPeriodEnd,trialEnd,referralCreditMonths);

@override
String toString() {
  return 'SubscriptionModel(userId: $userId, planType: $planType, status: $status, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, cancelAtPeriodEnd: $cancelAtPeriodEnd, trialEnd: $trialEnd, referralCreditMonths: $referralCreditMonths)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionModelCopyWith<$Res> implements $SubscriptionModelCopyWith<$Res> {
  factory _$SubscriptionModelCopyWith(_SubscriptionModel value, $Res Function(_SubscriptionModel) _then) = __$SubscriptionModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'plan_type') PlanType planType, SubscriptionStatus status,@JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'cancel_at_period_end') bool cancelAtPeriodEnd,@JsonKey(name: 'trial_end') DateTime? trialEnd,@JsonKey(name: 'referral_credit_months') int referralCreditMonths
});




}
/// @nodoc
class __$SubscriptionModelCopyWithImpl<$Res>
    implements _$SubscriptionModelCopyWith<$Res> {
  __$SubscriptionModelCopyWithImpl(this._self, this._then);

  final _SubscriptionModel _self;
  final $Res Function(_SubscriptionModel) _then;

/// Create a copy of SubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? planType = null,Object? status = null,Object? currentPeriodStart = freezed,Object? currentPeriodEnd = freezed,Object? cancelAtPeriodEnd = null,Object? trialEnd = freezed,Object? referralCreditMonths = null,}) {
  return _then(_SubscriptionModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,currentPeriodStart: freezed == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,trialEnd: freezed == trialEnd ? _self.trialEnd : trialEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,referralCreditMonths: null == referralCreditMonths ? _self.referralCreditMonths : referralCreditMonths // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UsageLimitsModel {

@JsonKey(name: 'monthly_extractions') int get monthlyExtractions;@JsonKey(name: 'monthly_extractions_limit') int get monthlyExtractionsLimit;@JsonKey(name: 'monthly_generations') int get monthlyGenerations;@JsonKey(name: 'monthly_generations_limit') int get monthlyGenerationsLimit;@JsonKey(name: 'period_start') DateTime? get periodStart;@JsonKey(name: 'period_end') DateTime? get periodEnd;
/// Create a copy of UsageLimitsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsageLimitsModelCopyWith<UsageLimitsModel> get copyWith => _$UsageLimitsModelCopyWithImpl<UsageLimitsModel>(this as UsageLimitsModel, _$identity);

  /// Serializes this UsageLimitsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsageLimitsModel&&(identical(other.monthlyExtractions, monthlyExtractions) || other.monthlyExtractions == monthlyExtractions)&&(identical(other.monthlyExtractionsLimit, monthlyExtractionsLimit) || other.monthlyExtractionsLimit == monthlyExtractionsLimit)&&(identical(other.monthlyGenerations, monthlyGenerations) || other.monthlyGenerations == monthlyGenerations)&&(identical(other.monthlyGenerationsLimit, monthlyGenerationsLimit) || other.monthlyGenerationsLimit == monthlyGenerationsLimit)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,monthlyExtractions,monthlyExtractionsLimit,monthlyGenerations,monthlyGenerationsLimit,periodStart,periodEnd);

@override
String toString() {
  return 'UsageLimitsModel(monthlyExtractions: $monthlyExtractions, monthlyExtractionsLimit: $monthlyExtractionsLimit, monthlyGenerations: $monthlyGenerations, monthlyGenerationsLimit: $monthlyGenerationsLimit, periodStart: $periodStart, periodEnd: $periodEnd)';
}


}

/// @nodoc
abstract mixin class $UsageLimitsModelCopyWith<$Res>  {
  factory $UsageLimitsModelCopyWith(UsageLimitsModel value, $Res Function(UsageLimitsModel) _then) = _$UsageLimitsModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'monthly_extractions') int monthlyExtractions,@JsonKey(name: 'monthly_extractions_limit') int monthlyExtractionsLimit,@JsonKey(name: 'monthly_generations') int monthlyGenerations,@JsonKey(name: 'monthly_generations_limit') int monthlyGenerationsLimit,@JsonKey(name: 'period_start') DateTime? periodStart,@JsonKey(name: 'period_end') DateTime? periodEnd
});




}
/// @nodoc
class _$UsageLimitsModelCopyWithImpl<$Res>
    implements $UsageLimitsModelCopyWith<$Res> {
  _$UsageLimitsModelCopyWithImpl(this._self, this._then);

  final UsageLimitsModel _self;
  final $Res Function(UsageLimitsModel) _then;

/// Create a copy of UsageLimitsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthlyExtractions = null,Object? monthlyExtractionsLimit = null,Object? monthlyGenerations = null,Object? monthlyGenerationsLimit = null,Object? periodStart = freezed,Object? periodEnd = freezed,}) {
  return _then(_self.copyWith(
monthlyExtractions: null == monthlyExtractions ? _self.monthlyExtractions : monthlyExtractions // ignore: cast_nullable_to_non_nullable
as int,monthlyExtractionsLimit: null == monthlyExtractionsLimit ? _self.monthlyExtractionsLimit : monthlyExtractionsLimit // ignore: cast_nullable_to_non_nullable
as int,monthlyGenerations: null == monthlyGenerations ? _self.monthlyGenerations : monthlyGenerations // ignore: cast_nullable_to_non_nullable
as int,monthlyGenerationsLimit: null == monthlyGenerationsLimit ? _self.monthlyGenerationsLimit : monthlyGenerationsLimit // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UsageLimitsModel].
extension UsageLimitsModelPatterns on UsageLimitsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsageLimitsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsageLimitsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsageLimitsModel value)  $default,){
final _that = this;
switch (_that) {
case _UsageLimitsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsageLimitsModel value)?  $default,){
final _that = this;
switch (_that) {
case _UsageLimitsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'monthly_extractions')  int monthlyExtractions, @JsonKey(name: 'monthly_extractions_limit')  int monthlyExtractionsLimit, @JsonKey(name: 'monthly_generations')  int monthlyGenerations, @JsonKey(name: 'monthly_generations_limit')  int monthlyGenerationsLimit, @JsonKey(name: 'period_start')  DateTime? periodStart, @JsonKey(name: 'period_end')  DateTime? periodEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsageLimitsModel() when $default != null:
return $default(_that.monthlyExtractions,_that.monthlyExtractionsLimit,_that.monthlyGenerations,_that.monthlyGenerationsLimit,_that.periodStart,_that.periodEnd);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'monthly_extractions')  int monthlyExtractions, @JsonKey(name: 'monthly_extractions_limit')  int monthlyExtractionsLimit, @JsonKey(name: 'monthly_generations')  int monthlyGenerations, @JsonKey(name: 'monthly_generations_limit')  int monthlyGenerationsLimit, @JsonKey(name: 'period_start')  DateTime? periodStart, @JsonKey(name: 'period_end')  DateTime? periodEnd)  $default,) {final _that = this;
switch (_that) {
case _UsageLimitsModel():
return $default(_that.monthlyExtractions,_that.monthlyExtractionsLimit,_that.monthlyGenerations,_that.monthlyGenerationsLimit,_that.periodStart,_that.periodEnd);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'monthly_extractions')  int monthlyExtractions, @JsonKey(name: 'monthly_extractions_limit')  int monthlyExtractionsLimit, @JsonKey(name: 'monthly_generations')  int monthlyGenerations, @JsonKey(name: 'monthly_generations_limit')  int monthlyGenerationsLimit, @JsonKey(name: 'period_start')  DateTime? periodStart, @JsonKey(name: 'period_end')  DateTime? periodEnd)?  $default,) {final _that = this;
switch (_that) {
case _UsageLimitsModel() when $default != null:
return $default(_that.monthlyExtractions,_that.monthlyExtractionsLimit,_that.monthlyGenerations,_that.monthlyGenerationsLimit,_that.periodStart,_that.periodEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UsageLimitsModel implements UsageLimitsModel {
  const _UsageLimitsModel({@JsonKey(name: 'monthly_extractions') this.monthlyExtractions = 0, @JsonKey(name: 'monthly_extractions_limit') this.monthlyExtractionsLimit = 25, @JsonKey(name: 'monthly_generations') this.monthlyGenerations = 0, @JsonKey(name: 'monthly_generations_limit') this.monthlyGenerationsLimit = 50, @JsonKey(name: 'period_start') this.periodStart, @JsonKey(name: 'period_end') this.periodEnd});
  factory _UsageLimitsModel.fromJson(Map<String, dynamic> json) => _$UsageLimitsModelFromJson(json);

@override@JsonKey(name: 'monthly_extractions') final  int monthlyExtractions;
@override@JsonKey(name: 'monthly_extractions_limit') final  int monthlyExtractionsLimit;
@override@JsonKey(name: 'monthly_generations') final  int monthlyGenerations;
@override@JsonKey(name: 'monthly_generations_limit') final  int monthlyGenerationsLimit;
@override@JsonKey(name: 'period_start') final  DateTime? periodStart;
@override@JsonKey(name: 'period_end') final  DateTime? periodEnd;

/// Create a copy of UsageLimitsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsageLimitsModelCopyWith<_UsageLimitsModel> get copyWith => __$UsageLimitsModelCopyWithImpl<_UsageLimitsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsageLimitsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsageLimitsModel&&(identical(other.monthlyExtractions, monthlyExtractions) || other.monthlyExtractions == monthlyExtractions)&&(identical(other.monthlyExtractionsLimit, monthlyExtractionsLimit) || other.monthlyExtractionsLimit == monthlyExtractionsLimit)&&(identical(other.monthlyGenerations, monthlyGenerations) || other.monthlyGenerations == monthlyGenerations)&&(identical(other.monthlyGenerationsLimit, monthlyGenerationsLimit) || other.monthlyGenerationsLimit == monthlyGenerationsLimit)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,monthlyExtractions,monthlyExtractionsLimit,monthlyGenerations,monthlyGenerationsLimit,periodStart,periodEnd);

@override
String toString() {
  return 'UsageLimitsModel(monthlyExtractions: $monthlyExtractions, monthlyExtractionsLimit: $monthlyExtractionsLimit, monthlyGenerations: $monthlyGenerations, monthlyGenerationsLimit: $monthlyGenerationsLimit, periodStart: $periodStart, periodEnd: $periodEnd)';
}


}

/// @nodoc
abstract mixin class _$UsageLimitsModelCopyWith<$Res> implements $UsageLimitsModelCopyWith<$Res> {
  factory _$UsageLimitsModelCopyWith(_UsageLimitsModel value, $Res Function(_UsageLimitsModel) _then) = __$UsageLimitsModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'monthly_extractions') int monthlyExtractions,@JsonKey(name: 'monthly_extractions_limit') int monthlyExtractionsLimit,@JsonKey(name: 'monthly_generations') int monthlyGenerations,@JsonKey(name: 'monthly_generations_limit') int monthlyGenerationsLimit,@JsonKey(name: 'period_start') DateTime? periodStart,@JsonKey(name: 'period_end') DateTime? periodEnd
});




}
/// @nodoc
class __$UsageLimitsModelCopyWithImpl<$Res>
    implements _$UsageLimitsModelCopyWith<$Res> {
  __$UsageLimitsModelCopyWithImpl(this._self, this._then);

  final _UsageLimitsModel _self;
  final $Res Function(_UsageLimitsModel) _then;

/// Create a copy of UsageLimitsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthlyExtractions = null,Object? monthlyExtractionsLimit = null,Object? monthlyGenerations = null,Object? monthlyGenerationsLimit = null,Object? periodStart = freezed,Object? periodEnd = freezed,}) {
  return _then(_UsageLimitsModel(
monthlyExtractions: null == monthlyExtractions ? _self.monthlyExtractions : monthlyExtractions // ignore: cast_nullable_to_non_nullable
as int,monthlyExtractionsLimit: null == monthlyExtractionsLimit ? _self.monthlyExtractionsLimit : monthlyExtractionsLimit // ignore: cast_nullable_to_non_nullable
as int,monthlyGenerations: null == monthlyGenerations ? _self.monthlyGenerations : monthlyGenerations // ignore: cast_nullable_to_non_nullable
as int,monthlyGenerationsLimit: null == monthlyGenerationsLimit ? _self.monthlyGenerationsLimit : monthlyGenerationsLimit // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SubscriptionWithUsage {

 SubscriptionModel get subscription; UsageLimitsModel get usage;
/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionWithUsageCopyWith<SubscriptionWithUsage> get copyWith => _$SubscriptionWithUsageCopyWithImpl<SubscriptionWithUsage>(this as SubscriptionWithUsage, _$identity);

  /// Serializes this SubscriptionWithUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionWithUsage&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subscription,usage);

@override
String toString() {
  return 'SubscriptionWithUsage(subscription: $subscription, usage: $usage)';
}


}

/// @nodoc
abstract mixin class $SubscriptionWithUsageCopyWith<$Res>  {
  factory $SubscriptionWithUsageCopyWith(SubscriptionWithUsage value, $Res Function(SubscriptionWithUsage) _then) = _$SubscriptionWithUsageCopyWithImpl;
@useResult
$Res call({
 SubscriptionModel subscription, UsageLimitsModel usage
});


$SubscriptionModelCopyWith<$Res> get subscription;$UsageLimitsModelCopyWith<$Res> get usage;

}
/// @nodoc
class _$SubscriptionWithUsageCopyWithImpl<$Res>
    implements $SubscriptionWithUsageCopyWith<$Res> {
  _$SubscriptionWithUsageCopyWithImpl(this._self, this._then);

  final SubscriptionWithUsage _self;
  final $Res Function(SubscriptionWithUsage) _then;

/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = null,Object? usage = null,}) {
  return _then(_self.copyWith(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionModel,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as UsageLimitsModel,
  ));
}
/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionModelCopyWith<$Res> get subscription {
  
  return $SubscriptionModelCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageLimitsModelCopyWith<$Res> get usage {
  
  return $UsageLimitsModelCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscriptionWithUsage].
extension SubscriptionWithUsagePatterns on SubscriptionWithUsage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionWithUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionWithUsage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionWithUsage value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionWithUsage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionWithUsage value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionWithUsage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SubscriptionModel subscription,  UsageLimitsModel usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionWithUsage() when $default != null:
return $default(_that.subscription,_that.usage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SubscriptionModel subscription,  UsageLimitsModel usage)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionWithUsage():
return $default(_that.subscription,_that.usage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SubscriptionModel subscription,  UsageLimitsModel usage)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionWithUsage() when $default != null:
return $default(_that.subscription,_that.usage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionWithUsage implements SubscriptionWithUsage {
  const _SubscriptionWithUsage({required this.subscription, required this.usage});
  factory _SubscriptionWithUsage.fromJson(Map<String, dynamic> json) => _$SubscriptionWithUsageFromJson(json);

@override final  SubscriptionModel subscription;
@override final  UsageLimitsModel usage;

/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionWithUsageCopyWith<_SubscriptionWithUsage> get copyWith => __$SubscriptionWithUsageCopyWithImpl<_SubscriptionWithUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionWithUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionWithUsage&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subscription,usage);

@override
String toString() {
  return 'SubscriptionWithUsage(subscription: $subscription, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionWithUsageCopyWith<$Res> implements $SubscriptionWithUsageCopyWith<$Res> {
  factory _$SubscriptionWithUsageCopyWith(_SubscriptionWithUsage value, $Res Function(_SubscriptionWithUsage) _then) = __$SubscriptionWithUsageCopyWithImpl;
@override @useResult
$Res call({
 SubscriptionModel subscription, UsageLimitsModel usage
});


@override $SubscriptionModelCopyWith<$Res> get subscription;@override $UsageLimitsModelCopyWith<$Res> get usage;

}
/// @nodoc
class __$SubscriptionWithUsageCopyWithImpl<$Res>
    implements _$SubscriptionWithUsageCopyWith<$Res> {
  __$SubscriptionWithUsageCopyWithImpl(this._self, this._then);

  final _SubscriptionWithUsage _self;
  final $Res Function(_SubscriptionWithUsage) _then;

/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = null,Object? usage = null,}) {
  return _then(_SubscriptionWithUsage(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SubscriptionModel,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as UsageLimitsModel,
  ));
}

/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionModelCopyWith<$Res> get subscription {
  
  return $SubscriptionModelCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SubscriptionWithUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageLimitsModelCopyWith<$Res> get usage {
  
  return $UsageLimitsModelCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// @nodoc
mixin _$ReferralCodeModel {

 String get code;@JsonKey(name: 'share_url') String get shareUrl;@JsonKey(name: 'times_used') int get timesUsed;@JsonKey(name: 'referrer_name') String? get referrerName;
/// Create a copy of ReferralCodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferralCodeModelCopyWith<ReferralCodeModel> get copyWith => _$ReferralCodeModelCopyWithImpl<ReferralCodeModel>(this as ReferralCodeModel, _$identity);

  /// Serializes this ReferralCodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferralCodeModel&&(identical(other.code, code) || other.code == code)&&(identical(other.shareUrl, shareUrl) || other.shareUrl == shareUrl)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&(identical(other.referrerName, referrerName) || other.referrerName == referrerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,shareUrl,timesUsed,referrerName);

@override
String toString() {
  return 'ReferralCodeModel(code: $code, shareUrl: $shareUrl, timesUsed: $timesUsed, referrerName: $referrerName)';
}


}

/// @nodoc
abstract mixin class $ReferralCodeModelCopyWith<$Res>  {
  factory $ReferralCodeModelCopyWith(ReferralCodeModel value, $Res Function(ReferralCodeModel) _then) = _$ReferralCodeModelCopyWithImpl;
@useResult
$Res call({
 String code,@JsonKey(name: 'share_url') String shareUrl,@JsonKey(name: 'times_used') int timesUsed,@JsonKey(name: 'referrer_name') String? referrerName
});




}
/// @nodoc
class _$ReferralCodeModelCopyWithImpl<$Res>
    implements $ReferralCodeModelCopyWith<$Res> {
  _$ReferralCodeModelCopyWithImpl(this._self, this._then);

  final ReferralCodeModel _self;
  final $Res Function(ReferralCodeModel) _then;

/// Create a copy of ReferralCodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? shareUrl = null,Object? timesUsed = null,Object? referrerName = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,shareUrl: null == shareUrl ? _self.shareUrl : shareUrl // ignore: cast_nullable_to_non_nullable
as String,timesUsed: null == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int,referrerName: freezed == referrerName ? _self.referrerName : referrerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferralCodeModel].
extension ReferralCodeModelPatterns on ReferralCodeModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferralCodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferralCodeModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferralCodeModel value)  $default,){
final _that = this;
switch (_that) {
case _ReferralCodeModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferralCodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReferralCodeModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'share_url')  String shareUrl, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'referrer_name')  String? referrerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferralCodeModel() when $default != null:
return $default(_that.code,_that.shareUrl,_that.timesUsed,_that.referrerName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'share_url')  String shareUrl, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'referrer_name')  String? referrerName)  $default,) {final _that = this;
switch (_that) {
case _ReferralCodeModel():
return $default(_that.code,_that.shareUrl,_that.timesUsed,_that.referrerName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code, @JsonKey(name: 'share_url')  String shareUrl, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'referrer_name')  String? referrerName)?  $default,) {final _that = this;
switch (_that) {
case _ReferralCodeModel() when $default != null:
return $default(_that.code,_that.shareUrl,_that.timesUsed,_that.referrerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReferralCodeModel implements ReferralCodeModel {
  const _ReferralCodeModel({required this.code, @JsonKey(name: 'share_url') required this.shareUrl, @JsonKey(name: 'times_used') this.timesUsed = 0, @JsonKey(name: 'referrer_name') this.referrerName});
  factory _ReferralCodeModel.fromJson(Map<String, dynamic> json) => _$ReferralCodeModelFromJson(json);

@override final  String code;
@override@JsonKey(name: 'share_url') final  String shareUrl;
@override@JsonKey(name: 'times_used') final  int timesUsed;
@override@JsonKey(name: 'referrer_name') final  String? referrerName;

/// Create a copy of ReferralCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferralCodeModelCopyWith<_ReferralCodeModel> get copyWith => __$ReferralCodeModelCopyWithImpl<_ReferralCodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferralCodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferralCodeModel&&(identical(other.code, code) || other.code == code)&&(identical(other.shareUrl, shareUrl) || other.shareUrl == shareUrl)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&(identical(other.referrerName, referrerName) || other.referrerName == referrerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,shareUrl,timesUsed,referrerName);

@override
String toString() {
  return 'ReferralCodeModel(code: $code, shareUrl: $shareUrl, timesUsed: $timesUsed, referrerName: $referrerName)';
}


}

/// @nodoc
abstract mixin class _$ReferralCodeModelCopyWith<$Res> implements $ReferralCodeModelCopyWith<$Res> {
  factory _$ReferralCodeModelCopyWith(_ReferralCodeModel value, $Res Function(_ReferralCodeModel) _then) = __$ReferralCodeModelCopyWithImpl;
@override @useResult
$Res call({
 String code,@JsonKey(name: 'share_url') String shareUrl,@JsonKey(name: 'times_used') int timesUsed,@JsonKey(name: 'referrer_name') String? referrerName
});




}
/// @nodoc
class __$ReferralCodeModelCopyWithImpl<$Res>
    implements _$ReferralCodeModelCopyWith<$Res> {
  __$ReferralCodeModelCopyWithImpl(this._self, this._then);

  final _ReferralCodeModel _self;
  final $Res Function(_ReferralCodeModel) _then;

/// Create a copy of ReferralCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? shareUrl = null,Object? timesUsed = null,Object? referrerName = freezed,}) {
  return _then(_ReferralCodeModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,shareUrl: null == shareUrl ? _self.shareUrl : shareUrl // ignore: cast_nullable_to_non_nullable
as String,timesUsed: null == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int,referrerName: freezed == referrerName ? _self.referrerName : referrerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReferralStatsModel {

@JsonKey(name: 'total_referrals') int get totalReferrals;@JsonKey(name: 'successful_referrals') int get successfulReferrals;@JsonKey(name: 'pending_referrals') int get pendingReferrals;@JsonKey(name: 'months_earned') int get monthsEarned;
/// Create a copy of ReferralStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferralStatsModelCopyWith<ReferralStatsModel> get copyWith => _$ReferralStatsModelCopyWithImpl<ReferralStatsModel>(this as ReferralStatsModel, _$identity);

  /// Serializes this ReferralStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferralStatsModel&&(identical(other.totalReferrals, totalReferrals) || other.totalReferrals == totalReferrals)&&(identical(other.successfulReferrals, successfulReferrals) || other.successfulReferrals == successfulReferrals)&&(identical(other.pendingReferrals, pendingReferrals) || other.pendingReferrals == pendingReferrals)&&(identical(other.monthsEarned, monthsEarned) || other.monthsEarned == monthsEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReferrals,successfulReferrals,pendingReferrals,monthsEarned);

@override
String toString() {
  return 'ReferralStatsModel(totalReferrals: $totalReferrals, successfulReferrals: $successfulReferrals, pendingReferrals: $pendingReferrals, monthsEarned: $monthsEarned)';
}


}

/// @nodoc
abstract mixin class $ReferralStatsModelCopyWith<$Res>  {
  factory $ReferralStatsModelCopyWith(ReferralStatsModel value, $Res Function(ReferralStatsModel) _then) = _$ReferralStatsModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_referrals') int totalReferrals,@JsonKey(name: 'successful_referrals') int successfulReferrals,@JsonKey(name: 'pending_referrals') int pendingReferrals,@JsonKey(name: 'months_earned') int monthsEarned
});




}
/// @nodoc
class _$ReferralStatsModelCopyWithImpl<$Res>
    implements $ReferralStatsModelCopyWith<$Res> {
  _$ReferralStatsModelCopyWithImpl(this._self, this._then);

  final ReferralStatsModel _self;
  final $Res Function(ReferralStatsModel) _then;

/// Create a copy of ReferralStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalReferrals = null,Object? successfulReferrals = null,Object? pendingReferrals = null,Object? monthsEarned = null,}) {
  return _then(_self.copyWith(
totalReferrals: null == totalReferrals ? _self.totalReferrals : totalReferrals // ignore: cast_nullable_to_non_nullable
as int,successfulReferrals: null == successfulReferrals ? _self.successfulReferrals : successfulReferrals // ignore: cast_nullable_to_non_nullable
as int,pendingReferrals: null == pendingReferrals ? _self.pendingReferrals : pendingReferrals // ignore: cast_nullable_to_non_nullable
as int,monthsEarned: null == monthsEarned ? _self.monthsEarned : monthsEarned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferralStatsModel].
extension ReferralStatsModelPatterns on ReferralStatsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferralStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferralStatsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferralStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _ReferralStatsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferralStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReferralStatsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_referrals')  int totalReferrals, @JsonKey(name: 'successful_referrals')  int successfulReferrals, @JsonKey(name: 'pending_referrals')  int pendingReferrals, @JsonKey(name: 'months_earned')  int monthsEarned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferralStatsModel() when $default != null:
return $default(_that.totalReferrals,_that.successfulReferrals,_that.pendingReferrals,_that.monthsEarned);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_referrals')  int totalReferrals, @JsonKey(name: 'successful_referrals')  int successfulReferrals, @JsonKey(name: 'pending_referrals')  int pendingReferrals, @JsonKey(name: 'months_earned')  int monthsEarned)  $default,) {final _that = this;
switch (_that) {
case _ReferralStatsModel():
return $default(_that.totalReferrals,_that.successfulReferrals,_that.pendingReferrals,_that.monthsEarned);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_referrals')  int totalReferrals, @JsonKey(name: 'successful_referrals')  int successfulReferrals, @JsonKey(name: 'pending_referrals')  int pendingReferrals, @JsonKey(name: 'months_earned')  int monthsEarned)?  $default,) {final _that = this;
switch (_that) {
case _ReferralStatsModel() when $default != null:
return $default(_that.totalReferrals,_that.successfulReferrals,_that.pendingReferrals,_that.monthsEarned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReferralStatsModel implements ReferralStatsModel {
  const _ReferralStatsModel({@JsonKey(name: 'total_referrals') this.totalReferrals = 0, @JsonKey(name: 'successful_referrals') this.successfulReferrals = 0, @JsonKey(name: 'pending_referrals') this.pendingReferrals = 0, @JsonKey(name: 'months_earned') this.monthsEarned = 0});
  factory _ReferralStatsModel.fromJson(Map<String, dynamic> json) => _$ReferralStatsModelFromJson(json);

@override@JsonKey(name: 'total_referrals') final  int totalReferrals;
@override@JsonKey(name: 'successful_referrals') final  int successfulReferrals;
@override@JsonKey(name: 'pending_referrals') final  int pendingReferrals;
@override@JsonKey(name: 'months_earned') final  int monthsEarned;

/// Create a copy of ReferralStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferralStatsModelCopyWith<_ReferralStatsModel> get copyWith => __$ReferralStatsModelCopyWithImpl<_ReferralStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferralStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferralStatsModel&&(identical(other.totalReferrals, totalReferrals) || other.totalReferrals == totalReferrals)&&(identical(other.successfulReferrals, successfulReferrals) || other.successfulReferrals == successfulReferrals)&&(identical(other.pendingReferrals, pendingReferrals) || other.pendingReferrals == pendingReferrals)&&(identical(other.monthsEarned, monthsEarned) || other.monthsEarned == monthsEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReferrals,successfulReferrals,pendingReferrals,monthsEarned);

@override
String toString() {
  return 'ReferralStatsModel(totalReferrals: $totalReferrals, successfulReferrals: $successfulReferrals, pendingReferrals: $pendingReferrals, monthsEarned: $monthsEarned)';
}


}

/// @nodoc
abstract mixin class _$ReferralStatsModelCopyWith<$Res> implements $ReferralStatsModelCopyWith<$Res> {
  factory _$ReferralStatsModelCopyWith(_ReferralStatsModel value, $Res Function(_ReferralStatsModel) _then) = __$ReferralStatsModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_referrals') int totalReferrals,@JsonKey(name: 'successful_referrals') int successfulReferrals,@JsonKey(name: 'pending_referrals') int pendingReferrals,@JsonKey(name: 'months_earned') int monthsEarned
});




}
/// @nodoc
class __$ReferralStatsModelCopyWithImpl<$Res>
    implements _$ReferralStatsModelCopyWith<$Res> {
  __$ReferralStatsModelCopyWithImpl(this._self, this._then);

  final _ReferralStatsModel _self;
  final $Res Function(_ReferralStatsModel) _then;

/// Create a copy of ReferralStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalReferrals = null,Object? successfulReferrals = null,Object? pendingReferrals = null,Object? monthsEarned = null,}) {
  return _then(_ReferralStatsModel(
totalReferrals: null == totalReferrals ? _self.totalReferrals : totalReferrals // ignore: cast_nullable_to_non_nullable
as int,successfulReferrals: null == successfulReferrals ? _self.successfulReferrals : successfulReferrals // ignore: cast_nullable_to_non_nullable
as int,pendingReferrals: null == pendingReferrals ? _self.pendingReferrals : pendingReferrals // ignore: cast_nullable_to_non_nullable
as int,monthsEarned: null == monthsEarned ? _self.monthsEarned : monthsEarned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PlanDetailsModel {

 String get id; String get name; String? get description;@JsonKey(name: 'price_monthly') double get priceMonthly;@JsonKey(name: 'price_yearly') double get priceYearly;@JsonKey(name: 'monthly_extractions') int get monthlyExtractions;@JsonKey(name: 'monthly_generations') int get monthlyGenerations; List<String> get features;
/// Create a copy of PlanDetailsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanDetailsModelCopyWith<PlanDetailsModel> get copyWith => _$PlanDetailsModelCopyWithImpl<PlanDetailsModel>(this as PlanDetailsModel, _$identity);

  /// Serializes this PlanDetailsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanDetailsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceMonthly, priceMonthly) || other.priceMonthly == priceMonthly)&&(identical(other.priceYearly, priceYearly) || other.priceYearly == priceYearly)&&(identical(other.monthlyExtractions, monthlyExtractions) || other.monthlyExtractions == monthlyExtractions)&&(identical(other.monthlyGenerations, monthlyGenerations) || other.monthlyGenerations == monthlyGenerations)&&const DeepCollectionEquality().equals(other.features, features));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,priceMonthly,priceYearly,monthlyExtractions,monthlyGenerations,const DeepCollectionEquality().hash(features));

@override
String toString() {
  return 'PlanDetailsModel(id: $id, name: $name, description: $description, priceMonthly: $priceMonthly, priceYearly: $priceYearly, monthlyExtractions: $monthlyExtractions, monthlyGenerations: $monthlyGenerations, features: $features)';
}


}

/// @nodoc
abstract mixin class $PlanDetailsModelCopyWith<$Res>  {
  factory $PlanDetailsModelCopyWith(PlanDetailsModel value, $Res Function(PlanDetailsModel) _then) = _$PlanDetailsModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'price_monthly') double priceMonthly,@JsonKey(name: 'price_yearly') double priceYearly,@JsonKey(name: 'monthly_extractions') int monthlyExtractions,@JsonKey(name: 'monthly_generations') int monthlyGenerations, List<String> features
});




}
/// @nodoc
class _$PlanDetailsModelCopyWithImpl<$Res>
    implements $PlanDetailsModelCopyWith<$Res> {
  _$PlanDetailsModelCopyWithImpl(this._self, this._then);

  final PlanDetailsModel _self;
  final $Res Function(PlanDetailsModel) _then;

/// Create a copy of PlanDetailsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? priceMonthly = null,Object? priceYearly = null,Object? monthlyExtractions = null,Object? monthlyGenerations = null,Object? features = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priceMonthly: null == priceMonthly ? _self.priceMonthly : priceMonthly // ignore: cast_nullable_to_non_nullable
as double,priceYearly: null == priceYearly ? _self.priceYearly : priceYearly // ignore: cast_nullable_to_non_nullable
as double,monthlyExtractions: null == monthlyExtractions ? _self.monthlyExtractions : monthlyExtractions // ignore: cast_nullable_to_non_nullable
as int,monthlyGenerations: null == monthlyGenerations ? _self.monthlyGenerations : monthlyGenerations // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanDetailsModel].
extension PlanDetailsModelPatterns on PlanDetailsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanDetailsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanDetailsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanDetailsModel value)  $default,){
final _that = this;
switch (_that) {
case _PlanDetailsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanDetailsModel value)?  $default,){
final _that = this;
switch (_that) {
case _PlanDetailsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(name: 'price_monthly')  double priceMonthly, @JsonKey(name: 'price_yearly')  double priceYearly, @JsonKey(name: 'monthly_extractions')  int monthlyExtractions, @JsonKey(name: 'monthly_generations')  int monthlyGenerations,  List<String> features)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanDetailsModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.priceMonthly,_that.priceYearly,_that.monthlyExtractions,_that.monthlyGenerations,_that.features);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(name: 'price_monthly')  double priceMonthly, @JsonKey(name: 'price_yearly')  double priceYearly, @JsonKey(name: 'monthly_extractions')  int monthlyExtractions, @JsonKey(name: 'monthly_generations')  int monthlyGenerations,  List<String> features)  $default,) {final _that = this;
switch (_that) {
case _PlanDetailsModel():
return $default(_that.id,_that.name,_that.description,_that.priceMonthly,_that.priceYearly,_that.monthlyExtractions,_that.monthlyGenerations,_that.features);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description, @JsonKey(name: 'price_monthly')  double priceMonthly, @JsonKey(name: 'price_yearly')  double priceYearly, @JsonKey(name: 'monthly_extractions')  int monthlyExtractions, @JsonKey(name: 'monthly_generations')  int monthlyGenerations,  List<String> features)?  $default,) {final _that = this;
switch (_that) {
case _PlanDetailsModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.priceMonthly,_that.priceYearly,_that.monthlyExtractions,_that.monthlyGenerations,_that.features);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanDetailsModel implements PlanDetailsModel {
  const _PlanDetailsModel({required this.id, required this.name, this.description, @JsonKey(name: 'price_monthly') this.priceMonthly = 0.0, @JsonKey(name: 'price_yearly') this.priceYearly = 0.0, @JsonKey(name: 'monthly_extractions') this.monthlyExtractions = 25, @JsonKey(name: 'monthly_generations') this.monthlyGenerations = 50, final  List<String> features = const []}): _features = features;
  factory _PlanDetailsModel.fromJson(Map<String, dynamic> json) => _$PlanDetailsModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey(name: 'price_monthly') final  double priceMonthly;
@override@JsonKey(name: 'price_yearly') final  double priceYearly;
@override@JsonKey(name: 'monthly_extractions') final  int monthlyExtractions;
@override@JsonKey(name: 'monthly_generations') final  int monthlyGenerations;
 final  List<String> _features;
@override@JsonKey() List<String> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}


/// Create a copy of PlanDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanDetailsModelCopyWith<_PlanDetailsModel> get copyWith => __$PlanDetailsModelCopyWithImpl<_PlanDetailsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanDetailsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanDetailsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceMonthly, priceMonthly) || other.priceMonthly == priceMonthly)&&(identical(other.priceYearly, priceYearly) || other.priceYearly == priceYearly)&&(identical(other.monthlyExtractions, monthlyExtractions) || other.monthlyExtractions == monthlyExtractions)&&(identical(other.monthlyGenerations, monthlyGenerations) || other.monthlyGenerations == monthlyGenerations)&&const DeepCollectionEquality().equals(other._features, _features));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,priceMonthly,priceYearly,monthlyExtractions,monthlyGenerations,const DeepCollectionEquality().hash(_features));

@override
String toString() {
  return 'PlanDetailsModel(id: $id, name: $name, description: $description, priceMonthly: $priceMonthly, priceYearly: $priceYearly, monthlyExtractions: $monthlyExtractions, monthlyGenerations: $monthlyGenerations, features: $features)';
}


}

/// @nodoc
abstract mixin class _$PlanDetailsModelCopyWith<$Res> implements $PlanDetailsModelCopyWith<$Res> {
  factory _$PlanDetailsModelCopyWith(_PlanDetailsModel value, $Res Function(_PlanDetailsModel) _then) = __$PlanDetailsModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'price_monthly') double priceMonthly,@JsonKey(name: 'price_yearly') double priceYearly,@JsonKey(name: 'monthly_extractions') int monthlyExtractions,@JsonKey(name: 'monthly_generations') int monthlyGenerations, List<String> features
});




}
/// @nodoc
class __$PlanDetailsModelCopyWithImpl<$Res>
    implements _$PlanDetailsModelCopyWith<$Res> {
  __$PlanDetailsModelCopyWithImpl(this._self, this._then);

  final _PlanDetailsModel _self;
  final $Res Function(_PlanDetailsModel) _then;

/// Create a copy of PlanDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? priceMonthly = null,Object? priceYearly = null,Object? monthlyExtractions = null,Object? monthlyGenerations = null,Object? features = null,}) {
  return _then(_PlanDetailsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priceMonthly: null == priceMonthly ? _self.priceMonthly : priceMonthly // ignore: cast_nullable_to_non_nullable
as double,priceYearly: null == priceYearly ? _self.priceYearly : priceYearly // ignore: cast_nullable_to_non_nullable
as double,monthlyExtractions: null == monthlyExtractions ? _self.monthlyExtractions : monthlyExtractions // ignore: cast_nullable_to_non_nullable
as int,monthlyGenerations: null == monthlyGenerations ? _self.monthlyGenerations : monthlyGenerations // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CheckoutSessionModel {

@JsonKey(name: 'checkout_url') String get checkoutUrl;@JsonKey(name: 'session_id') String get sessionId;
/// Create a copy of CheckoutSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutSessionModelCopyWith<CheckoutSessionModel> get copyWith => _$CheckoutSessionModelCopyWithImpl<CheckoutSessionModel>(this as CheckoutSessionModel, _$identity);

  /// Serializes this CheckoutSessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutSessionModel&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkoutUrl,sessionId);

@override
String toString() {
  return 'CheckoutSessionModel(checkoutUrl: $checkoutUrl, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $CheckoutSessionModelCopyWith<$Res>  {
  factory $CheckoutSessionModelCopyWith(CheckoutSessionModel value, $Res Function(CheckoutSessionModel) _then) = _$CheckoutSessionModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'checkout_url') String checkoutUrl,@JsonKey(name: 'session_id') String sessionId
});




}
/// @nodoc
class _$CheckoutSessionModelCopyWithImpl<$Res>
    implements $CheckoutSessionModelCopyWith<$Res> {
  _$CheckoutSessionModelCopyWithImpl(this._self, this._then);

  final CheckoutSessionModel _self;
  final $Res Function(CheckoutSessionModel) _then;

/// Create a copy of CheckoutSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkoutUrl = null,Object? sessionId = null,}) {
  return _then(_self.copyWith(
checkoutUrl: null == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutSessionModel].
extension CheckoutSessionModelPatterns on CheckoutSessionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutSessionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutSessionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutSessionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'checkout_url')  String checkoutUrl, @JsonKey(name: 'session_id')  String sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutSessionModel() when $default != null:
return $default(_that.checkoutUrl,_that.sessionId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'checkout_url')  String checkoutUrl, @JsonKey(name: 'session_id')  String sessionId)  $default,) {final _that = this;
switch (_that) {
case _CheckoutSessionModel():
return $default(_that.checkoutUrl,_that.sessionId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'checkout_url')  String checkoutUrl, @JsonKey(name: 'session_id')  String sessionId)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutSessionModel() when $default != null:
return $default(_that.checkoutUrl,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutSessionModel implements CheckoutSessionModel {
  const _CheckoutSessionModel({@JsonKey(name: 'checkout_url') required this.checkoutUrl, @JsonKey(name: 'session_id') required this.sessionId});
  factory _CheckoutSessionModel.fromJson(Map<String, dynamic> json) => _$CheckoutSessionModelFromJson(json);

@override@JsonKey(name: 'checkout_url') final  String checkoutUrl;
@override@JsonKey(name: 'session_id') final  String sessionId;

/// Create a copy of CheckoutSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutSessionModelCopyWith<_CheckoutSessionModel> get copyWith => __$CheckoutSessionModelCopyWithImpl<_CheckoutSessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutSessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutSessionModel&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkoutUrl,sessionId);

@override
String toString() {
  return 'CheckoutSessionModel(checkoutUrl: $checkoutUrl, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$CheckoutSessionModelCopyWith<$Res> implements $CheckoutSessionModelCopyWith<$Res> {
  factory _$CheckoutSessionModelCopyWith(_CheckoutSessionModel value, $Res Function(_CheckoutSessionModel) _then) = __$CheckoutSessionModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'checkout_url') String checkoutUrl,@JsonKey(name: 'session_id') String sessionId
});




}
/// @nodoc
class __$CheckoutSessionModelCopyWithImpl<$Res>
    implements _$CheckoutSessionModelCopyWith<$Res> {
  __$CheckoutSessionModelCopyWithImpl(this._self, this._then);

  final _CheckoutSessionModel _self;
  final $Res Function(_CheckoutSessionModel) _then;

/// Create a copy of CheckoutSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkoutUrl = null,Object? sessionId = null,}) {
  return _then(_CheckoutSessionModel(
checkoutUrl: null == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ValidateReferralResponse {

 bool get valid;@JsonKey(name: 'referrer_name') String? get referrerName; String? get error;
/// Create a copy of ValidateReferralResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidateReferralResponseCopyWith<ValidateReferralResponse> get copyWith => _$ValidateReferralResponseCopyWithImpl<ValidateReferralResponse>(this as ValidateReferralResponse, _$identity);

  /// Serializes this ValidateReferralResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidateReferralResponse&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.referrerName, referrerName) || other.referrerName == referrerName)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,referrerName,error);

@override
String toString() {
  return 'ValidateReferralResponse(valid: $valid, referrerName: $referrerName, error: $error)';
}


}

/// @nodoc
abstract mixin class $ValidateReferralResponseCopyWith<$Res>  {
  factory $ValidateReferralResponseCopyWith(ValidateReferralResponse value, $Res Function(ValidateReferralResponse) _then) = _$ValidateReferralResponseCopyWithImpl;
@useResult
$Res call({
 bool valid,@JsonKey(name: 'referrer_name') String? referrerName, String? error
});




}
/// @nodoc
class _$ValidateReferralResponseCopyWithImpl<$Res>
    implements $ValidateReferralResponseCopyWith<$Res> {
  _$ValidateReferralResponseCopyWithImpl(this._self, this._then);

  final ValidateReferralResponse _self;
  final $Res Function(ValidateReferralResponse) _then;

/// Create a copy of ValidateReferralResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valid = null,Object? referrerName = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,referrerName: freezed == referrerName ? _self.referrerName : referrerName // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidateReferralResponse].
extension ValidateReferralResponsePatterns on ValidateReferralResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidateReferralResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidateReferralResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidateReferralResponse value)  $default,){
final _that = this;
switch (_that) {
case _ValidateReferralResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidateReferralResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ValidateReferralResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool valid, @JsonKey(name: 'referrer_name')  String? referrerName,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidateReferralResponse() when $default != null:
return $default(_that.valid,_that.referrerName,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool valid, @JsonKey(name: 'referrer_name')  String? referrerName,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ValidateReferralResponse():
return $default(_that.valid,_that.referrerName,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool valid, @JsonKey(name: 'referrer_name')  String? referrerName,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ValidateReferralResponse() when $default != null:
return $default(_that.valid,_that.referrerName,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValidateReferralResponse implements ValidateReferralResponse {
  const _ValidateReferralResponse({this.valid = false, @JsonKey(name: 'referrer_name') this.referrerName, this.error});
  factory _ValidateReferralResponse.fromJson(Map<String, dynamic> json) => _$ValidateReferralResponseFromJson(json);

@override@JsonKey() final  bool valid;
@override@JsonKey(name: 'referrer_name') final  String? referrerName;
@override final  String? error;

/// Create a copy of ValidateReferralResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidateReferralResponseCopyWith<_ValidateReferralResponse> get copyWith => __$ValidateReferralResponseCopyWithImpl<_ValidateReferralResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidateReferralResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidateReferralResponse&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.referrerName, referrerName) || other.referrerName == referrerName)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valid,referrerName,error);

@override
String toString() {
  return 'ValidateReferralResponse(valid: $valid, referrerName: $referrerName, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ValidateReferralResponseCopyWith<$Res> implements $ValidateReferralResponseCopyWith<$Res> {
  factory _$ValidateReferralResponseCopyWith(_ValidateReferralResponse value, $Res Function(_ValidateReferralResponse) _then) = __$ValidateReferralResponseCopyWithImpl;
@override @useResult
$Res call({
 bool valid,@JsonKey(name: 'referrer_name') String? referrerName, String? error
});




}
/// @nodoc
class __$ValidateReferralResponseCopyWithImpl<$Res>
    implements _$ValidateReferralResponseCopyWith<$Res> {
  __$ValidateReferralResponseCopyWithImpl(this._self, this._then);

  final _ValidateReferralResponse _self;
  final $Res Function(_ValidateReferralResponse) _then;

/// Create a copy of ValidateReferralResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valid = null,Object? referrerName = freezed,Object? error = freezed,}) {
  return _then(_ValidateReferralResponse(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,referrerName: freezed == referrerName ? _self.referrerName : referrerName // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
