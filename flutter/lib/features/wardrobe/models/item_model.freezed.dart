// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemModel {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name; String? get description; Category get category; List<String>? get colors; String? get brand; String? get size; String? get material; String? get pattern; Condition get condition; double? get price;@JsonKey(name: 'purchase_date') DateTime? get purchaseDate; String? get location;@JsonKey(name: 'is_favorite') bool get isFavorite; List<String>? get tags;@JsonKey(name: 'occasion_tags') List<String>? get occasionTags;@JsonKey(name: 'item_images') List<ItemImage>? get itemImages;@JsonKey(name: 'worn_count') int get wornCount;@JsonKey(name: 'last_worn_at') DateTime? get lastWornAt;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemModelCopyWith<ItemModel> get copyWith => _$ItemModelCopyWithImpl<ItemModel>(this as ItemModel, _$identity);

  /// Serializes this ItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.price, price) || other.price == price)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.occasionTags, occasionTags)&&const DeepCollectionEquality().equals(other.itemImages, itemImages)&&(identical(other.wornCount, wornCount) || other.wornCount == wornCount)&&(identical(other.lastWornAt, lastWornAt) || other.lastWornAt == lastWornAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,description,category,const DeepCollectionEquality().hash(colors),brand,size,material,pattern,condition,price,purchaseDate,location,isFavorite,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(occasionTags),const DeepCollectionEquality().hash(itemImages),wornCount,lastWornAt,createdAt,updatedAt]);

@override
String toString() {
  return 'ItemModel(id: $id, userId: $userId, name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, isFavorite: $isFavorite, tags: $tags, occasionTags: $occasionTags, itemImages: $itemImages, wornCount: $wornCount, lastWornAt: $lastWornAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemModelCopyWith<$Res>  {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) _then) = _$ItemModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String? description, Category category, List<String>? colors, String? brand, String? size, String? material, String? pattern, Condition condition, double? price,@JsonKey(name: 'purchase_date') DateTime? purchaseDate, String? location,@JsonKey(name: 'is_favorite') bool isFavorite, List<String>? tags,@JsonKey(name: 'occasion_tags') List<String>? occasionTags,@JsonKey(name: 'item_images') List<ItemImage>? itemImages,@JsonKey(name: 'worn_count') int wornCount,@JsonKey(name: 'last_worn_at') DateTime? lastWornAt,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$ItemModelCopyWithImpl<$Res>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._self, this._then);

  final ItemModel _self;
  final $Res Function(ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? category = null,Object? colors = freezed,Object? brand = freezed,Object? size = freezed,Object? material = freezed,Object? pattern = freezed,Object? condition = null,Object? price = freezed,Object? purchaseDate = freezed,Object? location = freezed,Object? isFavorite = null,Object? tags = freezed,Object? occasionTags = freezed,Object? itemImages = freezed,Object? wornCount = null,Object? lastWornAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as Condition,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,occasionTags: freezed == occasionTags ? _self.occasionTags : occasionTags // ignore: cast_nullable_to_non_nullable
as List<String>?,itemImages: freezed == itemImages ? _self.itemImages : itemImages // ignore: cast_nullable_to_non_nullable
as List<ItemImage>?,wornCount: null == wornCount ? _self.wornCount : wornCount // ignore: cast_nullable_to_non_nullable
as int,lastWornAt: freezed == lastWornAt ? _self.lastWornAt : lastWornAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemModel].
extension ItemModelPatterns on ItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description,  Category category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition condition,  double? price, @JsonKey(name: 'purchase_date')  DateTime? purchaseDate,  String? location, @JsonKey(name: 'is_favorite')  bool isFavorite,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags, @JsonKey(name: 'item_images')  List<ItemImage>? itemImages, @JsonKey(name: 'worn_count')  int wornCount, @JsonKey(name: 'last_worn_at')  DateTime? lastWornAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.isFavorite,_that.tags,_that.occasionTags,_that.itemImages,_that.wornCount,_that.lastWornAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description,  Category category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition condition,  double? price, @JsonKey(name: 'purchase_date')  DateTime? purchaseDate,  String? location, @JsonKey(name: 'is_favorite')  bool isFavorite,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags, @JsonKey(name: 'item_images')  List<ItemImage>? itemImages, @JsonKey(name: 'worn_count')  int wornCount, @JsonKey(name: 'last_worn_at')  DateTime? lastWornAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemModel():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.isFavorite,_that.tags,_that.occasionTags,_that.itemImages,_that.wornCount,_that.lastWornAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description,  Category category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition condition,  double? price, @JsonKey(name: 'purchase_date')  DateTime? purchaseDate,  String? location, @JsonKey(name: 'is_favorite')  bool isFavorite,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags, @JsonKey(name: 'item_images')  List<ItemImage>? itemImages, @JsonKey(name: 'worn_count')  int wornCount, @JsonKey(name: 'last_worn_at')  DateTime? lastWornAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.isFavorite,_that.tags,_that.occasionTags,_that.itemImages,_that.wornCount,_that.lastWornAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemModel implements ItemModel {
  const _ItemModel({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, this.description, required this.category, final  List<String>? colors, this.brand, this.size, this.material, this.pattern, required this.condition, this.price, @JsonKey(name: 'purchase_date') this.purchaseDate, this.location, @JsonKey(name: 'is_favorite') this.isFavorite = false, final  List<String>? tags, @JsonKey(name: 'occasion_tags') final  List<String>? occasionTags, @JsonKey(name: 'item_images') final  List<ItemImage>? itemImages, @JsonKey(name: 'worn_count') this.wornCount = 0, @JsonKey(name: 'last_worn_at') this.lastWornAt, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _colors = colors,_tags = tags,_occasionTags = occasionTags,_itemImages = itemImages;
  factory _ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override final  String? description;
@override final  Category category;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? brand;
@override final  String? size;
@override final  String? material;
@override final  String? pattern;
@override final  Condition condition;
@override final  double? price;
@override@JsonKey(name: 'purchase_date') final  DateTime? purchaseDate;
@override final  String? location;
@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _occasionTags;
@override@JsonKey(name: 'occasion_tags') List<String>? get occasionTags {
  final value = _occasionTags;
  if (value == null) return null;
  if (_occasionTags is EqualUnmodifiableListView) return _occasionTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ItemImage>? _itemImages;
@override@JsonKey(name: 'item_images') List<ItemImage>? get itemImages {
  final value = _itemImages;
  if (value == null) return null;
  if (_itemImages is EqualUnmodifiableListView) return _itemImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'worn_count') final  int wornCount;
@override@JsonKey(name: 'last_worn_at') final  DateTime? lastWornAt;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemModelCopyWith<_ItemModel> get copyWith => __$ItemModelCopyWithImpl<_ItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.price, price) || other.price == price)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._occasionTags, _occasionTags)&&const DeepCollectionEquality().equals(other._itemImages, _itemImages)&&(identical(other.wornCount, wornCount) || other.wornCount == wornCount)&&(identical(other.lastWornAt, lastWornAt) || other.lastWornAt == lastWornAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,description,category,const DeepCollectionEquality().hash(_colors),brand,size,material,pattern,condition,price,purchaseDate,location,isFavorite,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_occasionTags),const DeepCollectionEquality().hash(_itemImages),wornCount,lastWornAt,createdAt,updatedAt]);

