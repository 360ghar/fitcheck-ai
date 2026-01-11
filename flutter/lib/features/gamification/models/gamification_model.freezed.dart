// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakModel _$StreakModelFromJson(Map<String, dynamic> json) {
  return _StreakModel.fromJson(json);
}

/// @nodoc
mixin _$StreakModel {
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int? get nextMilestone => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_active_at')
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StreakModelCopyWith<StreakModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakModelCopyWith<$Res> {
  factory $StreakModelCopyWith(
          StreakModel value, $Res Function(StreakModel) then) =
      _$StreakModelCopyWithImpl<$Res, StreakModel>;
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      int? nextMilestone,
      @JsonKey(name: 'last_active_at') DateTime? lastActiveAt});
}

/// @nodoc
class _$StreakModelCopyWithImpl<$Res, $Val extends StreakModel>
    implements $StreakModelCopyWith<$Res> {
  _$StreakModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? nextMilestone = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      nextMilestone: freezed == nextMilestone
          ? _value.nextMilestone
          : nextMilestone // ignore: cast_nullable_to_non_nullable
              as int?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakModelImplCopyWith<$Res>
    implements $StreakModelCopyWith<$Res> {
  factory _$$StreakModelImplCopyWith(
          _$StreakModelImpl value, $Res Function(_$StreakModelImpl) then) =
      __$$StreakModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      int? nextMilestone,
      @JsonKey(name: 'last_active_at') DateTime? lastActiveAt});
}

/// @nodoc
class __$$StreakModelImplCopyWithImpl<$Res>
    extends _$StreakModelCopyWithImpl<$Res, _$StreakModelImpl>
    implements _$$StreakModelImplCopyWith<$Res> {
  __$$StreakModelImplCopyWithImpl(
      _$StreakModelImpl _value, $Res Function(_$StreakModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? nextMilestone = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_$StreakModelImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      nextMilestone: freezed == nextMilestone
          ? _value.nextMilestone
          : nextMilestone // ignore: cast_nullable_to_non_nullable
              as int?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakModelImpl implements _StreakModel {
  const _$StreakModelImpl(
      {this.currentStreak = 0,
      this.longestStreak = 0,
      this.nextMilestone,
      @JsonKey(name: 'last_active_at') this.lastActiveAt});

  factory _$StreakModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakModelImplFromJson(json);

  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  final int? nextMilestone;
  @override
  @JsonKey(name: 'last_active_at')
  final DateTime? lastActiveAt;

  @override
  String toString() {
    return 'StreakModel(currentStreak: $currentStreak, longestStreak: $longestStreak, nextMilestone: $nextMilestone, lastActiveAt: $lastActiveAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakModelImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.nextMilestone, nextMilestone) ||
                other.nextMilestone == nextMilestone) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, currentStreak, longestStreak, nextMilestone, lastActiveAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakModelImplCopyWith<_$StreakModelImpl> get copyWith =>
      __$$StreakModelImplCopyWithImpl<_$StreakModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakModelImplToJson(
      this,
    );
  }
}

abstract class _StreakModel implements StreakModel {
  const factory _StreakModel(
          {final int currentStreak,
          final int longestStreak,
          final int? nextMilestone,
          @JsonKey(name: 'last_active_at') final DateTime? lastActiveAt}) =
      _$StreakModelImpl;

  factory _StreakModel.fromJson(Map<String, dynamic> json) =
      _$StreakModelImpl.fromJson;

  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  int? get nextMilestone;
  @override
  @JsonKey(name: 'last_active_at')
  DateTime? get lastActiveAt;
  @override
  @JsonKey(ignore: true)
  _$$StreakModelImplCopyWith<_$StreakModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AchievementModel _$AchievementModelFromJson(Map<String, dynamic> json) {
  return _AchievementModel.fromJson(json);
}

/// @nodoc
mixin _$AchievementModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get iconName => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  int get target => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'unlocked_at')
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AchievementModelCopyWith<AchievementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementModelCopyWith<$Res> {
  factory $AchievementModelCopyWith(
          AchievementModel value, $Res Function(AchievementModel) then) =
      _$AchievementModelCopyWithImpl<$Res, AchievementModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? iconName,
      int progress,
      int target,
      bool isUnlocked,
      @JsonKey(name: 'unlocked_at') DateTime? unlockedAt});
}

