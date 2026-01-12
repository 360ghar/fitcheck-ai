// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OutfitModel _$OutfitModelFromJson(Map<String, dynamic> json) {
  return _OutfitModel.fromJson(json);
}

/// @nodoc
mixin _$OutfitModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_ids')
  List<String> get itemIds => throw _privateConstructorUsedError;
  Style? get style => throw _privateConstructorUsedError;
  Season? get season => throw _privateConstructorUsedError;
  String? get occasion => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorite')
  bool get isFavorite => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_draft')
  bool get isDraft => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_public')
  bool get isPublic => throw _privateConstructorUsedError;
  @JsonKey(name: 'worn_count')
  int get wornCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_worn_at')
  DateTime? get lastWornAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'outfit_images')
  List<OutfitImage>? get outfitImages => throw _privateConstructorUsedError;
  List<ItemModel>? get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OutfitModelCopyWith<OutfitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitModelCopyWith<$Res> {
  factory $OutfitModelCopyWith(
          OutfitModel value, $Res Function(OutfitModel) then) =
      _$OutfitModelCopyWithImpl<$Res, OutfitModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      String? description,
      @JsonKey(name: 'item_ids') List<String> itemIds,
      Style? style,
      Season? season,
      String? occasion,
      List<String>? tags,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'is_draft') bool isDraft,
      @JsonKey(name: 'is_public') bool isPublic,
      @JsonKey(name: 'worn_count') int wornCount,
      @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
      @JsonKey(name: 'outfit_images') List<OutfitImage>? outfitImages,
      List<ItemModel>? items,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$OutfitModelCopyWithImpl<$Res, $Val extends OutfitModel>
    implements $OutfitModelCopyWith<$Res> {
  _$OutfitModelCopyWithImpl(this._value, this._then);

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
    Object? description = freezed,
    Object? itemIds = null,
    Object? style = freezed,
    Object? season = freezed,
    Object? occasion = freezed,
    Object? tags = freezed,
    Object? isFavorite = null,
    Object? isDraft = null,
    Object? isPublic = null,
    Object? wornCount = null,
    Object? lastWornAt = freezed,
    Object? outfitImages = freezed,
    Object? items = freezed,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: null == itemIds
          ? _value.itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      wornCount: null == wornCount
          ? _value.wornCount
          : wornCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastWornAt: freezed == lastWornAt
          ? _value.lastWornAt
          : lastWornAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      outfitImages: freezed == outfitImages
          ? _value.outfitImages
          : outfitImages // ignore: cast_nullable_to_non_nullable
              as List<OutfitImage>?,
      items: freezed == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ItemModel>?,
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
abstract class _$$OutfitModelImplCopyWith<$Res>
    implements $OutfitModelCopyWith<$Res> {
  factory _$$OutfitModelImplCopyWith(
          _$OutfitModelImpl value, $Res Function(_$OutfitModelImpl) then) =
      __$$OutfitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      String? description,
      @JsonKey(name: 'item_ids') List<String> itemIds,
      Style? style,
      Season? season,
      String? occasion,
      List<String>? tags,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'is_draft') bool isDraft,
      @JsonKey(name: 'is_public') bool isPublic,
      @JsonKey(name: 'worn_count') int wornCount,
      @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
      @JsonKey(name: 'outfit_images') List<OutfitImage>? outfitImages,
      List<ItemModel>? items,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$OutfitModelImplCopyWithImpl<$Res>
    extends _$OutfitModelCopyWithImpl<$Res, _$OutfitModelImpl>
    implements _$$OutfitModelImplCopyWith<$Res> {
  __$$OutfitModelImplCopyWithImpl(
      _$OutfitModelImpl _value, $Res Function(_$OutfitModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? itemIds = null,
    Object? style = freezed,
    Object? season = freezed,
    Object? occasion = freezed,
    Object? tags = freezed,
    Object? isFavorite = null,
    Object? isDraft = null,
    Object? isPublic = null,
    Object? wornCount = null,
    Object? lastWornAt = freezed,
    Object? outfitImages = freezed,
    Object? items = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$OutfitModelImpl(
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: null == itemIds
          ? _value._itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      wornCount: null == wornCount
          ? _value.wornCount
          : wornCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastWornAt: freezed == lastWornAt
          ? _value.lastWornAt
          : lastWornAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      outfitImages: freezed == outfitImages
          ? _value._outfitImages
          : outfitImages // ignore: cast_nullable_to_non_nullable
              as List<OutfitImage>?,
      items: freezed == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ItemModel>?,
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
class _$OutfitModelImpl implements _OutfitModel {
  const _$OutfitModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.name,
      this.description,
      @JsonKey(name: 'item_ids') required final List<String> itemIds,
      this.style,
      this.season,
      this.occasion,
      final List<String>? tags,
      @JsonKey(name: 'is_favorite') this.isFavorite = false,
      @JsonKey(name: 'is_draft') this.isDraft = false,
      @JsonKey(name: 'is_public') this.isPublic = false,
      @JsonKey(name: 'worn_count') this.wornCount = 0,
      @JsonKey(name: 'last_worn_at') this.lastWornAt,
      @JsonKey(name: 'outfit_images') final List<OutfitImage>? outfitImages,
      final List<ItemModel>? items,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _itemIds = itemIds,
        _tags = tags,
        _outfitImages = outfitImages,
        _items = items;

  factory _$OutfitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  final List<String> _itemIds;
  @override
  @JsonKey(name: 'item_ids')
  List<String> get itemIds {
    if (_itemIds is EqualUnmodifiableListView) return _itemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemIds);
  }

  @override
  final Style? style;
  @override
  final Season? season;
  @override
  final String? occasion;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @override
  @JsonKey(name: 'is_draft')
  final bool isDraft;
  @override
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @override
  @JsonKey(name: 'worn_count')
  final int wornCount;
  @override
  @JsonKey(name: 'last_worn_at')
  final DateTime? lastWornAt;
  final List<OutfitImage>? _outfitImages;
  @override
  @JsonKey(name: 'outfit_images')
  List<OutfitImage>? get outfitImages {
    final value = _outfitImages;
    if (value == null) return null;
    if (_outfitImages is EqualUnmodifiableListView) return _outfitImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<ItemModel>? _items;
  @override
  List<ItemModel>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'OutfitModel(id: $id, userId: $userId, name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags, isFavorite: $isFavorite, isDraft: $isDraft, isPublic: $isPublic, wornCount: $wornCount, lastWornAt: $lastWornAt, outfitImages: $outfitImages, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._itemIds, _itemIds) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.wornCount, wornCount) ||
                other.wornCount == wornCount) &&
            (identical(other.lastWornAt, lastWornAt) ||
                other.lastWornAt == lastWornAt) &&
            const DeepCollectionEquality()
                .equals(other._outfitImages, _outfitImages) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      description,
      const DeepCollectionEquality().hash(_itemIds),
      style,
      season,
      occasion,
      const DeepCollectionEquality().hash(_tags),
      isFavorite,
      isDraft,
      isPublic,
      wornCount,
      lastWornAt,
      const DeepCollectionEquality().hash(_outfitImages),
      const DeepCollectionEquality().hash(_items),
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitModelImplCopyWith<_$OutfitModelImpl> get copyWith =>
      __$$OutfitModelImplCopyWithImpl<_$OutfitModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitModelImplToJson(
      this,
    );
  }
}

abstract class _OutfitModel implements OutfitModel {
  const factory _OutfitModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String name,
          final String? description,
          @JsonKey(name: 'item_ids') required final List<String> itemIds,
          final Style? style,
          final Season? season,
          final String? occasion,
          final List<String>? tags,
          @JsonKey(name: 'is_favorite') final bool isFavorite,
          @JsonKey(name: 'is_draft') final bool isDraft,
          @JsonKey(name: 'is_public') final bool isPublic,
          @JsonKey(name: 'worn_count') final int wornCount,
          @JsonKey(name: 'last_worn_at') final DateTime? lastWornAt,
          @JsonKey(name: 'outfit_images') final List<OutfitImage>? outfitImages,
          final List<ItemModel>? items,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$OutfitModelImpl;

  factory _OutfitModel.fromJson(Map<String, dynamic> json) =
      _$OutfitModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'item_ids')
  List<String> get itemIds;
  @override
  Style? get style;
  @override
  Season? get season;
  @override
  String? get occasion;
  @override
  List<String>? get tags;
  @override
  @JsonKey(name: 'is_favorite')
  bool get isFavorite;
  @override
  @JsonKey(name: 'is_draft')
  bool get isDraft;
  @override
  @JsonKey(name: 'is_public')
  bool get isPublic;
  @override
  @JsonKey(name: 'worn_count')
  int get wornCount;
  @override
  @JsonKey(name: 'last_worn_at')
  DateTime? get lastWornAt;
  @override
  @JsonKey(name: 'outfit_images')
  List<OutfitImage>? get outfitImages;
  @override
  List<ItemModel>? get items;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$OutfitModelImplCopyWith<_$OutfitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OutfitImage _$OutfitImageFromJson(Map<String, dynamic> json) {
  return _OutfitImage.fromJson(json);
}

/// @nodoc
mixin _$OutfitImage {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get pose => throw _privateConstructorUsedError;
  String? get lighting => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_profile_id')
  String? get bodyProfileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_generated')
  bool get isGenerated => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  String? get blurhash => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OutfitImageCopyWith<OutfitImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitImageCopyWith<$Res> {
  factory $OutfitImageCopyWith(
          OutfitImage value, $Res Function(OutfitImage) then) =
      _$OutfitImageCopyWithImpl<$Res, OutfitImage>;
  @useResult
  $Res call(
      {String id,
      String url,
      String? type,
      String? pose,
      String? lighting,
      @JsonKey(name: 'body_profile_id') String? bodyProfileId,
      @JsonKey(name: 'is_generated') bool isGenerated,
      int? width,
      int? height,
      String? blurhash});
}

/// @nodoc
class _$OutfitImageCopyWithImpl<$Res, $Val extends OutfitImage>
    implements $OutfitImageCopyWith<$Res> {
  _$OutfitImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? type = freezed,
    Object? pose = freezed,
    Object? lighting = freezed,
    Object? bodyProfileId = freezed,
    Object? isGenerated = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? blurhash = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      pose: freezed == pose
          ? _value.pose
          : pose // ignore: cast_nullable_to_non_nullable
              as String?,
      lighting: freezed == lighting
          ? _value.lighting
          : lighting // ignore: cast_nullable_to_non_nullable
              as String?,
      bodyProfileId: freezed == bodyProfileId
          ? _value.bodyProfileId
          : bodyProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      isGenerated: null == isGenerated
          ? _value.isGenerated
          : isGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      blurhash: freezed == blurhash
          ? _value.blurhash
          : blurhash // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutfitImageImplCopyWith<$Res>
    implements $OutfitImageCopyWith<$Res> {
  factory _$$OutfitImageImplCopyWith(
          _$OutfitImageImpl value, $Res Function(_$OutfitImageImpl) then) =
      __$$OutfitImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      String? type,
      String? pose,
      String? lighting,
      @JsonKey(name: 'body_profile_id') String? bodyProfileId,
      @JsonKey(name: 'is_generated') bool isGenerated,
      int? width,
      int? height,
      String? blurhash});
}

/// @nodoc
class __$$OutfitImageImplCopyWithImpl<$Res>
    extends _$OutfitImageCopyWithImpl<$Res, _$OutfitImageImpl>
    implements _$$OutfitImageImplCopyWith<$Res> {
  __$$OutfitImageImplCopyWithImpl(
      _$OutfitImageImpl _value, $Res Function(_$OutfitImageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? type = freezed,
    Object? pose = freezed,
    Object? lighting = freezed,
    Object? bodyProfileId = freezed,
    Object? isGenerated = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? blurhash = freezed,
  }) {
    return _then(_$OutfitImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      pose: freezed == pose
          ? _value.pose
          : pose // ignore: cast_nullable_to_non_nullable
              as String?,
      lighting: freezed == lighting
          ? _value.lighting
          : lighting // ignore: cast_nullable_to_non_nullable
              as String?,
      bodyProfileId: freezed == bodyProfileId
          ? _value.bodyProfileId
          : bodyProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      isGenerated: null == isGenerated
          ? _value.isGenerated
          : isGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      blurhash: freezed == blurhash
          ? _value.blurhash
          : blurhash // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitImageImpl implements _OutfitImage {
  const _$OutfitImageImpl(
      {required this.id,
      required this.url,
      this.type,
      this.pose,
      this.lighting,
      @JsonKey(name: 'body_profile_id') this.bodyProfileId,
      @JsonKey(name: 'is_generated') this.isGenerated = false,
      this.width,
      this.height,
      this.blurhash});

  factory _$OutfitImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitImageImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String? type;
  @override
  final String? pose;
  @override
  final String? lighting;
  @override
  @JsonKey(name: 'body_profile_id')
  final String? bodyProfileId;
  @override
  @JsonKey(name: 'is_generated')
  final bool isGenerated;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final String? blurhash;

  @override
  String toString() {
    return 'OutfitImage(id: $id, url: $url, type: $type, pose: $pose, lighting: $lighting, bodyProfileId: $bodyProfileId, isGenerated: $isGenerated, width: $width, height: $height, blurhash: $blurhash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.pose, pose) || other.pose == pose) &&
            (identical(other.lighting, lighting) ||
                other.lighting == lighting) &&
            (identical(other.bodyProfileId, bodyProfileId) ||
                other.bodyProfileId == bodyProfileId) &&
            (identical(other.isGenerated, isGenerated) ||
                other.isGenerated == isGenerated) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.blurhash, blurhash) ||
                other.blurhash == blurhash));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, type, pose, lighting,
      bodyProfileId, isGenerated, width, height, blurhash);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitImageImplCopyWith<_$OutfitImageImpl> get copyWith =>
      __$$OutfitImageImplCopyWithImpl<_$OutfitImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitImageImplToJson(
      this,
    );
  }
}

abstract class _OutfitImage implements OutfitImage {
  const factory _OutfitImage(
      {required final String id,
      required final String url,
      final String? type,
      final String? pose,
      final String? lighting,
      @JsonKey(name: 'body_profile_id') final String? bodyProfileId,
      @JsonKey(name: 'is_generated') final bool isGenerated,
      final int? width,
      final int? height,
      final String? blurhash}) = _$OutfitImageImpl;

  factory _OutfitImage.fromJson(Map<String, dynamic> json) =
      _$OutfitImageImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  String? get type;
  @override
  String? get pose;
  @override
  String? get lighting;
  @override
  @JsonKey(name: 'body_profile_id')
  String? get bodyProfileId;
  @override
  @JsonKey(name: 'is_generated')
  bool get isGenerated;
  @override
  int? get width;
  @override
  int? get height;
  @override
  String? get blurhash;
  @override
  @JsonKey(ignore: true)
  _$$OutfitImageImplCopyWith<_$OutfitImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateOutfitRequest _$CreateOutfitRequestFromJson(Map<String, dynamic> json) {
  return _CreateOutfitRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateOutfitRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String> get itemIds => throw _privateConstructorUsedError;
  Style? get style => throw _privateConstructorUsedError;
  Season? get season => throw _privateConstructorUsedError;
  String? get occasion => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateOutfitRequestCopyWith<CreateOutfitRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateOutfitRequestCopyWith<$Res> {
  factory $CreateOutfitRequestCopyWith(
          CreateOutfitRequest value, $Res Function(CreateOutfitRequest) then) =
      _$CreateOutfitRequestCopyWithImpl<$Res, CreateOutfitRequest>;
  @useResult
  $Res call(
      {String name,
      String? description,
      List<String> itemIds,
      Style? style,
      Season? season,
      String? occasion,
      List<String>? tags});
}

/// @nodoc
class _$CreateOutfitRequestCopyWithImpl<$Res, $Val extends CreateOutfitRequest>
    implements $CreateOutfitRequestCopyWith<$Res> {
  _$CreateOutfitRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? itemIds = null,
    Object? style = freezed,
    Object? season = freezed,
    Object? occasion = freezed,
    Object? tags = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: null == itemIds
          ? _value.itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateOutfitRequestImplCopyWith<$Res>
    implements $CreateOutfitRequestCopyWith<$Res> {
  factory _$$CreateOutfitRequestImplCopyWith(_$CreateOutfitRequestImpl value,
          $Res Function(_$CreateOutfitRequestImpl) then) =
      __$$CreateOutfitRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      List<String> itemIds,
      Style? style,
      Season? season,
      String? occasion,
      List<String>? tags});
}

/// @nodoc
class __$$CreateOutfitRequestImplCopyWithImpl<$Res>
    extends _$CreateOutfitRequestCopyWithImpl<$Res, _$CreateOutfitRequestImpl>
    implements _$$CreateOutfitRequestImplCopyWith<$Res> {
  __$$CreateOutfitRequestImplCopyWithImpl(_$CreateOutfitRequestImpl _value,
      $Res Function(_$CreateOutfitRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? itemIds = null,
    Object? style = freezed,
    Object? season = freezed,
    Object? occasion = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$CreateOutfitRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: null == itemIds
          ? _value._itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateOutfitRequestImpl implements _CreateOutfitRequest {
  const _$CreateOutfitRequestImpl(
      {required this.name,
      this.description,
      required final List<String> itemIds,
      this.style,
      this.season,
      this.occasion,
      final List<String>? tags})
      : _itemIds = itemIds,
        _tags = tags;

  factory _$CreateOutfitRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateOutfitRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  final List<String> _itemIds;
  @override
  List<String> get itemIds {
    if (_itemIds is EqualUnmodifiableListView) return _itemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemIds);
  }

  @override
  final Style? style;
  @override
  final Season? season;
  @override
  final String? occasion;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreateOutfitRequest(name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateOutfitRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._itemIds, _itemIds) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      const DeepCollectionEquality().hash(_itemIds),
      style,
      season,
      occasion,
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateOutfitRequestImplCopyWith<_$CreateOutfitRequestImpl> get copyWith =>
      __$$CreateOutfitRequestImplCopyWithImpl<_$CreateOutfitRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateOutfitRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateOutfitRequest implements CreateOutfitRequest {
  const factory _CreateOutfitRequest(
      {required final String name,
      final String? description,
      required final List<String> itemIds,
      final Style? style,
      final Season? season,
      final String? occasion,
      final List<String>? tags}) = _$CreateOutfitRequestImpl;

  factory _CreateOutfitRequest.fromJson(Map<String, dynamic> json) =
      _$CreateOutfitRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  List<String> get itemIds;
  @override
  Style? get style;
  @override
  Season? get season;
  @override
  String? get occasion;
  @override
  List<String>? get tags;
  @override
  @JsonKey(ignore: true)
  _$$CreateOutfitRequestImplCopyWith<_$CreateOutfitRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateOutfitRequest _$UpdateOutfitRequestFromJson(Map<String, dynamic> json) {
  return _UpdateOutfitRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateOutfitRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String>? get itemIds => throw _privateConstructorUsedError;
  Style? get style => throw _privateConstructorUsedError;
  Season? get season => throw _privateConstructorUsedError;
  String? get occasion => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  bool? get isFavorite => throw _privateConstructorUsedError;
  bool? get isDraft => throw _privateConstructorUsedError;
  bool? get isPublic => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateOutfitRequestCopyWith<UpdateOutfitRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateOutfitRequestCopyWith<$Res> {
  factory $UpdateOutfitRequestCopyWith(
          UpdateOutfitRequest value, $Res Function(UpdateOutfitRequest) then) =
      _$UpdateOutfitRequestCopyWithImpl<$Res, UpdateOutfitRequest>;
  @useResult
  $Res call(
      {String? name,
      String? description,
      List<String>? itemIds,
      Style? style,
      Season? season,
      String? occasion,
      List<String>? tags,
      bool? isFavorite,
      bool? isDraft,
      bool? isPublic});
}

/// @nodoc
class _$UpdateOutfitRequestCopyWithImpl<$Res, $Val extends UpdateOutfitRequest>
    implements $UpdateOutfitRequestCopyWith<$Res> {
  _$UpdateOutfitRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? itemIds = freezed,
    Object? style = freezed,
    Object? season = freezed,
    Object? occasion = freezed,
    Object? tags = freezed,
    Object? isFavorite = freezed,
    Object? isDraft = freezed,
    Object? isPublic = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: freezed == itemIds
          ? _value.itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
      isDraft: freezed == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool?,
      isPublic: freezed == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateOutfitRequestImplCopyWith<$Res>
    implements $UpdateOutfitRequestCopyWith<$Res> {
  factory _$$UpdateOutfitRequestImplCopyWith(_$UpdateOutfitRequestImpl value,
          $Res Function(_$UpdateOutfitRequestImpl) then) =
      __$$UpdateOutfitRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? description,
      List<String>? itemIds,
      Style? style,
      Season? season,
      String? occasion,
      List<String>? tags,
      bool? isFavorite,
      bool? isDraft,
      bool? isPublic});
}

/// @nodoc
class __$$UpdateOutfitRequestImplCopyWithImpl<$Res>
    extends _$UpdateOutfitRequestCopyWithImpl<$Res, _$UpdateOutfitRequestImpl>
    implements _$$UpdateOutfitRequestImplCopyWith<$Res> {
  __$$UpdateOutfitRequestImplCopyWithImpl(_$UpdateOutfitRequestImpl _value,
      $Res Function(_$UpdateOutfitRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? itemIds = freezed,
    Object? style = freezed,
    Object? season = freezed,
    Object? occasion = freezed,
    Object? tags = freezed,
    Object? isFavorite = freezed,
    Object? isDraft = freezed,
    Object? isPublic = freezed,
  }) {
    return _then(_$UpdateOutfitRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: freezed == itemIds
          ? _value._itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      occasion: freezed == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: freezed == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool?,
      isDraft: freezed == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool?,
      isPublic: freezed == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateOutfitRequestImpl implements _UpdateOutfitRequest {
  const _$UpdateOutfitRequestImpl(
      {this.name,
      this.description,
      final List<String>? itemIds,
      this.style,
      this.season,
      this.occasion,
      final List<String>? tags,
      this.isFavorite,
      this.isDraft,
      this.isPublic})
      : _itemIds = itemIds,
        _tags = tags;

  factory _$UpdateOutfitRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateOutfitRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  final List<String>? _itemIds;
  @override
  List<String>? get itemIds {
    final value = _itemIds;
    if (value == null) return null;
    if (_itemIds is EqualUnmodifiableListView) return _itemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Style? style;
  @override
  final Season? season;
  @override
  final String? occasion;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isFavorite;
  @override
  final bool? isDraft;
  @override
  final bool? isPublic;

  @override
  String toString() {
    return 'UpdateOutfitRequest(name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags, isFavorite: $isFavorite, isDraft: $isDraft, isPublic: $isPublic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateOutfitRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._itemIds, _itemIds) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      const DeepCollectionEquality().hash(_itemIds),
      style,
      season,
      occasion,
      const DeepCollectionEquality().hash(_tags),
      isFavorite,
      isDraft,
      isPublic);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateOutfitRequestImplCopyWith<_$UpdateOutfitRequestImpl> get copyWith =>
      __$$UpdateOutfitRequestImplCopyWithImpl<_$UpdateOutfitRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateOutfitRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateOutfitRequest implements UpdateOutfitRequest {
  const factory _UpdateOutfitRequest(
      {final String? name,
      final String? description,
      final List<String>? itemIds,
      final Style? style,
      final Season? season,
      final String? occasion,
      final List<String>? tags,
      final bool? isFavorite,
      final bool? isDraft,
      final bool? isPublic}) = _$UpdateOutfitRequestImpl;

  factory _UpdateOutfitRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateOutfitRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  List<String>? get itemIds;
  @override
  Style? get style;
  @override
  Season? get season;
  @override
  String? get occasion;
  @override
  List<String>? get tags;
  @override
  bool? get isFavorite;
  @override
  bool? get isDraft;
  @override
  bool? get isPublic;
  @override
  @JsonKey(ignore: true)
  _$$UpdateOutfitRequestImplCopyWith<_$UpdateOutfitRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OutfitsListResponse _$OutfitsListResponseFromJson(Map<String, dynamic> json) {
  return _OutfitsListResponse.fromJson(json);
}

/// @nodoc
mixin _$OutfitsListResponse {
  List<OutfitModel> get outfits => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_more')
  bool get hasMore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OutfitsListResponseCopyWith<OutfitsListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitsListResponseCopyWith<$Res> {
  factory $OutfitsListResponseCopyWith(
          OutfitsListResponse value, $Res Function(OutfitsListResponse) then) =
      _$OutfitsListResponseCopyWithImpl<$Res, OutfitsListResponse>;
  @useResult
  $Res call(
      {List<OutfitModel> outfits,
      int total,
      int page,
      int limit,
      @JsonKey(name: 'has_more') bool hasMore});
}

/// @nodoc
class _$OutfitsListResponseCopyWithImpl<$Res, $Val extends OutfitsListResponse>
    implements $OutfitsListResponseCopyWith<$Res> {
  _$OutfitsListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outfits = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      outfits: null == outfits
          ? _value.outfits
          : outfits // ignore: cast_nullable_to_non_nullable
              as List<OutfitModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutfitsListResponseImplCopyWith<$Res>
    implements $OutfitsListResponseCopyWith<$Res> {
  factory _$$OutfitsListResponseImplCopyWith(_$OutfitsListResponseImpl value,
          $Res Function(_$OutfitsListResponseImpl) then) =
      __$$OutfitsListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<OutfitModel> outfits,
      int total,
      int page,
      int limit,
      @JsonKey(name: 'has_more') bool hasMore});
}

/// @nodoc
class __$$OutfitsListResponseImplCopyWithImpl<$Res>
    extends _$OutfitsListResponseCopyWithImpl<$Res, _$OutfitsListResponseImpl>
    implements _$$OutfitsListResponseImplCopyWith<$Res> {
  __$$OutfitsListResponseImplCopyWithImpl(_$OutfitsListResponseImpl _value,
      $Res Function(_$OutfitsListResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outfits = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasMore = null,
  }) {
    return _then(_$OutfitsListResponseImpl(
      outfits: null == outfits
          ? _value._outfits
          : outfits // ignore: cast_nullable_to_non_nullable
              as List<OutfitModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitsListResponseImpl implements _OutfitsListResponse {
  const _$OutfitsListResponseImpl(
      {required final List<OutfitModel> outfits,
      required this.total,
      required this.page,
      required this.limit,
      @JsonKey(name: 'has_more') required this.hasMore})
      : _outfits = outfits;

  factory _$OutfitsListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitsListResponseImplFromJson(json);

  final List<OutfitModel> _outfits;
  @override
  List<OutfitModel> get outfits {
    if (_outfits is EqualUnmodifiableListView) return _outfits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_outfits);
  }

  @override
  final int total;
  @override
  final int page;
  @override
  final int limit;
  @override
  @JsonKey(name: 'has_more')
  final bool hasMore;

  @override
  String toString() {
    return 'OutfitsListResponse(outfits: $outfits, total: $total, page: $page, limit: $limit, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitsListResponseImpl &&
            const DeepCollectionEquality().equals(other._outfits, _outfits) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_outfits),
      total,
      page,
      limit,
      hasMore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitsListResponseImplCopyWith<_$OutfitsListResponseImpl> get copyWith =>
      __$$OutfitsListResponseImplCopyWithImpl<_$OutfitsListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitsListResponseImplToJson(
      this,
    );
  }
}

abstract class _OutfitsListResponse implements OutfitsListResponse {
  const factory _OutfitsListResponse(
          {required final List<OutfitModel> outfits,
          required final int total,
          required final int page,
          required final int limit,
          @JsonKey(name: 'has_more') required final bool hasMore}) =
      _$OutfitsListResponseImpl;

  factory _OutfitsListResponse.fromJson(Map<String, dynamic> json) =
      _$OutfitsListResponseImpl.fromJson;

  @override
  List<OutfitModel> get outfits;
  @override
  int get total;
  @override
  int get page;
  @override
  int get limit;
  @override
  @JsonKey(name: 'has_more')
  bool get hasMore;
  @override
  @JsonKey(ignore: true)
  _$$OutfitsListResponseImplCopyWith<_$OutfitsListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIGenerationRequest _$AIGenerationRequestFromJson(Map<String, dynamic> json) {
  return _AIGenerationRequest.fromJson(json);
}

/// @nodoc
mixin _$AIGenerationRequest {
  @JsonKey(name: 'outfit_id')
  String get outfitId => throw _privateConstructorUsedError;
  String? get pose => throw _privateConstructorUsedError;
  String? get lighting => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_profile_id')
  String? get bodyProfileId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AIGenerationRequestCopyWith<AIGenerationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIGenerationRequestCopyWith<$Res> {
  factory $AIGenerationRequestCopyWith(
          AIGenerationRequest value, $Res Function(AIGenerationRequest) then) =
      _$AIGenerationRequestCopyWithImpl<$Res, AIGenerationRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'outfit_id') String outfitId,
      String? pose,
      String? lighting,
      @JsonKey(name: 'body_profile_id') String? bodyProfileId});
}

/// @nodoc
class _$AIGenerationRequestCopyWithImpl<$Res, $Val extends AIGenerationRequest>
    implements $AIGenerationRequestCopyWith<$Res> {
  _$AIGenerationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outfitId = null,
    Object? pose = freezed,
    Object? lighting = freezed,
    Object? bodyProfileId = freezed,
  }) {
    return _then(_value.copyWith(
      outfitId: null == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as String,
      pose: freezed == pose
          ? _value.pose
          : pose // ignore: cast_nullable_to_non_nullable
              as String?,
      lighting: freezed == lighting
          ? _value.lighting
          : lighting // ignore: cast_nullable_to_non_nullable
              as String?,
      bodyProfileId: freezed == bodyProfileId
          ? _value.bodyProfileId
          : bodyProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIGenerationRequestImplCopyWith<$Res>
    implements $AIGenerationRequestCopyWith<$Res> {
  factory _$$AIGenerationRequestImplCopyWith(_$AIGenerationRequestImpl value,
          $Res Function(_$AIGenerationRequestImpl) then) =
      __$$AIGenerationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'outfit_id') String outfitId,
      String? pose,
      String? lighting,
      @JsonKey(name: 'body_profile_id') String? bodyProfileId});
}

/// @nodoc
class __$$AIGenerationRequestImplCopyWithImpl<$Res>
    extends _$AIGenerationRequestCopyWithImpl<$Res, _$AIGenerationRequestImpl>
    implements _$$AIGenerationRequestImplCopyWith<$Res> {
  __$$AIGenerationRequestImplCopyWithImpl(_$AIGenerationRequestImpl _value,
      $Res Function(_$AIGenerationRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outfitId = null,
    Object? pose = freezed,
    Object? lighting = freezed,
    Object? bodyProfileId = freezed,
  }) {
    return _then(_$AIGenerationRequestImpl(
      outfitId: null == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as String,
      pose: freezed == pose
          ? _value.pose
          : pose // ignore: cast_nullable_to_non_nullable
              as String?,
      lighting: freezed == lighting
          ? _value.lighting
          : lighting // ignore: cast_nullable_to_non_nullable
              as String?,
      bodyProfileId: freezed == bodyProfileId
          ? _value.bodyProfileId
          : bodyProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIGenerationRequestImpl implements _AIGenerationRequest {
  const _$AIGenerationRequestImpl(
      {@JsonKey(name: 'outfit_id') required this.outfitId,
      this.pose,
      this.lighting,
      @JsonKey(name: 'body_profile_id') this.bodyProfileId});

  factory _$AIGenerationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIGenerationRequestImplFromJson(json);

  @override
  @JsonKey(name: 'outfit_id')
  final String outfitId;
  @override
  final String? pose;
  @override
  final String? lighting;
  @override
  @JsonKey(name: 'body_profile_id')
  final String? bodyProfileId;

  @override
  String toString() {
    return 'AIGenerationRequest(outfitId: $outfitId, pose: $pose, lighting: $lighting, bodyProfileId: $bodyProfileId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIGenerationRequestImpl &&
            (identical(other.outfitId, outfitId) ||
                other.outfitId == outfitId) &&
            (identical(other.pose, pose) || other.pose == pose) &&
            (identical(other.lighting, lighting) ||
                other.lighting == lighting) &&
            (identical(other.bodyProfileId, bodyProfileId) ||
                other.bodyProfileId == bodyProfileId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, outfitId, pose, lighting, bodyProfileId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AIGenerationRequestImplCopyWith<_$AIGenerationRequestImpl> get copyWith =>
      __$$AIGenerationRequestImplCopyWithImpl<_$AIGenerationRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIGenerationRequestImplToJson(
      this,
    );
  }
}

abstract class _AIGenerationRequest implements AIGenerationRequest {
  const factory _AIGenerationRequest(
          {@JsonKey(name: 'outfit_id') required final String outfitId,
          final String? pose,
          final String? lighting,
          @JsonKey(name: 'body_profile_id') final String? bodyProfileId}) =
      _$AIGenerationRequestImpl;

  factory _AIGenerationRequest.fromJson(Map<String, dynamic> json) =
      _$AIGenerationRequestImpl.fromJson;

  @override
  @JsonKey(name: 'outfit_id')
  String get outfitId;
  @override
  String? get pose;
  @override
  String? get lighting;
  @override
  @JsonKey(name: 'body_profile_id')
  String? get bodyProfileId;
  @override
  @JsonKey(ignore: true)
  _$$AIGenerationRequestImplCopyWith<_$AIGenerationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GenerationStatus _$GenerationStatusFromJson(Map<String, dynamic> json) {
  return _GenerationStatus.fromJson(json);
}

/// @nodoc
mixin _$GenerationStatus {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double? get progress => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GenerationStatusCopyWith<GenerationStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationStatusCopyWith<$Res> {
  factory $GenerationStatusCopyWith(
          GenerationStatus value, $Res Function(GenerationStatus) then) =
      _$GenerationStatusCopyWithImpl<$Res, GenerationStatus>;
  @useResult
  $Res call(
      {String id,
      String status,
      double? progress,
      String? message,
      String? imageUrl,
      String? error,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt});
}

/// @nodoc
class _$GenerationStatusCopyWithImpl<$Res, $Val extends GenerationStatus>
    implements $GenerationStatusCopyWith<$Res> {
  _$GenerationStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? progress = freezed,
    Object? message = freezed,
    Object? imageUrl = freezed,
    Object? error = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GenerationStatusImplCopyWith<$Res>
    implements $GenerationStatusCopyWith<$Res> {
  factory _$$GenerationStatusImplCopyWith(_$GenerationStatusImpl value,
          $Res Function(_$GenerationStatusImpl) then) =
      __$$GenerationStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      double? progress,
      String? message,
      String? imageUrl,
      String? error,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt});
}

/// @nodoc
class __$$GenerationStatusImplCopyWithImpl<$Res>
    extends _$GenerationStatusCopyWithImpl<$Res, _$GenerationStatusImpl>
    implements _$$GenerationStatusImplCopyWith<$Res> {
  __$$GenerationStatusImplCopyWithImpl(_$GenerationStatusImpl _value,
      $Res Function(_$GenerationStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? progress = freezed,
    Object? message = freezed,
    Object? imageUrl = freezed,
    Object? error = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_$GenerationStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationStatusImpl implements _GenerationStatus {
  const _$GenerationStatusImpl(
      {required this.id,
      required this.status,
      this.progress,
      this.message,
      this.imageUrl,
      this.error,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'completed_at') this.completedAt});

  factory _$GenerationStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationStatusImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  final double? progress;
  @override
  final String? message;
  @override
  final String? imageUrl;
  @override
  final String? error;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @override
  String toString() {
    return 'GenerationStatus(id: $id, status: $status, progress: $progress, message: $message, imageUrl: $imageUrl, error: $error, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, progress, message,
      imageUrl, error, createdAt, completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationStatusImplCopyWith<_$GenerationStatusImpl> get copyWith =>
      __$$GenerationStatusImplCopyWithImpl<_$GenerationStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationStatusImplToJson(
      this,
    );
  }
}

abstract class _GenerationStatus implements GenerationStatus {
  const factory _GenerationStatus(
          {required final String id,
          required final String status,
          final double? progress,
          final String? message,
          final String? imageUrl,
          final String? error,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'completed_at') final DateTime? completedAt}) =
      _$GenerationStatusImpl;

  factory _GenerationStatus.fromJson(Map<String, dynamic> json) =
      _$GenerationStatusImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  double? get progress;
  @override
  String? get message;
  @override
  String? get imageUrl;
  @override
  String? get error;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$GenerationStatusImplCopyWith<_$GenerationStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SharedOutfitModel _$SharedOutfitModelFromJson(Map<String, dynamic> json) {
  return _SharedOutfitModel.fromJson(json);
}

/// @nodoc
mixin _$SharedOutfitModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Style get style => throw _privateConstructorUsedError;
  Season get season => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_images')
  List<String> get itemImages => throw _privateConstructorUsedError;
  @JsonKey(name: 'outfit_images')
  List<String>? get outfitImages => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'share_count')
  int get shareCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'view_count')
  int get viewCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SharedOutfitModelCopyWith<SharedOutfitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedOutfitModelCopyWith<$Res> {
  factory $SharedOutfitModelCopyWith(
          SharedOutfitModel value, $Res Function(SharedOutfitModel) then) =
      _$SharedOutfitModelCopyWithImpl<$Res, SharedOutfitModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      Style style,
      Season season,
      @JsonKey(name: 'item_images') List<String> itemImages,
      @JsonKey(name: 'outfit_images') List<String>? outfitImages,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'share_count') int shareCount,
      @JsonKey(name: 'view_count') int viewCount});
}

/// @nodoc
class _$SharedOutfitModelCopyWithImpl<$Res, $Val extends SharedOutfitModel>
    implements $SharedOutfitModelCopyWith<$Res> {
  _$SharedOutfitModelCopyWithImpl(this._value, this._then);

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
    Object? style = null,
    Object? season = null,
    Object? itemImages = null,
    Object? outfitImages = freezed,
    Object? createdAt = null,
    Object? shareCount = null,
    Object? viewCount = null,
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
      style: null == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season,
      itemImages: null == itemImages
          ? _value.itemImages
          : itemImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      outfitImages: freezed == outfitImages
          ? _value.outfitImages
          : outfitImages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SharedOutfitModelImplCopyWith<$Res>
    implements $SharedOutfitModelCopyWith<$Res> {
  factory _$$SharedOutfitModelImplCopyWith(_$SharedOutfitModelImpl value,
          $Res Function(_$SharedOutfitModelImpl) then) =
      __$$SharedOutfitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      Style style,
      Season season,
      @JsonKey(name: 'item_images') List<String> itemImages,
      @JsonKey(name: 'outfit_images') List<String>? outfitImages,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'share_count') int shareCount,
      @JsonKey(name: 'view_count') int viewCount});
}

/// @nodoc
class __$$SharedOutfitModelImplCopyWithImpl<$Res>
    extends _$SharedOutfitModelCopyWithImpl<$Res, _$SharedOutfitModelImpl>
    implements _$$SharedOutfitModelImplCopyWith<$Res> {
  __$$SharedOutfitModelImplCopyWithImpl(_$SharedOutfitModelImpl _value,
      $Res Function(_$SharedOutfitModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? style = null,
    Object? season = null,
    Object? itemImages = null,
    Object? outfitImages = freezed,
    Object? createdAt = null,
    Object? shareCount = null,
    Object? viewCount = null,
  }) {
    return _then(_$SharedOutfitModelImpl(
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
      style: null == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style,
      season: null == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season,
      itemImages: null == itemImages
          ? _value._itemImages
          : itemImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      outfitImages: freezed == outfitImages
          ? _value._outfitImages
          : outfitImages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedOutfitModelImpl implements _SharedOutfitModel {
  const _$SharedOutfitModelImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.style,
      required this.season,
      @JsonKey(name: 'item_images') required final List<String> itemImages,
      @JsonKey(name: 'outfit_images') final List<String>? outfitImages,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'share_count') this.shareCount = 0,
      @JsonKey(name: 'view_count') this.viewCount = 0})
      : _itemImages = itemImages,
        _outfitImages = outfitImages;

  factory _$SharedOutfitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedOutfitModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final Style style;
  @override
  final Season season;
  final List<String> _itemImages;
  @override
  @JsonKey(name: 'item_images')
  List<String> get itemImages {
    if (_itemImages is EqualUnmodifiableListView) return _itemImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemImages);
  }

  final List<String>? _outfitImages;
  @override
  @JsonKey(name: 'outfit_images')
  List<String>? get outfitImages {
    final value = _outfitImages;
    if (value == null) return null;
    if (_outfitImages is EqualUnmodifiableListView) return _outfitImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'share_count')
  final int shareCount;
  @override
  @JsonKey(name: 'view_count')
  final int viewCount;

  @override
  String toString() {
    return 'SharedOutfitModel(id: $id, name: $name, description: $description, style: $style, season: $season, itemImages: $itemImages, outfitImages: $outfitImages, createdAt: $createdAt, shareCount: $shareCount, viewCount: $viewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedOutfitModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.season, season) || other.season == season) &&
            const DeepCollectionEquality()
                .equals(other._itemImages, _itemImages) &&
            const DeepCollectionEquality()
                .equals(other._outfitImages, _outfitImages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      style,
      season,
      const DeepCollectionEquality().hash(_itemImages),
      const DeepCollectionEquality().hash(_outfitImages),
      createdAt,
      shareCount,
      viewCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedOutfitModelImplCopyWith<_$SharedOutfitModelImpl> get copyWith =>
      __$$SharedOutfitModelImplCopyWithImpl<_$SharedOutfitModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedOutfitModelImplToJson(
      this,
    );
  }
}

abstract class _SharedOutfitModel implements SharedOutfitModel {
  const factory _SharedOutfitModel(
          {required final String id,
          required final String name,
          final String? description,
          required final Style style,
          required final Season season,
          @JsonKey(name: 'item_images') required final List<String> itemImages,
          @JsonKey(name: 'outfit_images') final List<String>? outfitImages,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'share_count') final int shareCount,
          @JsonKey(name: 'view_count') final int viewCount}) =
      _$SharedOutfitModelImpl;

  factory _SharedOutfitModel.fromJson(Map<String, dynamic> json) =
      _$SharedOutfitModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  Style get style;
  @override
  Season get season;
  @override
  @JsonKey(name: 'item_images')
  List<String> get itemImages;
  @override
  @JsonKey(name: 'outfit_images')
  List<String>? get outfitImages;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'share_count')
  int get shareCount;
  @override
  @JsonKey(name: 'view_count')
  int get viewCount;
  @override
  @JsonKey(ignore: true)
  _$$SharedOutfitModelImplCopyWith<_$SharedOutfitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OutfitVisualizationResult _$OutfitVisualizationResultFromJson(
    Map<String, dynamic> json) {
  return _OutfitVisualizationResult.fromJson(json);
}

/// @nodoc
mixin _$OutfitVisualizationResult {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_base64')
  String? get imageBase64 => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OutfitVisualizationResultCopyWith<OutfitVisualizationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitVisualizationResultCopyWith<$Res> {
  factory $OutfitVisualizationResultCopyWith(OutfitVisualizationResult value,
          $Res Function(OutfitVisualizationResult) then) =
      _$OutfitVisualizationResultCopyWithImpl<$Res, OutfitVisualizationResult>;
  @useResult
  $Res call(
      {String id,
      String status,
      String? imageUrl,
      @JsonKey(name: 'image_base64') String? imageBase64,
      String? error,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$OutfitVisualizationResultCopyWithImpl<$Res,
        $Val extends OutfitVisualizationResult>
    implements $OutfitVisualizationResultCopyWith<$Res> {
  _$OutfitVisualizationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? error = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutfitVisualizationResultImplCopyWith<$Res>
    implements $OutfitVisualizationResultCopyWith<$Res> {
  factory _$$OutfitVisualizationResultImplCopyWith(
          _$OutfitVisualizationResultImpl value,
          $Res Function(_$OutfitVisualizationResultImpl) then) =
      __$$OutfitVisualizationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      String? imageUrl,
      @JsonKey(name: 'image_base64') String? imageBase64,
      String? error,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$OutfitVisualizationResultImplCopyWithImpl<$Res>
    extends _$OutfitVisualizationResultCopyWithImpl<$Res,
        _$OutfitVisualizationResultImpl>
    implements _$$OutfitVisualizationResultImplCopyWith<$Res> {
  __$$OutfitVisualizationResultImplCopyWithImpl(
      _$OutfitVisualizationResultImpl _value,
      $Res Function(_$OutfitVisualizationResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? error = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$OutfitVisualizationResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitVisualizationResultImpl implements _OutfitVisualizationResult {
  const _$OutfitVisualizationResultImpl(
      {required this.id,
      required this.status,
      this.imageUrl,
      @JsonKey(name: 'image_base64') this.imageBase64,
      this.error,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$OutfitVisualizationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitVisualizationResultImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  final String? imageUrl;
  @override
  @JsonKey(name: 'image_base64')
  final String? imageBase64;
  @override
  final String? error;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'OutfitVisualizationResult(id: $id, status: $status, imageUrl: $imageUrl, imageBase64: $imageBase64, error: $error, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitVisualizationResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, status, imageUrl, imageBase64, error, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitVisualizationResultImplCopyWith<_$OutfitVisualizationResultImpl>
      get copyWith => __$$OutfitVisualizationResultImplCopyWithImpl<
          _$OutfitVisualizationResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitVisualizationResultImplToJson(
      this,
    );
  }
}

abstract class _OutfitVisualizationResult implements OutfitVisualizationResult {
  const factory _OutfitVisualizationResult(
          {required final String id,
          required final String status,
          final String? imageUrl,
          @JsonKey(name: 'image_base64') final String? imageBase64,
          final String? error,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$OutfitVisualizationResultImpl;

  factory _OutfitVisualizationResult.fromJson(Map<String, dynamic> json) =
      _$OutfitVisualizationResultImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  String? get imageUrl;
  @override
  @JsonKey(name: 'image_base64')
  String? get imageBase64;
  @override
  String? get error;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$OutfitVisualizationResultImplCopyWith<_$OutfitVisualizationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WearHistoryEntry _$WearHistoryEntryFromJson(Map<String, dynamic> json) {
  return _WearHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$WearHistoryEntry {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'outfit_id')
  String get outfitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'worn_at')
  DateTime get wornAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WearHistoryEntryCopyWith<WearHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WearHistoryEntryCopyWith<$Res> {
  factory $WearHistoryEntryCopyWith(
          WearHistoryEntry value, $Res Function(WearHistoryEntry) then) =
      _$WearHistoryEntryCopyWithImpl<$Res, WearHistoryEntry>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'outfit_id') String outfitId,
      @JsonKey(name: 'worn_at') DateTime wornAt,
      String? notes,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$WearHistoryEntryCopyWithImpl<$Res, $Val extends WearHistoryEntry>
    implements $WearHistoryEntryCopyWith<$Res> {
  _$WearHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? outfitId = null,
    Object? wornAt = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      outfitId: null == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as String,
      wornAt: null == wornAt
          ? _value.wornAt
          : wornAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WearHistoryEntryImplCopyWith<$Res>
    implements $WearHistoryEntryCopyWith<$Res> {
  factory _$$WearHistoryEntryImplCopyWith(_$WearHistoryEntryImpl value,
          $Res Function(_$WearHistoryEntryImpl) then) =
      __$$WearHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'outfit_id') String outfitId,
      @JsonKey(name: 'worn_at') DateTime wornAt,
      String? notes,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$WearHistoryEntryImplCopyWithImpl<$Res>
    extends _$WearHistoryEntryCopyWithImpl<$Res, _$WearHistoryEntryImpl>
    implements _$$WearHistoryEntryImplCopyWith<$Res> {
  __$$WearHistoryEntryImplCopyWithImpl(_$WearHistoryEntryImpl _value,
      $Res Function(_$WearHistoryEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? outfitId = null,
    Object? wornAt = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$WearHistoryEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      outfitId: null == outfitId
          ? _value.outfitId
          : outfitId // ignore: cast_nullable_to_non_nullable
              as String,
      wornAt: null == wornAt
          ? _value.wornAt
          : wornAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WearHistoryEntryImpl implements _WearHistoryEntry {
  const _$WearHistoryEntryImpl(
      {required this.id,
      @JsonKey(name: 'outfit_id') required this.outfitId,
      @JsonKey(name: 'worn_at') required this.wornAt,
      this.notes,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$WearHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WearHistoryEntryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'outfit_id')
  final String outfitId;
  @override
  @JsonKey(name: 'worn_at')
  final DateTime wornAt;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'WearHistoryEntry(id: $id, outfitId: $outfitId, wornAt: $wornAt, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WearHistoryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.outfitId, outfitId) ||
                other.outfitId == outfitId) &&
            (identical(other.wornAt, wornAt) || other.wornAt == wornAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, outfitId, wornAt, notes, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WearHistoryEntryImplCopyWith<_$WearHistoryEntryImpl> get copyWith =>
      __$$WearHistoryEntryImplCopyWithImpl<_$WearHistoryEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WearHistoryEntryImplToJson(
      this,
    );
  }
}

abstract class _WearHistoryEntry implements WearHistoryEntry {
  const factory _WearHistoryEntry(
          {required final String id,
          @JsonKey(name: 'outfit_id') required final String outfitId,
          @JsonKey(name: 'worn_at') required final DateTime wornAt,
          final String? notes,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$WearHistoryEntryImpl;

  factory _WearHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$WearHistoryEntryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'outfit_id')
  String get outfitId;
  @override
  @JsonKey(name: 'worn_at')
  DateTime get wornAt;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$WearHistoryEntryImplCopyWith<_$WearHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
