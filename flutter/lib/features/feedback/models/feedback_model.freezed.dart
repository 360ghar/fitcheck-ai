// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) {
  return _DeviceInfo.fromJson(json);
}

/// @nodoc
mixin _$DeviceInfo {
  String? get platform => throw _privateConstructorUsedError;
  @JsonKey(name: 'os_version')
  String? get osVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'device_model')
  String? get deviceModel => throw _privateConstructorUsedError;
  @JsonKey(name: 'screen_size')
  String? get screenSize => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeviceInfoCopyWith<DeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceInfoCopyWith<$Res> {
  factory $DeviceInfoCopyWith(
          DeviceInfo value, $Res Function(DeviceInfo) then) =
      _$DeviceInfoCopyWithImpl<$Res, DeviceInfo>;
  @useResult
  $Res call(
      {String? platform,
      @JsonKey(name: 'os_version') String? osVersion,
      @JsonKey(name: 'device_model') String? deviceModel,
      @JsonKey(name: 'screen_size') String? screenSize});
}

/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res, $Val extends DeviceInfo>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? platform = freezed,
    Object? osVersion = freezed,
    Object? deviceModel = freezed,
    Object? screenSize = freezed,
  }) {
    return _then(_value.copyWith(
      platform: freezed == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String?,
      osVersion: freezed == osVersion
          ? _value.osVersion
          : osVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceModel: freezed == deviceModel
          ? _value.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String?,
      screenSize: freezed == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceInfoImplCopyWith<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  factory _$$DeviceInfoImplCopyWith(
          _$DeviceInfoImpl value, $Res Function(_$DeviceInfoImpl) then) =
      __$$DeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? platform,
      @JsonKey(name: 'os_version') String? osVersion,
      @JsonKey(name: 'device_model') String? deviceModel,
      @JsonKey(name: 'screen_size') String? screenSize});
}

