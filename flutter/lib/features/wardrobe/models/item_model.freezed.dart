// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ItemModel _$ItemModelFromJson(Map<String, dynamic> json) {
  return _ItemModel.fromJson(json);
}

/// @nodoc
mixin _$ItemModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Category get category => throw _privateConstructorUsedError;
  List<String>? get colors => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  Condition get condition => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'purchase_date')
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorite')
  bool get isFavorite => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_images')
  List<ItemImage>? get itemImages => throw _privateConstructorUsedError;
  @JsonKey(name: 'worn_count')
  int get wornCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_worn_at')
  DateTime? get lastWornAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItemModelCopyWith<ItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemModelCopyWith<$Res> {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) then) =
      _$ItemModelCopyWithImpl<$Res, ItemModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      String? description,
      Category category,
      List<String>? colors,
      String? brand,
      String? size,
      String? material,
      String? pattern,
      Condition condition,
      double? price,
      @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
      String? location,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      List<String>? tags,
      @JsonKey(name: 'item_images') List<ItemImage>? itemImages,
      @JsonKey(name: 'worn_count') int wornCount,
      @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ItemModelCopyWithImpl<$Res, $Val extends ItemModel>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._value, this._then);

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
    Object? category = null,
    Object? colors = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? condition = null,
    Object? price = freezed,
    Object? purchaseDate = freezed,
    Object? location = freezed,
    Object? isFavorite = null,
    Object? tags = freezed,
    Object? itemImages = freezed,
    Object? wornCount = null,
    Object? lastWornAt = freezed,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value.colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Condition,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      itemImages: freezed == itemImages
          ? _value.itemImages
          : itemImages // ignore: cast_nullable_to_non_nullable
              as List<ItemImage>?,
      wornCount: null == wornCount
          ? _value.wornCount
          : wornCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastWornAt: freezed == lastWornAt
          ? _value.lastWornAt
          : lastWornAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$ItemModelImplCopyWith<$Res>
    implements $ItemModelCopyWith<$Res> {
  factory _$$ItemModelImplCopyWith(
          _$ItemModelImpl value, $Res Function(_$ItemModelImpl) then) =
      __$$ItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      String? description,
      Category category,
      List<String>? colors,
      String? brand,
      String? size,
      String? material,
      String? pattern,
      Condition condition,
      double? price,
      @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
      String? location,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      List<String>? tags,
      @JsonKey(name: 'item_images') List<ItemImage>? itemImages,
      @JsonKey(name: 'worn_count') int wornCount,
      @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$ItemModelImplCopyWithImpl<$Res>
    extends _$ItemModelCopyWithImpl<$Res, _$ItemModelImpl>
    implements _$$ItemModelImplCopyWith<$Res> {
  __$$ItemModelImplCopyWithImpl(
      _$ItemModelImpl _value, $Res Function(_$ItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? colors = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? condition = null,
    Object? price = freezed,
    Object? purchaseDate = freezed,
    Object? location = freezed,
    Object? isFavorite = null,
    Object? tags = freezed,
    Object? itemImages = freezed,
    Object? wornCount = null,
    Object? lastWornAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ItemModelImpl(
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value._colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Condition,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      itemImages: freezed == itemImages
          ? _value._itemImages
          : itemImages // ignore: cast_nullable_to_non_nullable
              as List<ItemImage>?,
      wornCount: null == wornCount
          ? _value.wornCount
          : wornCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastWornAt: freezed == lastWornAt
          ? _value.lastWornAt
          : lastWornAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$ItemModelImpl implements _ItemModel {
  const _$ItemModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.name,
      this.description,
      required this.category,
      final List<String>? colors,
      this.brand,
      this.size,
      this.material,
      this.pattern,
      required this.condition,
      this.price,
      @JsonKey(name: 'purchase_date') this.purchaseDate,
      this.location,
      @JsonKey(name: 'is_favorite') this.isFavorite = false,
      final List<String>? tags,
      @JsonKey(name: 'item_images') final List<ItemImage>? itemImages,
      @JsonKey(name: 'worn_count') this.wornCount = 0,
      @JsonKey(name: 'last_worn_at') this.lastWornAt,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _colors = colors,
        _tags = tags,
        _itemImages = itemImages;

  factory _$ItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final Category category;
  final List<String>? _colors;
  @override
  List<String>? get colors {
    final value = _colors;
    if (value == null) return null;
    if (_colors is EqualUnmodifiableListView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? brand;
  @override
  final String? size;
  @override
  final String? material;
  @override
  final String? pattern;
  @override
  final Condition condition;
  @override
  final double? price;
  @override
  @JsonKey(name: 'purchase_date')
  final DateTime? purchaseDate;
  @override
  final String? location;
  @override
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<ItemImage>? _itemImages;
  @override
  @JsonKey(name: 'item_images')
  List<ItemImage>? get itemImages {
    final value = _itemImages;
    if (value == null) return null;
    if (_itemImages is EqualUnmodifiableListView) return _itemImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'worn_count')
  final int wornCount;
  @override
  @JsonKey(name: 'last_worn_at')
  final DateTime? lastWornAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ItemModel(id: $id, userId: $userId, name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, isFavorite: $isFavorite, tags: $tags, itemImages: $itemImages, wornCount: $wornCount, lastWornAt: $lastWornAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._itemImages, _itemImages) &&
            (identical(other.wornCount, wornCount) ||
                other.wornCount == wornCount) &&
            (identical(other.lastWornAt, lastWornAt) ||
                other.lastWornAt == lastWornAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        name,
        description,
        category,
        const DeepCollectionEquality().hash(_colors),
        brand,
        size,
        material,
        pattern,
        condition,
        price,
        purchaseDate,
        location,
        isFavorite,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_itemImages),
        wornCount,
        lastWornAt,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      __$$ItemModelImplCopyWithImpl<_$ItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemModelImplToJson(
      this,
    );
  }
}

abstract class _ItemModel implements ItemModel {
  const factory _ItemModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String name,
          final String? description,
          required final Category category,
          final List<String>? colors,
          final String? brand,
          final String? size,
          final String? material,
          final String? pattern,
          required final Condition condition,
          final double? price,
          @JsonKey(name: 'purchase_date') final DateTime? purchaseDate,
          final String? location,
          @JsonKey(name: 'is_favorite') final bool isFavorite,
          final List<String>? tags,
          @JsonKey(name: 'item_images') final List<ItemImage>? itemImages,
          @JsonKey(name: 'worn_count') final int wornCount,
          @JsonKey(name: 'last_worn_at') final DateTime? lastWornAt,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$ItemModelImpl;

  factory _ItemModel.fromJson(Map<String, dynamic> json) =
      _$ItemModelImpl.fromJson;

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
  Category get category;
  @override
  List<String>? get colors;
  @override
  String? get brand;
  @override
  String? get size;
  @override
  String? get material;
  @override
  String? get pattern;
  @override
  Condition get condition;
  @override
  double? get price;
  @override
  @JsonKey(name: 'purchase_date')
  DateTime? get purchaseDate;
  @override
  String? get location;
  @override
  @JsonKey(name: 'is_favorite')
  bool get isFavorite;
  @override
  List<String>? get tags;
  @override
  @JsonKey(name: 'item_images')
  List<ItemImage>? get itemImages;
  @override
  @JsonKey(name: 'worn_count')
  int get wornCount;
  @override
  @JsonKey(name: 'last_worn_at')
  DateTime? get lastWornAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItemImage _$ItemImageFromJson(Map<String, dynamic> json) {
  return _ItemImage.fromJson(json);
}

/// @nodoc
mixin _$ItemImage {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool get isPrimary => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  String? get blurhash => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItemImageCopyWith<ItemImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemImageCopyWith<$Res> {
  factory $ItemImageCopyWith(ItemImage value, $Res Function(ItemImage) then) =
      _$ItemImageCopyWithImpl<$Res, ItemImage>;
  @useResult
  $Res call(
      {String id,
      String url,
      @JsonKey(name: 'is_primary') bool isPrimary,
      int? width,
      int? height,
      String? blurhash});
}

/// @nodoc
class _$ItemImageCopyWithImpl<$Res, $Val extends ItemImage>
    implements $ItemImageCopyWith<$Res> {
  _$ItemImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? isPrimary = null,
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
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ItemImageImplCopyWith<$Res>
    implements $ItemImageCopyWith<$Res> {
  factory _$$ItemImageImplCopyWith(
          _$ItemImageImpl value, $Res Function(_$ItemImageImpl) then) =
      __$$ItemImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      @JsonKey(name: 'is_primary') bool isPrimary,
      int? width,
      int? height,
      String? blurhash});
}

/// @nodoc
class __$$ItemImageImplCopyWithImpl<$Res>
    extends _$ItemImageCopyWithImpl<$Res, _$ItemImageImpl>
    implements _$$ItemImageImplCopyWith<$Res> {
  __$$ItemImageImplCopyWithImpl(
      _$ItemImageImpl _value, $Res Function(_$ItemImageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? isPrimary = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? blurhash = freezed,
  }) {
    return _then(_$ItemImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
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
class _$ItemImageImpl implements _ItemImage {
  const _$ItemImageImpl(
      {required this.id,
      required this.url,
      @JsonKey(name: 'is_primary') this.isPrimary = false,
      this.width,
      this.height,
      this.blurhash});

  factory _$ItemImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemImageImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final String? blurhash;

  @override
  String toString() {
    return 'ItemImage(id: $id, url: $url, isPrimary: $isPrimary, width: $width, height: $height, blurhash: $blurhash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.blurhash, blurhash) ||
                other.blurhash == blurhash));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, url, isPrimary, width, height, blurhash);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemImageImplCopyWith<_$ItemImageImpl> get copyWith =>
      __$$ItemImageImplCopyWithImpl<_$ItemImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemImageImplToJson(
      this,
    );
  }
}

abstract class _ItemImage implements ItemImage {
  const factory _ItemImage(
      {required final String id,
      required final String url,
      @JsonKey(name: 'is_primary') final bool isPrimary,
      final int? width,
      final int? height,
      final String? blurhash}) = _$ItemImageImpl;

  factory _ItemImage.fromJson(Map<String, dynamic> json) =
      _$ItemImageImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  @JsonKey(name: 'is_primary')
  bool get isPrimary;
  @override
  int? get width;
  @override
  int? get height;
  @override
  String? get blurhash;
  @override
  @JsonKey(ignore: true)
  _$$ItemImageImplCopyWith<_$ItemImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateItemRequest _$CreateItemRequestFromJson(Map<String, dynamic> json) {
  return _CreateItemRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateItemRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Category get category => throw _privateConstructorUsedError;
  List<String>? get colors => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  Condition get condition => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'purchase_date')
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateItemRequestCopyWith<CreateItemRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateItemRequestCopyWith<$Res> {
  factory $CreateItemRequestCopyWith(
          CreateItemRequest value, $Res Function(CreateItemRequest) then) =
      _$CreateItemRequestCopyWithImpl<$Res, CreateItemRequest>;
  @useResult
  $Res call(
      {String name,
      String? description,
      Category category,
      List<String>? colors,
      String? brand,
      String? size,
      String? material,
      String? pattern,
      Condition condition,
      double? price,
      @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
      String? location,
      List<String>? tags});
}

/// @nodoc
class _$CreateItemRequestCopyWithImpl<$Res, $Val extends CreateItemRequest>
    implements $CreateItemRequestCopyWith<$Res> {
  _$CreateItemRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? colors = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? condition = null,
    Object? price = freezed,
    Object? purchaseDate = freezed,
    Object? location = freezed,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value.colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Condition,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateItemRequestImplCopyWith<$Res>
    implements $CreateItemRequestCopyWith<$Res> {
  factory _$$CreateItemRequestImplCopyWith(_$CreateItemRequestImpl value,
          $Res Function(_$CreateItemRequestImpl) then) =
      __$$CreateItemRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      Category category,
      List<String>? colors,
      String? brand,
      String? size,
      String? material,
      String? pattern,
      Condition condition,
      double? price,
      @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
      String? location,
      List<String>? tags});
}

/// @nodoc
class __$$CreateItemRequestImplCopyWithImpl<$Res>
    extends _$CreateItemRequestCopyWithImpl<$Res, _$CreateItemRequestImpl>
    implements _$$CreateItemRequestImplCopyWith<$Res> {
  __$$CreateItemRequestImplCopyWithImpl(_$CreateItemRequestImpl _value,
      $Res Function(_$CreateItemRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? colors = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? condition = null,
    Object? price = freezed,
    Object? purchaseDate = freezed,
    Object? location = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$CreateItemRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value._colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Condition,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
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
class _$CreateItemRequestImpl implements _CreateItemRequest {
  const _$CreateItemRequestImpl(
      {required this.name,
      this.description,
      required this.category,
      final List<String>? colors,
      this.brand,
      this.size,
      this.material,
      this.pattern,
      this.condition = Condition.clean,
      this.price,
      @JsonKey(name: 'purchase_date') this.purchaseDate,
      this.location,
      final List<String>? tags})
      : _colors = colors,
        _tags = tags;

  factory _$CreateItemRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateItemRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final Category category;
  final List<String>? _colors;
  @override
  List<String>? get colors {
    final value = _colors;
    if (value == null) return null;
    if (_colors is EqualUnmodifiableListView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? brand;
  @override
  final String? size;
  @override
  final String? material;
  @override
  final String? pattern;
  @override
  @JsonKey()
  final Condition condition;
  @override
  final double? price;
  @override
  @JsonKey(name: 'purchase_date')
  final DateTime? purchaseDate;
  @override
  final String? location;
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
    return 'CreateItemRequest(name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateItemRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      category,
      const DeepCollectionEquality().hash(_colors),
      brand,
      size,
      material,
      pattern,
      condition,
      price,
      purchaseDate,
      location,
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateItemRequestImplCopyWith<_$CreateItemRequestImpl> get copyWith =>
      __$$CreateItemRequestImplCopyWithImpl<_$CreateItemRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateItemRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateItemRequest implements CreateItemRequest {
  const factory _CreateItemRequest(
      {required final String name,
      final String? description,
      required final Category category,
      final List<String>? colors,
      final String? brand,
      final String? size,
      final String? material,
      final String? pattern,
      final Condition condition,
      final double? price,
      @JsonKey(name: 'purchase_date') final DateTime? purchaseDate,
      final String? location,
      final List<String>? tags}) = _$CreateItemRequestImpl;

  factory _CreateItemRequest.fromJson(Map<String, dynamic> json) =
      _$CreateItemRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  Category get category;
  @override
  List<String>? get colors;
  @override
  String? get brand;
  @override
  String? get size;
  @override
  String? get material;
  @override
  String? get pattern;
  @override
  Condition get condition;
  @override
  double? get price;
  @override
  @JsonKey(name: 'purchase_date')
  DateTime? get purchaseDate;
  @override
  String? get location;
  @override
  List<String>? get tags;
  @override
  @JsonKey(ignore: true)
  _$$CreateItemRequestImplCopyWith<_$CreateItemRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateItemRequest _$UpdateItemRequestFromJson(Map<String, dynamic> json) {
  return _UpdateItemRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateItemRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Category? get category => throw _privateConstructorUsedError;
  List<String>? get colors => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  Condition? get condition => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateItemRequestCopyWith<UpdateItemRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateItemRequestCopyWith<$Res> {
  factory $UpdateItemRequestCopyWith(
          UpdateItemRequest value, $Res Function(UpdateItemRequest) then) =
      _$UpdateItemRequestCopyWithImpl<$Res, UpdateItemRequest>;
  @useResult
  $Res call(
      {String? name,
      String? description,
      Category? category,
      List<String>? colors,
      String? brand,
      String? size,
      String? material,
      String? pattern,
      Condition? condition,
      double? price,
      DateTime? purchaseDate,
      String? location,
      List<String>? tags});
}

/// @nodoc
class _$UpdateItemRequestCopyWithImpl<$Res, $Val extends UpdateItemRequest>
    implements $UpdateItemRequestCopyWith<$Res> {
  _$UpdateItemRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? colors = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? condition = freezed,
    Object? price = freezed,
    Object? purchaseDate = freezed,
    Object? location = freezed,
    Object? tags = freezed,
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
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category?,
      colors: freezed == colors
          ? _value.colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Condition?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateItemRequestImplCopyWith<$Res>
    implements $UpdateItemRequestCopyWith<$Res> {
  factory _$$UpdateItemRequestImplCopyWith(_$UpdateItemRequestImpl value,
          $Res Function(_$UpdateItemRequestImpl) then) =
      __$$UpdateItemRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? description,
      Category? category,
      List<String>? colors,
      String? brand,
      String? size,
      String? material,
      String? pattern,
      Condition? condition,
      double? price,
      DateTime? purchaseDate,
      String? location,
      List<String>? tags});
}

/// @nodoc
class __$$UpdateItemRequestImplCopyWithImpl<$Res>
    extends _$UpdateItemRequestCopyWithImpl<$Res, _$UpdateItemRequestImpl>
    implements _$$UpdateItemRequestImplCopyWith<$Res> {
  __$$UpdateItemRequestImplCopyWithImpl(_$UpdateItemRequestImpl _value,
      $Res Function(_$UpdateItemRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? colors = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? condition = freezed,
    Object? price = freezed,
    Object? purchaseDate = freezed,
    Object? location = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$UpdateItemRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category?,
      colors: freezed == colors
          ? _value._colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Condition?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      purchaseDate: freezed == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
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
class _$UpdateItemRequestImpl implements _UpdateItemRequest {
  const _$UpdateItemRequestImpl(
      {this.name,
      this.description,
      this.category,
      final List<String>? colors,
      this.brand,
      this.size,
      this.material,
      this.pattern,
      this.condition,
      this.price,
      this.purchaseDate,
      this.location,
      final List<String>? tags})
      : _colors = colors,
        _tags = tags;

  factory _$UpdateItemRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateItemRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  final Category? category;
  final List<String>? _colors;
  @override
  List<String>? get colors {
    final value = _colors;
    if (value == null) return null;
    if (_colors is EqualUnmodifiableListView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? brand;
  @override
  final String? size;
  @override
  final String? material;
  @override
  final String? pattern;
  @override
  final Condition? condition;
  @override
  final double? price;
  @override
  final DateTime? purchaseDate;
  @override
  final String? location;
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
    return 'UpdateItemRequest(name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateItemRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      category,
      const DeepCollectionEquality().hash(_colors),
      brand,
      size,
      material,
      pattern,
      condition,
      price,
      purchaseDate,
      location,
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateItemRequestImplCopyWith<_$UpdateItemRequestImpl> get copyWith =>
      __$$UpdateItemRequestImplCopyWithImpl<_$UpdateItemRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateItemRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateItemRequest implements UpdateItemRequest {
  const factory _UpdateItemRequest(
      {final String? name,
      final String? description,
      final Category? category,
      final List<String>? colors,
      final String? brand,
      final String? size,
      final String? material,
      final String? pattern,
      final Condition? condition,
      final double? price,
      final DateTime? purchaseDate,
      final String? location,
      final List<String>? tags}) = _$UpdateItemRequestImpl;

  factory _UpdateItemRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateItemRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  Category? get category;
  @override
  List<String>? get colors;
  @override
  String? get brand;
  @override
  String? get size;
  @override
  String? get material;
  @override
  String? get pattern;
  @override
  Condition? get condition;
  @override
  double? get price;
  @override
  DateTime? get purchaseDate;
  @override
  String? get location;
  @override
  List<String>? get tags;
  @override
  @JsonKey(ignore: true)
  _$$UpdateItemRequestImplCopyWith<_$UpdateItemRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItemsListResponse _$ItemsListResponseFromJson(Map<String, dynamic> json) {
  return _ItemsListResponse.fromJson(json);
}

/// @nodoc
mixin _$ItemsListResponse {
  List<ItemModel> get items => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_more')
  bool get hasMore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItemsListResponseCopyWith<ItemsListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemsListResponseCopyWith<$Res> {
  factory $ItemsListResponseCopyWith(
          ItemsListResponse value, $Res Function(ItemsListResponse) then) =
      _$ItemsListResponseCopyWithImpl<$Res, ItemsListResponse>;
  @useResult
  $Res call(
      {List<ItemModel> items,
      int total,
      int page,
      int limit,
      @JsonKey(name: 'has_more') bool hasMore});
}

/// @nodoc
class _$ItemsListResponseCopyWithImpl<$Res, $Val extends ItemsListResponse>
    implements $ItemsListResponseCopyWith<$Res> {
  _$ItemsListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ItemModel>,
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
abstract class _$$ItemsListResponseImplCopyWith<$Res>
    implements $ItemsListResponseCopyWith<$Res> {
  factory _$$ItemsListResponseImplCopyWith(_$ItemsListResponseImpl value,
          $Res Function(_$ItemsListResponseImpl) then) =
      __$$ItemsListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ItemModel> items,
      int total,
      int page,
      int limit,
      @JsonKey(name: 'has_more') bool hasMore});
}

/// @nodoc
class __$$ItemsListResponseImplCopyWithImpl<$Res>
    extends _$ItemsListResponseCopyWithImpl<$Res, _$ItemsListResponseImpl>
    implements _$$ItemsListResponseImplCopyWith<$Res> {
  __$$ItemsListResponseImplCopyWithImpl(_$ItemsListResponseImpl _value,
      $Res Function(_$ItemsListResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasMore = null,
  }) {
    return _then(_$ItemsListResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ItemModel>,
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
class _$ItemsListResponseImpl implements _ItemsListResponse {
  const _$ItemsListResponseImpl(
      {required final List<ItemModel> items,
      required this.total,
      required this.page,
      required this.limit,
      @JsonKey(name: 'has_more') required this.hasMore})
      : _items = items;

  factory _$ItemsListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemsListResponseImplFromJson(json);

  final List<ItemModel> _items;
  @override
  List<ItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
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
    return 'ItemsListResponse(items: $items, total: $total, page: $page, limit: $limit, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemsListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_items), total, page, limit, hasMore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemsListResponseImplCopyWith<_$ItemsListResponseImpl> get copyWith =>
      __$$ItemsListResponseImplCopyWithImpl<_$ItemsListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemsListResponseImplToJson(
      this,
    );
  }
}

abstract class _ItemsListResponse implements ItemsListResponse {
  const factory _ItemsListResponse(
          {required final List<ItemModel> items,
          required final int total,
          required final int page,
          required final int limit,
          @JsonKey(name: 'has_more') required final bool hasMore}) =
      _$ItemsListResponseImpl;

  factory _ItemsListResponse.fromJson(Map<String, dynamic> json) =
      _$ItemsListResponseImpl.fromJson;

  @override
  List<ItemModel> get items;
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
  _$$ItemsListResponseImplCopyWith<_$ItemsListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExtractedItem _$ExtractedItemFromJson(Map<String, dynamic> json) {
  return _ExtractedItem.fromJson(json);
}

/// @nodoc
mixin _$ExtractedItem {
  String get name => throw _privateConstructorUsedError;
  Category get category => throw _privateConstructorUsedError;
  List<String>? get colors => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'bounding_box')
  Map<String, dynamic>? get boundingBox => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExtractedItemCopyWith<ExtractedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExtractedItemCopyWith<$Res> {
  factory $ExtractedItemCopyWith(
          ExtractedItem value, $Res Function(ExtractedItem) then) =
      _$ExtractedItemCopyWithImpl<$Res, ExtractedItem>;
  @useResult
  $Res call(
      {String name,
      Category category,
      List<String>? colors,
      String? material,
      String? pattern,
      String? description,
      @JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox});
}

/// @nodoc
class _$ExtractedItemCopyWithImpl<$Res, $Val extends ExtractedItem>
    implements $ExtractedItemCopyWith<$Res> {
  _$ExtractedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? colors = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? description = freezed,
    Object? boundingBox = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value.colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      boundingBox: freezed == boundingBox
          ? _value.boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExtractedItemImplCopyWith<$Res>
    implements $ExtractedItemCopyWith<$Res> {
  factory _$$ExtractedItemImplCopyWith(
          _$ExtractedItemImpl value, $Res Function(_$ExtractedItemImpl) then) =
      __$$ExtractedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      Category category,
      List<String>? colors,
      String? material,
      String? pattern,
      String? description,
      @JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox});
}

/// @nodoc
class __$$ExtractedItemImplCopyWithImpl<$Res>
    extends _$ExtractedItemCopyWithImpl<$Res, _$ExtractedItemImpl>
    implements _$$ExtractedItemImplCopyWith<$Res> {
  __$$ExtractedItemImplCopyWithImpl(
      _$ExtractedItemImpl _value, $Res Function(_$ExtractedItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? colors = freezed,
    Object? material = freezed,
    Object? pattern = freezed,
    Object? description = freezed,
    Object? boundingBox = freezed,
  }) {
    return _then(_$ExtractedItemImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      colors: freezed == colors
          ? _value._colors
          : colors // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      pattern: freezed == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      boundingBox: freezed == boundingBox
          ? _value._boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtractedItemImpl implements _ExtractedItem {
  const _$ExtractedItemImpl(
      {required this.name,
      required this.category,
      final List<String>? colors,
      this.material,
      this.pattern,
      this.description,
      @JsonKey(name: 'bounding_box') final Map<String, dynamic>? boundingBox})
      : _colors = colors,
        _boundingBox = boundingBox;

  factory _$ExtractedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtractedItemImplFromJson(json);

  @override
  final String name;
  @override
  final Category category;
  final List<String>? _colors;
  @override
  List<String>? get colors {
    final value = _colors;
    if (value == null) return null;
    if (_colors is EqualUnmodifiableListView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? material;
  @override
  final String? pattern;
  @override
  final String? description;
  final Map<String, dynamic>? _boundingBox;
  @override
  @JsonKey(name: 'bounding_box')
  Map<String, dynamic>? get boundingBox {
    final value = _boundingBox;
    if (value == null) return null;
    if (_boundingBox is EqualUnmodifiableMapView) return _boundingBox;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ExtractedItem(name: $name, category: $category, colors: $colors, material: $material, pattern: $pattern, description: $description, boundingBox: $boundingBox)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractedItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._boundingBox, _boundingBox));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      category,
      const DeepCollectionEquality().hash(_colors),
      material,
      pattern,
      description,
      const DeepCollectionEquality().hash(_boundingBox));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractedItemImplCopyWith<_$ExtractedItemImpl> get copyWith =>
      __$$ExtractedItemImplCopyWithImpl<_$ExtractedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtractedItemImplToJson(
      this,
    );
  }
}

abstract class _ExtractedItem implements ExtractedItem {
  const factory _ExtractedItem(
      {required final String name,
      required final Category category,
      final List<String>? colors,
      final String? material,
      final String? pattern,
      final String? description,
      @JsonKey(name: 'bounding_box')
      final Map<String, dynamic>? boundingBox}) = _$ExtractedItemImpl;

  factory _ExtractedItem.fromJson(Map<String, dynamic> json) =
      _$ExtractedItemImpl.fromJson;

  @override
  String get name;
  @override
  Category get category;
  @override
  List<String>? get colors;
  @override
  String? get material;
  @override
  String? get pattern;
  @override
  String? get description;
  @override
  @JsonKey(name: 'bounding_box')
  Map<String, dynamic>? get boundingBox;
  @override
  @JsonKey(ignore: true)
  _$$ExtractedItemImplCopyWith<_$ExtractedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExtractionResponse _$ExtractionResponseFromJson(Map<String, dynamic> json) {
  return _ExtractionResponse.fromJson(json);
}

/// @nodoc
mixin _$ExtractionResponse {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<ExtractedItem>? get items => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExtractionResponseCopyWith<ExtractionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExtractionResponseCopyWith<$Res> {
  factory $ExtractionResponseCopyWith(
          ExtractionResponse value, $Res Function(ExtractionResponse) then) =
      _$ExtractionResponseCopyWithImpl<$Res, ExtractionResponse>;
  @useResult
  $Res call(
      {String id,
      String status,
      List<ExtractedItem>? items,
      String? imageUrl,
      String? error,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$ExtractionResponseCopyWithImpl<$Res, $Val extends ExtractionResponse>
    implements $ExtractionResponseCopyWith<$Res> {
  _$ExtractionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? items = freezed,
    Object? imageUrl = freezed,
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
      items: freezed == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ExtractedItem>?,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExtractionResponseImplCopyWith<$Res>
    implements $ExtractionResponseCopyWith<$Res> {
  factory _$$ExtractionResponseImplCopyWith(_$ExtractionResponseImpl value,
          $Res Function(_$ExtractionResponseImpl) then) =
      __$$ExtractionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      List<ExtractedItem>? items,
      String? imageUrl,
      String? error,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$ExtractionResponseImplCopyWithImpl<$Res>
    extends _$ExtractionResponseCopyWithImpl<$Res, _$ExtractionResponseImpl>
    implements _$$ExtractionResponseImplCopyWith<$Res> {
  __$$ExtractionResponseImplCopyWithImpl(_$ExtractionResponseImpl _value,
      $Res Function(_$ExtractionResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? items = freezed,
    Object? imageUrl = freezed,
    Object? error = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ExtractionResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: freezed == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ExtractedItem>?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtractionResponseImpl implements _ExtractionResponse {
  const _$ExtractionResponseImpl(
      {required this.id,
      required this.status,
      final List<ExtractedItem>? items,
      this.imageUrl,
      this.error,
      @JsonKey(name: 'created_at') this.createdAt})
      : _items = items;

  factory _$ExtractionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtractionResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  final List<ExtractedItem>? _items;
  @override
  List<ExtractedItem>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? imageUrl;
  @override
  final String? error;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ExtractionResponse(id: $id, status: $status, items: $items, imageUrl: $imageUrl, error: $error, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractionResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, status,
      const DeepCollectionEquality().hash(_items), imageUrl, error, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractionResponseImplCopyWith<_$ExtractionResponseImpl> get copyWith =>
      __$$ExtractionResponseImplCopyWithImpl<_$ExtractionResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtractionResponseImplToJson(
      this,
    );
  }
}

abstract class _ExtractionResponse implements ExtractionResponse {
  const factory _ExtractionResponse(
          {required final String id,
          required final String status,
          final List<ExtractedItem>? items,
          final String? imageUrl,
          final String? error,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$ExtractionResponseImpl;

  factory _ExtractionResponse.fromJson(Map<String, dynamic> json) =
      _$ExtractionResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  List<ExtractedItem>? get items;
  @override
  String? get imageUrl;
  @override
  String? get error;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ExtractionResponseImplCopyWith<_$ExtractionResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
