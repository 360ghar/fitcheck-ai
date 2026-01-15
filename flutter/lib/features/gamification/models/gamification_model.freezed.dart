// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakModel {

 int get currentStreak; int get longestStreak; int? get nextMilestone;@JsonKey(name: 'last_active_at') DateTime? get lastActiveAt;
/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakModelCopyWith<StreakModel> get copyWith => _$StreakModelCopyWithImpl<StreakModel>(this as StreakModel, _$identity);

  /// Serializes this StreakModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakModel&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.nextMilestone, nextMilestone) || other.nextMilestone == nextMilestone)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,nextMilestone,lastActiveAt);

@override
String toString() {
  return 'StreakModel(currentStreak: $currentStreak, longestStreak: $longestStreak, nextMilestone: $nextMilestone, lastActiveAt: $lastActiveAt)';
}


}

/// @nodoc
abstract mixin class $StreakModelCopyWith<$Res>  {
  factory $StreakModelCopyWith(StreakModel value, $Res Function(StreakModel) _then) = _$StreakModelCopyWithImpl;
@useResult
$Res call({
 int currentStreak, int longestStreak, int? nextMilestone,@JsonKey(name: 'last_active_at') DateTime? lastActiveAt
});




}
/// @nodoc
class _$StreakModelCopyWithImpl<$Res>
    implements $StreakModelCopyWith<$Res> {
  _$StreakModelCopyWithImpl(this._self, this._then);

  final StreakModel _self;
  final $Res Function(StreakModel) _then;

/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? nextMilestone = freezed,Object? lastActiveAt = freezed,}) {
  return _then(_self.copyWith(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,nextMilestone: freezed == nextMilestone ? _self.nextMilestone : nextMilestone // ignore: cast_nullable_to_non_nullable
as int?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakModel].
extension StreakModelPatterns on StreakModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakModel value)  $default,){
final _that = this;
switch (_that) {
case _StreakModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakModel value)?  $default,){
final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  int? nextMilestone, @JsonKey(name: 'last_active_at')  DateTime? lastActiveAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.nextMilestone,_that.lastActiveAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  int? nextMilestone, @JsonKey(name: 'last_active_at')  DateTime? lastActiveAt)  $default,) {final _that = this;
switch (_that) {
case _StreakModel():
return $default(_that.currentStreak,_that.longestStreak,_that.nextMilestone,_that.lastActiveAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  int longestStreak,  int? nextMilestone, @JsonKey(name: 'last_active_at')  DateTime? lastActiveAt)?  $default,) {final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.nextMilestone,_that.lastActiveAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakModel implements StreakModel {
  const _StreakModel({this.currentStreak = 0, this.longestStreak = 0, this.nextMilestone, @JsonKey(name: 'last_active_at') this.lastActiveAt});
  factory _StreakModel.fromJson(Map<String, dynamic> json) => _$StreakModelFromJson(json);

@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override final  int? nextMilestone;
@override@JsonKey(name: 'last_active_at') final  DateTime? lastActiveAt;

/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakModelCopyWith<_StreakModel> get copyWith => __$StreakModelCopyWithImpl<_StreakModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakModel&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.nextMilestone, nextMilestone) || other.nextMilestone == nextMilestone)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,nextMilestone,lastActiveAt);

@override
String toString() {
  return 'StreakModel(currentStreak: $currentStreak, longestStreak: $longestStreak, nextMilestone: $nextMilestone, lastActiveAt: $lastActiveAt)';
}


}