/// @nodoc
class __$$DeviceInfoImplCopyWithImpl<$Res>
    extends _$DeviceInfoCopyWithImpl<$Res, _$DeviceInfoImpl>
    implements _$$DeviceInfoImplCopyWith<$Res> {
  __$$DeviceInfoImplCopyWithImpl(
      _$DeviceInfoImpl _value, $Res Function(_$DeviceInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? platform = freezed,
    Object? osVersion = freezed,
    Object? deviceModel = freezed,
    Object? screenSize = freezed,
  }) {
    return _then(_$DeviceInfoImpl(
      platform: freezed == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String?,
      osVersion: freezed == osVersion
          ? _value.osVersion
          : osVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceModel: freezed == deviceModel
          ? _value.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String?,
      screenSize: freezed == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceInfoImpl implements _DeviceInfo {
  const _$DeviceInfoImpl(
      {this.platform,
      @JsonKey(name: 'os_version') this.osVersion,
      @JsonKey(name: 'device_model') this.deviceModel,
      @JsonKey(name: 'screen_size') this.screenSize});

  factory _$DeviceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceInfoImplFromJson(json);

  @override
  final String? platform;
  @override
  @JsonKey(name: 'os_version')
  final String? osVersion;
  @override
  @JsonKey(name: 'device_model')
  final String? deviceModel;
  @override
  @JsonKey(name: 'screen_size')
  final String? screenSize;

  @override
  String toString() {
    return 'DeviceInfo(platform: $platform, osVersion: $osVersion, deviceModel: $deviceModel, screenSize: $screenSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceInfoImpl &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.osVersion, osVersion) ||
                other.osVersion == osVersion) &&
            (identical(other.deviceModel, deviceModel) ||
                other.deviceModel == deviceModel) &&
            (identical(other.screenSize, screenSize) ||
                other.screenSize == screenSize));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, platform, osVersion, deviceModel, screenSize);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      __$$DeviceInfoImplCopyWithImpl<_$DeviceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceInfoImplToJson(
      this,
    );
  }
}

abstract class _DeviceInfo implements DeviceInfo {
  const factory _DeviceInfo(
          {final String? platform,
          @JsonKey(name: 'os_version') final String? osVersion,
          @JsonKey(name: 'device_model') final String? deviceModel,
          @JsonKey(name: 'screen_size') final String? screenSize}) =
      _$DeviceInfoImpl;

  factory _DeviceInfo.fromJson(Map<String, dynamic> json) =
      _$DeviceInfoImpl.fromJson;

  @override
  String? get platform;
  @override
  @JsonKey(name: 'os_version')
  String? get osVersion;
  @override
  @JsonKey(name: 'device_model')
  String? get deviceModel;
  @override
  @JsonKey(name: 'screen_size')
  String? get screenSize;
  @override
  @JsonKey(ignore: true)
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedbackResponse _$FeedbackResponseFromJson(Map<String, dynamic> json) {
  return _FeedbackResponse.fromJson(json);
}

/// @nodoc
mixin _$FeedbackResponse {
  String get id => throw _privateConstructorUsedError;
  TicketCategory get category => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  TicketStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedbackResponseCopyWith<FeedbackResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackResponseCopyWith<$Res> {
  factory $FeedbackResponseCopyWith(
          FeedbackResponse value, $Res Function(FeedbackResponse) then) =
      _$FeedbackResponseCopyWithImpl<$Res, FeedbackResponse>;
  @useResult
  $Res call(
      {String id,
      TicketCategory category,
      String subject,
      TicketStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String message});
}

/// @nodoc
class _$FeedbackResponseCopyWithImpl<$Res, $Val extends FeedbackResponse>
    implements $FeedbackResponseCopyWith<$Res> {
  _$FeedbackResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? subject = null,
    Object? status = null,
    Object? createdAt = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TicketCategory,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TicketStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedbackResponseImplCopyWith<$Res>
    implements $FeedbackResponseCopyWith<$Res> {
  factory _$$FeedbackResponseImplCopyWith(_$FeedbackResponseImpl value,
          $Res Function(_$FeedbackResponseImpl) then) =
      __$$FeedbackResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TicketCategory category,
      String subject,
      TicketStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String message});
}

/// @nodoc
class __$$FeedbackResponseImplCopyWithImpl<$Res>
    extends _$FeedbackResponseCopyWithImpl<$Res, _$FeedbackResponseImpl>
    implements _$$FeedbackResponseImplCopyWith<$Res> {
  __$$FeedbackResponseImplCopyWithImpl(_$FeedbackResponseImpl _value,
      $Res Function(_$FeedbackResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? subject = null,
    Object? status = null,
    Object? createdAt = null,
    Object? message = null,
  }) {
    return _then(_$FeedbackResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TicketCategory,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TicketStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackResponseImpl implements _FeedbackResponse {
  const _$FeedbackResponseImpl(
      {required this.id,
      required this.category,
      required this.subject,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      required this.message});

  factory _$FeedbackResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackResponseImplFromJson(json);

  @override
  final String id;
  @override
  final TicketCategory category;
  @override
  final String subject;
  @override
  final TicketStatus status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final String message;

  @override
  String toString() {
    return 'FeedbackResponse(id: $id, category: $category, subject: $subject, status: $status, createdAt: $createdAt, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, category, subject, status, createdAt, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackResponseImplCopyWith<_$FeedbackResponseImpl> get copyWith =>
      __$$FeedbackResponseImplCopyWithImpl<_$FeedbackResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackResponseImplToJson(
      this,
    );
  }
}

abstract class _FeedbackResponse implements FeedbackResponse {
  const factory _FeedbackResponse(
      {required final String id,
      required final TicketCategory category,
      required final String subject,
      required final TicketStatus status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      required final String message}) = _$FeedbackResponseImpl;

  factory _FeedbackResponse.fromJson(Map<String, dynamic> json) =
      _$FeedbackResponseImpl.fromJson;

  @override
  String get id;
  @override
  TicketCategory get category;
  @override
  String get subject;
  @override
  TicketStatus get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$FeedbackResponseImplCopyWith<_$FeedbackResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TicketListItem _$TicketListItemFromJson(Map<String, dynamic> json) {
  return _TicketListItem.fromJson(json);
}

/// @nodoc
mixin _$TicketListItem {
  String get id => throw _privateConstructorUsedError;
  TicketCategory get category => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  TicketStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TicketListItemCopyWith<TicketListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketListItemCopyWith<$Res> {
  factory $TicketListItemCopyWith(
          TicketListItem value, $Res Function(TicketListItem) then) =
      _$TicketListItemCopyWithImpl<$Res, TicketListItem>;
  @useResult
  $Res call(
      {String id,
      TicketCategory category,
      String subject,
      TicketStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TicketListItemCopyWithImpl<$Res, $Val extends TicketListItem>
    implements $TicketListItemCopyWith<$Res> {
  _$TicketListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? subject = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TicketCategory,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TicketStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TicketListItemImplCopyWith<$Res>
    implements $TicketListItemCopyWith<$Res> {
  factory _$$TicketListItemImplCopyWith(_$TicketListItemImpl value,
          $Res Function(_$TicketListItemImpl) then) =
      __$$TicketListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TicketCategory category,
      String subject,
      TicketStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TicketListItemImplCopyWithImpl<$Res>
    extends _$TicketListItemCopyWithImpl<$Res, _$TicketListItemImpl>
    implements _$$TicketListItemImplCopyWith<$Res> {
  __$$TicketListItemImplCopyWithImpl(
      _$TicketListItemImpl _value, $Res Function(_$TicketListItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? subject = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_$TicketListItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TicketCategory,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TicketStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TicketListItemImpl implements _TicketListItem {
  const _$TicketListItemImpl(
      {required this.id,
      required this.category,
      required this.subject,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TicketListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketListItemImplFromJson(json);

  @override
  final String id;
  @override
  final TicketCategory category;
  @override
  final String subject;
  @override
  final TicketStatus status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'TicketListItem(id: $id, category: $category, subject: $subject, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, category, subject, status, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketListItemImplCopyWith<_$TicketListItemImpl> get copyWith =>
      __$$TicketListItemImplCopyWithImpl<_$TicketListItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketListItemImplToJson(
      this,
    );
  }
}

abstract class _TicketListItem implements TicketListItem {
  const factory _TicketListItem(
          {required final String id,
          required final TicketCategory category,
          required final String subject,
          required final TicketStatus status,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TicketListItemImpl;

  factory _TicketListItem.fromJson(Map<String, dynamic> json) =
      _$TicketListItemImpl.fromJson;

  @override
  String get id;
  @override
  TicketCategory get category;
  @override
  String get subject;
  @override
  TicketStatus get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TicketListItemImplCopyWith<_$TicketListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
