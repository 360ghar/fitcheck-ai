// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id; String get email; String? get fullName; String? get avatarUrl; String? get birthDate; String? get birthTime; String? get birthPlace;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt; UserPreferences? get preferences; UserSettings? get settings;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.birthTime, birthTime) || other.birthTime == birthTime)&&(identical(other.birthPlace, birthPlace) || other.birthPlace == birthPlace)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,fullName,avatarUrl,birthDate,birthTime,birthPlace,createdAt,updatedAt,preferences,settings);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, fullName: $fullName, avatarUrl: $avatarUrl, birthDate: $birthDate, birthTime: $birthTime, birthPlace: $birthPlace, createdAt: $createdAt, updatedAt: $updatedAt, preferences: $preferences, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, String? fullName, String? avatarUrl, String? birthDate, String? birthTime, String? birthPlace,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, UserPreferences? preferences, UserSettings? settings
});


$UserPreferencesCopyWith<$Res>? get preferences;$UserSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? fullName = freezed,Object? avatarUrl = freezed,Object? birthDate = freezed,Object? birthTime = freezed,Object? birthPlace = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? preferences = freezed,Object? settings = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,birthTime: freezed == birthTime ? _self.birthTime : birthTime // ignore: cast_nullable_to_non_nullable
as String?,birthPlace: freezed == birthPlace ? _self.birthPlace : birthPlace // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preferences: freezed == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings?,
  ));
}
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res>? get preferences {
    if (_self.preferences == null) {
    return null;
  }

  return $UserPreferencesCopyWith<$Res>(_self.preferences!, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $UserSettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String? fullName,  String? avatarUrl,  String? birthDate,  String? birthTime,  String? birthPlace, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  UserPreferences? preferences,  UserSettings? settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.fullName,_that.avatarUrl,_that.birthDate,_that.birthTime,_that.birthPlace,_that.createdAt,_that.updatedAt,_that.preferences,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String? fullName,  String? avatarUrl,  String? birthDate,  String? birthTime,  String? birthPlace, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  UserPreferences? preferences,  UserSettings? settings)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.email,_that.fullName,_that.avatarUrl,_that.birthDate,_that.birthTime,_that.birthPlace,_that.createdAt,_that.updatedAt,_that.preferences,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String? fullName,  String? avatarUrl,  String? birthDate,  String? birthTime,  String? birthPlace, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  UserPreferences? preferences,  UserSettings? settings)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.fullName,_that.avatarUrl,_that.birthDate,_that.birthTime,_that.birthPlace,_that.createdAt,_that.updatedAt,_that.preferences,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.email, this.fullName, this.avatarUrl, this.birthDate, this.birthTime, this.birthPlace, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, this.preferences, this.settings});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String email;
@override final  String? fullName;
@override final  String? avatarUrl;
@override final  String? birthDate;
@override final  String? birthTime;
@override final  String? birthPlace;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override final  UserPreferences? preferences;
@override final  UserSettings? settings;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.birthTime, birthTime) || other.birthTime == birthTime)&&(identical(other.birthPlace, birthPlace) || other.birthPlace == birthPlace)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,fullName,avatarUrl,birthDate,birthTime,birthPlace,createdAt,updatedAt,preferences,settings);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, fullName: $fullName, avatarUrl: $avatarUrl, birthDate: $birthDate, birthTime: $birthTime, birthPlace: $birthPlace, createdAt: $createdAt, updatedAt: $updatedAt, preferences: $preferences, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String? fullName, String? avatarUrl, String? birthDate, String? birthTime, String? birthPlace,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, UserPreferences? preferences, UserSettings? settings
});


