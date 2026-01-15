// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BodyProfileModel {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name;@JsonKey(name: 'height_cm') double get heightCm;@JsonKey(name: 'weight_kg') double get weightKg;@JsonKey(name: 'body_shape') String get bodyShape;@JsonKey(name: 'skin_tone') String get skinTone;@JsonKey(name: 'is_default') bool get isDefault;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of BodyProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyProfileModelCopyWith<BodyProfileModel> get copyWith => _$BodyProfileModelCopyWithImpl<BodyProfileModel>(this as BodyProfileModel, _$identity);

  /// Serializes this BodyProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyShape, bodyShape) || other.bodyShape == bodyShape)&&(identical(other.skinTone, skinTone) || other.skinTone == skinTone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,heightCm,weightKg,bodyShape,skinTone,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'BodyProfileModel(id: $id, userId: $userId, name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BodyProfileModelCopyWith<$Res>  {
  factory $BodyProfileModelCopyWith(BodyProfileModel value, $Res Function(BodyProfileModel) _then) = _$BodyProfileModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'height_cm') double heightCm,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'body_shape') String bodyShape,@JsonKey(name: 'skin_tone') String skinTone,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$BodyProfileModelCopyWithImpl<$Res>
    implements $BodyProfileModelCopyWith<$Res> {
  _$BodyProfileModelCopyWithImpl(this._self, this._then);

  final BodyProfileModel _self;
  final $Res Function(BodyProfileModel) _then;

/// Create a copy of BodyProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? heightCm = null,Object? weightKg = null,Object? bodyShape = null,Object? skinTone = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyShape: null == bodyShape ? _self.bodyShape : bodyShape // ignore: cast_nullable_to_non_nullable
as String,skinTone: null == skinTone ? _self.skinTone : skinTone // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BodyProfileModel].
extension BodyProfileModelPatterns on BodyProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _BodyProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _BodyProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'height_cm')  double heightCm, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_shape')  String bodyShape, @JsonKey(name: 'skin_tone')  String skinTone, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyProfileModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'height_cm')  double heightCm, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_shape')  String bodyShape, @JsonKey(name: 'skin_tone')  String skinTone, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BodyProfileModel():
return $default(_that.id,_that.userId,_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'height_cm')  double heightCm, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_shape')  String bodyShape, @JsonKey(name: 'skin_tone')  String skinTone, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BodyProfileModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodyProfileModel implements BodyProfileModel {
  const _BodyProfileModel({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, @JsonKey(name: 'height_cm') required this.heightCm, @JsonKey(name: 'weight_kg') required this.weightKg, @JsonKey(name: 'body_shape') required this.bodyShape, @JsonKey(name: 'skin_tone') required this.skinTone, @JsonKey(name: 'is_default') this.isDefault = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _BodyProfileModel.fromJson(Map<String, dynamic> json) => _$BodyProfileModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override@JsonKey(name: 'height_cm') final  double heightCm;
@override@JsonKey(name: 'weight_kg') final  double weightKg;
@override@JsonKey(name: 'body_shape') final  String bodyShape;
@override@JsonKey(name: 'skin_tone') final  String skinTone;
@override@JsonKey(name: 'is_default') final  bool isDefault;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of BodyProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyProfileModelCopyWith<_BodyProfileModel> get copyWith => __$BodyProfileModelCopyWithImpl<_BodyProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodyProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyShape, bodyShape) || other.bodyShape == bodyShape)&&(identical(other.skinTone, skinTone) || other.skinTone == skinTone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,heightCm,weightKg,bodyShape,skinTone,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'BodyProfileModel(id: $id, userId: $userId, name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BodyProfileModelCopyWith<$Res> implements $BodyProfileModelCopyWith<$Res> {
  factory _$BodyProfileModelCopyWith(_BodyProfileModel value, $Res Function(_BodyProfileModel) _then) = __$BodyProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'height_cm') double heightCm,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'body_shape') String bodyShape,@JsonKey(name: 'skin_tone') String skinTone,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$BodyProfileModelCopyWithImpl<$Res>
    implements _$BodyProfileModelCopyWith<$Res> {
  __$BodyProfileModelCopyWithImpl(this._self, this._then);

  final _BodyProfileModel _self;
  final $Res Function(_BodyProfileModel) _then;

/// Create a copy of BodyProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? heightCm = null,Object? weightKg = null,Object? bodyShape = null,Object? skinTone = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BodyProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyShape: null == bodyShape ? _self.bodyShape : bodyShape // ignore: cast_nullable_to_non_nullable
as String,skinTone: null == skinTone ? _self.skinTone : skinTone // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreateBodyProfileRequest {

 String get name;@JsonKey(name: 'height_cm') double get heightCm;@JsonKey(name: 'weight_kg') double get weightKg;@JsonKey(name: 'body_shape') String get bodyShape;@JsonKey(name: 'skin_tone') String get skinTone;@JsonKey(name: 'is_default') bool get isDefault;
/// Create a copy of CreateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateBodyProfileRequestCopyWith<CreateBodyProfileRequest> get copyWith => _$CreateBodyProfileRequestCopyWithImpl<CreateBodyProfileRequest>(this as CreateBodyProfileRequest, _$identity);

  /// Serializes this CreateBodyProfileRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateBodyProfileRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyShape, bodyShape) || other.bodyShape == bodyShape)&&(identical(other.skinTone, skinTone) || other.skinTone == skinTone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,heightCm,weightKg,bodyShape,skinTone,isDefault);

@override
String toString() {
  return 'CreateBodyProfileRequest(name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $CreateBodyProfileRequestCopyWith<$Res>  {
  factory $CreateBodyProfileRequestCopyWith(CreateBodyProfileRequest value, $Res Function(CreateBodyProfileRequest) _then) = _$CreateBodyProfileRequestCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: 'height_cm') double heightCm,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'body_shape') String bodyShape,@JsonKey(name: 'skin_tone') String skinTone,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class _$CreateBodyProfileRequestCopyWithImpl<$Res>
    implements $CreateBodyProfileRequestCopyWith<$Res> {
  _$CreateBodyProfileRequestCopyWithImpl(this._self, this._then);

  final CreateBodyProfileRequest _self;
  final $Res Function(CreateBodyProfileRequest) _then;

/// Create a copy of CreateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? heightCm = null,Object? weightKg = null,Object? bodyShape = null,Object? skinTone = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyShape: null == bodyShape ? _self.bodyShape : bodyShape // ignore: cast_nullable_to_non_nullable
as String,skinTone: null == skinTone ? _self.skinTone : skinTone // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateBodyProfileRequest].
extension CreateBodyProfileRequestPatterns on CreateBodyProfileRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateBodyProfileRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateBodyProfileRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateBodyProfileRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateBodyProfileRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateBodyProfileRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateBodyProfileRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'height_cm')  double heightCm, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_shape')  String bodyShape, @JsonKey(name: 'skin_tone')  String skinTone, @JsonKey(name: 'is_default')  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateBodyProfileRequest() when $default != null:
return $default(_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'height_cm')  double heightCm, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_shape')  String bodyShape, @JsonKey(name: 'skin_tone')  String skinTone, @JsonKey(name: 'is_default')  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _CreateBodyProfileRequest():
return $default(_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: 'height_cm')  double heightCm, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_shape')  String bodyShape, @JsonKey(name: 'skin_tone')  String skinTone, @JsonKey(name: 'is_default')  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _CreateBodyProfileRequest() when $default != null:
return $default(_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateBodyProfileRequest implements CreateBodyProfileRequest {
  const _CreateBodyProfileRequest({required this.name, @JsonKey(name: 'height_cm') required this.heightCm, @JsonKey(name: 'weight_kg') required this.weightKg, @JsonKey(name: 'body_shape') required this.bodyShape, @JsonKey(name: 'skin_tone') required this.skinTone, @JsonKey(name: 'is_default') this.isDefault = false});
  factory _CreateBodyProfileRequest.fromJson(Map<String, dynamic> json) => _$CreateBodyProfileRequestFromJson(json);

@override final  String name;
@override@JsonKey(name: 'height_cm') final  double heightCm;
@override@JsonKey(name: 'weight_kg') final  double weightKg;
@override@JsonKey(name: 'body_shape') final  String bodyShape;
@override@JsonKey(name: 'skin_tone') final  String skinTone;
@override@JsonKey(name: 'is_default') final  bool isDefault;

/// Create a copy of CreateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateBodyProfileRequestCopyWith<_CreateBodyProfileRequest> get copyWith => __$CreateBodyProfileRequestCopyWithImpl<_CreateBodyProfileRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateBodyProfileRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateBodyProfileRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyShape, bodyShape) || other.bodyShape == bodyShape)&&(identical(other.skinTone, skinTone) || other.skinTone == skinTone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,heightCm,weightKg,bodyShape,skinTone,isDefault);

@override
String toString() {
  return 'CreateBodyProfileRequest(name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$CreateBodyProfileRequestCopyWith<$Res> implements $CreateBodyProfileRequestCopyWith<$Res> {
  factory _$CreateBodyProfileRequestCopyWith(_CreateBodyProfileRequest value, $Res Function(_CreateBodyProfileRequest) _then) = __$CreateBodyProfileRequestCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: 'height_cm') double heightCm,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'body_shape') String bodyShape,@JsonKey(name: 'skin_tone') String skinTone,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class __$CreateBodyProfileRequestCopyWithImpl<$Res>
    implements _$CreateBodyProfileRequestCopyWith<$Res> {
  __$CreateBodyProfileRequestCopyWithImpl(this._self, this._then);

  final _CreateBodyProfileRequest _self;
  final $Res Function(_CreateBodyProfileRequest) _then;

/// Create a copy of CreateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? heightCm = null,Object? weightKg = null,Object? bodyShape = null,Object? skinTone = null,Object? isDefault = null,}) {
  return _then(_CreateBodyProfileRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyShape: null == bodyShape ? _self.bodyShape : bodyShape // ignore: cast_nullable_to_non_nullable
as String,skinTone: null == skinTone ? _self.skinTone : skinTone // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateBodyProfileRequest {

 String? get name;@JsonKey(name: 'height_cm') double? get heightCm;@JsonKey(name: 'weight_kg') double? get weightKg;@JsonKey(name: 'body_shape') String? get bodyShape;@JsonKey(name: 'skin_tone') String? get skinTone;@JsonKey(name: 'is_default') bool? get isDefault;
/// Create a copy of UpdateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateBodyProfileRequestCopyWith<UpdateBodyProfileRequest> get copyWith => _$UpdateBodyProfileRequestCopyWithImpl<UpdateBodyProfileRequest>(this as UpdateBodyProfileRequest, _$identity);

  /// Serializes this UpdateBodyProfileRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateBodyProfileRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyShape, bodyShape) || other.bodyShape == bodyShape)&&(identical(other.skinTone, skinTone) || other.skinTone == skinTone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,heightCm,weightKg,bodyShape,skinTone,isDefault);

@override
String toString() {
  return 'UpdateBodyProfileRequest(name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $UpdateBodyProfileRequestCopyWith<$Res>  {
  factory $UpdateBodyProfileRequestCopyWith(UpdateBodyProfileRequest value, $Res Function(UpdateBodyProfileRequest) _then) = _$UpdateBodyProfileRequestCopyWithImpl;
@useResult
$Res call({
 String? name,@JsonKey(name: 'height_cm') double? heightCm,@JsonKey(name: 'weight_kg') double? weightKg,@JsonKey(name: 'body_shape') String? bodyShape,@JsonKey(name: 'skin_tone') String? skinTone,@JsonKey(name: 'is_default') bool? isDefault
});




}
/// @nodoc
class _$UpdateBodyProfileRequestCopyWithImpl<$Res>
    implements $UpdateBodyProfileRequestCopyWith<$Res> {
  _$UpdateBodyProfileRequestCopyWithImpl(this._self, this._then);

  final UpdateBodyProfileRequest _self;
  final $Res Function(UpdateBodyProfileRequest) _then;

/// Create a copy of UpdateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? bodyShape = freezed,Object? skinTone = freezed,Object? isDefault = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,bodyShape: freezed == bodyShape ? _self.bodyShape : bodyShape // ignore: cast_nullable_to_non_nullable
as String?,skinTone: freezed == skinTone ? _self.skinTone : skinTone // ignore: cast_nullable_to_non_nullable
as String?,isDefault: freezed == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateBodyProfileRequest].
extension UpdateBodyProfileRequestPatterns on UpdateBodyProfileRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateBodyProfileRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateBodyProfileRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateBodyProfileRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateBodyProfileRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateBodyProfileRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateBodyProfileRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: 'height_cm')  double? heightCm, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'body_shape')  String? bodyShape, @JsonKey(name: 'skin_tone')  String? skinTone, @JsonKey(name: 'is_default')  bool? isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateBodyProfileRequest() when $default != null:
return $default(_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: 'height_cm')  double? heightCm, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'body_shape')  String? bodyShape, @JsonKey(name: 'skin_tone')  String? skinTone, @JsonKey(name: 'is_default')  bool? isDefault)  $default,) {final _that = this;
switch (_that) {
case _UpdateBodyProfileRequest():
return $default(_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name, @JsonKey(name: 'height_cm')  double? heightCm, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'body_shape')  String? bodyShape, @JsonKey(name: 'skin_tone')  String? skinTone, @JsonKey(name: 'is_default')  bool? isDefault)?  $default,) {final _that = this;
switch (_that) {
case _UpdateBodyProfileRequest() when $default != null:
return $default(_that.name,_that.heightCm,_that.weightKg,_that.bodyShape,_that.skinTone,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateBodyProfileRequest implements UpdateBodyProfileRequest {
  const _UpdateBodyProfileRequest({this.name, @JsonKey(name: 'height_cm') this.heightCm, @JsonKey(name: 'weight_kg') this.weightKg, @JsonKey(name: 'body_shape') this.bodyShape, @JsonKey(name: 'skin_tone') this.skinTone, @JsonKey(name: 'is_default') this.isDefault});
  factory _UpdateBodyProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateBodyProfileRequestFromJson(json);

@override final  String? name;
@override@JsonKey(name: 'height_cm') final  double? heightCm;
@override@JsonKey(name: 'weight_kg') final  double? weightKg;
@override@JsonKey(name: 'body_shape') final  String? bodyShape;
@override@JsonKey(name: 'skin_tone') final  String? skinTone;
@override@JsonKey(name: 'is_default') final  bool? isDefault;

/// Create a copy of UpdateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateBodyProfileRequestCopyWith<_UpdateBodyProfileRequest> get copyWith => __$UpdateBodyProfileRequestCopyWithImpl<_UpdateBodyProfileRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateBodyProfileRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateBodyProfileRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyShape, bodyShape) || other.bodyShape == bodyShape)&&(identical(other.skinTone, skinTone) || other.skinTone == skinTone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,heightCm,weightKg,bodyShape,skinTone,isDefault);

@override
String toString() {
  return 'UpdateBodyProfileRequest(name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$UpdateBodyProfileRequestCopyWith<$Res> implements $UpdateBodyProfileRequestCopyWith<$Res> {
  factory _$UpdateBodyProfileRequestCopyWith(_UpdateBodyProfileRequest value, $Res Function(_UpdateBodyProfileRequest) _then) = __$UpdateBodyProfileRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name,@JsonKey(name: 'height_cm') double? heightCm,@JsonKey(name: 'weight_kg') double? weightKg,@JsonKey(name: 'body_shape') String? bodyShape,@JsonKey(name: 'skin_tone') String? skinTone,@JsonKey(name: 'is_default') bool? isDefault
});




}
/// @nodoc
class __$UpdateBodyProfileRequestCopyWithImpl<$Res>
    implements _$UpdateBodyProfileRequestCopyWith<$Res> {
  __$UpdateBodyProfileRequestCopyWithImpl(this._self, this._then);

  final _UpdateBodyProfileRequest _self;
  final $Res Function(_UpdateBodyProfileRequest) _then;

/// Create a copy of UpdateBodyProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? bodyShape = freezed,Object? skinTone = freezed,Object? isDefault = freezed,}) {
  return _then(_UpdateBodyProfileRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,bodyShape: freezed == bodyShape ? _self.bodyShape : bodyShape // ignore: cast_nullable_to_non_nullable
as String?,skinTone: freezed == skinTone ? _self.skinTone : skinTone // ignore: cast_nullable_to_non_nullable
as String?,isDefault: freezed == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