/// @nodoc
class _$AchievementModelCopyWithImpl<$Res, $Val extends AchievementModel>
    implements $AchievementModelCopyWith<$Res> {
  _$AchievementModelCopyWithImpl(this._value, this._then);

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
    Object? iconName = freezed,
    Object? progress = null,
    Object? target = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
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
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementModelImplCopyWith<$Res>
    implements $AchievementModelCopyWith<$Res> {
  factory _$$AchievementModelImplCopyWith(_$AchievementModelImpl value,
          $Res Function(_$AchievementModelImpl) then) =
      __$$AchievementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? iconName,
      int progress,
      int target,
      bool isUnlocked,
      @JsonKey(name: 'unlocked_at') DateTime? unlockedAt});
}

/// @nodoc
class __$$AchievementModelImplCopyWithImpl<$Res>
    extends _$AchievementModelCopyWithImpl<$Res, _$AchievementModelImpl>
    implements _$$AchievementModelImplCopyWith<$Res> {
  __$$AchievementModelImplCopyWithImpl(_$AchievementModelImpl _value,
      $Res Function(_$AchievementModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? iconName = freezed,
    Object? progress = null,
    Object? target = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(_$AchievementModelImpl(
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
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementModelImpl implements _AchievementModel {
  const _$AchievementModelImpl(
      {required this.id,
      required this.name,
      this.description,
      this.iconName,
      this.progress = 0,
      this.target = 1,
      this.isUnlocked = false,
      @JsonKey(name: 'unlocked_at') this.unlockedAt});

  factory _$AchievementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? iconName;
  @override
  @JsonKey()
  final int progress;
  @override
  @JsonKey()
  final int target;
  @override
  @JsonKey()
  final bool isUnlocked;
  @override
  @JsonKey(name: 'unlocked_at')
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, description: $description, iconName: $iconName, progress: $progress, target: $target, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, iconName,
      progress, target, isUnlocked, unlockedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementModelImplCopyWith<_$AchievementModelImpl> get copyWith =>
      __$$AchievementModelImplCopyWithImpl<_$AchievementModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementModelImplToJson(
      this,
    );
  }
}

abstract class _AchievementModel implements AchievementModel {
  const factory _AchievementModel(
          {required final String id,
          required final String name,
          final String? description,
          final String? iconName,
          final int progress,
          final int target,
          final bool isUnlocked,
          @JsonKey(name: 'unlocked_at') final DateTime? unlockedAt}) =
      _$AchievementModelImpl;

  factory _AchievementModel.fromJson(Map<String, dynamic> json) =
      _$AchievementModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get iconName;
  @override
  int get progress;
  @override
  int get target;
  @override
  bool get isUnlocked;
  @override
  @JsonKey(name: 'unlocked_at')
  DateTime? get unlockedAt;
  @override
  @JsonKey(ignore: true)
  _$$AchievementModelImplCopyWith<_$AchievementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
          LeaderboardEntry value, $Res Function(LeaderboardEntry) then) =
      _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call(
      {String userId,
      String username,
      int points,
      String? avatarUrl,
      int rank});
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? points = null,
    Object? avatarUrl = freezed,
    Object? rank = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(_$LeaderboardEntryImpl value,
          $Res Function(_$LeaderboardEntryImpl) then) =
      __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String username,
      int points,
      String? avatarUrl,
      int rank});
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(_$LeaderboardEntryImpl _value,
      $Res Function(_$LeaderboardEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? points = null,
    Object? avatarUrl = freezed,
    Object? rank = null,
  }) {
    return _then(_$LeaderboardEntryImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl implements _LeaderboardEntry {
  const _$LeaderboardEntryImpl(
      {required this.userId,
      required this.username,
      required this.points,
      this.avatarUrl,
      this.rank = 0});

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  @override
  final String userId;
  @override
  final String username;
  @override
  final int points;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final int rank;

  @override
  String toString() {
    return 'LeaderboardEntry(userId: $userId, username: $username, points: $points, avatarUrl: $avatarUrl, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.rank, rank) || other.rank == rank));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, username, points, avatarUrl, rank);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(
      this,
    );
  }
}

abstract class _LeaderboardEntry implements LeaderboardEntry {
  const factory _LeaderboardEntry(
      {required final String userId,
      required final String username,
      required final int points,
      final String? avatarUrl,
      final int rank}) = _$LeaderboardEntryImpl;

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override
  String get userId;
  @override
  String get username;
  @override
  int get points;
  @override
  String? get avatarUrl;
  @override
  int get rank;
  @override
  @JsonKey(ignore: true)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
