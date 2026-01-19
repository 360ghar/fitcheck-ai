// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photoshoot_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GeneratedImage {

 String get id; int get index;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'image_base64') String? get imageBase64;
/// Create a copy of GeneratedImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedImageCopyWith<GeneratedImage> get copyWith => _$GeneratedImageCopyWithImpl<GeneratedImage>(this as GeneratedImage, _$identity);

  /// Serializes this GeneratedImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedImage&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,imageUrl,imageBase64);

@override
String toString() {
  return 'GeneratedImage(id: $id, index: $index, imageUrl: $imageUrl, imageBase64: $imageBase64)';
}


}

/// @nodoc
abstract mixin class $GeneratedImageCopyWith<$Res>  {
  factory $GeneratedImageCopyWith(GeneratedImage value, $Res Function(GeneratedImage) _then) = _$GeneratedImageCopyWithImpl;
@useResult
$Res call({
 String id, int index,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'image_base64') String? imageBase64
});




}
/// @nodoc
class _$GeneratedImageCopyWithImpl<$Res>
    implements $GeneratedImageCopyWith<$Res> {
  _$GeneratedImageCopyWithImpl(this._self, this._then);

  final GeneratedImage _self;
  final $Res Function(GeneratedImage) _then;

/// Create a copy of GeneratedImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? index = null,Object? imageUrl = freezed,Object? imageBase64 = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedImage].
extension GeneratedImagePatterns on GeneratedImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedImage value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedImage value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int index, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'image_base64')  String? imageBase64)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedImage() when $default != null:
return $default(_that.id,_that.index,_that.imageUrl,_that.imageBase64);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int index, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'image_base64')  String? imageBase64)  $default,) {final _that = this;
switch (_that) {
case _GeneratedImage():
return $default(_that.id,_that.index,_that.imageUrl,_that.imageBase64);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int index, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'image_base64')  String? imageBase64)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedImage() when $default != null:
return $default(_that.id,_that.index,_that.imageUrl,_that.imageBase64);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeneratedImage implements GeneratedImage {
  const _GeneratedImage({required this.id, required this.index, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'image_base64') this.imageBase64});
  factory _GeneratedImage.fromJson(Map<String, dynamic> json) => _$GeneratedImageFromJson(json);

@override final  String id;
@override final  int index;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'image_base64') final  String? imageBase64;

/// Create a copy of GeneratedImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedImageCopyWith<_GeneratedImage> get copyWith => __$GeneratedImageCopyWithImpl<_GeneratedImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeneratedImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedImage&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,imageUrl,imageBase64);

@override
String toString() {
  return 'GeneratedImage(id: $id, index: $index, imageUrl: $imageUrl, imageBase64: $imageBase64)';
}


}

