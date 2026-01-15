// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceInfo {

 String? get platform;@JsonKey(name: 'os_version') String? get osVersion;@JsonKey(name: 'device_model') String? get deviceModel;@JsonKey(name: 'screen_size') String? get screenSize;
/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<DeviceInfo> get copyWith => _$DeviceInfoCopyWithImpl<DeviceInfo>(this as DeviceInfo, _$identity);

  /// Serializes this DeviceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceInfo&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.osVersion, osVersion) || other.osVersion == osVersion)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.screenSize, screenSize) || other.screenSize == screenSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,osVersion,deviceModel,screenSize);

@override
String toString() {
  return 'DeviceInfo(platform: $platform, osVersion: $osVersion, deviceModel: $deviceModel, screenSize: $screenSize)';
}


}

/// @nodoc
abstract mixin class $DeviceInfoCopyWith<$Res>  {
  factory $DeviceInfoCopyWith(DeviceInfo value, $Res Function(DeviceInfo) _then) = _$DeviceInfoCopyWithImpl;
@useResult
$Res call({
 String? platform,@JsonKey(name: 'os_version') String? osVersion,@JsonKey(name: 'device_model') String? deviceModel,@JsonKey(name: 'screen_size') String? screenSize
});




}
/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._self, this._then);

  final DeviceInfo _self;
  final $Res Function(DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = freezed,Object? osVersion = freezed,Object? deviceModel = freezed,Object? screenSize = freezed,}) {
  return _then(_self.copyWith(
platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,osVersion: freezed == osVersion ? _self.osVersion : osVersion // ignore: cast_nullable_to_non_nullable
as String?,deviceModel: freezed == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as String?,screenSize: freezed == screenSize ? _self.screenSize : screenSize // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceInfo].
extension DeviceInfoPatterns on DeviceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceInfo value)  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? platform, @JsonKey(name: 'os_version')  String? osVersion, @JsonKey(name: 'device_model')  String? deviceModel, @JsonKey(name: 'screen_size')  String? screenSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.platform,_that.osVersion,_that.deviceModel,_that.screenSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? platform, @JsonKey(name: 'os_version')  String? osVersion, @JsonKey(name: 'device_model')  String? deviceModel, @JsonKey(name: 'screen_size')  String? screenSize)  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo():
return $default(_that.platform,_that.osVersion,_that.deviceModel,_that.screenSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? platform, @JsonKey(name: 'os_version')  String? osVersion, @JsonKey(name: 'device_model')  String? deviceModel, @JsonKey(name: 'screen_size')  String? screenSize)?  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.platform,_that.osVersion,_that.deviceModel,_that.screenSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceInfo implements DeviceInfo {
  const _DeviceInfo({this.platform, @JsonKey(name: 'os_version') this.osVersion, @JsonKey(name: 'device_model') this.deviceModel, @JsonKey(name: 'screen_size') this.screenSize});
  factory _DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

@override final  String? platform;
@override@JsonKey(name: 'os_version') final  String? osVersion;
@override@JsonKey(name: 'device_model') final  String? deviceModel;
@override@JsonKey(name: 'screen_size') final  String? screenSize;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceInfoCopyWith<_DeviceInfo> get copyWith => __$DeviceInfoCopyWithImpl<_DeviceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceInfo&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.osVersion, osVersion) || other.osVersion == osVersion)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.screenSize, screenSize) || other.screenSize == screenSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,osVersion,deviceModel,screenSize);

@override
String toString() {
  return 'DeviceInfo(platform: $platform, osVersion: $osVersion, deviceModel: $deviceModel, screenSize: $screenSize)';
}


}

