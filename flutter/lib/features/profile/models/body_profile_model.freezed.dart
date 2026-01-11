// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BodyProfileModel _$BodyProfileModelFromJson(Map<String, dynamic> json) {
  return _BodyProfileModel.fromJson(json);
}

/// @nodoc
mixin _$BodyProfileModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'height_cm')
  double get heightCm => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_kg')
  double get weightKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_shape')
  String get bodyShape => throw _privateConstructorUsedError;
  @JsonKey(name: 'skin_tone')
  String get skinTone => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BodyProfileModelCopyWith<BodyProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyProfileModelCopyWith<$Res> {
  factory $BodyProfileModelCopyWith(
          BodyProfileModel value, $Res Function(BodyProfileModel) then) =
      _$BodyProfileModelCopyWithImpl<$Res, BodyProfileModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'height_cm') double heightCm,
      @JsonKey(name: 'weight_kg') double weightKg,
      @JsonKey(name: 'body_shape') String bodyShape,
      @JsonKey(name: 'skin_tone') String skinTone,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$BodyProfileModelCopyWithImpl<$Res, $Val extends BodyProfileModel>
    implements $BodyProfileModelCopyWith<$Res> {
  _$BodyProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? bodyShape = null,
    Object? skinTone = null,
    Object? isDefault = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      bodyShape: null == bodyShape
          ? _value.bodyShape
          : bodyShape // ignore: cast_nullable_to_non_nullable
              as String,
      skinTone: null == skinTone
          ? _value.skinTone
          : skinTone // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BodyProfileModelImplCopyWith<$Res>
    implements $BodyProfileModelCopyWith<$Res> {
  factory _$$BodyProfileModelImplCopyWith(_$BodyProfileModelImpl value,
          $Res Function(_$BodyProfileModelImpl) then) =
      __$$BodyProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'height_cm') double heightCm,
      @JsonKey(name: 'weight_kg') double weightKg,
      @JsonKey(name: 'body_shape') String bodyShape,
      @JsonKey(name: 'skin_tone') String skinTone,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$BodyProfileModelImplCopyWithImpl<$Res>
    extends _$BodyProfileModelCopyWithImpl<$Res, _$BodyProfileModelImpl>
    implements _$$BodyProfileModelImplCopyWith<$Res> {
  __$$BodyProfileModelImplCopyWithImpl(_$BodyProfileModelImpl _value,
      $Res Function(_$BodyProfileModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? bodyShape = null,
    Object? skinTone = null,
    Object? isDefault = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BodyProfileModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      bodyShape: null == bodyShape
          ? _value.bodyShape
          : bodyShape // ignore: cast_nullable_to_non_nullable
              as String,
      skinTone: null == skinTone
          ? _value.skinTone
          : skinTone // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyProfileModelImpl implements _BodyProfileModel {
  const _$BodyProfileModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.name,
      @JsonKey(name: 'height_cm') required this.heightCm,
      @JsonKey(name: 'weight_kg') required this.weightKg,
      @JsonKey(name: 'body_shape') required this.bodyShape,
      @JsonKey(name: 'skin_tone') required this.skinTone,
      @JsonKey(name: 'is_default') this.isDefault = false,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$BodyProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyProfileModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'height_cm')
  final double heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  final double weightKg;
  @override
  @JsonKey(name: 'body_shape')
  final String bodyShape;
  @override
  @JsonKey(name: 'skin_tone')
  final String skinTone;
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BodyProfileModel(id: $id, userId: $userId, name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bodyShape, bodyShape) ||
                other.bodyShape == bodyShape) &&
            (identical(other.skinTone, skinTone) ||
                other.skinTone == skinTone) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name, heightCm,
      weightKg, bodyShape, skinTone, isDefault, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyProfileModelImplCopyWith<_$BodyProfileModelImpl> get copyWith =>
      __$$BodyProfileModelImplCopyWithImpl<_$BodyProfileModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyProfileModelImplToJson(
      this,
    );
  }
}