/// @nodoc
abstract mixin class _$GeneratedImageCopyWith<$Res> implements $GeneratedImageCopyWith<$Res> {
  factory _$GeneratedImageCopyWith(_GeneratedImage value, $Res Function(_GeneratedImage) _then) = __$GeneratedImageCopyWithImpl;
@override @useResult
$Res call({
 String id, int index,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'image_base64') String? imageBase64
});




}
/// @nodoc
class __$GeneratedImageCopyWithImpl<$Res>
    implements _$GeneratedImageCopyWith<$Res> {
  __$GeneratedImageCopyWithImpl(this._self, this._then);

  final _GeneratedImage _self;
  final $Res Function(_GeneratedImage) _then;

/// Create a copy of GeneratedImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? index = null,Object? imageUrl = freezed,Object? imageBase64 = freezed,}) {
  return _then(_GeneratedImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PhotoshootUsage {

@JsonKey(name: 'used_today') int get usedToday;@JsonKey(name: 'limit_today') int get limitToday; int get remaining;@JsonKey(name: 'plan_type') String get planType;@JsonKey(name: 'resets_at') DateTime? get resetsAt;
/// Create a copy of PhotoshootUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoshootUsageCopyWith<PhotoshootUsage> get copyWith => _$PhotoshootUsageCopyWithImpl<PhotoshootUsage>(this as PhotoshootUsage, _$identity);

  /// Serializes this PhotoshootUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoshootUsage&&(identical(other.usedToday, usedToday) || other.usedToday == usedToday)&&(identical(other.limitToday, limitToday) || other.limitToday == limitToday)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.resetsAt, resetsAt) || other.resetsAt == resetsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usedToday,limitToday,remaining,planType,resetsAt);

@override
String toString() {
  return 'PhotoshootUsage(usedToday: $usedToday, limitToday: $limitToday, remaining: $remaining, planType: $planType, resetsAt: $resetsAt)';
}


}

/// @nodoc
abstract mixin class $PhotoshootUsageCopyWith<$Res>  {
  factory $PhotoshootUsageCopyWith(PhotoshootUsage value, $Res Function(PhotoshootUsage) _then) = _$PhotoshootUsageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'used_today') int usedToday,@JsonKey(name: 'limit_today') int limitToday, int remaining,@JsonKey(name: 'plan_type') String planType,@JsonKey(name: 'resets_at') DateTime? resetsAt
});




}
/// @nodoc
class _$PhotoshootUsageCopyWithImpl<$Res>
    implements $PhotoshootUsageCopyWith<$Res> {
  _$PhotoshootUsageCopyWithImpl(this._self, this._then);

  final PhotoshootUsage _self;
  final $Res Function(PhotoshootUsage) _then;

/// Create a copy of PhotoshootUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? usedToday = null,Object? limitToday = null,Object? remaining = null,Object? planType = null,Object? resetsAt = freezed,}) {
  return _then(_self.copyWith(
usedToday: null == usedToday ? _self.usedToday : usedToday // ignore: cast_nullable_to_non_nullable
as int,limitToday: null == limitToday ? _self.limitToday : limitToday // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,resetsAt: freezed == resetsAt ? _self.resetsAt : resetsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoshootUsage].
extension PhotoshootUsagePatterns on PhotoshootUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoshootUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoshootUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoshootUsage value)  $default,){
final _that = this;
switch (_that) {
case _PhotoshootUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoshootUsage value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoshootUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'used_today')  int usedToday, @JsonKey(name: 'limit_today')  int limitToday,  int remaining, @JsonKey(name: 'plan_type')  String planType, @JsonKey(name: 'resets_at')  DateTime? resetsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoshootUsage() when $default != null:
return $default(_that.usedToday,_that.limitToday,_that.remaining,_that.planType,_that.resetsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'used_today')  int usedToday, @JsonKey(name: 'limit_today')  int limitToday,  int remaining, @JsonKey(name: 'plan_type')  String planType, @JsonKey(name: 'resets_at')  DateTime? resetsAt)  $default,) {final _that = this;
switch (_that) {
case _PhotoshootUsage():
return $default(_that.usedToday,_that.limitToday,_that.remaining,_that.planType,_that.resetsAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'used_today')  int usedToday, @JsonKey(name: 'limit_today')  int limitToday,  int remaining, @JsonKey(name: 'plan_type')  String planType, @JsonKey(name: 'resets_at')  DateTime? resetsAt)?  $default,) {final _that = this;
switch (_that) {
case _PhotoshootUsage() when $default != null:
return $default(_that.usedToday,_that.limitToday,_that.remaining,_that.planType,_that.resetsAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoshootUsage implements PhotoshootUsage {
  const _PhotoshootUsage({@JsonKey(name: 'used_today') this.usedToday = 0, @JsonKey(name: 'limit_today') this.limitToday = 10, this.remaining = 0, @JsonKey(name: 'plan_type') this.planType = 'free', @JsonKey(name: 'resets_at') this.resetsAt});
  factory _PhotoshootUsage.fromJson(Map<String, dynamic> json) => _$PhotoshootUsageFromJson(json);

@override@JsonKey(name: 'used_today') final  int usedToday;
@override@JsonKey(name: 'limit_today') final  int limitToday;
@override@JsonKey() final  int remaining;
@override@JsonKey(name: 'plan_type') final  String planType;
@override@JsonKey(name: 'resets_at') final  DateTime? resetsAt;

/// Create a copy of PhotoshootUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoshootUsageCopyWith<_PhotoshootUsage> get copyWith => __$PhotoshootUsageCopyWithImpl<_PhotoshootUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoshootUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoshootUsage&&(identical(other.usedToday, usedToday) || other.usedToday == usedToday)&&(identical(other.limitToday, limitToday) || other.limitToday == limitToday)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.resetsAt, resetsAt) || other.resetsAt == resetsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usedToday,limitToday,remaining,planType,resetsAt);

@override
String toString() {
  return 'PhotoshootUsage(usedToday: $usedToday, limitToday: $limitToday, remaining: $remaining, planType: $planType, resetsAt: $resetsAt)';
}


}

/// @nodoc
abstract mixin class _$PhotoshootUsageCopyWith<$Res> implements $PhotoshootUsageCopyWith<$Res> {
  factory _$PhotoshootUsageCopyWith(_PhotoshootUsage value, $Res Function(_PhotoshootUsage) _then) = __$PhotoshootUsageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'used_today') int usedToday,@JsonKey(name: 'limit_today') int limitToday, int remaining,@JsonKey(name: 'plan_type') String planType,@JsonKey(name: 'resets_at') DateTime? resetsAt
});




}
/// @nodoc
class __$PhotoshootUsageCopyWithImpl<$Res>
    implements _$PhotoshootUsageCopyWith<$Res> {
  __$PhotoshootUsageCopyWithImpl(this._self, this._then);

  final _PhotoshootUsage _self;
  final $Res Function(_PhotoshootUsage) _then;

/// Create a copy of PhotoshootUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? usedToday = null,Object? limitToday = null,Object? remaining = null,Object? planType = null,Object? resetsAt = freezed,}) {
  return _then(_PhotoshootUsage(
usedToday: null == usedToday ? _self.usedToday : usedToday // ignore: cast_nullable_to_non_nullable
as int,limitToday: null == limitToday ? _self.limitToday : limitToday // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,resetsAt: freezed == resetsAt ? _self.resetsAt : resetsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PhotoshootRequest {

 List<String> get photos;@JsonKey(name: 'use_case') PhotoshootUseCase get useCase;@JsonKey(name: 'custom_prompt') String? get customPrompt;@JsonKey(name: 'num_images') int get numImages;
/// Create a copy of PhotoshootRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoshootRequestCopyWith<PhotoshootRequest> get copyWith => _$PhotoshootRequestCopyWithImpl<PhotoshootRequest>(this as PhotoshootRequest, _$identity);

  /// Serializes this PhotoshootRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoshootRequest&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.useCase, useCase) || other.useCase == useCase)&&(identical(other.customPrompt, customPrompt) || other.customPrompt == customPrompt)&&(identical(other.numImages, numImages) || other.numImages == numImages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(photos),useCase,customPrompt,numImages);

@override
String toString() {
  return 'PhotoshootRequest(photos: $photos, useCase: $useCase, customPrompt: $customPrompt, numImages: $numImages)';
}


}

/// @nodoc
abstract mixin class $PhotoshootRequestCopyWith<$Res>  {
  factory $PhotoshootRequestCopyWith(PhotoshootRequest value, $Res Function(PhotoshootRequest) _then) = _$PhotoshootRequestCopyWithImpl;
@useResult
$Res call({
 List<String> photos,@JsonKey(name: 'use_case') PhotoshootUseCase useCase,@JsonKey(name: 'custom_prompt') String? customPrompt,@JsonKey(name: 'num_images') int numImages
});




}
/// @nodoc
class _$PhotoshootRequestCopyWithImpl<$Res>
    implements $PhotoshootRequestCopyWith<$Res> {
  _$PhotoshootRequestCopyWithImpl(this._self, this._then);

  final PhotoshootRequest _self;
  final $Res Function(PhotoshootRequest) _then;

/// Create a copy of PhotoshootRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photos = null,Object? useCase = null,Object? customPrompt = freezed,Object? numImages = null,}) {
  return _then(_self.copyWith(
photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,useCase: null == useCase ? _self.useCase : useCase // ignore: cast_nullable_to_non_nullable
as PhotoshootUseCase,customPrompt: freezed == customPrompt ? _self.customPrompt : customPrompt // ignore: cast_nullable_to_non_nullable
as String?,numImages: null == numImages ? _self.numImages : numImages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoshootRequest].
extension PhotoshootRequestPatterns on PhotoshootRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoshootRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoshootRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoshootRequest value)  $default,){
final _that = this;
switch (_that) {
case _PhotoshootRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoshootRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoshootRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> photos, @JsonKey(name: 'use_case')  PhotoshootUseCase useCase, @JsonKey(name: 'custom_prompt')  String? customPrompt, @JsonKey(name: 'num_images')  int numImages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoshootRequest() when $default != null:
return $default(_that.photos,_that.useCase,_that.customPrompt,_that.numImages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> photos, @JsonKey(name: 'use_case')  PhotoshootUseCase useCase, @JsonKey(name: 'custom_prompt')  String? customPrompt, @JsonKey(name: 'num_images')  int numImages)  $default,) {final _that = this;
switch (_that) {
case _PhotoshootRequest():
return $default(_that.photos,_that.useCase,_that.customPrompt,_that.numImages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> photos, @JsonKey(name: 'use_case')  PhotoshootUseCase useCase, @JsonKey(name: 'custom_prompt')  String? customPrompt, @JsonKey(name: 'num_images')  int numImages)?  $default,) {final _that = this;
switch (_that) {
case _PhotoshootRequest() when $default != null:
return $default(_that.photos,_that.useCase,_that.customPrompt,_that.numImages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoshootRequest implements PhotoshootRequest {
  const _PhotoshootRequest({required final  List<String> photos, @JsonKey(name: 'use_case') required this.useCase, @JsonKey(name: 'custom_prompt') this.customPrompt, @JsonKey(name: 'num_images') this.numImages = 10}): _photos = photos;
  factory _PhotoshootRequest.fromJson(Map<String, dynamic> json) => _$PhotoshootRequestFromJson(json);

 final  List<String> _photos;
@override List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override@JsonKey(name: 'use_case') final  PhotoshootUseCase useCase;
@override@JsonKey(name: 'custom_prompt') final  String? customPrompt;
@override@JsonKey(name: 'num_images') final  int numImages;

/// Create a copy of PhotoshootRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoshootRequestCopyWith<_PhotoshootRequest> get copyWith => __$PhotoshootRequestCopyWithImpl<_PhotoshootRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoshootRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoshootRequest&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.useCase, useCase) || other.useCase == useCase)&&(identical(other.customPrompt, customPrompt) || other.customPrompt == customPrompt)&&(identical(other.numImages, numImages) || other.numImages == numImages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_photos),useCase,customPrompt,numImages);

@override
String toString() {
  return 'PhotoshootRequest(photos: $photos, useCase: $useCase, customPrompt: $customPrompt, numImages: $numImages)';
}


}

/// @nodoc
abstract mixin class _$PhotoshootRequestCopyWith<$Res> implements $PhotoshootRequestCopyWith<$Res> {
  factory _$PhotoshootRequestCopyWith(_PhotoshootRequest value, $Res Function(_PhotoshootRequest) _then) = __$PhotoshootRequestCopyWithImpl;
@override @useResult
$Res call({
 List<String> photos,@JsonKey(name: 'use_case') PhotoshootUseCase useCase,@JsonKey(name: 'custom_prompt') String? customPrompt,@JsonKey(name: 'num_images') int numImages
});




}
/// @nodoc
class __$PhotoshootRequestCopyWithImpl<$Res>
    implements _$PhotoshootRequestCopyWith<$Res> {
  __$PhotoshootRequestCopyWithImpl(this._self, this._then);

  final _PhotoshootRequest _self;
  final $Res Function(_PhotoshootRequest) _then;

/// Create a copy of PhotoshootRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photos = null,Object? useCase = null,Object? customPrompt = freezed,Object? numImages = null,}) {
  return _then(_PhotoshootRequest(
photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,useCase: null == useCase ? _self.useCase : useCase // ignore: cast_nullable_to_non_nullable
as PhotoshootUseCase,customPrompt: freezed == customPrompt ? _self.customPrompt : customPrompt // ignore: cast_nullable_to_non_nullable
as String?,numImages: null == numImages ? _self.numImages : numImages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PhotoshootResult {

@JsonKey(name: 'session_id') String get sessionId; PhotoshootStatus get status; List<GeneratedImage> get images; PhotoshootUsage? get usage; String? get error;
/// Create a copy of PhotoshootResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoshootResultCopyWith<PhotoshootResult> get copyWith => _$PhotoshootResultCopyWithImpl<PhotoshootResult>(this as PhotoshootResult, _$identity);

  /// Serializes this PhotoshootResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoshootResult&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,status,const DeepCollectionEquality().hash(images),usage,error);

@override
String toString() {
  return 'PhotoshootResult(sessionId: $sessionId, status: $status, images: $images, usage: $usage, error: $error)';
}


}

/// @nodoc
abstract mixin class $PhotoshootResultCopyWith<$Res>  {
  factory $PhotoshootResultCopyWith(PhotoshootResult value, $Res Function(PhotoshootResult) _then) = _$PhotoshootResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, PhotoshootStatus status, List<GeneratedImage> images, PhotoshootUsage? usage, String? error
});


$PhotoshootUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class _$PhotoshootResultCopyWithImpl<$Res>
    implements $PhotoshootResultCopyWith<$Res> {
  _$PhotoshootResultCopyWithImpl(this._self, this._then);

  final PhotoshootResult _self;
  final $Res Function(PhotoshootResult) _then;

/// Create a copy of PhotoshootResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? status = null,Object? images = null,Object? usage = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhotoshootStatus,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<GeneratedImage>,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as PhotoshootUsage?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PhotoshootResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoshootUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $PhotoshootUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhotoshootResult].
extension PhotoshootResultPatterns on PhotoshootResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoshootResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoshootResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoshootResult value)  $default,){
final _that = this;
switch (_that) {
case _PhotoshootResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoshootResult value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoshootResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  PhotoshootStatus status,  List<GeneratedImage> images,  PhotoshootUsage? usage,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoshootResult() when $default != null:
return $default(_that.sessionId,_that.status,_that.images,_that.usage,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId,  PhotoshootStatus status,  List<GeneratedImage> images,  PhotoshootUsage? usage,  String? error)  $default,) {final _that = this;
switch (_that) {
case _PhotoshootResult():
return $default(_that.sessionId,_that.status,_that.images,_that.usage,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId,  PhotoshootStatus status,  List<GeneratedImage> images,  PhotoshootUsage? usage,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _PhotoshootResult() when $default != null:
return $default(_that.sessionId,_that.status,_that.images,_that.usage,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoshootResult implements PhotoshootResult {
  const _PhotoshootResult({@JsonKey(name: 'session_id') required this.sessionId, required this.status, final  List<GeneratedImage> images = const [], this.usage, this.error}): _images = images;
  factory _PhotoshootResult.fromJson(Map<String, dynamic> json) => _$PhotoshootResultFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override final  PhotoshootStatus status;
 final  List<GeneratedImage> _images;
@override@JsonKey() List<GeneratedImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  PhotoshootUsage? usage;
@override final  String? error;

/// Create a copy of PhotoshootResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoshootResultCopyWith<_PhotoshootResult> get copyWith => __$PhotoshootResultCopyWithImpl<_PhotoshootResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoshootResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoshootResult&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,status,const DeepCollectionEquality().hash(_images),usage,error);

@override
String toString() {
  return 'PhotoshootResult(sessionId: $sessionId, status: $status, images: $images, usage: $usage, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PhotoshootResultCopyWith<$Res> implements $PhotoshootResultCopyWith<$Res> {
  factory _$PhotoshootResultCopyWith(_PhotoshootResult value, $Res Function(_PhotoshootResult) _then) = __$PhotoshootResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId, PhotoshootStatus status, List<GeneratedImage> images, PhotoshootUsage? usage, String? error
});


@override $PhotoshootUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class __$PhotoshootResultCopyWithImpl<$Res>
    implements _$PhotoshootResultCopyWith<$Res> {
  __$PhotoshootResultCopyWithImpl(this._self, this._then);

  final _PhotoshootResult _self;
  final $Res Function(_PhotoshootResult) _then;

/// Create a copy of PhotoshootResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? status = null,Object? images = null,Object? usage = freezed,Object? error = freezed,}) {
  return _then(_PhotoshootResult(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhotoshootStatus,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<GeneratedImage>,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as PhotoshootUsage?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PhotoshootResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoshootUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $PhotoshootUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// @nodoc
mixin _$UseCaseInfo {

 String get id; String get name; String get description;@JsonKey(name: 'example_prompts') List<String> get examplePrompts;
/// Create a copy of UseCaseInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UseCaseInfoCopyWith<UseCaseInfo> get copyWith => _$UseCaseInfoCopyWithImpl<UseCaseInfo>(this as UseCaseInfo, _$identity);

  /// Serializes this UseCaseInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCaseInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.examplePrompts, examplePrompts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(examplePrompts));

@override
String toString() {
  return 'UseCaseInfo(id: $id, name: $name, description: $description, examplePrompts: $examplePrompts)';
}


}

/// @nodoc
abstract mixin class $UseCaseInfoCopyWith<$Res>  {
  factory $UseCaseInfoCopyWith(UseCaseInfo value, $Res Function(UseCaseInfo) _then) = _$UseCaseInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description,@JsonKey(name: 'example_prompts') List<String> examplePrompts
});




}
/// @nodoc
class _$UseCaseInfoCopyWithImpl<$Res>
    implements $UseCaseInfoCopyWith<$Res> {
  _$UseCaseInfoCopyWithImpl(this._self, this._then);

  final UseCaseInfo _self;
  final $Res Function(UseCaseInfo) _then;

/// Create a copy of UseCaseInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? examplePrompts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,examplePrompts: null == examplePrompts ? _self.examplePrompts : examplePrompts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UseCaseInfo].
extension UseCaseInfoPatterns on UseCaseInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UseCaseInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UseCaseInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UseCaseInfo value)  $default,){
final _that = this;
switch (_that) {
case _UseCaseInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UseCaseInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UseCaseInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description, @JsonKey(name: 'example_prompts')  List<String> examplePrompts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UseCaseInfo() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.examplePrompts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description, @JsonKey(name: 'example_prompts')  List<String> examplePrompts)  $default,) {final _that = this;
switch (_that) {
case _UseCaseInfo():
return $default(_that.id,_that.name,_that.description,_that.examplePrompts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description, @JsonKey(name: 'example_prompts')  List<String> examplePrompts)?  $default,) {final _that = this;
switch (_that) {
case _UseCaseInfo() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.examplePrompts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UseCaseInfo implements UseCaseInfo {
  const _UseCaseInfo({required this.id, required this.name, required this.description, @JsonKey(name: 'example_prompts') final  List<String> examplePrompts = const []}): _examplePrompts = examplePrompts;
  factory _UseCaseInfo.fromJson(Map<String, dynamic> json) => _$UseCaseInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
 final  List<String> _examplePrompts;
@override@JsonKey(name: 'example_prompts') List<String> get examplePrompts {
  if (_examplePrompts is EqualUnmodifiableListView) return _examplePrompts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examplePrompts);
}


/// Create a copy of UseCaseInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UseCaseInfoCopyWith<_UseCaseInfo> get copyWith => __$UseCaseInfoCopyWithImpl<_UseCaseInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UseCaseInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UseCaseInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._examplePrompts, _examplePrompts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_examplePrompts));

@override
String toString() {
  return 'UseCaseInfo(id: $id, name: $name, description: $description, examplePrompts: $examplePrompts)';
}


}

/// @nodoc
abstract mixin class _$UseCaseInfoCopyWith<$Res> implements $UseCaseInfoCopyWith<$Res> {
  factory _$UseCaseInfoCopyWith(_UseCaseInfo value, $Res Function(_UseCaseInfo) _then) = __$UseCaseInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description,@JsonKey(name: 'example_prompts') List<String> examplePrompts
});




}
/// @nodoc
class __$UseCaseInfoCopyWithImpl<$Res>
    implements _$UseCaseInfoCopyWith<$Res> {
  __$UseCaseInfoCopyWithImpl(this._self, this._then);

  final _UseCaseInfo _self;
  final $Res Function(_UseCaseInfo) _then;

/// Create a copy of UseCaseInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? examplePrompts = null,}) {
  return _then(_UseCaseInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,examplePrompts: null == examplePrompts ? _self._examplePrompts : examplePrompts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$PhotoshootJobResponse {

@JsonKey(name: 'job_id') String get jobId; String get status; String? get message;
/// Create a copy of PhotoshootJobResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoshootJobResponseCopyWith<PhotoshootJobResponse> get copyWith => _$PhotoshootJobResponseCopyWithImpl<PhotoshootJobResponse>(this as PhotoshootJobResponse, _$identity);

  /// Serializes this PhotoshootJobResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoshootJobResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,message);

@override
String toString() {
  return 'PhotoshootJobResponse(jobId: $jobId, status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class $PhotoshootJobResponseCopyWith<$Res>  {
  factory $PhotoshootJobResponseCopyWith(PhotoshootJobResponse value, $Res Function(PhotoshootJobResponse) _then) = _$PhotoshootJobResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status, String? message
});




}
/// @nodoc
class _$PhotoshootJobResponseCopyWithImpl<$Res>
    implements $PhotoshootJobResponseCopyWith<$Res> {
  _$PhotoshootJobResponseCopyWithImpl(this._self, this._then);

  final PhotoshootJobResponse _self;
  final $Res Function(PhotoshootJobResponse) _then;

/// Create a copy of PhotoshootJobResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoshootJobResponse].
extension PhotoshootJobResponsePatterns on PhotoshootJobResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoshootJobResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoshootJobResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoshootJobResponse value)  $default,){
final _that = this;
switch (_that) {
case _PhotoshootJobResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoshootJobResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoshootJobResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoshootJobResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status,  String? message)  $default,) {final _that = this;
switch (_that) {
case _PhotoshootJobResponse():
return $default(_that.jobId,_that.status,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'job_id')  String jobId,  String status,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _PhotoshootJobResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoshootJobResponse implements PhotoshootJobResponse {
  const _PhotoshootJobResponse({@JsonKey(name: 'job_id') required this.jobId, required this.status, this.message});
  factory _PhotoshootJobResponse.fromJson(Map<String, dynamic> json) => _$PhotoshootJobResponseFromJson(json);

@override@JsonKey(name: 'job_id') final  String jobId;
@override final  String status;
@override final  String? message;

/// Create a copy of PhotoshootJobResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoshootJobResponseCopyWith<_PhotoshootJobResponse> get copyWith => __$PhotoshootJobResponseCopyWithImpl<_PhotoshootJobResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoshootJobResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoshootJobResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,message);

@override
String toString() {
  return 'PhotoshootJobResponse(jobId: $jobId, status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PhotoshootJobResponseCopyWith<$Res> implements $PhotoshootJobResponseCopyWith<$Res> {
  factory _$PhotoshootJobResponseCopyWith(_PhotoshootJobResponse value, $Res Function(_PhotoshootJobResponse) _then) = __$PhotoshootJobResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status, String? message
});




}
/// @nodoc
class __$PhotoshootJobResponseCopyWithImpl<$Res>
    implements _$PhotoshootJobResponseCopyWith<$Res> {
  __$PhotoshootJobResponseCopyWithImpl(this._self, this._then);

  final _PhotoshootJobResponse _self;
  final $Res Function(_PhotoshootJobResponse) _then;

/// Create a copy of PhotoshootJobResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? message = freezed,}) {
  return _then(_PhotoshootJobResponse(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PhotoshootJobStatusResponse {

@JsonKey(name: 'job_id') String get jobId; String get status;@JsonKey(name: 'generated_count') int get generatedCount;@JsonKey(name: 'total_count') int get totalCount;@JsonKey(name: 'current_batch') int get currentBatch;@JsonKey(name: 'total_batches') int get totalBatches; List<GeneratedImage> get images; PhotoshootUsage? get usage; String? get error;
/// Create a copy of PhotoshootJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoshootJobStatusResponseCopyWith<PhotoshootJobStatusResponse> get copyWith => _$PhotoshootJobStatusResponseCopyWithImpl<PhotoshootJobStatusResponse>(this as PhotoshootJobStatusResponse, _$identity);

  /// Serializes this PhotoshootJobStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoshootJobStatusResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.totalBatches, totalBatches) || other.totalBatches == totalBatches)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,generatedCount,totalCount,currentBatch,totalBatches,const DeepCollectionEquality().hash(images),usage,error);

@override
String toString() {
  return 'PhotoshootJobStatusResponse(jobId: $jobId, status: $status, generatedCount: $generatedCount, totalCount: $totalCount, currentBatch: $currentBatch, totalBatches: $totalBatches, images: $images, usage: $usage, error: $error)';
}


}

/// @nodoc
abstract mixin class $PhotoshootJobStatusResponseCopyWith<$Res>  {
  factory $PhotoshootJobStatusResponseCopyWith(PhotoshootJobStatusResponse value, $Res Function(PhotoshootJobStatusResponse) _then) = _$PhotoshootJobStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status,@JsonKey(name: 'generated_count') int generatedCount,@JsonKey(name: 'total_count') int totalCount,@JsonKey(name: 'current_batch') int currentBatch,@JsonKey(name: 'total_batches') int totalBatches, List<GeneratedImage> images, PhotoshootUsage? usage, String? error
});


$PhotoshootUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class _$PhotoshootJobStatusResponseCopyWithImpl<$Res>
    implements $PhotoshootJobStatusResponseCopyWith<$Res> {
  _$PhotoshootJobStatusResponseCopyWithImpl(this._self, this._then);

  final PhotoshootJobStatusResponse _self;
  final $Res Function(PhotoshootJobStatusResponse) _then;

/// Create a copy of PhotoshootJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? generatedCount = null,Object? totalCount = null,Object? currentBatch = null,Object? totalBatches = null,Object? images = null,Object? usage = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,totalBatches: null == totalBatches ? _self.totalBatches : totalBatches // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<GeneratedImage>,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as PhotoshootUsage?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PhotoshootJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoshootUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $PhotoshootUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhotoshootJobStatusResponse].
extension PhotoshootJobStatusResponsePatterns on PhotoshootJobStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoshootJobStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoshootJobStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoshootJobStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _PhotoshootJobStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoshootJobStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoshootJobStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'generated_count')  int generatedCount, @JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'current_batch')  int currentBatch, @JsonKey(name: 'total_batches')  int totalBatches,  List<GeneratedImage> images,  PhotoshootUsage? usage,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoshootJobStatusResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.generatedCount,_that.totalCount,_that.currentBatch,_that.totalBatches,_that.images,_that.usage,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'generated_count')  int generatedCount, @JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'current_batch')  int currentBatch, @JsonKey(name: 'total_batches')  int totalBatches,  List<GeneratedImage> images,  PhotoshootUsage? usage,  String? error)  $default,) {final _that = this;
switch (_that) {
case _PhotoshootJobStatusResponse():
return $default(_that.jobId,_that.status,_that.generatedCount,_that.totalCount,_that.currentBatch,_that.totalBatches,_that.images,_that.usage,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'job_id')  String jobId,  String status, @JsonKey(name: 'generated_count')  int generatedCount, @JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'current_batch')  int currentBatch, @JsonKey(name: 'total_batches')  int totalBatches,  List<GeneratedImage> images,  PhotoshootUsage? usage,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _PhotoshootJobStatusResponse() when $default != null:
return $default(_that.jobId,_that.status,_that.generatedCount,_that.totalCount,_that.currentBatch,_that.totalBatches,_that.images,_that.usage,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoshootJobStatusResponse implements PhotoshootJobStatusResponse {
  const _PhotoshootJobStatusResponse({@JsonKey(name: 'job_id') required this.jobId, required this.status, @JsonKey(name: 'generated_count') this.generatedCount = 0, @JsonKey(name: 'total_count') this.totalCount = 0, @JsonKey(name: 'current_batch') this.currentBatch = 0, @JsonKey(name: 'total_batches') this.totalBatches = 0, final  List<GeneratedImage> images = const [], this.usage, this.error}): _images = images;
  factory _PhotoshootJobStatusResponse.fromJson(Map<String, dynamic> json) => _$PhotoshootJobStatusResponseFromJson(json);

@override@JsonKey(name: 'job_id') final  String jobId;
@override final  String status;
@override@JsonKey(name: 'generated_count') final  int generatedCount;
@override@JsonKey(name: 'total_count') final  int totalCount;
@override@JsonKey(name: 'current_batch') final  int currentBatch;
@override@JsonKey(name: 'total_batches') final  int totalBatches;
 final  List<GeneratedImage> _images;
@override@JsonKey() List<GeneratedImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  PhotoshootUsage? usage;
@override final  String? error;

/// Create a copy of PhotoshootJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoshootJobStatusResponseCopyWith<_PhotoshootJobStatusResponse> get copyWith => __$PhotoshootJobStatusResponseCopyWithImpl<_PhotoshootJobStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoshootJobStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoshootJobStatusResponse&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.totalBatches, totalBatches) || other.totalBatches == totalBatches)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status,generatedCount,totalCount,currentBatch,totalBatches,const DeepCollectionEquality().hash(_images),usage,error);

@override
String toString() {
  return 'PhotoshootJobStatusResponse(jobId: $jobId, status: $status, generatedCount: $generatedCount, totalCount: $totalCount, currentBatch: $currentBatch, totalBatches: $totalBatches, images: $images, usage: $usage, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PhotoshootJobStatusResponseCopyWith<$Res> implements $PhotoshootJobStatusResponseCopyWith<$Res> {
  factory _$PhotoshootJobStatusResponseCopyWith(_PhotoshootJobStatusResponse value, $Res Function(_PhotoshootJobStatusResponse) _then) = __$PhotoshootJobStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status,@JsonKey(name: 'generated_count') int generatedCount,@JsonKey(name: 'total_count') int totalCount,@JsonKey(name: 'current_batch') int currentBatch,@JsonKey(name: 'total_batches') int totalBatches, List<GeneratedImage> images, PhotoshootUsage? usage, String? error
});


@override $PhotoshootUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class __$PhotoshootJobStatusResponseCopyWithImpl<$Res>
    implements _$PhotoshootJobStatusResponseCopyWith<$Res> {
  __$PhotoshootJobStatusResponseCopyWithImpl(this._self, this._then);

  final _PhotoshootJobStatusResponse _self;
  final $Res Function(_PhotoshootJobStatusResponse) _then;

/// Create a copy of PhotoshootJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? generatedCount = null,Object? totalCount = null,Object? currentBatch = null,Object? totalBatches = null,Object? images = null,Object? usage = freezed,Object? error = freezed,}) {
  return _then(_PhotoshootJobStatusResponse(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,totalBatches: null == totalBatches ? _self.totalBatches : totalBatches // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<GeneratedImage>,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as PhotoshootUsage?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PhotoshootJobStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoshootUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $PhotoshootUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}

// dart format on