/// @nodoc
abstract mixin class _$DeviceInfoCopyWith<$Res> implements $DeviceInfoCopyWith<$Res> {
  factory _$DeviceInfoCopyWith(_DeviceInfo value, $Res Function(_DeviceInfo) _then) = __$DeviceInfoCopyWithImpl;
@override @useResult
$Res call({
 String? platform,@JsonKey(name: 'os_version') String? osVersion,@JsonKey(name: 'device_model') String? deviceModel,@JsonKey(name: 'screen_size') String? screenSize
});




}
/// @nodoc
class __$DeviceInfoCopyWithImpl<$Res>
    implements _$DeviceInfoCopyWith<$Res> {
  __$DeviceInfoCopyWithImpl(this._self, this._then);

  final _DeviceInfo _self;
  final $Res Function(_DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = freezed,Object? osVersion = freezed,Object? deviceModel = freezed,Object? screenSize = freezed,}) {
  return _then(_DeviceInfo(
platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,osVersion: freezed == osVersion ? _self.osVersion : osVersion // ignore: cast_nullable_to_non_nullable
as String?,deviceModel: freezed == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as String?,screenSize: freezed == screenSize ? _self.screenSize : screenSize // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FeedbackResponse {

 String get id; TicketCategory get category; String get subject; TicketStatus get status;@JsonKey(name: 'created_at') DateTime get createdAt; String get message;
/// Create a copy of FeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackResponseCopyWith<FeedbackResponse> get copyWith => _$FeedbackResponseCopyWithImpl<FeedbackResponse>(this as FeedbackResponse, _$identity);

  /// Serializes this FeedbackResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,subject,status,createdAt,message);

@override
String toString() {
  return 'FeedbackResponse(id: $id, category: $category, subject: $subject, status: $status, createdAt: $createdAt, message: $message)';
}


}

/// @nodoc
abstract mixin class $FeedbackResponseCopyWith<$Res>  {
  factory $FeedbackResponseCopyWith(FeedbackResponse value, $Res Function(FeedbackResponse) _then) = _$FeedbackResponseCopyWithImpl;
@useResult
$Res call({
 String id, TicketCategory category, String subject, TicketStatus status,@JsonKey(name: 'created_at') DateTime createdAt, String message
});




}
/// @nodoc
class _$FeedbackResponseCopyWithImpl<$Res>
    implements $FeedbackResponseCopyWith<$Res> {
  _$FeedbackResponseCopyWithImpl(this._self, this._then);

  final FeedbackResponse _self;
  final $Res Function(FeedbackResponse) _then;

/// Create a copy of FeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? subject = null,Object? status = null,Object? createdAt = null,Object? message = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackResponse].
extension FeedbackResponsePatterns on FeedbackResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackResponse value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TicketCategory category,  String subject,  TicketStatus status, @JsonKey(name: 'created_at')  DateTime createdAt,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackResponse() when $default != null:
return $default(_that.id,_that.category,_that.subject,_that.status,_that.createdAt,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TicketCategory category,  String subject,  TicketStatus status, @JsonKey(name: 'created_at')  DateTime createdAt,  String message)  $default,) {final _that = this;
switch (_that) {
case _FeedbackResponse():
return $default(_that.id,_that.category,_that.subject,_that.status,_that.createdAt,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TicketCategory category,  String subject,  TicketStatus status, @JsonKey(name: 'created_at')  DateTime createdAt,  String message)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackResponse() when $default != null:
return $default(_that.id,_that.category,_that.subject,_that.status,_that.createdAt,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackResponse implements FeedbackResponse {
  const _FeedbackResponse({required this.id, required this.category, required this.subject, required this.status, @JsonKey(name: 'created_at') required this.createdAt, required this.message});
  factory _FeedbackResponse.fromJson(Map<String, dynamic> json) => _$FeedbackResponseFromJson(json);

@override final  String id;
@override final  TicketCategory category;
@override final  String subject;
@override final  TicketStatus status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override final  String message;

/// Create a copy of FeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackResponseCopyWith<_FeedbackResponse> get copyWith => __$FeedbackResponseCopyWithImpl<_FeedbackResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,subject,status,createdAt,message);

@override
String toString() {
  return 'FeedbackResponse(id: $id, category: $category, subject: $subject, status: $status, createdAt: $createdAt, message: $message)';
}


}

/// @nodoc
abstract mixin class _$FeedbackResponseCopyWith<$Res> implements $FeedbackResponseCopyWith<$Res> {
  factory _$FeedbackResponseCopyWith(_FeedbackResponse value, $Res Function(_FeedbackResponse) _then) = __$FeedbackResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, TicketCategory category, String subject, TicketStatus status,@JsonKey(name: 'created_at') DateTime createdAt, String message
});




}
/// @nodoc
class __$FeedbackResponseCopyWithImpl<$Res>
    implements _$FeedbackResponseCopyWith<$Res> {
  __$FeedbackResponseCopyWithImpl(this._self, this._then);

  final _FeedbackResponse _self;
  final $Res Function(_FeedbackResponse) _then;

/// Create a copy of FeedbackResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? subject = null,Object? status = null,Object? createdAt = null,Object? message = null,}) {
  return _then(_FeedbackResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TicketListItem {

 String get id; TicketCategory get category; String get subject; TicketStatus get status;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of TicketListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketListItemCopyWith<TicketListItem> get copyWith => _$TicketListItemCopyWithImpl<TicketListItem>(this as TicketListItem, _$identity);

  /// Serializes this TicketListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,subject,status,createdAt);

@override
String toString() {
  return 'TicketListItem(id: $id, category: $category, subject: $subject, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TicketListItemCopyWith<$Res>  {
  factory $TicketListItemCopyWith(TicketListItem value, $Res Function(TicketListItem) _then) = _$TicketListItemCopyWithImpl;
@useResult
$Res call({
 String id, TicketCategory category, String subject, TicketStatus status,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$TicketListItemCopyWithImpl<$Res>
    implements $TicketListItemCopyWith<$Res> {
  _$TicketListItemCopyWithImpl(this._self, this._then);

  final TicketListItem _self;
  final $Res Function(TicketListItem) _then;

/// Create a copy of TicketListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? subject = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketListItem].
extension TicketListItemPatterns on TicketListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketListItem value)  $default,){
final _that = this;
switch (_that) {
case _TicketListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketListItem value)?  $default,){
final _that = this;
switch (_that) {
case _TicketListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TicketCategory category,  String subject,  TicketStatus status, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketListItem() when $default != null:
return $default(_that.id,_that.category,_that.subject,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TicketCategory category,  String subject,  TicketStatus status, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TicketListItem():
return $default(_that.id,_that.category,_that.subject,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TicketCategory category,  String subject,  TicketStatus status, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TicketListItem() when $default != null:
return $default(_that.id,_that.category,_that.subject,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketListItem implements TicketListItem {
  const _TicketListItem({required this.id, required this.category, required this.subject, required this.status, @JsonKey(name: 'created_at') required this.createdAt});
  factory _TicketListItem.fromJson(Map<String, dynamic> json) => _$TicketListItemFromJson(json);

@override final  String id;
@override final  TicketCategory category;
@override final  String subject;
@override final  TicketStatus status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of TicketListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketListItemCopyWith<_TicketListItem> get copyWith => __$TicketListItemCopyWithImpl<_TicketListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,subject,status,createdAt);

@override
String toString() {
  return 'TicketListItem(id: $id, category: $category, subject: $subject, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TicketListItemCopyWith<$Res> implements $TicketListItemCopyWith<$Res> {
  factory _$TicketListItemCopyWith(_TicketListItem value, $Res Function(_TicketListItem) _then) = __$TicketListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, TicketCategory category, String subject, TicketStatus status,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$TicketListItemCopyWithImpl<$Res>
    implements _$TicketListItemCopyWith<$Res> {
  __$TicketListItemCopyWithImpl(this._self, this._then);

  final _TicketListItem _self;
  final $Res Function(_TicketListItem) _then;

/// Create a copy of TicketListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? subject = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_TicketListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