abstract class _BodyProfileModel implements BodyProfileModel {
  const factory _BodyProfileModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String name,
          @JsonKey(name: 'height_cm') required final double heightCm,
          @JsonKey(name: 'weight_kg') required final double weightKg,
          @JsonKey(name: 'body_shape') required final String bodyShape,
          @JsonKey(name: 'skin_tone') required final String skinTone,
          @JsonKey(name: 'is_default') final bool isDefault,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$BodyProfileModelImpl;

  factory _BodyProfileModel.fromJson(Map<String, dynamic> json) =
      _$BodyProfileModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'height_cm')
  double get heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  double get weightKg;
  @override
  @JsonKey(name: 'body_shape')
  String get bodyShape;
  @override
  @JsonKey(name: 'skin_tone')
  String get skinTone;
  @override
  @JsonKey(name: 'is_default')
  bool get isDefault;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BodyProfileModelImplCopyWith<_$BodyProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateBodyProfileRequest _$CreateBodyProfileRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateBodyProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateBodyProfileRequest {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'height_cm')
  double get heightCm => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_kg')
  double get weightKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_shape')
  String get bodyShape => throw _privateConstructorUsedError;
  @JsonKey(name: 'skin_tone')
  String get skinTone => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateBodyProfileRequestCopyWith<CreateBodyProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBodyProfileRequestCopyWith<$Res> {
  factory $CreateBodyProfileRequestCopyWith(CreateBodyProfileRequest value,
          $Res Function(CreateBodyProfileRequest) then) =
      _$CreateBodyProfileRequestCopyWithImpl<$Res, CreateBodyProfileRequest>;
  @useResult
  $Res call(
      {String name,
      @JsonKey(name: 'height_cm') double heightCm,
      @JsonKey(name: 'weight_kg') double weightKg,
      @JsonKey(name: 'body_shape') String bodyShape,
      @JsonKey(name: 'skin_tone') String skinTone,
      @JsonKey(name: 'is_default') bool isDefault});
}

/// @nodoc
class _$CreateBodyProfileRequestCopyWithImpl<$Res,
        $Val extends CreateBodyProfileRequest>
    implements $CreateBodyProfileRequestCopyWith<$Res> {
  _$CreateBodyProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? bodyShape = null,
    Object? skinTone = null,
    Object? isDefault = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      bodyShape: null == bodyShape
          ? _value.bodyShape
          : bodyShape // ignore: cast_nullable_to_non_nullable
              as String,
      skinTone: null == skinTone
          ? _value.skinTone
          : skinTone // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateBodyProfileRequestImplCopyWith<$Res>
    implements $CreateBodyProfileRequestCopyWith<$Res> {
  factory _$$CreateBodyProfileRequestImplCopyWith(
          _$CreateBodyProfileRequestImpl value,
          $Res Function(_$CreateBodyProfileRequestImpl) then) =
      __$$CreateBodyProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      @JsonKey(name: 'height_cm') double heightCm,
      @JsonKey(name: 'weight_kg') double weightKg,
      @JsonKey(name: 'body_shape') String bodyShape,
      @JsonKey(name: 'skin_tone') String skinTone,
      @JsonKey(name: 'is_default') bool isDefault});
}