@override $UserPreferencesCopyWith<$Res>? get preferences;@override $UserSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? fullName = freezed,Object? avatarUrl = freezed,Object? birthDate = freezed,Object? birthTime = freezed,Object? birthPlace = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? preferences = freezed,Object? settings = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,birthTime: freezed == birthTime ? _self.birthTime : birthTime // ignore: cast_nullable_to_non_nullable
as String?,birthPlace: freezed == birthPlace ? _self.birthPlace : birthPlace // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,preferences: freezed == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings?,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res>? get preferences {
    if (_self.preferences == null) {
    return null;
  }

  return $UserPreferencesCopyWith<$Res>(_self.preferences!, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $UserSettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// @nodoc
mixin _$UserPreferences {

@JsonKey(name: 'favorite_colors') List<String>? get favoriteColors; List<String>? get styles; List<String>? get brands; List<String>? get occasions; Map<String, dynamic>? get additionalData;
/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<UserPreferences> get copyWith => _$UserPreferencesCopyWithImpl<UserPreferences>(this as UserPreferences, _$identity);

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferences&&const DeepCollectionEquality().equals(other.favoriteColors, favoriteColors)&&const DeepCollectionEquality().equals(other.styles, styles)&&const DeepCollectionEquality().equals(other.brands, brands)&&const DeepCollectionEquality().equals(other.occasions, occasions)&&const DeepCollectionEquality().equals(other.additionalData, additionalData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(favoriteColors),const DeepCollectionEquality().hash(styles),const DeepCollectionEquality().hash(brands),const DeepCollectionEquality().hash(occasions),const DeepCollectionEquality().hash(additionalData));

@override
String toString() {
  return 'UserPreferences(favoriteColors: $favoriteColors, styles: $styles, brands: $brands, occasions: $occasions, additionalData: $additionalData)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesCopyWith<$Res>  {
  factory $UserPreferencesCopyWith(UserPreferences value, $Res Function(UserPreferences) _then) = _$UserPreferencesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'favorite_colors') List<String>? favoriteColors, List<String>? styles, List<String>? brands, List<String>? occasions, Map<String, dynamic>? additionalData
});




}
/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._self, this._then);

  final UserPreferences _self;
  final $Res Function(UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? favoriteColors = freezed,Object? styles = freezed,Object? brands = freezed,Object? occasions = freezed,Object? additionalData = freezed,}) {
  return _then(_self.copyWith(
favoriteColors: freezed == favoriteColors ? _self.favoriteColors : favoriteColors // ignore: cast_nullable_to_non_nullable
as List<String>?,styles: freezed == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,brands: freezed == brands ? _self.brands : brands // ignore: cast_nullable_to_non_nullable
as List<String>?,occasions: freezed == occasions ? _self.occasions : occasions // ignore: cast_nullable_to_non_nullable
as List<String>?,additionalData: freezed == additionalData ? _self.additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPreferences].
extension UserPreferencesPatterns on UserPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreferences value)  $default,){
final _that = this;
switch (_that) {
case _UserPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'favorite_colors')  List<String>? favoriteColors,  List<String>? styles,  List<String>? brands,  List<String>? occasions,  Map<String, dynamic>? additionalData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.favoriteColors,_that.styles,_that.brands,_that.occasions,_that.additionalData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'favorite_colors')  List<String>? favoriteColors,  List<String>? styles,  List<String>? brands,  List<String>? occasions,  Map<String, dynamic>? additionalData)  $default,) {final _that = this;
switch (_that) {
case _UserPreferences():
return $default(_that.favoriteColors,_that.styles,_that.brands,_that.occasions,_that.additionalData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'favorite_colors')  List<String>? favoriteColors,  List<String>? styles,  List<String>? brands,  List<String>? occasions,  Map<String, dynamic>? additionalData)?  $default,) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.favoriteColors,_that.styles,_that.brands,_that.occasions,_that.additionalData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreferences implements UserPreferences {
  const _UserPreferences({@JsonKey(name: 'favorite_colors') final  List<String>? favoriteColors, final  List<String>? styles, final  List<String>? brands, final  List<String>? occasions, final  Map<String, dynamic>? additionalData}): _favoriteColors = favoriteColors,_styles = styles,_brands = brands,_occasions = occasions,_additionalData = additionalData;
  factory _UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);

 final  List<String>? _favoriteColors;