/// @nodoc
abstract mixin class _$StreakModelCopyWith<$Res> implements $StreakModelCopyWith<$Res> {
  factory _$StreakModelCopyWith(_StreakModel value, $Res Function(_StreakModel) _then) = __$StreakModelCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, int longestStreak, int? nextMilestone,@JsonKey(name: 'last_active_at') DateTime? lastActiveAt
});




}
/// @nodoc
class __$StreakModelCopyWithImpl<$Res>
    implements _$StreakModelCopyWith<$Res> {
  __$StreakModelCopyWithImpl(this._self, this._then);

  final _StreakModel _self;
  final $Res Function(_StreakModel) _then;

/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? nextMilestone = freezed,Object? lastActiveAt = freezed,}) {
  return _then(_StreakModel(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,nextMilestone: freezed == nextMilestone ? _self.nextMilestone : nextMilestone // ignore: cast_nullable_to_non_nullable
as int?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$AchievementModel {

 String get id; String get name; String? get description; String? get iconName; int get progress; int get target; bool get isUnlocked;@JsonKey(name: 'unlocked_at') DateTime? get unlockedAt;
/// Create a copy of AchievementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementModelCopyWith<AchievementModel> get copyWith => _$AchievementModelCopyWithImpl<AchievementModel>(this as AchievementModel, _$identity);

  /// Serializes this AchievementModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.target, target) || other.target == target)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,iconName,progress,target,isUnlocked,unlockedAt);

@override
String toString() {
  return 'AchievementModel(id: $id, name: $name, description: $description, iconName: $iconName, progress: $progress, target: $target, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class $AchievementModelCopyWith<$Res>  {
  factory $AchievementModelCopyWith(AchievementModel value, $Res Function(AchievementModel) _then) = _$AchievementModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? iconName, int progress, int target, bool isUnlocked,@JsonKey(name: 'unlocked_at') DateTime? unlockedAt
});




}
/// @nodoc
class _$AchievementModelCopyWithImpl<$Res>
    implements $AchievementModelCopyWith<$Res> {
  _$AchievementModelCopyWithImpl(this._self, this._then);

  final AchievementModel _self;
  final $Res Function(AchievementModel) _then;

/// Create a copy of AchievementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? iconName = freezed,Object? progress = null,Object? target = null,Object? isUnlocked = null,Object? unlockedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AchievementModel].
extension AchievementModelPatterns on AchievementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementModel value)  $default,){
final _that = this;
switch (_that) {
case _AchievementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementModel value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? iconName,  int progress,  int target,  bool isUnlocked, @JsonKey(name: 'unlocked_at')  DateTime? unlockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.iconName,_that.progress,_that.target,_that.isUnlocked,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? iconName,  int progress,  int target,  bool isUnlocked, @JsonKey(name: 'unlocked_at')  DateTime? unlockedAt)  $default,) {final _that = this;
switch (_that) {
case _AchievementModel():
return $default(_that.id,_that.name,_that.description,_that.iconName,_that.progress,_that.target,_that.isUnlocked,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? iconName,  int progress,  int target,  bool isUnlocked, @JsonKey(name: 'unlocked_at')  DateTime? unlockedAt)?  $default,) {final _that = this;
switch (_that) {
case _AchievementModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.iconName,_that.progress,_that.target,_that.isUnlocked,_that.unlockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AchievementModel implements AchievementModel {
  const _AchievementModel({required this.id, required this.name, this.description, this.iconName, this.progress = 0, this.target = 1, this.isUnlocked = false, @JsonKey(name: 'unlocked_at') this.unlockedAt});
  factory _AchievementModel.fromJson(Map<String, dynamic> json) => _$AchievementModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? iconName;
@override@JsonKey() final  int progress;
@override@JsonKey() final  int target;
@override@JsonKey() final  bool isUnlocked;
@override@JsonKey(name: 'unlocked_at') final  DateTime? unlockedAt;

/// Create a copy of AchievementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementModelCopyWith<_AchievementModel> get copyWith => __$AchievementModelCopyWithImpl<_AchievementModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.target, target) || other.target == target)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,iconName,progress,target,isUnlocked,unlockedAt);

@override
String toString() {
  return 'AchievementModel(id: $id, name: $name, description: $description, iconName: $iconName, progress: $progress, target: $target, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class _$AchievementModelCopyWith<$Res> implements $AchievementModelCopyWith<$Res> {
  factory _$AchievementModelCopyWith(_AchievementModel value, $Res Function(_AchievementModel) _then) = __$AchievementModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? iconName, int progress, int target, bool isUnlocked,@JsonKey(name: 'unlocked_at') DateTime? unlockedAt
});




}
/// @nodoc
class __$AchievementModelCopyWithImpl<$Res>
    implements _$AchievementModelCopyWith<$Res> {
  __$AchievementModelCopyWithImpl(this._self, this._then);

  final _AchievementModel _self;
  final $Res Function(_AchievementModel) _then;

/// Create a copy of AchievementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? iconName = freezed,Object? progress = null,Object? target = null,Object? isUnlocked = null,Object? unlockedAt = freezed,}) {
  return _then(_AchievementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$LeaderboardEntry {

 String get userId; String get username; int get points; String? get avatarUrl; int get rank;
/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith => _$LeaderboardEntryCopyWithImpl<LeaderboardEntry>(this as LeaderboardEntry, _$identity);

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardEntry&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.points, points) || other.points == points)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,points,avatarUrl,rank);

@override
String toString() {
  return 'LeaderboardEntry(userId: $userId, username: $username, points: $points, avatarUrl: $avatarUrl, rank: $rank)';
}


}

/// @nodoc
abstract mixin class $LeaderboardEntryCopyWith<$Res>  {
  factory $LeaderboardEntryCopyWith(LeaderboardEntry value, $Res Function(LeaderboardEntry) _then) = _$LeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 String userId, String username, int points, String? avatarUrl, int rank
});




}
/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final LeaderboardEntry _self;
  final $Res Function(LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? points = null,Object? avatarUrl = freezed,Object? rank = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardEntry].
extension LeaderboardEntryPatterns on LeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  int points,  String? avatarUrl,  int rank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.userId,_that.username,_that.points,_that.avatarUrl,_that.rank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  int points,  String? avatarUrl,  int rank)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that.userId,_that.username,_that.points,_that.avatarUrl,_that.rank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  int points,  String? avatarUrl,  int rank)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.userId,_that.username,_that.points,_that.avatarUrl,_that.rank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardEntry implements LeaderboardEntry {
  const _LeaderboardEntry({required this.userId, required this.username, required this.points, this.avatarUrl, this.rank = 0});
  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);

@override final  String userId;
@override final  String username;
@override final  int points;
@override final  String? avatarUrl;
@override@JsonKey() final  int rank;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardEntryCopyWith<_LeaderboardEntry> get copyWith => __$LeaderboardEntryCopyWithImpl<_LeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardEntry&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.points, points) || other.points == points)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,points,avatarUrl,rank);

@override
String toString() {
  return 'LeaderboardEntry(userId: $userId, username: $username, points: $points, avatarUrl: $avatarUrl, rank: $rank)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardEntryCopyWith<$Res> implements $LeaderboardEntryCopyWith<$Res> {
  factory _$LeaderboardEntryCopyWith(_LeaderboardEntry value, $Res Function(_LeaderboardEntry) _then) = __$LeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, int points, String? avatarUrl, int rank
});




}
/// @nodoc
class __$LeaderboardEntryCopyWithImpl<$Res>
    implements _$LeaderboardEntryCopyWith<$Res> {
  __$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LeaderboardEntry _self;
  final $Res Function(_LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? points = null,Object? avatarUrl = freezed,Object? rank = null,}) {
  return _then(_LeaderboardEntry(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