/// @nodoc
class __$$CreateBodyProfileRequestImplCopyWithImpl<$Res>
    extends _$CreateBodyProfileRequestCopyWithImpl<$Res,
        _$CreateBodyProfileRequestImpl>
    implements _$$CreateBodyProfileRequestImplCopyWith<$Res> {
  __$$CreateBodyProfileRequestImplCopyWithImpl(
      _$CreateBodyProfileRequestImpl _value,
      $Res Function(_$CreateBodyProfileRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? bodyShape = null,
    Object? skinTone = null,
    Object? isDefault = null,
  }) {
    return _then(_$CreateBodyProfileRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      bodyShape: null == bodyShape
          ? _value.bodyShape
          : bodyShape // ignore: cast_nullable_to_non_nullable
              as String,
      skinTone: null == skinTone
          ? _value.skinTone
          : skinTone // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateBodyProfileRequestImpl implements _CreateBodyProfileRequest {
  const _$CreateBodyProfileRequestImpl(
      {required this.name,
      @JsonKey(name: 'height_cm') required this.heightCm,
      @JsonKey(name: 'weight_kg') required this.weightKg,
      @JsonKey(name: 'body_shape') required this.bodyShape,
      @JsonKey(name: 'skin_tone') required this.skinTone,
      @JsonKey(name: 'is_default') this.isDefault = false});

  factory _$CreateBodyProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateBodyProfileRequestImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'height_cm')
  final double heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  final double weightKg;
  @override
  @JsonKey(name: 'body_shape')
  final String bodyShape;
  @override
  @JsonKey(name: 'skin_tone')
  final String skinTone;
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;

  @override
  String toString() {
    return 'CreateBodyProfileRequest(name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBodyProfileRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bodyShape, bodyShape) ||
                other.bodyShape == bodyShape) &&
            (identical(other.skinTone, skinTone) ||
                other.skinTone == skinTone) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, heightCm, weightKg, bodyShape, skinTone, isDefault);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBodyProfileRequestImplCopyWith<_$CreateBodyProfileRequestImpl>
      get copyWith => __$$CreateBodyProfileRequestImplCopyWithImpl<
          _$CreateBodyProfileRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateBodyProfileRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateBodyProfileRequest implements CreateBodyProfileRequest {
  const factory _CreateBodyProfileRequest(
          {required final String name,
          @JsonKey(name: 'height_cm') required final double heightCm,
          @JsonKey(name: 'weight_kg') required final double weightKg,
          @JsonKey(name: 'body_shape') required final String bodyShape,
          @JsonKey(name: 'skin_tone') required final String skinTone,
          @JsonKey(name: 'is_default') final bool isDefault}) =
      _$CreateBodyProfileRequestImpl;

  factory _CreateBodyProfileRequest.fromJson(Map<String, dynamic> json) =
      _$CreateBodyProfileRequestImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'height_cm')
  double get heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  double get weightKg;
  @override
  @JsonKey(name: 'body_shape')
  String get bodyShape;
  @override
  @JsonKey(name: 'skin_tone')
  String get skinTone;
  @override
  @JsonKey(name: 'is_default')
  bool get isDefault;
  @override
  @JsonKey(ignore: true)
  _$$CreateBodyProfileRequestImplCopyWith<_$CreateBodyProfileRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateBodyProfileRequest _$UpdateBodyProfileRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateBodyProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateBodyProfileRequest {
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'height_cm')
  double? get heightCm => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_kg')
  double? get weightKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_shape')
  String? get bodyShape => throw _privateConstructorUsedError;
  @JsonKey(name: 'skin_tone')
  String? get skinTone => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool? get isDefault => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateBodyProfileRequestCopyWith<UpdateBodyProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateBodyProfileRequestCopyWith<$Res> {
  factory $UpdateBodyProfileRequestCopyWith(UpdateBodyProfileRequest value,
          $Res Function(UpdateBodyProfileRequest) then) =
      _$UpdateBodyProfileRequestCopyWithImpl<$Res, UpdateBodyProfileRequest>;
  @useResult
  $Res call(
      {String? name,
      @JsonKey(name: 'height_cm') double? heightCm,
      @JsonKey(name: 'weight_kg') double? weightKg,
      @JsonKey(name: 'body_shape') String? bodyShape,
      @JsonKey(name: 'skin_tone') String? skinTone,
      @JsonKey(name: 'is_default') bool? isDefault});
}

/// @nodoc
class _$UpdateBodyProfileRequestCopyWithImpl<$Res,
        $Val extends UpdateBodyProfileRequest>
    implements $UpdateBodyProfileRequestCopyWith<$Res> {
  _$UpdateBodyProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? bodyShape = freezed,
    Object? skinTone = freezed,
    Object? isDefault = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyShape: freezed == bodyShape
          ? _value.bodyShape
          : bodyShape // ignore: cast_nullable_to_non_nullable
              as String?,
      skinTone: freezed == skinTone
          ? _value.skinTone
          : skinTone // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: freezed == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateBodyProfileRequestImplCopyWith<$Res>
    implements $UpdateBodyProfileRequestCopyWith<$Res> {
  factory _$$UpdateBodyProfileRequestImplCopyWith(
          _$UpdateBodyProfileRequestImpl value,
          $Res Function(_$UpdateBodyProfileRequestImpl) then) =
      __$$UpdateBodyProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      @JsonKey(name: 'height_cm') double? heightCm,
      @JsonKey(name: 'weight_kg') double? weightKg,
      @JsonKey(name: 'body_shape') String? bodyShape,
      @JsonKey(name: 'skin_tone') String? skinTone,
      @JsonKey(name: 'is_default') bool? isDefault});
}