@override
String toString() {
  return 'ItemModel(id: $id, userId: $userId, name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, isFavorite: $isFavorite, tags: $tags, occasionTags: $occasionTags, itemImages: $itemImages, wornCount: $wornCount, lastWornAt: $lastWornAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemModelCopyWith<$Res> implements $ItemModelCopyWith<$Res> {
  factory _$ItemModelCopyWith(_ItemModel value, $Res Function(_ItemModel) _then) = __$ItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String? description, Category category, List<String>? colors, String? brand, String? size, String? material, String? pattern, Condition condition, double? price,@JsonKey(name: 'purchase_date') DateTime? purchaseDate, String? location,@JsonKey(name: 'is_favorite') bool isFavorite, List<String>? tags,@JsonKey(name: 'occasion_tags') List<String>? occasionTags,@JsonKey(name: 'item_images') List<ItemImage>? itemImages,@JsonKey(name: 'worn_count') int wornCount,@JsonKey(name: 'last_worn_at') DateTime? lastWornAt,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$ItemModelCopyWithImpl<$Res>
    implements _$ItemModelCopyWith<$Res> {
  __$ItemModelCopyWithImpl(this._self, this._then);

  final _ItemModel _self;
  final $Res Function(_ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? category = null,Object? colors = freezed,Object? brand = freezed,Object? size = freezed,Object? material = freezed,Object? pattern = freezed,Object? condition = null,Object? price = freezed,Object? purchaseDate = freezed,Object? location = freezed,Object? isFavorite = null,Object? tags = freezed,Object? occasionTags = freezed,Object? itemImages = freezed,Object? wornCount = null,Object? lastWornAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as Condition,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,occasionTags: freezed == occasionTags ? _self._occasionTags : occasionTags // ignore: cast_nullable_to_non_nullable
as List<String>?,itemImages: freezed == itemImages ? _self._itemImages : itemImages // ignore: cast_nullable_to_non_nullable
as List<ItemImage>?,wornCount: null == wornCount ? _self.wornCount : wornCount // ignore: cast_nullable_to_non_nullable
as int,lastWornAt: freezed == lastWornAt ? _self.lastWornAt : lastWornAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ItemImage {

 String get id; String get url;@JsonKey(name: 'is_primary') bool get isPrimary; int? get width; int? get height; String? get blurhash;
/// Create a copy of ItemImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemImageCopyWith<ItemImage> get copyWith => _$ItemImageCopyWithImpl<ItemImage>(this as ItemImage, _$identity);

  /// Serializes this ItemImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemImage&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,isPrimary,width,height,blurhash);

@override
String toString() {
  return 'ItemImage(id: $id, url: $url, isPrimary: $isPrimary, width: $width, height: $height, blurhash: $blurhash)';
}


}

/// @nodoc
abstract mixin class $ItemImageCopyWith<$Res>  {
  factory $ItemImageCopyWith(ItemImage value, $Res Function(ItemImage) _then) = _$ItemImageCopyWithImpl;
@useResult
$Res call({
 String id, String url,@JsonKey(name: 'is_primary') bool isPrimary, int? width, int? height, String? blurhash
});




}
/// @nodoc
class _$ItemImageCopyWithImpl<$Res>
    implements $ItemImageCopyWith<$Res> {
  _$ItemImageCopyWithImpl(this._self, this._then);

  final ItemImage _self;
  final $Res Function(ItemImage) _then;

/// Create a copy of ItemImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? isPrimary = null,Object? width = freezed,Object? height = freezed,Object? blurhash = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemImage].
extension ItemImagePatterns on ItemImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemImage value)  $default,){
final _that = this;
switch (_that) {
case _ItemImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemImage value)?  $default,){
final _that = this;
switch (_that) {
case _ItemImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'is_primary')  bool isPrimary,  int? width,  int? height,  String? blurhash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemImage() when $default != null:
return $default(_that.id,_that.url,_that.isPrimary,_that.width,_that.height,_that.blurhash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url, @JsonKey(name: 'is_primary')  bool isPrimary,  int? width,  int? height,  String? blurhash)  $default,) {final _that = this;
switch (_that) {
case _ItemImage():
return $default(_that.id,_that.url,_that.isPrimary,_that.width,_that.height,_that.blurhash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url, @JsonKey(name: 'is_primary')  bool isPrimary,  int? width,  int? height,  String? blurhash)?  $default,) {final _that = this;
switch (_that) {
case _ItemImage() when $default != null:
return $default(_that.id,_that.url,_that.isPrimary,_that.width,_that.height,_that.blurhash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemImage implements ItemImage {
  const _ItemImage({required this.id, required this.url, @JsonKey(name: 'is_primary') this.isPrimary = false, this.width, this.height, this.blurhash});
  factory _ItemImage.fromJson(Map<String, dynamic> json) => _$ItemImageFromJson(json);

@override final  String id;
@override final  String url;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
@override final  int? width;
@override final  int? height;
@override final  String? blurhash;

/// Create a copy of ItemImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemImageCopyWith<_ItemImage> get copyWith => __$ItemImageCopyWithImpl<_ItemImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemImage&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,isPrimary,width,height,blurhash);

@override
String toString() {
  return 'ItemImage(id: $id, url: $url, isPrimary: $isPrimary, width: $width, height: $height, blurhash: $blurhash)';
}


}

/// @nodoc
abstract mixin class _$ItemImageCopyWith<$Res> implements $ItemImageCopyWith<$Res> {
  factory _$ItemImageCopyWith(_ItemImage value, $Res Function(_ItemImage) _then) = __$ItemImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String url,@JsonKey(name: 'is_primary') bool isPrimary, int? width, int? height, String? blurhash
});




}
/// @nodoc
class __$ItemImageCopyWithImpl<$Res>
    implements _$ItemImageCopyWith<$Res> {
  __$ItemImageCopyWithImpl(this._self, this._then);

  final _ItemImage _self;
  final $Res Function(_ItemImage) _then;

/// Create a copy of ItemImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? isPrimary = null,Object? width = freezed,Object? height = freezed,Object? blurhash = freezed,}) {
  return _then(_ItemImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateItemRequest {

 String get name; String? get description; Category get category; List<String>? get colors; String? get brand; String? get size; String? get material; String? get pattern; Condition get condition; double? get price;@JsonKey(name: 'purchase_date') DateTime? get purchaseDate; String? get location; List<String>? get tags;@JsonKey(name: 'occasion_tags') List<String>? get occasionTags;
/// Create a copy of CreateItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateItemRequestCopyWith<CreateItemRequest> get copyWith => _$CreateItemRequestCopyWithImpl<CreateItemRequest>(this as CreateItemRequest, _$identity);

  /// Serializes this CreateItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateItemRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.price, price) || other.price == price)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.occasionTags, occasionTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,category,const DeepCollectionEquality().hash(colors),brand,size,material,pattern,condition,price,purchaseDate,location,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(occasionTags));

@override
String toString() {
  return 'CreateItemRequest(name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, tags: $tags, occasionTags: $occasionTags)';
}


}

/// @nodoc
abstract mixin class $CreateItemRequestCopyWith<$Res>  {
  factory $CreateItemRequestCopyWith(CreateItemRequest value, $Res Function(CreateItemRequest) _then) = _$CreateItemRequestCopyWithImpl;
@useResult
$Res call({
 String name, String? description, Category category, List<String>? colors, String? brand, String? size, String? material, String? pattern, Condition condition, double? price,@JsonKey(name: 'purchase_date') DateTime? purchaseDate, String? location, List<String>? tags,@JsonKey(name: 'occasion_tags') List<String>? occasionTags
});




}
/// @nodoc
class _$CreateItemRequestCopyWithImpl<$Res>
    implements $CreateItemRequestCopyWith<$Res> {
  _$CreateItemRequestCopyWithImpl(this._self, this._then);

  final CreateItemRequest _self;
  final $Res Function(CreateItemRequest) _then;

/// Create a copy of CreateItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? category = null,Object? colors = freezed,Object? brand = freezed,Object? size = freezed,Object? material = freezed,Object? pattern = freezed,Object? condition = null,Object? price = freezed,Object? purchaseDate = freezed,Object? location = freezed,Object? tags = freezed,Object? occasionTags = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as Condition,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,occasionTags: freezed == occasionTags ? _self.occasionTags : occasionTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateItemRequest].
extension CreateItemRequestPatterns on CreateItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  Category category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition condition,  double? price, @JsonKey(name: 'purchase_date')  DateTime? purchaseDate,  String? location,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateItemRequest() when $default != null:
return $default(_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.tags,_that.occasionTags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  Category category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition condition,  double? price, @JsonKey(name: 'purchase_date')  DateTime? purchaseDate,  String? location,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags)  $default,) {final _that = this;
switch (_that) {
case _CreateItemRequest():
return $default(_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.tags,_that.occasionTags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  Category category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition condition,  double? price, @JsonKey(name: 'purchase_date')  DateTime? purchaseDate,  String? location,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags)?  $default,) {final _that = this;
switch (_that) {
case _CreateItemRequest() when $default != null:
return $default(_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.tags,_that.occasionTags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateItemRequest implements CreateItemRequest {
  const _CreateItemRequest({required this.name, this.description, required this.category, final  List<String>? colors, this.brand, this.size, this.material, this.pattern, this.condition = Condition.clean, this.price, @JsonKey(name: 'purchase_date') this.purchaseDate, this.location, final  List<String>? tags, @JsonKey(name: 'occasion_tags') final  List<String>? occasionTags}): _colors = colors,_tags = tags,_occasionTags = occasionTags;
  factory _CreateItemRequest.fromJson(Map<String, dynamic> json) => _$CreateItemRequestFromJson(json);

@override final  String name;
@override final  String? description;
@override final  Category category;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? brand;
@override final  String? size;
@override final  String? material;
@override final  String? pattern;
@override@JsonKey() final  Condition condition;
@override final  double? price;
@override@JsonKey(name: 'purchase_date') final  DateTime? purchaseDate;
@override final  String? location;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _occasionTags;
@override@JsonKey(name: 'occasion_tags') List<String>? get occasionTags {
  final value = _occasionTags;
  if (value == null) return null;
  if (_occasionTags is EqualUnmodifiableListView) return _occasionTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateItemRequestCopyWith<_CreateItemRequest> get copyWith => __$CreateItemRequestCopyWithImpl<_CreateItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateItemRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.price, price) || other.price == price)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._occasionTags, _occasionTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,category,const DeepCollectionEquality().hash(_colors),brand,size,material,pattern,condition,price,purchaseDate,location,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_occasionTags));

@override
String toString() {
  return 'CreateItemRequest(name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, tags: $tags, occasionTags: $occasionTags)';
}


}

/// @nodoc
abstract mixin class _$CreateItemRequestCopyWith<$Res> implements $CreateItemRequestCopyWith<$Res> {
  factory _$CreateItemRequestCopyWith(_CreateItemRequest value, $Res Function(_CreateItemRequest) _then) = __$CreateItemRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, Category category, List<String>? colors, String? brand, String? size, String? material, String? pattern, Condition condition, double? price,@JsonKey(name: 'purchase_date') DateTime? purchaseDate, String? location, List<String>? tags,@JsonKey(name: 'occasion_tags') List<String>? occasionTags
});




}
/// @nodoc
class __$CreateItemRequestCopyWithImpl<$Res>
    implements _$CreateItemRequestCopyWith<$Res> {
  __$CreateItemRequestCopyWithImpl(this._self, this._then);

  final _CreateItemRequest _self;
  final $Res Function(_CreateItemRequest) _then;

/// Create a copy of CreateItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? category = null,Object? colors = freezed,Object? brand = freezed,Object? size = freezed,Object? material = freezed,Object? pattern = freezed,Object? condition = null,Object? price = freezed,Object? purchaseDate = freezed,Object? location = freezed,Object? tags = freezed,Object? occasionTags = freezed,}) {
  return _then(_CreateItemRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as Condition,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,occasionTags: freezed == occasionTags ? _self._occasionTags : occasionTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$UpdateItemRequest {

 String? get name; String? get description; Category? get category; List<String>? get colors; String? get brand; String? get size; String? get material; String? get pattern; Condition? get condition; double? get price; DateTime? get purchaseDate; String? get location; List<String>? get tags;@JsonKey(name: 'occasion_tags') List<String>? get occasionTags;
/// Create a copy of UpdateItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateItemRequestCopyWith<UpdateItemRequest> get copyWith => _$UpdateItemRequestCopyWithImpl<UpdateItemRequest>(this as UpdateItemRequest, _$identity);

  /// Serializes this UpdateItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateItemRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.price, price) || other.price == price)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.occasionTags, occasionTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,category,const DeepCollectionEquality().hash(colors),brand,size,material,pattern,condition,price,purchaseDate,location,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(occasionTags));

@override
String toString() {
  return 'UpdateItemRequest(name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, tags: $tags, occasionTags: $occasionTags)';
}


}

/// @nodoc
abstract mixin class $UpdateItemRequestCopyWith<$Res>  {
  factory $UpdateItemRequestCopyWith(UpdateItemRequest value, $Res Function(UpdateItemRequest) _then) = _$UpdateItemRequestCopyWithImpl;
@useResult
$Res call({
 String? name, String? description, Category? category, List<String>? colors, String? brand, String? size, String? material, String? pattern, Condition? condition, double? price, DateTime? purchaseDate, String? location, List<String>? tags,@JsonKey(name: 'occasion_tags') List<String>? occasionTags
});




}
/// @nodoc
class _$UpdateItemRequestCopyWithImpl<$Res>
    implements $UpdateItemRequestCopyWith<$Res> {
  _$UpdateItemRequestCopyWithImpl(this._self, this._then);

  final UpdateItemRequest _self;
  final $Res Function(UpdateItemRequest) _then;

/// Create a copy of UpdateItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? description = freezed,Object? category = freezed,Object? colors = freezed,Object? brand = freezed,Object? size = freezed,Object? material = freezed,Object? pattern = freezed,Object? condition = freezed,Object? price = freezed,Object? purchaseDate = freezed,Object? location = freezed,Object? tags = freezed,Object? occasionTags = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as Condition?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,occasionTags: freezed == occasionTags ? _self.occasionTags : occasionTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateItemRequest].
extension UpdateItemRequestPatterns on UpdateItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? description,  Category? category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition? condition,  double? price,  DateTime? purchaseDate,  String? location,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateItemRequest() when $default != null:
return $default(_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.tags,_that.occasionTags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? description,  Category? category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition? condition,  double? price,  DateTime? purchaseDate,  String? location,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags)  $default,) {final _that = this;
switch (_that) {
case _UpdateItemRequest():
return $default(_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.tags,_that.occasionTags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? description,  Category? category,  List<String>? colors,  String? brand,  String? size,  String? material,  String? pattern,  Condition? condition,  double? price,  DateTime? purchaseDate,  String? location,  List<String>? tags, @JsonKey(name: 'occasion_tags')  List<String>? occasionTags)?  $default,) {final _that = this;
switch (_that) {
case _UpdateItemRequest() when $default != null:
return $default(_that.name,_that.description,_that.category,_that.colors,_that.brand,_that.size,_that.material,_that.pattern,_that.condition,_that.price,_that.purchaseDate,_that.location,_that.tags,_that.occasionTags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateItemRequest implements UpdateItemRequest {
  const _UpdateItemRequest({this.name, this.description, this.category, final  List<String>? colors, this.brand, this.size, this.material, this.pattern, this.condition, this.price, this.purchaseDate, this.location, final  List<String>? tags, @JsonKey(name: 'occasion_tags') final  List<String>? occasionTags}): _colors = colors,_tags = tags,_occasionTags = occasionTags;
  factory _UpdateItemRequest.fromJson(Map<String, dynamic> json) => _$UpdateItemRequestFromJson(json);

@override final  String? name;
@override final  String? description;
@override final  Category? category;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? brand;
@override final  String? size;
@override final  String? material;
@override final  String? pattern;
@override final  Condition? condition;
@override final  double? price;
@override final  DateTime? purchaseDate;
@override final  String? location;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _occasionTags;
@override@JsonKey(name: 'occasion_tags') List<String>? get occasionTags {
  final value = _occasionTags;
  if (value == null) return null;
  if (_occasionTags is EqualUnmodifiableListView) return _occasionTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateItemRequestCopyWith<_UpdateItemRequest> get copyWith => __$UpdateItemRequestCopyWithImpl<_UpdateItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateItemRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.size, size) || other.size == size)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.price, price) || other.price == price)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._occasionTags, _occasionTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,category,const DeepCollectionEquality().hash(_colors),brand,size,material,pattern,condition,price,purchaseDate,location,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_occasionTags));

@override
String toString() {
  return 'UpdateItemRequest(name: $name, description: $description, category: $category, colors: $colors, brand: $brand, size: $size, material: $material, pattern: $pattern, condition: $condition, price: $price, purchaseDate: $purchaseDate, location: $location, tags: $tags, occasionTags: $occasionTags)';
}


}

/// @nodoc
abstract mixin class _$UpdateItemRequestCopyWith<$Res> implements $UpdateItemRequestCopyWith<$Res> {
  factory _$UpdateItemRequestCopyWith(_UpdateItemRequest value, $Res Function(_UpdateItemRequest) _then) = __$UpdateItemRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? description, Category? category, List<String>? colors, String? brand, String? size, String? material, String? pattern, Condition? condition, double? price, DateTime? purchaseDate, String? location, List<String>? tags,@JsonKey(name: 'occasion_tags') List<String>? occasionTags
});




}
/// @nodoc
class __$UpdateItemRequestCopyWithImpl<$Res>
    implements _$UpdateItemRequestCopyWith<$Res> {
  __$UpdateItemRequestCopyWithImpl(this._self, this._then);

  final _UpdateItemRequest _self;
  final $Res Function(_UpdateItemRequest) _then;

/// Create a copy of UpdateItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? description = freezed,Object? category = freezed,Object? colors = freezed,Object? brand = freezed,Object? size = freezed,Object? material = freezed,Object? pattern = freezed,Object? condition = freezed,Object? price = freezed,Object? purchaseDate = freezed,Object? location = freezed,Object? tags = freezed,Object? occasionTags = freezed,}) {
  return _then(_UpdateItemRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as Condition?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,occasionTags: freezed == occasionTags ? _self._occasionTags : occasionTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$ItemsListResponse {

 List<ItemModel> get items; int get total; int get page; int get limit;@JsonKey(name: 'has_more') bool get hasMore;
/// Create a copy of ItemsListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemsListResponseCopyWith<ItemsListResponse> get copyWith => _$ItemsListResponseCopyWithImpl<ItemsListResponse>(this as ItemsListResponse, _$identity);

  /// Serializes this ItemsListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemsListResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,limit,hasMore);

@override
String toString() {
  return 'ItemsListResponse(items: $items, total: $total, page: $page, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $ItemsListResponseCopyWith<$Res>  {
  factory $ItemsListResponseCopyWith(ItemsListResponse value, $Res Function(ItemsListResponse) _then) = _$ItemsListResponseCopyWithImpl;
@useResult
$Res call({
 List<ItemModel> items, int total, int page, int limit,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class _$ItemsListResponseCopyWithImpl<$Res>
    implements $ItemsListResponseCopyWith<$Res> {
  _$ItemsListResponseCopyWithImpl(this._self, this._then);

  final ItemsListResponse _self;
  final $Res Function(ItemsListResponse) _then;

/// Create a copy of ItemsListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ItemModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemsListResponse].
extension ItemsListResponsePatterns on ItemsListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemsListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemsListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemsListResponse value)  $default,){
final _that = this;
switch (_that) {
case _ItemsListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemsListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ItemsListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ItemModel> items,  int total,  int page,  int limit, @JsonKey(name: 'has_more')  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemsListResponse() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ItemModel> items,  int total,  int page,  int limit, @JsonKey(name: 'has_more')  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _ItemsListResponse():
return $default(_that.items,_that.total,_that.page,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ItemModel> items,  int total,  int page,  int limit, @JsonKey(name: 'has_more')  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _ItemsListResponse() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemsListResponse implements ItemsListResponse {
  const _ItemsListResponse({required final  List<ItemModel> items, required this.total, required this.page, required this.limit, @JsonKey(name: 'has_more') required this.hasMore}): _items = items;
  factory _ItemsListResponse.fromJson(Map<String, dynamic> json) => _$ItemsListResponseFromJson(json);

 final  List<ItemModel> _items;
@override List<ItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int limit;
@override@JsonKey(name: 'has_more') final  bool hasMore;

/// Create a copy of ItemsListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemsListResponseCopyWith<_ItemsListResponse> get copyWith => __$ItemsListResponseCopyWithImpl<_ItemsListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemsListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemsListResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,limit,hasMore);

@override
String toString() {
  return 'ItemsListResponse(items: $items, total: $total, page: $page, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$ItemsListResponseCopyWith<$Res> implements $ItemsListResponseCopyWith<$Res> {
  factory _$ItemsListResponseCopyWith(_ItemsListResponse value, $Res Function(_ItemsListResponse) _then) = __$ItemsListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<ItemModel> items, int total, int page, int limit,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class __$ItemsListResponseCopyWithImpl<$Res>
    implements _$ItemsListResponseCopyWith<$Res> {
  __$ItemsListResponseCopyWithImpl(this._self, this._then);

  final _ItemsListResponse _self;
  final $Res Function(_ItemsListResponse) _then;

/// Create a copy of ItemsListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,Object? hasMore = null,}) {
  return _then(_ItemsListResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ItemModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ExtractedItem {

 String get name; Category get category; List<String>? get colors; String? get material; String? get pattern; String? get description;@JsonKey(name: 'bounding_box') Map<String, dynamic>? get boundingBox;
/// Create a copy of ExtractedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedItemCopyWith<ExtractedItem> get copyWith => _$ExtractedItemCopyWithImpl<ExtractedItem>(this as ExtractedItem, _$identity);

  /// Serializes this ExtractedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedItem&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.boundingBox, boundingBox));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,const DeepCollectionEquality().hash(colors),material,pattern,description,const DeepCollectionEquality().hash(boundingBox));

@override
String toString() {
  return 'ExtractedItem(name: $name, category: $category, colors: $colors, material: $material, pattern: $pattern, description: $description, boundingBox: $boundingBox)';
}


}

/// @nodoc
abstract mixin class $ExtractedItemCopyWith<$Res>  {
  factory $ExtractedItemCopyWith(ExtractedItem value, $Res Function(ExtractedItem) _then) = _$ExtractedItemCopyWithImpl;
@useResult
$Res call({
 String name, Category category, List<String>? colors, String? material, String? pattern, String? description,@JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox
});




}
/// @nodoc
class _$ExtractedItemCopyWithImpl<$Res>
    implements $ExtractedItemCopyWith<$Res> {
  _$ExtractedItemCopyWithImpl(this._self, this._then);

  final ExtractedItem _self;
  final $Res Function(ExtractedItem) _then;

/// Create a copy of ExtractedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? category = null,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? description = freezed,Object? boundingBox = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,boundingBox: freezed == boundingBox ? _self.boundingBox : boundingBox // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractedItem].
extension ExtractedItemPatterns on ExtractedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractedItem value)  $default,){
final _that = this;
switch (_that) {
case _ExtractedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractedItem value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Category category,  List<String>? colors,  String? material,  String? pattern,  String? description, @JsonKey(name: 'bounding_box')  Map<String, dynamic>? boundingBox)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractedItem() when $default != null:
return $default(_that.name,_that.category,_that.colors,_that.material,_that.pattern,_that.description,_that.boundingBox);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Category category,  List<String>? colors,  String? material,  String? pattern,  String? description, @JsonKey(name: 'bounding_box')  Map<String, dynamic>? boundingBox)  $default,) {final _that = this;
switch (_that) {
case _ExtractedItem():
return $default(_that.name,_that.category,_that.colors,_that.material,_that.pattern,_that.description,_that.boundingBox);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Category category,  List<String>? colors,  String? material,  String? pattern,  String? description, @JsonKey(name: 'bounding_box')  Map<String, dynamic>? boundingBox)?  $default,) {final _that = this;
switch (_that) {
case _ExtractedItem() when $default != null:
return $default(_that.name,_that.category,_that.colors,_that.material,_that.pattern,_that.description,_that.boundingBox);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExtractedItem implements ExtractedItem {
  const _ExtractedItem({required this.name, required this.category, final  List<String>? colors, this.material, this.pattern, this.description, @JsonKey(name: 'bounding_box') final  Map<String, dynamic>? boundingBox}): _colors = colors,_boundingBox = boundingBox;
  factory _ExtractedItem.fromJson(Map<String, dynamic> json) => _$ExtractedItemFromJson(json);

@override final  String name;
@override final  Category category;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? material;
@override final  String? pattern;
@override final  String? description;
 final  Map<String, dynamic>? _boundingBox;
@override@JsonKey(name: 'bounding_box') Map<String, dynamic>? get boundingBox {
  final value = _boundingBox;
  if (value == null) return null;
  if (_boundingBox is EqualUnmodifiableMapView) return _boundingBox;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ExtractedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractedItemCopyWith<_ExtractedItem> get copyWith => __$ExtractedItemCopyWithImpl<_ExtractedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExtractedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractedItem&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._boundingBox, _boundingBox));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,const DeepCollectionEquality().hash(_colors),material,pattern,description,const DeepCollectionEquality().hash(_boundingBox));

@override
String toString() {
  return 'ExtractedItem(name: $name, category: $category, colors: $colors, material: $material, pattern: $pattern, description: $description, boundingBox: $boundingBox)';
}


}

/// @nodoc
abstract mixin class _$ExtractedItemCopyWith<$Res> implements $ExtractedItemCopyWith<$Res> {
  factory _$ExtractedItemCopyWith(_ExtractedItem value, $Res Function(_ExtractedItem) _then) = __$ExtractedItemCopyWithImpl;
@override @useResult
$Res call({
 String name, Category category, List<String>? colors, String? material, String? pattern, String? description,@JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox
});




}
/// @nodoc
class __$ExtractedItemCopyWithImpl<$Res>
    implements _$ExtractedItemCopyWith<$Res> {
  __$ExtractedItemCopyWithImpl(this._self, this._then);

  final _ExtractedItem _self;
  final $Res Function(_ExtractedItem) _then;

/// Create a copy of ExtractedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? category = null,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? description = freezed,Object? boundingBox = freezed,}) {
  return _then(_ExtractedItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,boundingBox: freezed == boundingBox ? _self._boundingBox : boundingBox // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ExtractionResponse {

 String get id; String get status; List<ExtractedItem>? get items; String? get imageUrl; String? get error;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of ExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractionResponseCopyWith<ExtractionResponse> get copyWith => _$ExtractionResponseCopyWithImpl<ExtractionResponse>(this as ExtractionResponse, _$identity);

  /// Serializes this ExtractionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,const DeepCollectionEquality().hash(items),imageUrl,error,createdAt);

@override
String toString() {
  return 'ExtractionResponse(id: $id, status: $status, items: $items, imageUrl: $imageUrl, error: $error, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExtractionResponseCopyWith<$Res>  {
  factory $ExtractionResponseCopyWith(ExtractionResponse value, $Res Function(ExtractionResponse) _then) = _$ExtractionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String status, List<ExtractedItem>? items, String? imageUrl, String? error,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$ExtractionResponseCopyWithImpl<$Res>
    implements $ExtractionResponseCopyWith<$Res> {
  _$ExtractionResponseCopyWithImpl(this._self, this._then);

  final ExtractionResponse _self;
  final $Res Function(ExtractionResponse) _then;

/// Create a copy of ExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? items = freezed,Object? imageUrl = freezed,Object? error = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ExtractedItem>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractionResponse].
extension ExtractionResponsePatterns on ExtractionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractionResponse value)  $default,){
final _that = this;
switch (_that) {
case _ExtractionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  List<ExtractedItem>? items,  String? imageUrl,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractionResponse() when $default != null:
return $default(_that.id,_that.status,_that.items,_that.imageUrl,_that.error,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  List<ExtractedItem>? items,  String? imageUrl,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ExtractionResponse():
return $default(_that.id,_that.status,_that.items,_that.imageUrl,_that.error,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  List<ExtractedItem>? items,  String? imageUrl,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ExtractionResponse() when $default != null:
return $default(_that.id,_that.status,_that.items,_that.imageUrl,_that.error,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExtractionResponse implements ExtractionResponse {
  const _ExtractionResponse({required this.id, required this.status, final  List<ExtractedItem>? items, this.imageUrl, this.error, @JsonKey(name: 'created_at') this.createdAt}): _items = items;
  factory _ExtractionResponse.fromJson(Map<String, dynamic> json) => _$ExtractionResponseFromJson(json);

@override final  String id;
@override final  String status;
 final  List<ExtractedItem>? _items;
@override List<ExtractedItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? imageUrl;
@override final  String? error;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of ExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractionResponseCopyWith<_ExtractionResponse> get copyWith => __$ExtractionResponseCopyWithImpl<_ExtractionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExtractionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,const DeepCollectionEquality().hash(_items),imageUrl,error,createdAt);

@override
String toString() {
  return 'ExtractionResponse(id: $id, status: $status, items: $items, imageUrl: $imageUrl, error: $error, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExtractionResponseCopyWith<$Res> implements $ExtractionResponseCopyWith<$Res> {
  factory _$ExtractionResponseCopyWith(_ExtractionResponse value, $Res Function(_ExtractionResponse) _then) = __$ExtractionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, List<ExtractedItem>? items, String? imageUrl, String? error,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$ExtractionResponseCopyWithImpl<$Res>
    implements _$ExtractionResponseCopyWith<$Res> {
  __$ExtractionResponseCopyWithImpl(this._self, this._then);

  final _ExtractionResponse _self;
  final $Res Function(_ExtractionResponse) _then;

/// Create a copy of ExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? items = freezed,Object? imageUrl = freezed,Object? error = freezed,Object? createdAt = freezed,}) {
  return _then(_ExtractionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ExtractedItem>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BoundingBox {

 double get x; double get y; double get width; double get height;
/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoundingBoxCopyWith<BoundingBox> get copyWith => _$BoundingBoxCopyWithImpl<BoundingBox>(this as BoundingBox, _$identity);

  /// Serializes this BoundingBox to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoundingBox&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,width,height);

@override
String toString() {
  return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $BoundingBoxCopyWith<$Res>  {
  factory $BoundingBoxCopyWith(BoundingBox value, $Res Function(BoundingBox) _then) = _$BoundingBoxCopyWithImpl;
@useResult
$Res call({
 double x, double y, double width, double height
});




}
/// @nodoc
class _$BoundingBoxCopyWithImpl<$Res>
    implements $BoundingBoxCopyWith<$Res> {
  _$BoundingBoxCopyWithImpl(this._self, this._then);

  final BoundingBox _self;
  final $Res Function(BoundingBox) _then;

/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,Object? width = null,Object? height = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BoundingBox].
extension BoundingBoxPatterns on BoundingBox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoundingBox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoundingBox() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoundingBox value)  $default,){
final _that = this;
switch (_that) {
case _BoundingBox():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoundingBox value)?  $default,){
final _that = this;
switch (_that) {
case _BoundingBox() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y,  double width,  double height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoundingBox() when $default != null:
return $default(_that.x,_that.y,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y,  double width,  double height)  $default,) {final _that = this;
switch (_that) {
case _BoundingBox():
return $default(_that.x,_that.y,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y,  double width,  double height)?  $default,) {final _that = this;
switch (_that) {
case _BoundingBox() when $default != null:
return $default(_that.x,_that.y,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BoundingBox implements BoundingBox {
  const _BoundingBox({required this.x, required this.y, required this.width, required this.height});
  factory _BoundingBox.fromJson(Map<String, dynamic> json) => _$BoundingBoxFromJson(json);

@override final  double x;
@override final  double y;
@override final  double width;
@override final  double height;

/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoundingBoxCopyWith<_BoundingBox> get copyWith => __$BoundingBoxCopyWithImpl<_BoundingBox>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoundingBoxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoundingBox&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,width,height);

@override
String toString() {
  return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$BoundingBoxCopyWith<$Res> implements $BoundingBoxCopyWith<$Res> {
  factory _$BoundingBoxCopyWith(_BoundingBox value, $Res Function(_BoundingBox) _then) = __$BoundingBoxCopyWithImpl;
@override @useResult
$Res call({
 double x, double y, double width, double height
});




}
/// @nodoc
class __$BoundingBoxCopyWithImpl<$Res>
    implements _$BoundingBoxCopyWith<$Res> {
  __$BoundingBoxCopyWithImpl(this._self, this._then);

  final _BoundingBox _self;
  final $Res Function(_BoundingBox) _then;

/// Create a copy of BoundingBox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,Object? width = null,Object? height = null,}) {
  return _then(_BoundingBox(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$DetectedItemData {

 String get tempId; String get category;@JsonKey(name: 'sub_category') String? get subCategory; List<String>? get colors; String? get material; String? get pattern; String? get brand; double get confidence;@JsonKey(name: 'detailed_description') String? get detailedDescription;@JsonKey(name: 'person_id') String? get personId;@JsonKey(name: 'person_label') String? get personLabel;@JsonKey(name: 'is_current_user_person') bool get isCurrentUserPerson;@JsonKey(name: 'include_in_wardrobe') bool get includeInWardrobe; String get status;
/// Create a copy of DetectedItemData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetectedItemDataCopyWith<DetectedItemData> get copyWith => _$DetectedItemDataCopyWithImpl<DetectedItemData>(this as DetectedItemData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetectedItemData&&(identical(other.tempId, tempId) || other.tempId == tempId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.detailedDescription, detailedDescription) || other.detailedDescription == detailedDescription)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personLabel, personLabel) || other.personLabel == personLabel)&&(identical(other.isCurrentUserPerson, isCurrentUserPerson) || other.isCurrentUserPerson == isCurrentUserPerson)&&(identical(other.includeInWardrobe, includeInWardrobe) || other.includeInWardrobe == includeInWardrobe)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,tempId,category,subCategory,const DeepCollectionEquality().hash(colors),material,pattern,brand,confidence,detailedDescription,personId,personLabel,isCurrentUserPerson,includeInWardrobe,status);

@override
String toString() {
  return 'DetectedItemData(tempId: $tempId, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, brand: $brand, confidence: $confidence, detailedDescription: $detailedDescription, personId: $personId, personLabel: $personLabel, isCurrentUserPerson: $isCurrentUserPerson, includeInWardrobe: $includeInWardrobe, status: $status)';
}


}

/// @nodoc
abstract mixin class $DetectedItemDataCopyWith<$Res>  {
  factory $DetectedItemDataCopyWith(DetectedItemData value, $Res Function(DetectedItemData) _then) = _$DetectedItemDataCopyWithImpl;
@useResult
$Res call({
 String tempId, String category,@JsonKey(name: 'sub_category') String? subCategory, List<String>? colors, String? material, String? pattern, String? brand, double confidence,@JsonKey(name: 'detailed_description') String? detailedDescription,@JsonKey(name: 'person_id') String? personId,@JsonKey(name: 'person_label') String? personLabel,@JsonKey(name: 'is_current_user_person') bool isCurrentUserPerson,@JsonKey(name: 'include_in_wardrobe') bool includeInWardrobe, String status
});




}
/// @nodoc
class _$DetectedItemDataCopyWithImpl<$Res>
    implements $DetectedItemDataCopyWith<$Res> {
  _$DetectedItemDataCopyWithImpl(this._self, this._then);

  final DetectedItemData _self;
  final $Res Function(DetectedItemData) _then;

/// Create a copy of DetectedItemData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tempId = null,Object? category = null,Object? subCategory = freezed,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? brand = freezed,Object? confidence = null,Object? detailedDescription = freezed,Object? personId = freezed,Object? personLabel = freezed,Object? isCurrentUserPerson = null,Object? includeInWardrobe = null,Object? status = null,}) {
  return _then(_self.copyWith(
tempId: null == tempId ? _self.tempId : tempId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,detailedDescription: freezed == detailedDescription ? _self.detailedDescription : detailedDescription // ignore: cast_nullable_to_non_nullable
as String?,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personLabel: freezed == personLabel ? _self.personLabel : personLabel // ignore: cast_nullable_to_non_nullable
as String?,isCurrentUserPerson: null == isCurrentUserPerson ? _self.isCurrentUserPerson : isCurrentUserPerson // ignore: cast_nullable_to_non_nullable
as bool,includeInWardrobe: null == includeInWardrobe ? _self.includeInWardrobe : includeInWardrobe // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DetectedItemData].
extension DetectedItemDataPatterns on DetectedItemData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetectedItemData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetectedItemData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetectedItemData value)  $default,){
final _that = this;
switch (_that) {
case _DetectedItemData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetectedItemData value)?  $default,){
final _that = this;
switch (_that) {
case _DetectedItemData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tempId,  String category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String? brand,  double confidence, @JsonKey(name: 'detailed_description')  String? detailedDescription, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetectedItemData() when $default != null:
return $default(_that.tempId,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.confidence,_that.detailedDescription,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tempId,  String category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String? brand,  double confidence, @JsonKey(name: 'detailed_description')  String? detailedDescription, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe,  String status)  $default,) {final _that = this;
switch (_that) {
case _DetectedItemData():
return $default(_that.tempId,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.confidence,_that.detailedDescription,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tempId,  String category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String? brand,  double confidence, @JsonKey(name: 'detailed_description')  String? detailedDescription, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe,  String status)?  $default,) {final _that = this;
switch (_that) {
case _DetectedItemData() when $default != null:
return $default(_that.tempId,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.confidence,_that.detailedDescription,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _DetectedItemData implements DetectedItemData {
  const _DetectedItemData({required this.tempId, required this.category, @JsonKey(name: 'sub_category') this.subCategory, final  List<String>? colors, this.material, this.pattern, this.brand, required this.confidence, @JsonKey(name: 'detailed_description') this.detailedDescription, @JsonKey(name: 'person_id') this.personId, @JsonKey(name: 'person_label') this.personLabel, @JsonKey(name: 'is_current_user_person') this.isCurrentUserPerson = false, @JsonKey(name: 'include_in_wardrobe') this.includeInWardrobe = true, this.status = 'detected'}): _colors = colors;
  

@override final  String tempId;
@override final  String category;
@override@JsonKey(name: 'sub_category') final  String? subCategory;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? material;
@override final  String? pattern;
@override final  String? brand;
@override final  double confidence;
@override@JsonKey(name: 'detailed_description') final  String? detailedDescription;
@override@JsonKey(name: 'person_id') final  String? personId;
@override@JsonKey(name: 'person_label') final  String? personLabel;
@override@JsonKey(name: 'is_current_user_person') final  bool isCurrentUserPerson;
@override@JsonKey(name: 'include_in_wardrobe') final  bool includeInWardrobe;
@override@JsonKey() final  String status;

/// Create a copy of DetectedItemData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetectedItemDataCopyWith<_DetectedItemData> get copyWith => __$DetectedItemDataCopyWithImpl<_DetectedItemData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetectedItemData&&(identical(other.tempId, tempId) || other.tempId == tempId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.detailedDescription, detailedDescription) || other.detailedDescription == detailedDescription)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personLabel, personLabel) || other.personLabel == personLabel)&&(identical(other.isCurrentUserPerson, isCurrentUserPerson) || other.isCurrentUserPerson == isCurrentUserPerson)&&(identical(other.includeInWardrobe, includeInWardrobe) || other.includeInWardrobe == includeInWardrobe)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,tempId,category,subCategory,const DeepCollectionEquality().hash(_colors),material,pattern,brand,confidence,detailedDescription,personId,personLabel,isCurrentUserPerson,includeInWardrobe,status);

@override
String toString() {
  return 'DetectedItemData(tempId: $tempId, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, brand: $brand, confidence: $confidence, detailedDescription: $detailedDescription, personId: $personId, personLabel: $personLabel, isCurrentUserPerson: $isCurrentUserPerson, includeInWardrobe: $includeInWardrobe, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DetectedItemDataCopyWith<$Res> implements $DetectedItemDataCopyWith<$Res> {
  factory _$DetectedItemDataCopyWith(_DetectedItemData value, $Res Function(_DetectedItemData) _then) = __$DetectedItemDataCopyWithImpl;
@override @useResult
$Res call({
 String tempId, String category,@JsonKey(name: 'sub_category') String? subCategory, List<String>? colors, String? material, String? pattern, String? brand, double confidence,@JsonKey(name: 'detailed_description') String? detailedDescription,@JsonKey(name: 'person_id') String? personId,@JsonKey(name: 'person_label') String? personLabel,@JsonKey(name: 'is_current_user_person') bool isCurrentUserPerson,@JsonKey(name: 'include_in_wardrobe') bool includeInWardrobe, String status
});




}
/// @nodoc
class __$DetectedItemDataCopyWithImpl<$Res>
    implements _$DetectedItemDataCopyWith<$Res> {
  __$DetectedItemDataCopyWithImpl(this._self, this._then);

  final _DetectedItemData _self;
  final $Res Function(_DetectedItemData) _then;

/// Create a copy of DetectedItemData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tempId = null,Object? category = null,Object? subCategory = freezed,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? brand = freezed,Object? confidence = null,Object? detailedDescription = freezed,Object? personId = freezed,Object? personLabel = freezed,Object? isCurrentUserPerson = null,Object? includeInWardrobe = null,Object? status = null,}) {
  return _then(_DetectedItemData(
tempId: null == tempId ? _self.tempId : tempId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,detailedDescription: freezed == detailedDescription ? _self.detailedDescription : detailedDescription // ignore: cast_nullable_to_non_nullable
as String?,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personLabel: freezed == personLabel ? _self.personLabel : personLabel // ignore: cast_nullable_to_non_nullable
as String?,isCurrentUserPerson: null == isCurrentUserPerson ? _self.isCurrentUserPerson : isCurrentUserPerson // ignore: cast_nullable_to_non_nullable
as bool,includeInWardrobe: null == includeInWardrobe ? _self.includeInWardrobe : includeInWardrobe // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SyncExtractionResponse {

 List<DetectedItemData> get items;@JsonKey(name: 'overall_confidence') double get overallConfidence;@JsonKey(name: 'image_description') String? get imageDescription;@JsonKey(name: 'item_count') int get itemCount;@JsonKey(name: 'requires_review') bool get requiresReview;@JsonKey(name: 'has_profile_reference') bool get hasProfileReference;@JsonKey(name: 'profile_match_found') bool get profileMatchFound;
/// Create a copy of SyncExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncExtractionResponseCopyWith<SyncExtractionResponse> get copyWith => _$SyncExtractionResponseCopyWithImpl<SyncExtractionResponse>(this as SyncExtractionResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncExtractionResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.overallConfidence, overallConfidence) || other.overallConfidence == overallConfidence)&&(identical(other.imageDescription, imageDescription) || other.imageDescription == imageDescription)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.requiresReview, requiresReview) || other.requiresReview == requiresReview)&&(identical(other.hasProfileReference, hasProfileReference) || other.hasProfileReference == hasProfileReference)&&(identical(other.profileMatchFound, profileMatchFound) || other.profileMatchFound == profileMatchFound));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),overallConfidence,imageDescription,itemCount,requiresReview,hasProfileReference,profileMatchFound);

@override
String toString() {
  return 'SyncExtractionResponse(items: $items, overallConfidence: $overallConfidence, imageDescription: $imageDescription, itemCount: $itemCount, requiresReview: $requiresReview, hasProfileReference: $hasProfileReference, profileMatchFound: $profileMatchFound)';
}


}

/// @nodoc
abstract mixin class $SyncExtractionResponseCopyWith<$Res>  {
  factory $SyncExtractionResponseCopyWith(SyncExtractionResponse value, $Res Function(SyncExtractionResponse) _then) = _$SyncExtractionResponseCopyWithImpl;
@useResult
$Res call({
 List<DetectedItemData> items,@JsonKey(name: 'overall_confidence') double overallConfidence,@JsonKey(name: 'image_description') String? imageDescription,@JsonKey(name: 'item_count') int itemCount,@JsonKey(name: 'requires_review') bool requiresReview,@JsonKey(name: 'has_profile_reference') bool hasProfileReference,@JsonKey(name: 'profile_match_found') bool profileMatchFound
});




}
/// @nodoc
class _$SyncExtractionResponseCopyWithImpl<$Res>
    implements $SyncExtractionResponseCopyWith<$Res> {
  _$SyncExtractionResponseCopyWithImpl(this._self, this._then);

  final SyncExtractionResponse _self;
  final $Res Function(SyncExtractionResponse) _then;

/// Create a copy of SyncExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? overallConfidence = null,Object? imageDescription = freezed,Object? itemCount = null,Object? requiresReview = null,Object? hasProfileReference = null,Object? profileMatchFound = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<DetectedItemData>,overallConfidence: null == overallConfidence ? _self.overallConfidence : overallConfidence // ignore: cast_nullable_to_non_nullable
as double,imageDescription: freezed == imageDescription ? _self.imageDescription : imageDescription // ignore: cast_nullable_to_non_nullable
as String?,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,requiresReview: null == requiresReview ? _self.requiresReview : requiresReview // ignore: cast_nullable_to_non_nullable
as bool,hasProfileReference: null == hasProfileReference ? _self.hasProfileReference : hasProfileReference // ignore: cast_nullable_to_non_nullable
as bool,profileMatchFound: null == profileMatchFound ? _self.profileMatchFound : profileMatchFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncExtractionResponse].
extension SyncExtractionResponsePatterns on SyncExtractionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncExtractionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncExtractionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncExtractionResponse value)  $default,){
final _that = this;
switch (_that) {
case _SyncExtractionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncExtractionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SyncExtractionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DetectedItemData> items, @JsonKey(name: 'overall_confidence')  double overallConfidence, @JsonKey(name: 'image_description')  String? imageDescription, @JsonKey(name: 'item_count')  int itemCount, @JsonKey(name: 'requires_review')  bool requiresReview, @JsonKey(name: 'has_profile_reference')  bool hasProfileReference, @JsonKey(name: 'profile_match_found')  bool profileMatchFound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncExtractionResponse() when $default != null:
return $default(_that.items,_that.overallConfidence,_that.imageDescription,_that.itemCount,_that.requiresReview,_that.hasProfileReference,_that.profileMatchFound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DetectedItemData> items, @JsonKey(name: 'overall_confidence')  double overallConfidence, @JsonKey(name: 'image_description')  String? imageDescription, @JsonKey(name: 'item_count')  int itemCount, @JsonKey(name: 'requires_review')  bool requiresReview, @JsonKey(name: 'has_profile_reference')  bool hasProfileReference, @JsonKey(name: 'profile_match_found')  bool profileMatchFound)  $default,) {final _that = this;
switch (_that) {
case _SyncExtractionResponse():
return $default(_that.items,_that.overallConfidence,_that.imageDescription,_that.itemCount,_that.requiresReview,_that.hasProfileReference,_that.profileMatchFound);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DetectedItemData> items, @JsonKey(name: 'overall_confidence')  double overallConfidence, @JsonKey(name: 'image_description')  String? imageDescription, @JsonKey(name: 'item_count')  int itemCount, @JsonKey(name: 'requires_review')  bool requiresReview, @JsonKey(name: 'has_profile_reference')  bool hasProfileReference, @JsonKey(name: 'profile_match_found')  bool profileMatchFound)?  $default,) {final _that = this;
switch (_that) {
case _SyncExtractionResponse() when $default != null:
return $default(_that.items,_that.overallConfidence,_that.imageDescription,_that.itemCount,_that.requiresReview,_that.hasProfileReference,_that.profileMatchFound);case _:
  return null;

}
}

}

/// @nodoc


class _SyncExtractionResponse implements SyncExtractionResponse {
  const _SyncExtractionResponse({required final  List<DetectedItemData> items, @JsonKey(name: 'overall_confidence') required this.overallConfidence, @JsonKey(name: 'image_description') this.imageDescription, @JsonKey(name: 'item_count') required this.itemCount, @JsonKey(name: 'requires_review') this.requiresReview = true, @JsonKey(name: 'has_profile_reference') this.hasProfileReference = false, @JsonKey(name: 'profile_match_found') this.profileMatchFound = false}): _items = items;
  

 final  List<DetectedItemData> _items;
@override List<DetectedItemData> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'overall_confidence') final  double overallConfidence;
@override@JsonKey(name: 'image_description') final  String? imageDescription;
@override@JsonKey(name: 'item_count') final  int itemCount;
@override@JsonKey(name: 'requires_review') final  bool requiresReview;
@override@JsonKey(name: 'has_profile_reference') final  bool hasProfileReference;
@override@JsonKey(name: 'profile_match_found') final  bool profileMatchFound;

/// Create a copy of SyncExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncExtractionResponseCopyWith<_SyncExtractionResponse> get copyWith => __$SyncExtractionResponseCopyWithImpl<_SyncExtractionResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncExtractionResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.overallConfidence, overallConfidence) || other.overallConfidence == overallConfidence)&&(identical(other.imageDescription, imageDescription) || other.imageDescription == imageDescription)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.requiresReview, requiresReview) || other.requiresReview == requiresReview)&&(identical(other.hasProfileReference, hasProfileReference) || other.hasProfileReference == hasProfileReference)&&(identical(other.profileMatchFound, profileMatchFound) || other.profileMatchFound == profileMatchFound));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),overallConfidence,imageDescription,itemCount,requiresReview,hasProfileReference,profileMatchFound);

@override
String toString() {
  return 'SyncExtractionResponse(items: $items, overallConfidence: $overallConfidence, imageDescription: $imageDescription, itemCount: $itemCount, requiresReview: $requiresReview, hasProfileReference: $hasProfileReference, profileMatchFound: $profileMatchFound)';
}


}

/// @nodoc
abstract mixin class _$SyncExtractionResponseCopyWith<$Res> implements $SyncExtractionResponseCopyWith<$Res> {
  factory _$SyncExtractionResponseCopyWith(_SyncExtractionResponse value, $Res Function(_SyncExtractionResponse) _then) = __$SyncExtractionResponseCopyWithImpl;
@override @useResult
$Res call({
 List<DetectedItemData> items,@JsonKey(name: 'overall_confidence') double overallConfidence,@JsonKey(name: 'image_description') String? imageDescription,@JsonKey(name: 'item_count') int itemCount,@JsonKey(name: 'requires_review') bool requiresReview,@JsonKey(name: 'has_profile_reference') bool hasProfileReference,@JsonKey(name: 'profile_match_found') bool profileMatchFound
});




}
/// @nodoc
class __$SyncExtractionResponseCopyWithImpl<$Res>
    implements _$SyncExtractionResponseCopyWith<$Res> {
  __$SyncExtractionResponseCopyWithImpl(this._self, this._then);

  final _SyncExtractionResponse _self;
  final $Res Function(_SyncExtractionResponse) _then;

/// Create a copy of SyncExtractionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? overallConfidence = null,Object? imageDescription = freezed,Object? itemCount = null,Object? requiresReview = null,Object? hasProfileReference = null,Object? profileMatchFound = null,}) {
  return _then(_SyncExtractionResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<DetectedItemData>,overallConfidence: null == overallConfidence ? _self.overallConfidence : overallConfidence // ignore: cast_nullable_to_non_nullable
as double,imageDescription: freezed == imageDescription ? _self.imageDescription : imageDescription // ignore: cast_nullable_to_non_nullable
as String?,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,requiresReview: null == requiresReview ? _self.requiresReview : requiresReview // ignore: cast_nullable_to_non_nullable
as bool,hasProfileReference: null == hasProfileReference ? _self.hasProfileReference : hasProfileReference // ignore: cast_nullable_to_non_nullable
as bool,profileMatchFound: null == profileMatchFound ? _self.profileMatchFound : profileMatchFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProductImageGenerationRequest {

 String get itemDescription; String get category; String? get subCategory; List<String>? get colors; String? get material; String? get pattern; String get background; String get viewAngle; bool get includeShadows; bool get saveToStorage;
/// Create a copy of ProductImageGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductImageGenerationRequestCopyWith<ProductImageGenerationRequest> get copyWith => _$ProductImageGenerationRequestCopyWithImpl<ProductImageGenerationRequest>(this as ProductImageGenerationRequest, _$identity);

  /// Serializes this ProductImageGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductImageGenerationRequest&&(identical(other.itemDescription, itemDescription) || other.itemDescription == itemDescription)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.background, background) || other.background == background)&&(identical(other.viewAngle, viewAngle) || other.viewAngle == viewAngle)&&(identical(other.includeShadows, includeShadows) || other.includeShadows == includeShadows)&&(identical(other.saveToStorage, saveToStorage) || other.saveToStorage == saveToStorage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemDescription,category,subCategory,const DeepCollectionEquality().hash(colors),material,pattern,background,viewAngle,includeShadows,saveToStorage);

@override
String toString() {
  return 'ProductImageGenerationRequest(itemDescription: $itemDescription, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, background: $background, viewAngle: $viewAngle, includeShadows: $includeShadows, saveToStorage: $saveToStorage)';
}


}

/// @nodoc
abstract mixin class $ProductImageGenerationRequestCopyWith<$Res>  {
  factory $ProductImageGenerationRequestCopyWith(ProductImageGenerationRequest value, $Res Function(ProductImageGenerationRequest) _then) = _$ProductImageGenerationRequestCopyWithImpl;
@useResult
$Res call({
 String itemDescription, String category, String? subCategory, List<String>? colors, String? material, String? pattern, String background, String viewAngle, bool includeShadows, bool saveToStorage
});




}
/// @nodoc
class _$ProductImageGenerationRequestCopyWithImpl<$Res>
    implements $ProductImageGenerationRequestCopyWith<$Res> {
  _$ProductImageGenerationRequestCopyWithImpl(this._self, this._then);

  final ProductImageGenerationRequest _self;
  final $Res Function(ProductImageGenerationRequest) _then;

/// Create a copy of ProductImageGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemDescription = null,Object? category = null,Object? subCategory = freezed,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? background = null,Object? viewAngle = null,Object? includeShadows = null,Object? saveToStorage = null,}) {
  return _then(_self.copyWith(
itemDescription: null == itemDescription ? _self.itemDescription : itemDescription // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as String,viewAngle: null == viewAngle ? _self.viewAngle : viewAngle // ignore: cast_nullable_to_non_nullable
as String,includeShadows: null == includeShadows ? _self.includeShadows : includeShadows // ignore: cast_nullable_to_non_nullable
as bool,saveToStorage: null == saveToStorage ? _self.saveToStorage : saveToStorage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductImageGenerationRequest].
extension ProductImageGenerationRequestPatterns on ProductImageGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductImageGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductImageGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductImageGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProductImageGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductImageGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProductImageGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemDescription,  String category,  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String background,  String viewAngle,  bool includeShadows,  bool saveToStorage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductImageGenerationRequest() when $default != null:
return $default(_that.itemDescription,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.background,_that.viewAngle,_that.includeShadows,_that.saveToStorage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemDescription,  String category,  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String background,  String viewAngle,  bool includeShadows,  bool saveToStorage)  $default,) {final _that = this;
switch (_that) {
case _ProductImageGenerationRequest():
return $default(_that.itemDescription,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.background,_that.viewAngle,_that.includeShadows,_that.saveToStorage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemDescription,  String category,  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String background,  String viewAngle,  bool includeShadows,  bool saveToStorage)?  $default,) {final _that = this;
switch (_that) {
case _ProductImageGenerationRequest() when $default != null:
return $default(_that.itemDescription,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.background,_that.viewAngle,_that.includeShadows,_that.saveToStorage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductImageGenerationRequest implements ProductImageGenerationRequest {
  const _ProductImageGenerationRequest({required this.itemDescription, required this.category, this.subCategory, final  List<String>? colors, this.material, this.pattern, this.background = 'white', this.viewAngle = 'front', this.includeShadows = false, this.saveToStorage = false}): _colors = colors;
  factory _ProductImageGenerationRequest.fromJson(Map<String, dynamic> json) => _$ProductImageGenerationRequestFromJson(json);

@override final  String itemDescription;
@override final  String category;
@override final  String? subCategory;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? material;
@override final  String? pattern;
@override@JsonKey() final  String background;
@override@JsonKey() final  String viewAngle;
@override@JsonKey() final  bool includeShadows;
@override@JsonKey() final  bool saveToStorage;

/// Create a copy of ProductImageGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductImageGenerationRequestCopyWith<_ProductImageGenerationRequest> get copyWith => __$ProductImageGenerationRequestCopyWithImpl<_ProductImageGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductImageGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductImageGenerationRequest&&(identical(other.itemDescription, itemDescription) || other.itemDescription == itemDescription)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.background, background) || other.background == background)&&(identical(other.viewAngle, viewAngle) || other.viewAngle == viewAngle)&&(identical(other.includeShadows, includeShadows) || other.includeShadows == includeShadows)&&(identical(other.saveToStorage, saveToStorage) || other.saveToStorage == saveToStorage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemDescription,category,subCategory,const DeepCollectionEquality().hash(_colors),material,pattern,background,viewAngle,includeShadows,saveToStorage);

@override
String toString() {
  return 'ProductImageGenerationRequest(itemDescription: $itemDescription, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, background: $background, viewAngle: $viewAngle, includeShadows: $includeShadows, saveToStorage: $saveToStorage)';
}


}

/// @nodoc
abstract mixin class _$ProductImageGenerationRequestCopyWith<$Res> implements $ProductImageGenerationRequestCopyWith<$Res> {
  factory _$ProductImageGenerationRequestCopyWith(_ProductImageGenerationRequest value, $Res Function(_ProductImageGenerationRequest) _then) = __$ProductImageGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String itemDescription, String category, String? subCategory, List<String>? colors, String? material, String? pattern, String background, String viewAngle, bool includeShadows, bool saveToStorage
});




}
/// @nodoc
class __$ProductImageGenerationRequestCopyWithImpl<$Res>
    implements _$ProductImageGenerationRequestCopyWith<$Res> {
  __$ProductImageGenerationRequestCopyWithImpl(this._self, this._then);

  final _ProductImageGenerationRequest _self;
  final $Res Function(_ProductImageGenerationRequest) _then;

/// Create a copy of ProductImageGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemDescription = null,Object? category = null,Object? subCategory = freezed,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? background = null,Object? viewAngle = null,Object? includeShadows = null,Object? saveToStorage = null,}) {
  return _then(_ProductImageGenerationRequest(
itemDescription: null == itemDescription ? _self.itemDescription : itemDescription // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as String,viewAngle: null == viewAngle ? _self.viewAngle : viewAngle // ignore: cast_nullable_to_non_nullable
as String,includeShadows: null == includeShadows ? _self.includeShadows : includeShadows // ignore: cast_nullable_to_non_nullable
as bool,saveToStorage: null == saveToStorage ? _self.saveToStorage : saveToStorage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ProductImageGenerationResponse {

@JsonKey(name: 'image_base64') String get imageBase64; String? get imageUrl; String? get storagePath; String get prompt; String get model; String get provider;
/// Create a copy of ProductImageGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductImageGenerationResponseCopyWith<ProductImageGenerationResponse> get copyWith => _$ProductImageGenerationResponseCopyWithImpl<ProductImageGenerationResponse>(this as ProductImageGenerationResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductImageGenerationResponse&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.model, model) || other.model == model)&&(identical(other.provider, provider) || other.provider == provider));
}


@override
int get hashCode => Object.hash(runtimeType,imageBase64,imageUrl,storagePath,prompt,model,provider);

@override
String toString() {
  return 'ProductImageGenerationResponse(imageBase64: $imageBase64, imageUrl: $imageUrl, storagePath: $storagePath, prompt: $prompt, model: $model, provider: $provider)';
}


}

/// @nodoc
abstract mixin class $ProductImageGenerationResponseCopyWith<$Res>  {
  factory $ProductImageGenerationResponseCopyWith(ProductImageGenerationResponse value, $Res Function(ProductImageGenerationResponse) _then) = _$ProductImageGenerationResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'image_base64') String imageBase64, String? imageUrl, String? storagePath, String prompt, String model, String provider
});




}
/// @nodoc
class _$ProductImageGenerationResponseCopyWithImpl<$Res>
    implements $ProductImageGenerationResponseCopyWith<$Res> {
  _$ProductImageGenerationResponseCopyWithImpl(this._self, this._then);

  final ProductImageGenerationResponse _self;
  final $Res Function(ProductImageGenerationResponse) _then;

/// Create a copy of ProductImageGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageBase64 = null,Object? imageUrl = freezed,Object? storagePath = freezed,Object? prompt = null,Object? model = null,Object? provider = null,}) {
  return _then(_self.copyWith(
imageBase64: null == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,storagePath: freezed == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String?,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductImageGenerationResponse].
extension ProductImageGenerationResponsePatterns on ProductImageGenerationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductImageGenerationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductImageGenerationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductImageGenerationResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProductImageGenerationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductImageGenerationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProductImageGenerationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_base64')  String imageBase64,  String? imageUrl,  String? storagePath,  String prompt,  String model,  String provider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductImageGenerationResponse() when $default != null:
return $default(_that.imageBase64,_that.imageUrl,_that.storagePath,_that.prompt,_that.model,_that.provider);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_base64')  String imageBase64,  String? imageUrl,  String? storagePath,  String prompt,  String model,  String provider)  $default,) {final _that = this;
switch (_that) {
case _ProductImageGenerationResponse():
return $default(_that.imageBase64,_that.imageUrl,_that.storagePath,_that.prompt,_that.model,_that.provider);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'image_base64')  String imageBase64,  String? imageUrl,  String? storagePath,  String prompt,  String model,  String provider)?  $default,) {final _that = this;
switch (_that) {
case _ProductImageGenerationResponse() when $default != null:
return $default(_that.imageBase64,_that.imageUrl,_that.storagePath,_that.prompt,_that.model,_that.provider);case _:
  return null;

}
}

}

/// @nodoc


class _ProductImageGenerationResponse implements ProductImageGenerationResponse {
  const _ProductImageGenerationResponse({@JsonKey(name: 'image_base64') required this.imageBase64, this.imageUrl, this.storagePath, required this.prompt, required this.model, required this.provider});
  

@override@JsonKey(name: 'image_base64') final  String imageBase64;
@override final  String? imageUrl;
@override final  String? storagePath;
@override final  String prompt;
@override final  String model;
@override final  String provider;

/// Create a copy of ProductImageGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductImageGenerationResponseCopyWith<_ProductImageGenerationResponse> get copyWith => __$ProductImageGenerationResponseCopyWithImpl<_ProductImageGenerationResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductImageGenerationResponse&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.model, model) || other.model == model)&&(identical(other.provider, provider) || other.provider == provider));
}


@override
int get hashCode => Object.hash(runtimeType,imageBase64,imageUrl,storagePath,prompt,model,provider);

@override
String toString() {
  return 'ProductImageGenerationResponse(imageBase64: $imageBase64, imageUrl: $imageUrl, storagePath: $storagePath, prompt: $prompt, model: $model, provider: $provider)';
}


}

/// @nodoc
abstract mixin class _$ProductImageGenerationResponseCopyWith<$Res> implements $ProductImageGenerationResponseCopyWith<$Res> {
  factory _$ProductImageGenerationResponseCopyWith(_ProductImageGenerationResponse value, $Res Function(_ProductImageGenerationResponse) _then) = __$ProductImageGenerationResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'image_base64') String imageBase64, String? imageUrl, String? storagePath, String prompt, String model, String provider
});




}
/// @nodoc
class __$ProductImageGenerationResponseCopyWithImpl<$Res>
    implements _$ProductImageGenerationResponseCopyWith<$Res> {
  __$ProductImageGenerationResponseCopyWithImpl(this._self, this._then);

  final _ProductImageGenerationResponse _self;
  final $Res Function(_ProductImageGenerationResponse) _then;

/// Create a copy of ProductImageGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageBase64 = null,Object? imageUrl = freezed,Object? storagePath = freezed,Object? prompt = null,Object? model = null,Object? provider = null,}) {
  return _then(_ProductImageGenerationResponse(
imageBase64: null == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,storagePath: freezed == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String?,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DetectedItemDataWithImage {

 String get tempId; String get category;@JsonKey(name: 'sub_category') String? get subCategory; List<String>? get colors; String? get material; String? get pattern; String? get brand; double get confidence;@JsonKey(name: 'detailed_description') String? get detailedDescription;@JsonKey(name: 'person_id') String? get personId;@JsonKey(name: 'person_label') String? get personLabel;@JsonKey(name: 'is_current_user_person') bool get isCurrentUserPerson;@JsonKey(name: 'include_in_wardrobe') bool get includeInWardrobe; String get status;/// Generated product image (data URL format: data:image/png;base64,...)
 String? get generatedImageUrl;/// Error message if generation failed
 String? get generationError;/// User-editable name
 String? get name;/// User-editable tags
 List<String>? get tags;
/// Create a copy of DetectedItemDataWithImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetectedItemDataWithImageCopyWith<DetectedItemDataWithImage> get copyWith => _$DetectedItemDataWithImageCopyWithImpl<DetectedItemDataWithImage>(this as DetectedItemDataWithImage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetectedItemDataWithImage&&(identical(other.tempId, tempId) || other.tempId == tempId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other.colors, colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.detailedDescription, detailedDescription) || other.detailedDescription == detailedDescription)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personLabel, personLabel) || other.personLabel == personLabel)&&(identical(other.isCurrentUserPerson, isCurrentUserPerson) || other.isCurrentUserPerson == isCurrentUserPerson)&&(identical(other.includeInWardrobe, includeInWardrobe) || other.includeInWardrobe == includeInWardrobe)&&(identical(other.status, status) || other.status == status)&&(identical(other.generatedImageUrl, generatedImageUrl) || other.generatedImageUrl == generatedImageUrl)&&(identical(other.generationError, generationError) || other.generationError == generationError)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.tags, tags));
}


@override
int get hashCode => Object.hash(runtimeType,tempId,category,subCategory,const DeepCollectionEquality().hash(colors),material,pattern,brand,confidence,detailedDescription,personId,personLabel,isCurrentUserPerson,includeInWardrobe,status,generatedImageUrl,generationError,name,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'DetectedItemDataWithImage(tempId: $tempId, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, brand: $brand, confidence: $confidence, detailedDescription: $detailedDescription, personId: $personId, personLabel: $personLabel, isCurrentUserPerson: $isCurrentUserPerson, includeInWardrobe: $includeInWardrobe, status: $status, generatedImageUrl: $generatedImageUrl, generationError: $generationError, name: $name, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $DetectedItemDataWithImageCopyWith<$Res>  {
  factory $DetectedItemDataWithImageCopyWith(DetectedItemDataWithImage value, $Res Function(DetectedItemDataWithImage) _then) = _$DetectedItemDataWithImageCopyWithImpl;
@useResult
$Res call({
 String tempId, String category,@JsonKey(name: 'sub_category') String? subCategory, List<String>? colors, String? material, String? pattern, String? brand, double confidence,@JsonKey(name: 'detailed_description') String? detailedDescription,@JsonKey(name: 'person_id') String? personId,@JsonKey(name: 'person_label') String? personLabel,@JsonKey(name: 'is_current_user_person') bool isCurrentUserPerson,@JsonKey(name: 'include_in_wardrobe') bool includeInWardrobe, String status, String? generatedImageUrl, String? generationError, String? name, List<String>? tags
});




}
/// @nodoc
class _$DetectedItemDataWithImageCopyWithImpl<$Res>
    implements $DetectedItemDataWithImageCopyWith<$Res> {
  _$DetectedItemDataWithImageCopyWithImpl(this._self, this._then);

  final DetectedItemDataWithImage _self;
  final $Res Function(DetectedItemDataWithImage) _then;

/// Create a copy of DetectedItemDataWithImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tempId = null,Object? category = null,Object? subCategory = freezed,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? brand = freezed,Object? confidence = null,Object? detailedDescription = freezed,Object? personId = freezed,Object? personLabel = freezed,Object? isCurrentUserPerson = null,Object? includeInWardrobe = null,Object? status = null,Object? generatedImageUrl = freezed,Object? generationError = freezed,Object? name = freezed,Object? tags = freezed,}) {
  return _then(_self.copyWith(
tempId: null == tempId ? _self.tempId : tempId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,detailedDescription: freezed == detailedDescription ? _self.detailedDescription : detailedDescription // ignore: cast_nullable_to_non_nullable
as String?,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personLabel: freezed == personLabel ? _self.personLabel : personLabel // ignore: cast_nullable_to_non_nullable
as String?,isCurrentUserPerson: null == isCurrentUserPerson ? _self.isCurrentUserPerson : isCurrentUserPerson // ignore: cast_nullable_to_non_nullable
as bool,includeInWardrobe: null == includeInWardrobe ? _self.includeInWardrobe : includeInWardrobe // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,generatedImageUrl: freezed == generatedImageUrl ? _self.generatedImageUrl : generatedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,generationError: freezed == generationError ? _self.generationError : generationError // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DetectedItemDataWithImage].
extension DetectedItemDataWithImagePatterns on DetectedItemDataWithImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetectedItemDataWithImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetectedItemDataWithImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetectedItemDataWithImage value)  $default,){
final _that = this;
switch (_that) {
case _DetectedItemDataWithImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetectedItemDataWithImage value)?  $default,){
final _that = this;
switch (_that) {
case _DetectedItemDataWithImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tempId,  String category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String? brand,  double confidence, @JsonKey(name: 'detailed_description')  String? detailedDescription, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe,  String status,  String? generatedImageUrl,  String? generationError,  String? name,  List<String>? tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetectedItemDataWithImage() when $default != null:
return $default(_that.tempId,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.confidence,_that.detailedDescription,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status,_that.generatedImageUrl,_that.generationError,_that.name,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tempId,  String category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String? brand,  double confidence, @JsonKey(name: 'detailed_description')  String? detailedDescription, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe,  String status,  String? generatedImageUrl,  String? generationError,  String? name,  List<String>? tags)  $default,) {final _that = this;
switch (_that) {
case _DetectedItemDataWithImage():
return $default(_that.tempId,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.confidence,_that.detailedDescription,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status,_that.generatedImageUrl,_that.generationError,_that.name,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tempId,  String category, @JsonKey(name: 'sub_category')  String? subCategory,  List<String>? colors,  String? material,  String? pattern,  String? brand,  double confidence, @JsonKey(name: 'detailed_description')  String? detailedDescription, @JsonKey(name: 'person_id')  String? personId, @JsonKey(name: 'person_label')  String? personLabel, @JsonKey(name: 'is_current_user_person')  bool isCurrentUserPerson, @JsonKey(name: 'include_in_wardrobe')  bool includeInWardrobe,  String status,  String? generatedImageUrl,  String? generationError,  String? name,  List<String>? tags)?  $default,) {final _that = this;
switch (_that) {
case _DetectedItemDataWithImage() when $default != null:
return $default(_that.tempId,_that.category,_that.subCategory,_that.colors,_that.material,_that.pattern,_that.brand,_that.confidence,_that.detailedDescription,_that.personId,_that.personLabel,_that.isCurrentUserPerson,_that.includeInWardrobe,_that.status,_that.generatedImageUrl,_that.generationError,_that.name,_that.tags);case _:
  return null;

}
}

}

/// @nodoc


class _DetectedItemDataWithImage implements DetectedItemDataWithImage {
  const _DetectedItemDataWithImage({required this.tempId, required this.category, @JsonKey(name: 'sub_category') this.subCategory, final  List<String>? colors, this.material, this.pattern, this.brand, required this.confidence, @JsonKey(name: 'detailed_description') this.detailedDescription, @JsonKey(name: 'person_id') this.personId, @JsonKey(name: 'person_label') this.personLabel, @JsonKey(name: 'is_current_user_person') this.isCurrentUserPerson = false, @JsonKey(name: 'include_in_wardrobe') this.includeInWardrobe = true, this.status = 'detected', this.generatedImageUrl, this.generationError, this.name, final  List<String>? tags}): _colors = colors,_tags = tags;
  

@override final  String tempId;
@override final  String category;
@override@JsonKey(name: 'sub_category') final  String? subCategory;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? material;
@override final  String? pattern;
@override final  String? brand;
@override final  double confidence;
@override@JsonKey(name: 'detailed_description') final  String? detailedDescription;
@override@JsonKey(name: 'person_id') final  String? personId;
@override@JsonKey(name: 'person_label') final  String? personLabel;
@override@JsonKey(name: 'is_current_user_person') final  bool isCurrentUserPerson;
@override@JsonKey(name: 'include_in_wardrobe') final  bool includeInWardrobe;
@override@JsonKey() final  String status;
/// Generated product image (data URL format: data:image/png;base64,...)
@override final  String? generatedImageUrl;
/// Error message if generation failed
@override final  String? generationError;
/// User-editable name
@override final  String? name;
/// User-editable tags
 final  List<String>? _tags;
/// User-editable tags
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of DetectedItemDataWithImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetectedItemDataWithImageCopyWith<_DetectedItemDataWithImage> get copyWith => __$DetectedItemDataWithImageCopyWithImpl<_DetectedItemDataWithImage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetectedItemDataWithImage&&(identical(other.tempId, tempId) || other.tempId == tempId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&const DeepCollectionEquality().equals(other._colors, _colors)&&(identical(other.material, material) || other.material == material)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.detailedDescription, detailedDescription) || other.detailedDescription == detailedDescription)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personLabel, personLabel) || other.personLabel == personLabel)&&(identical(other.isCurrentUserPerson, isCurrentUserPerson) || other.isCurrentUserPerson == isCurrentUserPerson)&&(identical(other.includeInWardrobe, includeInWardrobe) || other.includeInWardrobe == includeInWardrobe)&&(identical(other.status, status) || other.status == status)&&(identical(other.generatedImageUrl, generatedImageUrl) || other.generatedImageUrl == generatedImageUrl)&&(identical(other.generationError, generationError) || other.generationError == generationError)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._tags, _tags));
}


@override
int get hashCode => Object.hash(runtimeType,tempId,category,subCategory,const DeepCollectionEquality().hash(_colors),material,pattern,brand,confidence,detailedDescription,personId,personLabel,isCurrentUserPerson,includeInWardrobe,status,generatedImageUrl,generationError,name,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'DetectedItemDataWithImage(tempId: $tempId, category: $category, subCategory: $subCategory, colors: $colors, material: $material, pattern: $pattern, brand: $brand, confidence: $confidence, detailedDescription: $detailedDescription, personId: $personId, personLabel: $personLabel, isCurrentUserPerson: $isCurrentUserPerson, includeInWardrobe: $includeInWardrobe, status: $status, generatedImageUrl: $generatedImageUrl, generationError: $generationError, name: $name, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$DetectedItemDataWithImageCopyWith<$Res> implements $DetectedItemDataWithImageCopyWith<$Res> {
  factory _$DetectedItemDataWithImageCopyWith(_DetectedItemDataWithImage value, $Res Function(_DetectedItemDataWithImage) _then) = __$DetectedItemDataWithImageCopyWithImpl;
@override @useResult
$Res call({
 String tempId, String category,@JsonKey(name: 'sub_category') String? subCategory, List<String>? colors, String? material, String? pattern, String? brand, double confidence,@JsonKey(name: 'detailed_description') String? detailedDescription,@JsonKey(name: 'person_id') String? personId,@JsonKey(name: 'person_label') String? personLabel,@JsonKey(name: 'is_current_user_person') bool isCurrentUserPerson,@JsonKey(name: 'include_in_wardrobe') bool includeInWardrobe, String status, String? generatedImageUrl, String? generationError, String? name, List<String>? tags
});




}
/// @nodoc
class __$DetectedItemDataWithImageCopyWithImpl<$Res>
    implements _$DetectedItemDataWithImageCopyWith<$Res> {
  __$DetectedItemDataWithImageCopyWithImpl(this._self, this._then);

  final _DetectedItemDataWithImage _self;
  final $Res Function(_DetectedItemDataWithImage) _then;

/// Create a copy of DetectedItemDataWithImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tempId = null,Object? category = null,Object? subCategory = freezed,Object? colors = freezed,Object? material = freezed,Object? pattern = freezed,Object? brand = freezed,Object? confidence = null,Object? detailedDescription = freezed,Object? personId = freezed,Object? personLabel = freezed,Object? isCurrentUserPerson = null,Object? includeInWardrobe = null,Object? status = null,Object? generatedImageUrl = freezed,Object? generationError = freezed,Object? name = freezed,Object? tags = freezed,}) {
  return _then(_DetectedItemDataWithImage(
tempId: null == tempId ? _self.tempId : tempId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,detailedDescription: freezed == detailedDescription ? _self.detailedDescription : detailedDescription // ignore: cast_nullable_to_non_nullable
as String?,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personLabel: freezed == personLabel ? _self.personLabel : personLabel // ignore: cast_nullable_to_non_nullable
as String?,isCurrentUserPerson: null == isCurrentUserPerson ? _self.isCurrentUserPerson : isCurrentUserPerson // ignore: cast_nullable_to_non_nullable
as bool,includeInWardrobe: null == includeInWardrobe ? _self.includeInWardrobe : includeInWardrobe // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,generatedImageUrl: freezed == generatedImageUrl ? _self.generatedImageUrl : generatedImageUrl // ignore: cast_nullable_to_non_nullable
as String?,generationError: freezed == generationError ? _self.generationError : generationError // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