@override@JsonKey(name: 'favorite_colors') List<String>? get favoriteColors {
  final value = _favoriteColors;
  if (value == null) return null;
  if (_favoriteColors is EqualUnmodifiableListView) return _favoriteColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _styles;
@override List<String>? get styles {
  final value = _styles;
  if (value == null) return null;
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _brands;
@override List<String>? get brands {
  final value = _brands;
  if (value == null) return null;
  if (_brands is EqualUnmodifiableListView) return _brands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _occasions;
@override List<String>? get occasions {
  final value = _occasions;
  if (value == null) return null;
  if (_occasions is EqualUnmodifiableListView) return _occasions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _additionalData;
@override Map<String, dynamic>? get additionalData {
  final value = _additionalData;
  if (value == null) return null;
  if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesCopyWith<_UserPreferences> get copyWith => __$UserPreferencesCopyWithImpl<_UserPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferences&&const DeepCollectionEquality().equals(other._favoriteColors, _favoriteColors)&&const DeepCollectionEquality().equals(other._styles, _styles)&&const DeepCollectionEquality().equals(other._brands, _brands)&&const DeepCollectionEquality().equals(other._occasions, _occasions)&&const DeepCollectionEquality().equals(other._additionalData, _additionalData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_favoriteColors),const DeepCollectionEquality().hash(_styles),const DeepCollectionEquality().hash(_brands),const DeepCollectionEquality().hash(_occasions),const DeepCollectionEquality().hash(_additionalData));

@override
String toString() {
  return 'UserPreferences(favoriteColors: $favoriteColors, styles: $styles, brands: $brands, occasions: $occasions, additionalData: $additionalData)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesCopyWith<$Res> implements $UserPreferencesCopyWith<$Res> {
  factory _$UserPreferencesCopyWith(_UserPreferences value, $Res Function(_UserPreferences) _then) = __$UserPreferencesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'favorite_colors') List<String>? favoriteColors, List<String>? styles, List<String>? brands, List<String>? occasions, Map<String, dynamic>? additionalData
});




}
/// @nodoc
class __$UserPreferencesCopyWithImpl<$Res>
    implements _$UserPreferencesCopyWith<$Res> {
  __$UserPreferencesCopyWithImpl(this._self, this._then);

  final _UserPreferences _self;
  final $Res Function(_UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? favoriteColors = freezed,Object? styles = freezed,Object? brands = freezed,Object? occasions = freezed,Object? additionalData = freezed,}) {
  return _then(_UserPreferences(
favoriteColors: freezed == favoriteColors ? _self._favoriteColors : favoriteColors // ignore: cast_nullable_to_non_nullable
as List<String>?,styles: freezed == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<String>?,brands: freezed == brands ? _self._brands : brands // ignore: cast_nullable_to_non_nullable
as List<String>?,occasions: freezed == occasions ? _self._occasions : occasions // ignore: cast_nullable_to_non_nullable
as List<String>?,additionalData: freezed == additionalData ? _self._additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$UserSettings {

 String? get location; String? get timezone; String? get units;@JsonKey(name: 'notifications_enabled') bool? get notificationsEnabled;@JsonKey(name: 'email_notifications') bool? get emailNotifications; Map<String, dynamic>? get additionalData;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.location, location) || other.location == location)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.units, units) || other.units == units)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&const DeepCollectionEquality().equals(other.additionalData, additionalData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,timezone,units,notificationsEnabled,emailNotifications,const DeepCollectionEquality().hash(additionalData));

@override
String toString() {
  return 'UserSettings(location: $location, timezone: $timezone, units: $units, notificationsEnabled: $notificationsEnabled, emailNotifications: $emailNotifications, additionalData: $additionalData)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String? location, String? timezone, String? units,@JsonKey(name: 'notifications_enabled') bool? notificationsEnabled,@JsonKey(name: 'email_notifications') bool? emailNotifications, Map<String, dynamic>? additionalData
});




}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? timezone = freezed,Object? units = freezed,Object? notificationsEnabled = freezed,Object? emailNotifications = freezed,Object? additionalData = freezed,}) {
  return _then(_self.copyWith(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,units: freezed == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as String?,notificationsEnabled: freezed == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool?,emailNotifications: freezed == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool?,additionalData: freezed == additionalData ? _self.additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? location,  String? timezone,  String? units, @JsonKey(name: 'notifications_enabled')  bool? notificationsEnabled, @JsonKey(name: 'email_notifications')  bool? emailNotifications,  Map<String, dynamic>? additionalData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.location,_that.timezone,_that.units,_that.notificationsEnabled,_that.emailNotifications,_that.additionalData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? location,  String? timezone,  String? units, @JsonKey(name: 'notifications_enabled')  bool? notificationsEnabled, @JsonKey(name: 'email_notifications')  bool? emailNotifications,  Map<String, dynamic>? additionalData)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.location,_that.timezone,_that.units,_that.notificationsEnabled,_that.emailNotifications,_that.additionalData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? location,  String? timezone,  String? units, @JsonKey(name: 'notifications_enabled')  bool? notificationsEnabled, @JsonKey(name: 'email_notifications')  bool? emailNotifications,  Map<String, dynamic>? additionalData)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.location,_that.timezone,_that.units,_that.notificationsEnabled,_that.emailNotifications,_that.additionalData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings implements UserSettings {
  const _UserSettings({this.location, this.timezone, this.units, @JsonKey(name: 'notifications_enabled') this.notificationsEnabled, @JsonKey(name: 'email_notifications') this.emailNotifications, final  Map<String, dynamic>? additionalData}): _additionalData = additionalData;
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override final  String? location;
@override final  String? timezone;
@override final  String? units;
@override@JsonKey(name: 'notifications_enabled') final  bool? notificationsEnabled;
@override@JsonKey(name: 'email_notifications') final  bool? emailNotifications;
 final  Map<String, dynamic>? _additionalData;
@override Map<String, dynamic>? get additionalData {
  final value = _additionalData;
  if (value == null) return null;
  if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.location, location) || other.location == location)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.units, units) || other.units == units)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&const DeepCollectionEquality().equals(other._additionalData, _additionalData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,timezone,units,notificationsEnabled,emailNotifications,const DeepCollectionEquality().hash(_additionalData));

@override
String toString() {
  return 'UserSettings(location: $location, timezone: $timezone, units: $units, notificationsEnabled: $notificationsEnabled, emailNotifications: $emailNotifications, additionalData: $additionalData)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String? location, String? timezone, String? units,@JsonKey(name: 'notifications_enabled') bool? notificationsEnabled,@JsonKey(name: 'email_notifications') bool? emailNotifications, Map<String, dynamic>? additionalData
});




}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? timezone = freezed,Object? units = freezed,Object? notificationsEnabled = freezed,Object? emailNotifications = freezed,Object? additionalData = freezed,}) {
  return _then(_UserSettings(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,units: freezed == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as String?,notificationsEnabled: freezed == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool?,emailNotifications: freezed == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool?,additionalData: freezed == additionalData ? _self._additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