/// @nodoc
class __$$UpdateBodyProfileRequestImplCopyWithImpl<$Res>
    extends _$UpdateBodyProfileRequestCopyWithImpl<$Res,
        _$UpdateBodyProfileRequestImpl>
    implements _$$UpdateBodyProfileRequestImplCopyWith<$Res> {
  __$$UpdateBodyProfileRequestImplCopyWithImpl(
      _$UpdateBodyProfileRequestImpl _value,
      $Res Function(_$UpdateBodyProfileRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? bodyShape = freezed,
    Object? skinTone = freezed,
    Object? isDefault = freezed,
  }) {
    return _then(_$UpdateBodyProfileRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyShape: freezed == bodyShape
          ? _value.bodyShape
          : bodyShape // ignore: cast_nullable_to_non_nullable
              as String?,
      skinTone: freezed == skinTone
          ? _value.skinTone
          : skinTone // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: freezed == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateBodyProfileRequestImpl implements _UpdateBodyProfileRequest {
  const _$UpdateBodyProfileRequestImpl(
      {this.name,
      @JsonKey(name: 'height_cm') this.heightCm,
      @JsonKey(name: 'weight_kg') this.weightKg,
      @JsonKey(name: 'body_shape') this.bodyShape,
      @JsonKey(name: 'skin_tone') this.skinTone,
      @JsonKey(name: 'is_default') this.isDefault});

  factory _$UpdateBodyProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateBodyProfileRequestImplFromJson(json);

  @override
  final String? name;
  @override
  @JsonKey(name: 'height_cm')
  final double? heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  final double? weightKg;
  @override
  @JsonKey(name: 'body_shape')
  final String? bodyShape;
  @override
  @JsonKey(name: 'skin_tone')
  final String? skinTone;
  @override
  @JsonKey(name: 'is_default')
  final bool? isDefault;

  @override
  String toString() {
    return 'UpdateBodyProfileRequest(name: $name, heightCm: $heightCm, weightKg: $weightKg, bodyShape: $bodyShape, skinTone: $skinTone, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateBodyProfileRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bodyShape, bodyShape) ||
                other.bodyShape == bodyShape) &&
            (identical(other.skinTone, skinTone) ||
                other.skinTone == skinTone) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, heightCm, weightKg, bodyShape, skinTone, isDefault);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateBodyProfileRequestImplCopyWith<_$UpdateBodyProfileRequestImpl>
      get copyWith => __$$UpdateBodyProfileRequestImplCopyWithImpl<
          _$UpdateBodyProfileRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateBodyProfileRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateBodyProfileRequest implements UpdateBodyProfileRequest {
  const factory _UpdateBodyProfileRequest(
          {final String? name,
          @JsonKey(name: 'height_cm') final double? heightCm,
          @JsonKey(name: 'weight_kg') final double? weightKg,
          @JsonKey(name: 'body_shape') final String? bodyShape,
          @JsonKey(name: 'skin_tone') final String? skinTone,
          @JsonKey(name: 'is_default') final bool? isDefault}) =
      _$UpdateBodyProfileRequestImpl;

  factory _UpdateBodyProfileRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateBodyProfileRequestImpl.fromJson;

  @override
  String? get name;
  @override
  @JsonKey(name: 'height_cm')
  double? get heightCm;
  @override
  @JsonKey(name: 'weight_kg')
  double? get weightKg;
  @override
  @JsonKey(name: 'body_shape')
  String? get bodyShape;
  @override
  @JsonKey(name: 'skin_tone')
  String? get skinTone;
  @override
  @JsonKey(name: 'is_default')
  bool? get isDefault;
  @override
  @JsonKey(ignore: true)
  _$$UpdateBodyProfileRequestImplCopyWith<_$UpdateBodyProfileRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
