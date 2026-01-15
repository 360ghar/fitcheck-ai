// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutfitModel {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name; String? get description;@JsonKey(name: 'item_ids') List<String> get itemIds; Style? get style; Season? get season; String? get occasion; List<String>? get tags;@JsonKey(name: 'is_favorite') bool get isFavorite;@JsonKey(name: 'is_draft') bool get isDraft;@JsonKey(name: 'is_public') bool get isPublic;@JsonKey(name: 'worn_count') int get wornCount;@JsonKey(name: 'last_worn_at') DateTime? get lastWornAt;@JsonKey(name: 'outfit_images') List<OutfitImage>? get outfitImages; List<ItemModel>? get items;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of OutfitModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfitModelCopyWith<OutfitModel> get copyWith => _$OutfitModelCopyWithImpl<OutfitModel>(this as OutfitModel, _$identity);

  /// Serializes this OutfitModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutfitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.itemIds, itemIds)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDraft, isDraft) || other.isDraft == isDraft)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.wornCount, wornCount) || other.wornCount == wornCount)&&(identical(other.lastWornAt, lastWornAt) || other.lastWornAt == lastWornAt)&&const DeepCollectionEquality().equals(other.outfitImages, outfitImages)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,const DeepCollectionEquality().hash(itemIds),style,season,occasion,const DeepCollectionEquality().hash(tags),isFavorite,isDraft,isPublic,wornCount,lastWornAt,const DeepCollectionEquality().hash(outfitImages),const DeepCollectionEquality().hash(items),createdAt,updatedAt);

@override
String toString() {
  return 'OutfitModel(id: $id, userId: $userId, name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags, isFavorite: $isFavorite, isDraft: $isDraft, isPublic: $isPublic, wornCount: $wornCount, lastWornAt: $lastWornAt, outfitImages: $outfitImages, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OutfitModelCopyWith<$Res>  {
  factory $OutfitModelCopyWith(OutfitModel value, $Res Function(OutfitModel) _then) = _$OutfitModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String? description,@JsonKey(name: 'item_ids') List<String> itemIds, Style? style, Season? season, String? occasion, List<String>? tags,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'is_draft') bool isDraft,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'worn_count') int wornCount,@JsonKey(name: 'last_worn_at') DateTime? lastWornAt,@JsonKey(name: 'outfit_images') List<OutfitImage>? outfitImages, List<ItemModel>? items,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$OutfitModelCopyWithImpl<$Res>
    implements $OutfitModelCopyWith<$Res> {
  _$OutfitModelCopyWithImpl(this._self, this._then);

  final OutfitModel _self;
  final $Res Function(OutfitModel) _then;

/// Create a copy of OutfitModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? itemIds = null,Object? style = freezed,Object? season = freezed,Object? occasion = freezed,Object? tags = freezed,Object? isFavorite = null,Object? isDraft = null,Object? isPublic = null,Object? wornCount = null,Object? lastWornAt = freezed,Object? outfitImages = freezed,Object? items = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemIds: null == itemIds ? _self.itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isDraft: null == isDraft ? _self.isDraft : isDraft // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,wornCount: null == wornCount ? _self.wornCount : wornCount // ignore: cast_nullable_to_non_nullable
as int,lastWornAt: freezed == lastWornAt ? _self.lastWornAt : lastWornAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outfitImages: freezed == outfitImages ? _self.outfitImages : outfitImages // ignore: cast_nullable_to_non_nullable
as List<OutfitImage>?,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ItemModel>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutfitModel].
extension OutfitModelPatterns on OutfitModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutfitModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutfitModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutfitModel value)  $default,){
final _that = this;
switch (_that) {
case _OutfitModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutfitModel value)?  $default,){
final _that = this;
switch (_that) {
case _OutfitModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description, @JsonKey(name: 'item_ids')  List<String> itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'is_draft')  bool isDraft, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'worn_count')  int wornCount, @JsonKey(name: 'last_worn_at')  DateTime? lastWornAt, @JsonKey(name: 'outfit_images')  List<OutfitImage>? outfitImages,  List<ItemModel>? items, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutfitModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags,_that.isFavorite,_that.isDraft,_that.isPublic,_that.wornCount,_that.lastWornAt,_that.outfitImages,_that.items,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description, @JsonKey(name: 'item_ids')  List<String> itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'is_draft')  bool isDraft, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'worn_count')  int wornCount, @JsonKey(name: 'last_worn_at')  DateTime? lastWornAt, @JsonKey(name: 'outfit_images')  List<OutfitImage>? outfitImages,  List<ItemModel>? items, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OutfitModel():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags,_that.isFavorite,_that.isDraft,_that.isPublic,_that.wornCount,_that.lastWornAt,_that.outfitImages,_that.items,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description, @JsonKey(name: 'item_ids')  List<String> itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'is_draft')  bool isDraft, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'worn_count')  int wornCount, @JsonKey(name: 'last_worn_at')  DateTime? lastWornAt, @JsonKey(name: 'outfit_images')  List<OutfitImage>? outfitImages,  List<ItemModel>? items, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OutfitModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags,_that.isFavorite,_that.isDraft,_that.isPublic,_that.wornCount,_that.lastWornAt,_that.outfitImages,_that.items,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutfitModel implements OutfitModel {
  const _OutfitModel({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, this.description, @JsonKey(name: 'item_ids') required final  List<String> itemIds, this.style, this.season, this.occasion, final  List<String>? tags, @JsonKey(name: 'is_favorite') this.isFavorite = false, @JsonKey(name: 'is_draft') this.isDraft = false, @JsonKey(name: 'is_public') this.isPublic = false, @JsonKey(name: 'worn_count') this.wornCount = 0, @JsonKey(name: 'last_worn_at') this.lastWornAt, @JsonKey(name: 'outfit_images') final  List<OutfitImage>? outfitImages, final  List<ItemModel>? items, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _itemIds = itemIds,_tags = tags,_outfitImages = outfitImages,_items = items;
  factory _OutfitModel.fromJson(Map<String, dynamic> json) => _$OutfitModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override final  String? description;
 final  List<String> _itemIds;
@override@JsonKey(name: 'item_ids') List<String> get itemIds {
  if (_itemIds is EqualUnmodifiableListView) return _itemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itemIds);
}

@override final  Style? style;
@override final  Season? season;
@override final  String? occasion;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
@override@JsonKey(name: 'is_draft') final  bool isDraft;
@override@JsonKey(name: 'is_public') final  bool isPublic;
@override@JsonKey(name: 'worn_count') final  int wornCount;
@override@JsonKey(name: 'last_worn_at') final  DateTime? lastWornAt;
 final  List<OutfitImage>? _outfitImages;
@override@JsonKey(name: 'outfit_images') List<OutfitImage>? get outfitImages {
  final value = _outfitImages;
  if (value == null) return null;
  if (_outfitImages is EqualUnmodifiableListView) return _outfitImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ItemModel>? _items;
@override List<ItemModel>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of OutfitModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutfitModelCopyWith<_OutfitModel> get copyWith => __$OutfitModelCopyWithImpl<_OutfitModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutfitModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutfitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._itemIds, _itemIds)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDraft, isDraft) || other.isDraft == isDraft)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.wornCount, wornCount) || other.wornCount == wornCount)&&(identical(other.lastWornAt, lastWornAt) || other.lastWornAt == lastWornAt)&&const DeepCollectionEquality().equals(other._outfitImages, _outfitImages)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,const DeepCollectionEquality().hash(_itemIds),style,season,occasion,const DeepCollectionEquality().hash(_tags),isFavorite,isDraft,isPublic,wornCount,lastWornAt,const DeepCollectionEquality().hash(_outfitImages),const DeepCollectionEquality().hash(_items),createdAt,updatedAt);

@override
String toString() {
  return 'OutfitModel(id: $id, userId: $userId, name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags, isFavorite: $isFavorite, isDraft: $isDraft, isPublic: $isPublic, wornCount: $wornCount, lastWornAt: $lastWornAt, outfitImages: $outfitImages, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OutfitModelCopyWith<$Res> implements $OutfitModelCopyWith<$Res> {
  factory _$OutfitModelCopyWith(_OutfitModel value, $Res Function(_OutfitModel) _then) = __$OutfitModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String? description,@JsonKey(name: 'item_ids') List<String> itemIds, Style? style, Season? season, String? occasion, List<String>? tags,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'is_draft') bool isDraft,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'worn_count') int wornCount,@JsonKey(name: 'last_worn_at') DateTime? lastWornAt,@JsonKey(name: 'outfit_images') List<OutfitImage>? outfitImages, List<ItemModel>? items,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$OutfitModelCopyWithImpl<$Res>
    implements _$OutfitModelCopyWith<$Res> {
  __$OutfitModelCopyWithImpl(this._self, this._then);

  final _OutfitModel _self;
  final $Res Function(_OutfitModel) _then;

/// Create a copy of OutfitModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? itemIds = null,Object? style = freezed,Object? season = freezed,Object? occasion = freezed,Object? tags = freezed,Object? isFavorite = null,Object? isDraft = null,Object? isPublic = null,Object? wornCount = null,Object? lastWornAt = freezed,Object? outfitImages = freezed,Object? items = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_OutfitModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemIds: null == itemIds ? _self._itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isDraft: null == isDraft ? _self.isDraft : isDraft // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,wornCount: null == wornCount ? _self.wornCount : wornCount // ignore: cast_nullable_to_non_nullable
as int,lastWornAt: freezed == lastWornAt ? _self.lastWornAt : lastWornAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outfitImages: freezed == outfitImages ? _self._outfitImages : outfitImages // ignore: cast_nullable_to_non_nullable
as List<OutfitImage>?,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ItemModel>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$OutfitImage {

 String get id; String get url; String? get type; String? get pose; String? get lighting;@JsonKey(name: 'body_profile_id') String? get bodyProfileId;@JsonKey(name: 'is_generated') bool get isGenerated; int? get width; int? get height; String? get blurhash;
/// Create a copy of OutfitImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfitImageCopyWith<OutfitImage> get copyWith => _$OutfitImageCopyWithImpl<OutfitImage>(this as OutfitImage, _$identity);

  /// Serializes this OutfitImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutfitImage&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.type, type) || other.type == type)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.lighting, lighting) || other.lighting == lighting)&&(identical(other.bodyProfileId, bodyProfileId) || other.bodyProfileId == bodyProfileId)&&(identical(other.isGenerated, isGenerated) || other.isGenerated == isGenerated)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,type,pose,lighting,bodyProfileId,isGenerated,width,height,blurhash);

@override
String toString() {
  return 'OutfitImage(id: $id, url: $url, type: $type, pose: $pose, lighting: $lighting, bodyProfileId: $bodyProfileId, isGenerated: $isGenerated, width: $width, height: $height, blurhash: $blurhash)';
}


}

/// @nodoc
abstract mixin class $OutfitImageCopyWith<$Res>  {
  factory $OutfitImageCopyWith(OutfitImage value, $Res Function(OutfitImage) _then) = _$OutfitImageCopyWithImpl;
@useResult
$Res call({
 String id, String url, String? type, String? pose, String? lighting,@JsonKey(name: 'body_profile_id') String? bodyProfileId,@JsonKey(name: 'is_generated') bool isGenerated, int? width, int? height, String? blurhash
});




}
/// @nodoc
class _$OutfitImageCopyWithImpl<$Res>
    implements $OutfitImageCopyWith<$Res> {
  _$OutfitImageCopyWithImpl(this._self, this._then);

  final OutfitImage _self;
  final $Res Function(OutfitImage) _then;

/// Create a copy of OutfitImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? type = freezed,Object? pose = freezed,Object? lighting = freezed,Object? bodyProfileId = freezed,Object? isGenerated = null,Object? width = freezed,Object? height = freezed,Object? blurhash = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,lighting: freezed == lighting ? _self.lighting : lighting // ignore: cast_nullable_to_non_nullable
as String?,bodyProfileId: freezed == bodyProfileId ? _self.bodyProfileId : bodyProfileId // ignore: cast_nullable_to_non_nullable
as String?,isGenerated: null == isGenerated ? _self.isGenerated : isGenerated // ignore: cast_nullable_to_non_nullable
as bool,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutfitImage].
extension OutfitImagePatterns on OutfitImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutfitImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutfitImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutfitImage value)  $default,){
final _that = this;
switch (_that) {
case _OutfitImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutfitImage value)?  $default,){
final _that = this;
switch (_that) {
case _OutfitImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String? type,  String? pose,  String? lighting, @JsonKey(name: 'body_profile_id')  String? bodyProfileId, @JsonKey(name: 'is_generated')  bool isGenerated,  int? width,  int? height,  String? blurhash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutfitImage() when $default != null:
return $default(_that.id,_that.url,_that.type,_that.pose,_that.lighting,_that.bodyProfileId,_that.isGenerated,_that.width,_that.height,_that.blurhash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String? type,  String? pose,  String? lighting, @JsonKey(name: 'body_profile_id')  String? bodyProfileId, @JsonKey(name: 'is_generated')  bool isGenerated,  int? width,  int? height,  String? blurhash)  $default,) {final _that = this;
switch (_that) {
case _OutfitImage():
return $default(_that.id,_that.url,_that.type,_that.pose,_that.lighting,_that.bodyProfileId,_that.isGenerated,_that.width,_that.height,_that.blurhash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String? type,  String? pose,  String? lighting, @JsonKey(name: 'body_profile_id')  String? bodyProfileId, @JsonKey(name: 'is_generated')  bool isGenerated,  int? width,  int? height,  String? blurhash)?  $default,) {final _that = this;
switch (_that) {
case _OutfitImage() when $default != null:
return $default(_that.id,_that.url,_that.type,_that.pose,_that.lighting,_that.bodyProfileId,_that.isGenerated,_that.width,_that.height,_that.blurhash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutfitImage implements OutfitImage {
  const _OutfitImage({required this.id, required this.url, this.type, this.pose, this.lighting, @JsonKey(name: 'body_profile_id') this.bodyProfileId, @JsonKey(name: 'is_generated') this.isGenerated = false, this.width, this.height, this.blurhash});
  factory _OutfitImage.fromJson(Map<String, dynamic> json) => _$OutfitImageFromJson(json);

@override final  String id;
@override final  String url;
@override final  String? type;
@override final  String? pose;
@override final  String? lighting;
@override@JsonKey(name: 'body_profile_id') final  String? bodyProfileId;
@override@JsonKey(name: 'is_generated') final  bool isGenerated;
@override final  int? width;
@override final  int? height;
@override final  String? blurhash;

/// Create a copy of OutfitImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutfitImageCopyWith<_OutfitImage> get copyWith => __$OutfitImageCopyWithImpl<_OutfitImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutfitImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutfitImage&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.type, type) || other.type == type)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.lighting, lighting) || other.lighting == lighting)&&(identical(other.bodyProfileId, bodyProfileId) || other.bodyProfileId == bodyProfileId)&&(identical(other.isGenerated, isGenerated) || other.isGenerated == isGenerated)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,type,pose,lighting,bodyProfileId,isGenerated,width,height,blurhash);

@override
String toString() {
  return 'OutfitImage(id: $id, url: $url, type: $type, pose: $pose, lighting: $lighting, bodyProfileId: $bodyProfileId, isGenerated: $isGenerated, width: $width, height: $height, blurhash: $blurhash)';
}


}

/// @nodoc
abstract mixin class _$OutfitImageCopyWith<$Res> implements $OutfitImageCopyWith<$Res> {
  factory _$OutfitImageCopyWith(_OutfitImage value, $Res Function(_OutfitImage) _then) = __$OutfitImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? type, String? pose, String? lighting,@JsonKey(name: 'body_profile_id') String? bodyProfileId,@JsonKey(name: 'is_generated') bool isGenerated, int? width, int? height, String? blurhash
});




}
/// @nodoc
class __$OutfitImageCopyWithImpl<$Res>
    implements _$OutfitImageCopyWith<$Res> {
  __$OutfitImageCopyWithImpl(this._self, this._then);

  final _OutfitImage _self;
  final $Res Function(_OutfitImage) _then;

/// Create a copy of OutfitImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? type = freezed,Object? pose = freezed,Object? lighting = freezed,Object? bodyProfileId = freezed,Object? isGenerated = null,Object? width = freezed,Object? height = freezed,Object? blurhash = freezed,}) {
  return _then(_OutfitImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,lighting: freezed == lighting ? _self.lighting : lighting // ignore: cast_nullable_to_non_nullable
as String?,bodyProfileId: freezed == bodyProfileId ? _self.bodyProfileId : bodyProfileId // ignore: cast_nullable_to_non_nullable
as String?,isGenerated: null == isGenerated ? _self.isGenerated : isGenerated // ignore: cast_nullable_to_non_nullable
as bool,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateOutfitRequest {

 String get name; String? get description; List<String> get itemIds; Style? get style; Season? get season; String? get occasion; List<String>? get tags;
/// Create a copy of CreateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOutfitRequestCopyWith<CreateOutfitRequest> get copyWith => _$CreateOutfitRequestCopyWithImpl<CreateOutfitRequest>(this as CreateOutfitRequest, _$identity);

  /// Serializes this CreateOutfitRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOutfitRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.itemIds, itemIds)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(itemIds),style,season,occasion,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'CreateOutfitRequest(name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $CreateOutfitRequestCopyWith<$Res>  {
  factory $CreateOutfitRequestCopyWith(CreateOutfitRequest value, $Res Function(CreateOutfitRequest) _then) = _$CreateOutfitRequestCopyWithImpl;
@useResult
$Res call({
 String name, String? description, List<String> itemIds, Style? style, Season? season, String? occasion, List<String>? tags
});




}
/// @nodoc
class _$CreateOutfitRequestCopyWithImpl<$Res>
    implements $CreateOutfitRequestCopyWith<$Res> {
  _$CreateOutfitRequestCopyWithImpl(this._self, this._then);

  final CreateOutfitRequest _self;
  final $Res Function(CreateOutfitRequest) _then;

/// Create a copy of CreateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? itemIds = null,Object? style = freezed,Object? season = freezed,Object? occasion = freezed,Object? tags = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemIds: null == itemIds ? _self.itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateOutfitRequest].
extension CreateOutfitRequestPatterns on CreateOutfitRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateOutfitRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateOutfitRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateOutfitRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateOutfitRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateOutfitRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateOutfitRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  List<String> itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateOutfitRequest() when $default != null:
return $default(_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  List<String> itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags)  $default,) {final _that = this;
switch (_that) {
case _CreateOutfitRequest():
return $default(_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  List<String> itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags)?  $default,) {final _that = this;
switch (_that) {
case _CreateOutfitRequest() when $default != null:
return $default(_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateOutfitRequest implements CreateOutfitRequest {
  const _CreateOutfitRequest({required this.name, this.description, required final  List<String> itemIds, this.style, this.season, this.occasion, final  List<String>? tags}): _itemIds = itemIds,_tags = tags;
  factory _CreateOutfitRequest.fromJson(Map<String, dynamic> json) => _$CreateOutfitRequestFromJson(json);

@override final  String name;
@override final  String? description;
 final  List<String> _itemIds;
@override List<String> get itemIds {
  if (_itemIds is EqualUnmodifiableListView) return _itemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itemIds);
}

@override final  Style? style;
@override final  Season? season;
@override final  String? occasion;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOutfitRequestCopyWith<_CreateOutfitRequest> get copyWith => __$CreateOutfitRequestCopyWithImpl<_CreateOutfitRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOutfitRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOutfitRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._itemIds, _itemIds)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(_itemIds),style,season,occasion,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'CreateOutfitRequest(name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$CreateOutfitRequestCopyWith<$Res> implements $CreateOutfitRequestCopyWith<$Res> {
  factory _$CreateOutfitRequestCopyWith(_CreateOutfitRequest value, $Res Function(_CreateOutfitRequest) _then) = __$CreateOutfitRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, List<String> itemIds, Style? style, Season? season, String? occasion, List<String>? tags
});




}
/// @nodoc
class __$CreateOutfitRequestCopyWithImpl<$Res>
    implements _$CreateOutfitRequestCopyWith<$Res> {
  __$CreateOutfitRequestCopyWithImpl(this._self, this._then);

  final _CreateOutfitRequest _self;
  final $Res Function(_CreateOutfitRequest) _then;

/// Create a copy of CreateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? itemIds = null,Object? style = freezed,Object? season = freezed,Object? occasion = freezed,Object? tags = freezed,}) {
  return _then(_CreateOutfitRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemIds: null == itemIds ? _self._itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$UpdateOutfitRequest {

 String? get name; String? get description; List<String>? get itemIds; Style? get style; Season? get season; String? get occasion; List<String>? get tags; bool? get isFavorite; bool? get isDraft; bool? get isPublic;
/// Create a copy of UpdateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateOutfitRequestCopyWith<UpdateOutfitRequest> get copyWith => _$UpdateOutfitRequestCopyWithImpl<UpdateOutfitRequest>(this as UpdateOutfitRequest, _$identity);

  /// Serializes this UpdateOutfitRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateOutfitRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.itemIds, itemIds)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDraft, isDraft) || other.isDraft == isDraft)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(itemIds),style,season,occasion,const DeepCollectionEquality().hash(tags),isFavorite,isDraft,isPublic);

@override
String toString() {
  return 'UpdateOutfitRequest(name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags, isFavorite: $isFavorite, isDraft: $isDraft, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class $UpdateOutfitRequestCopyWith<$Res>  {
  factory $UpdateOutfitRequestCopyWith(UpdateOutfitRequest value, $Res Function(UpdateOutfitRequest) _then) = _$UpdateOutfitRequestCopyWithImpl;
@useResult
$Res call({
 String? name, String? description, List<String>? itemIds, Style? style, Season? season, String? occasion, List<String>? tags, bool? isFavorite, bool? isDraft, bool? isPublic
});




}
/// @nodoc
class _$UpdateOutfitRequestCopyWithImpl<$Res>
    implements $UpdateOutfitRequestCopyWith<$Res> {
  _$UpdateOutfitRequestCopyWithImpl(this._self, this._then);

  final UpdateOutfitRequest _self;
  final $Res Function(UpdateOutfitRequest) _then;

/// Create a copy of UpdateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? description = freezed,Object? itemIds = freezed,Object? style = freezed,Object? season = freezed,Object? occasion = freezed,Object? tags = freezed,Object? isFavorite = freezed,Object? isDraft = freezed,Object? isPublic = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemIds: freezed == itemIds ? _self.itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,isFavorite: freezed == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool?,isDraft: freezed == isDraft ? _self.isDraft : isDraft // ignore: cast_nullable_to_non_nullable
as bool?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateOutfitRequest].
extension UpdateOutfitRequestPatterns on UpdateOutfitRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateOutfitRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateOutfitRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateOutfitRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateOutfitRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateOutfitRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateOutfitRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? description,  List<String>? itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags,  bool? isFavorite,  bool? isDraft,  bool? isPublic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateOutfitRequest() when $default != null:
return $default(_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags,_that.isFavorite,_that.isDraft,_that.isPublic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? description,  List<String>? itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags,  bool? isFavorite,  bool? isDraft,  bool? isPublic)  $default,) {final _that = this;
switch (_that) {
case _UpdateOutfitRequest():
return $default(_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags,_that.isFavorite,_that.isDraft,_that.isPublic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? description,  List<String>? itemIds,  Style? style,  Season? season,  String? occasion,  List<String>? tags,  bool? isFavorite,  bool? isDraft,  bool? isPublic)?  $default,) {final _that = this;
switch (_that) {
case _UpdateOutfitRequest() when $default != null:
return $default(_that.name,_that.description,_that.itemIds,_that.style,_that.season,_that.occasion,_that.tags,_that.isFavorite,_that.isDraft,_that.isPublic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateOutfitRequest implements UpdateOutfitRequest {
  const _UpdateOutfitRequest({this.name, this.description, final  List<String>? itemIds, this.style, this.season, this.occasion, final  List<String>? tags, this.isFavorite, this.isDraft, this.isPublic}): _itemIds = itemIds,_tags = tags;
  factory _UpdateOutfitRequest.fromJson(Map<String, dynamic> json) => _$UpdateOutfitRequestFromJson(json);

@override final  String? name;
@override final  String? description;
 final  List<String>? _itemIds;
@override List<String>? get itemIds {
  final value = _itemIds;
  if (value == null) return null;
  if (_itemIds is EqualUnmodifiableListView) return _itemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  Style? style;
@override final  Season? season;
@override final  String? occasion;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? isFavorite;
@override final  bool? isDraft;
@override final  bool? isPublic;

/// Create a copy of UpdateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateOutfitRequestCopyWith<_UpdateOutfitRequest> get copyWith => __$UpdateOutfitRequestCopyWithImpl<_UpdateOutfitRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateOutfitRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateOutfitRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._itemIds, _itemIds)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDraft, isDraft) || other.isDraft == isDraft)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(_itemIds),style,season,occasion,const DeepCollectionEquality().hash(_tags),isFavorite,isDraft,isPublic);

@override
String toString() {
  return 'UpdateOutfitRequest(name: $name, description: $description, itemIds: $itemIds, style: $style, season: $season, occasion: $occasion, tags: $tags, isFavorite: $isFavorite, isDraft: $isDraft, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class _$UpdateOutfitRequestCopyWith<$Res> implements $UpdateOutfitRequestCopyWith<$Res> {
  factory _$UpdateOutfitRequestCopyWith(_UpdateOutfitRequest value, $Res Function(_UpdateOutfitRequest) _then) = __$UpdateOutfitRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? description, List<String>? itemIds, Style? style, Season? season, String? occasion, List<String>? tags, bool? isFavorite, bool? isDraft, bool? isPublic
});




}
/// @nodoc
class __$UpdateOutfitRequestCopyWithImpl<$Res>
    implements _$UpdateOutfitRequestCopyWith<$Res> {
  __$UpdateOutfitRequestCopyWithImpl(this._self, this._then);

  final _UpdateOutfitRequest _self;
  final $Res Function(_UpdateOutfitRequest) _then;

/// Create a copy of UpdateOutfitRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? description = freezed,Object? itemIds = freezed,Object? style = freezed,Object? season = freezed,Object? occasion = freezed,Object? tags = freezed,Object? isFavorite = freezed,Object? isDraft = freezed,Object? isPublic = freezed,}) {
  return _then(_UpdateOutfitRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,itemIds: freezed == itemIds ? _self._itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season?,occasion: freezed == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,isFavorite: freezed == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool?,isDraft: freezed == isDraft ? _self.isDraft : isDraft // ignore: cast_nullable_to_non_nullable
as bool?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$OutfitsListResponse {

 List<OutfitModel> get outfits; int get total; int get page; int get limit;@JsonKey(name: 'has_more') bool get hasMore;
/// Create a copy of OutfitsListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfitsListResponseCopyWith<OutfitsListResponse> get copyWith => _$OutfitsListResponseCopyWithImpl<OutfitsListResponse>(this as OutfitsListResponse, _$identity);

  /// Serializes this OutfitsListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutfitsListResponse&&const DeepCollectionEquality().equals(other.outfits, outfits)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(outfits),total,page,limit,hasMore);

@override
String toString() {
  return 'OutfitsListResponse(outfits: $outfits, total: $total, page: $page, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $OutfitsListResponseCopyWith<$Res>  {
  factory $OutfitsListResponseCopyWith(OutfitsListResponse value, $Res Function(OutfitsListResponse) _then) = _$OutfitsListResponseCopyWithImpl;
@useResult
$Res call({
 List<OutfitModel> outfits, int total, int page, int limit,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class _$OutfitsListResponseCopyWithImpl<$Res>
    implements $OutfitsListResponseCopyWith<$Res> {
  _$OutfitsListResponseCopyWithImpl(this._self, this._then);

  final OutfitsListResponse _self;
  final $Res Function(OutfitsListResponse) _then;

/// Create a copy of OutfitsListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outfits = null,Object? total = null,Object? page = null,Object? limit = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
outfits: null == outfits ? _self.outfits : outfits // ignore: cast_nullable_to_non_nullable
as List<OutfitModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OutfitsListResponse].
extension OutfitsListResponsePatterns on OutfitsListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutfitsListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutfitsListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutfitsListResponse value)  $default,){
final _that = this;
switch (_that) {
case _OutfitsListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutfitsListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OutfitsListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OutfitModel> outfits,  int total,  int page,  int limit, @JsonKey(name: 'has_more')  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutfitsListResponse() when $default != null:
return $default(_that.outfits,_that.total,_that.page,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OutfitModel> outfits,  int total,  int page,  int limit, @JsonKey(name: 'has_more')  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _OutfitsListResponse():
return $default(_that.outfits,_that.total,_that.page,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OutfitModel> outfits,  int total,  int page,  int limit, @JsonKey(name: 'has_more')  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _OutfitsListResponse() when $default != null:
return $default(_that.outfits,_that.total,_that.page,_that.limit,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutfitsListResponse implements OutfitsListResponse {
  const _OutfitsListResponse({required final  List<OutfitModel> outfits, required this.total, required this.page, required this.limit, @JsonKey(name: 'has_more') required this.hasMore}): _outfits = outfits;
  factory _OutfitsListResponse.fromJson(Map<String, dynamic> json) => _$OutfitsListResponseFromJson(json);

 final  List<OutfitModel> _outfits;
@override List<OutfitModel> get outfits {
  if (_outfits is EqualUnmodifiableListView) return _outfits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outfits);
}

@override final  int total;
@override final  int page;
@override final  int limit;
@override@JsonKey(name: 'has_more') final  bool hasMore;

/// Create a copy of OutfitsListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutfitsListResponseCopyWith<_OutfitsListResponse> get copyWith => __$OutfitsListResponseCopyWithImpl<_OutfitsListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutfitsListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutfitsListResponse&&const DeepCollectionEquality().equals(other._outfits, _outfits)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_outfits),total,page,limit,hasMore);

@override
String toString() {
  return 'OutfitsListResponse(outfits: $outfits, total: $total, page: $page, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$OutfitsListResponseCopyWith<$Res> implements $OutfitsListResponseCopyWith<$Res> {
  factory _$OutfitsListResponseCopyWith(_OutfitsListResponse value, $Res Function(_OutfitsListResponse) _then) = __$OutfitsListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<OutfitModel> outfits, int total, int page, int limit,@JsonKey(name: 'has_more') bool hasMore
});




}
/// @nodoc
class __$OutfitsListResponseCopyWithImpl<$Res>
    implements _$OutfitsListResponseCopyWith<$Res> {
  __$OutfitsListResponseCopyWithImpl(this._self, this._then);

  final _OutfitsListResponse _self;
  final $Res Function(_OutfitsListResponse) _then;

/// Create a copy of OutfitsListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outfits = null,Object? total = null,Object? page = null,Object? limit = null,Object? hasMore = null,}) {
  return _then(_OutfitsListResponse(
outfits: null == outfits ? _self._outfits : outfits // ignore: cast_nullable_to_non_nullable
as List<OutfitModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AIGenerationRequest {

@JsonKey(name: 'outfit_id') String get outfitId; String? get pose; String? get lighting;@JsonKey(name: 'body_profile_id') String? get bodyProfileId;
/// Create a copy of AIGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIGenerationRequestCopyWith<AIGenerationRequest> get copyWith => _$AIGenerationRequestCopyWithImpl<AIGenerationRequest>(this as AIGenerationRequest, _$identity);

  /// Serializes this AIGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIGenerationRequest&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.lighting, lighting) || other.lighting == lighting)&&(identical(other.bodyProfileId, bodyProfileId) || other.bodyProfileId == bodyProfileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outfitId,pose,lighting,bodyProfileId);

@override
String toString() {
  return 'AIGenerationRequest(outfitId: $outfitId, pose: $pose, lighting: $lighting, bodyProfileId: $bodyProfileId)';
}


}

/// @nodoc
abstract mixin class $AIGenerationRequestCopyWith<$Res>  {
  factory $AIGenerationRequestCopyWith(AIGenerationRequest value, $Res Function(AIGenerationRequest) _then) = _$AIGenerationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'outfit_id') String outfitId, String? pose, String? lighting,@JsonKey(name: 'body_profile_id') String? bodyProfileId
});




}
/// @nodoc
class _$AIGenerationRequestCopyWithImpl<$Res>
    implements $AIGenerationRequestCopyWith<$Res> {
  _$AIGenerationRequestCopyWithImpl(this._self, this._then);

  final AIGenerationRequest _self;
  final $Res Function(AIGenerationRequest) _then;

/// Create a copy of AIGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outfitId = null,Object? pose = freezed,Object? lighting = freezed,Object? bodyProfileId = freezed,}) {
  return _then(_self.copyWith(
outfitId: null == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as String,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,lighting: freezed == lighting ? _self.lighting : lighting // ignore: cast_nullable_to_non_nullable
as String?,bodyProfileId: freezed == bodyProfileId ? _self.bodyProfileId : bodyProfileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AIGenerationRequest].
extension AIGenerationRequestPatterns on AIGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _AIGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AIGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'outfit_id')  String outfitId,  String? pose,  String? lighting, @JsonKey(name: 'body_profile_id')  String? bodyProfileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIGenerationRequest() when $default != null:
return $default(_that.outfitId,_that.pose,_that.lighting,_that.bodyProfileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'outfit_id')  String outfitId,  String? pose,  String? lighting, @JsonKey(name: 'body_profile_id')  String? bodyProfileId)  $default,) {final _that = this;
switch (_that) {
case _AIGenerationRequest():
return $default(_that.outfitId,_that.pose,_that.lighting,_that.bodyProfileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'outfit_id')  String outfitId,  String? pose,  String? lighting, @JsonKey(name: 'body_profile_id')  String? bodyProfileId)?  $default,) {final _that = this;
switch (_that) {
case _AIGenerationRequest() when $default != null:
return $default(_that.outfitId,_that.pose,_that.lighting,_that.bodyProfileId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIGenerationRequest implements AIGenerationRequest {
  const _AIGenerationRequest({@JsonKey(name: 'outfit_id') required this.outfitId, this.pose, this.lighting, @JsonKey(name: 'body_profile_id') this.bodyProfileId});
  factory _AIGenerationRequest.fromJson(Map<String, dynamic> json) => _$AIGenerationRequestFromJson(json);

@override@JsonKey(name: 'outfit_id') final  String outfitId;
@override final  String? pose;
@override final  String? lighting;
@override@JsonKey(name: 'body_profile_id') final  String? bodyProfileId;

/// Create a copy of AIGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIGenerationRequestCopyWith<_AIGenerationRequest> get copyWith => __$AIGenerationRequestCopyWithImpl<_AIGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIGenerationRequest&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.lighting, lighting) || other.lighting == lighting)&&(identical(other.bodyProfileId, bodyProfileId) || other.bodyProfileId == bodyProfileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outfitId,pose,lighting,bodyProfileId);

@override
String toString() {
  return 'AIGenerationRequest(outfitId: $outfitId, pose: $pose, lighting: $lighting, bodyProfileId: $bodyProfileId)';
}


}

/// @nodoc
abstract mixin class _$AIGenerationRequestCopyWith<$Res> implements $AIGenerationRequestCopyWith<$Res> {
  factory _$AIGenerationRequestCopyWith(_AIGenerationRequest value, $Res Function(_AIGenerationRequest) _then) = __$AIGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'outfit_id') String outfitId, String? pose, String? lighting,@JsonKey(name: 'body_profile_id') String? bodyProfileId
});




}
/// @nodoc
class __$AIGenerationRequestCopyWithImpl<$Res>
    implements _$AIGenerationRequestCopyWith<$Res> {
  __$AIGenerationRequestCopyWithImpl(this._self, this._then);

  final _AIGenerationRequest _self;
  final $Res Function(_AIGenerationRequest) _then;

/// Create a copy of AIGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outfitId = null,Object? pose = freezed,Object? lighting = freezed,Object? bodyProfileId = freezed,}) {
  return _then(_AIGenerationRequest(
outfitId: null == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as String,pose: freezed == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as String?,lighting: freezed == lighting ? _self.lighting : lighting // ignore: cast_nullable_to_non_nullable
as String?,bodyProfileId: freezed == bodyProfileId ? _self.bodyProfileId : bodyProfileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GenerationStatus {

 String get id; String get status; double? get progress; String? get message; String? get imageUrl; String? get error;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'completed_at') DateTime? get completedAt;
/// Create a copy of GenerationStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationStatusCopyWith<GenerationStatus> get copyWith => _$GenerationStatusCopyWithImpl<GenerationStatus>(this as GenerationStatus, _$identity);

  /// Serializes this GenerationStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.message, message) || other.message == message)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,progress,message,imageUrl,error,createdAt,completedAt);

@override
String toString() {
  return 'GenerationStatus(id: $id, status: $status, progress: $progress, message: $message, imageUrl: $imageUrl, error: $error, createdAt: $createdAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $GenerationStatusCopyWith<$Res>  {
  factory $GenerationStatusCopyWith(GenerationStatus value, $Res Function(GenerationStatus) _then) = _$GenerationStatusCopyWithImpl;
@useResult
$Res call({
 String id, String status, double? progress, String? message, String? imageUrl, String? error,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'completed_at') DateTime? completedAt
});




}
/// @nodoc
class _$GenerationStatusCopyWithImpl<$Res>
    implements $GenerationStatusCopyWith<$Res> {
  _$GenerationStatusCopyWithImpl(this._self, this._then);

  final GenerationStatus _self;
  final $Res Function(GenerationStatus) _then;

/// Create a copy of GenerationStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? progress = freezed,Object? message = freezed,Object? imageUrl = freezed,Object? error = freezed,Object? createdAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GenerationStatus].
extension GenerationStatusPatterns on GenerationStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerationStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerationStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerationStatus value)  $default,){
final _that = this;
switch (_that) {
case _GenerationStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerationStatus value)?  $default,){
final _that = this;
switch (_that) {
case _GenerationStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  double? progress,  String? message,  String? imageUrl,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'completed_at')  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationStatus() when $default != null:
return $default(_that.id,_that.status,_that.progress,_that.message,_that.imageUrl,_that.error,_that.createdAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  double? progress,  String? message,  String? imageUrl,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'completed_at')  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _GenerationStatus():
return $default(_that.id,_that.status,_that.progress,_that.message,_that.imageUrl,_that.error,_that.createdAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  double? progress,  String? message,  String? imageUrl,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'completed_at')  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _GenerationStatus() when $default != null:
return $default(_that.id,_that.status,_that.progress,_that.message,_that.imageUrl,_that.error,_that.createdAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenerationStatus implements GenerationStatus {
  const _GenerationStatus({required this.id, required this.status, this.progress, this.message, this.imageUrl, this.error, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'completed_at') this.completedAt});
  factory _GenerationStatus.fromJson(Map<String, dynamic> json) => _$GenerationStatusFromJson(json);

@override final  String id;
@override final  String status;
@override final  double? progress;
@override final  String? message;
@override final  String? imageUrl;
@override final  String? error;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'completed_at') final  DateTime? completedAt;

/// Create a copy of GenerationStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationStatusCopyWith<_GenerationStatus> get copyWith => __$GenerationStatusCopyWithImpl<_GenerationStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenerationStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.message, message) || other.message == message)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,progress,message,imageUrl,error,createdAt,completedAt);

@override
String toString() {
  return 'GenerationStatus(id: $id, status: $status, progress: $progress, message: $message, imageUrl: $imageUrl, error: $error, createdAt: $createdAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$GenerationStatusCopyWith<$Res> implements $GenerationStatusCopyWith<$Res> {
  factory _$GenerationStatusCopyWith(_GenerationStatus value, $Res Function(_GenerationStatus) _then) = __$GenerationStatusCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, double? progress, String? message, String? imageUrl, String? error,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'completed_at') DateTime? completedAt
});




}
/// @nodoc
class __$GenerationStatusCopyWithImpl<$Res>
    implements _$GenerationStatusCopyWith<$Res> {
  __$GenerationStatusCopyWithImpl(this._self, this._then);

  final _GenerationStatus _self;
  final $Res Function(_GenerationStatus) _then;

/// Create a copy of GenerationStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? progress = freezed,Object? message = freezed,Object? imageUrl = freezed,Object? error = freezed,Object? createdAt = freezed,Object? completedAt = freezed,}) {
  return _then(_GenerationStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SharedOutfitModel {

 String get id; String get name; String? get description; Style get style; Season get season;@JsonKey(name: 'item_images') List<String> get itemImages;@JsonKey(name: 'outfit_images') List<String>? get outfitImages;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'share_count') int get shareCount;@JsonKey(name: 'view_count') int get viewCount;
/// Create a copy of SharedOutfitModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedOutfitModelCopyWith<SharedOutfitModel> get copyWith => _$SharedOutfitModelCopyWithImpl<SharedOutfitModel>(this as SharedOutfitModel, _$identity);

  /// Serializes this SharedOutfitModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedOutfitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&const DeepCollectionEquality().equals(other.itemImages, itemImages)&&const DeepCollectionEquality().equals(other.outfitImages, outfitImages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,style,season,const DeepCollectionEquality().hash(itemImages),const DeepCollectionEquality().hash(outfitImages),createdAt,shareCount,viewCount);

@override
String toString() {
  return 'SharedOutfitModel(id: $id, name: $name, description: $description, style: $style, season: $season, itemImages: $itemImages, outfitImages: $outfitImages, createdAt: $createdAt, shareCount: $shareCount, viewCount: $viewCount)';
}


}

/// @nodoc
abstract mixin class $SharedOutfitModelCopyWith<$Res>  {
  factory $SharedOutfitModelCopyWith(SharedOutfitModel value, $Res Function(SharedOutfitModel) _then) = _$SharedOutfitModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, Style style, Season season,@JsonKey(name: 'item_images') List<String> itemImages,@JsonKey(name: 'outfit_images') List<String>? outfitImages,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'share_count') int shareCount,@JsonKey(name: 'view_count') int viewCount
});




}
/// @nodoc
class _$SharedOutfitModelCopyWithImpl<$Res>
    implements $SharedOutfitModelCopyWith<$Res> {
  _$SharedOutfitModelCopyWithImpl(this._self, this._then);

  final SharedOutfitModel _self;
  final $Res Function(SharedOutfitModel) _then;

/// Create a copy of SharedOutfitModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? style = null,Object? season = null,Object? itemImages = null,Object? outfitImages = freezed,Object? createdAt = null,Object? shareCount = null,Object? viewCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style,season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season,itemImages: null == itemImages ? _self.itemImages : itemImages // ignore: cast_nullable_to_non_nullable
as List<String>,outfitImages: freezed == outfitImages ? _self.outfitImages : outfitImages // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedOutfitModel].
extension SharedOutfitModelPatterns on SharedOutfitModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedOutfitModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedOutfitModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedOutfitModel value)  $default,){
final _that = this;
switch (_that) {
case _SharedOutfitModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedOutfitModel value)?  $default,){
final _that = this;
switch (_that) {
case _SharedOutfitModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Style style,  Season season, @JsonKey(name: 'item_images')  List<String> itemImages, @JsonKey(name: 'outfit_images')  List<String>? outfitImages, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'view_count')  int viewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedOutfitModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.style,_that.season,_that.itemImages,_that.outfitImages,_that.createdAt,_that.shareCount,_that.viewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Style style,  Season season, @JsonKey(name: 'item_images')  List<String> itemImages, @JsonKey(name: 'outfit_images')  List<String>? outfitImages, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'view_count')  int viewCount)  $default,) {final _that = this;
switch (_that) {
case _SharedOutfitModel():
return $default(_that.id,_that.name,_that.description,_that.style,_that.season,_that.itemImages,_that.outfitImages,_that.createdAt,_that.shareCount,_that.viewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  Style style,  Season season, @JsonKey(name: 'item_images')  List<String> itemImages, @JsonKey(name: 'outfit_images')  List<String>? outfitImages, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'view_count')  int viewCount)?  $default,) {final _that = this;
switch (_that) {
case _SharedOutfitModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.style,_that.season,_that.itemImages,_that.outfitImages,_that.createdAt,_that.shareCount,_that.viewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SharedOutfitModel implements SharedOutfitModel {
  const _SharedOutfitModel({required this.id, required this.name, this.description, required this.style, required this.season, @JsonKey(name: 'item_images') required final  List<String> itemImages, @JsonKey(name: 'outfit_images') final  List<String>? outfitImages, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'share_count') this.shareCount = 0, @JsonKey(name: 'view_count') this.viewCount = 0}): _itemImages = itemImages,_outfitImages = outfitImages;
  factory _SharedOutfitModel.fromJson(Map<String, dynamic> json) => _$SharedOutfitModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  Style style;
@override final  Season season;
 final  List<String> _itemImages;
@override@JsonKey(name: 'item_images') List<String> get itemImages {
  if (_itemImages is EqualUnmodifiableListView) return _itemImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itemImages);
}

 final  List<String>? _outfitImages;
@override@JsonKey(name: 'outfit_images') List<String>? get outfitImages {
  final value = _outfitImages;
  if (value == null) return null;
  if (_outfitImages is EqualUnmodifiableListView) return _outfitImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'share_count') final  int shareCount;
@override@JsonKey(name: 'view_count') final  int viewCount;

/// Create a copy of SharedOutfitModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedOutfitModelCopyWith<_SharedOutfitModel> get copyWith => __$SharedOutfitModelCopyWithImpl<_SharedOutfitModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharedOutfitModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedOutfitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.style, style) || other.style == style)&&(identical(other.season, season) || other.season == season)&&const DeepCollectionEquality().equals(other._itemImages, _itemImages)&&const DeepCollectionEquality().equals(other._outfitImages, _outfitImages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,style,season,const DeepCollectionEquality().hash(_itemImages),const DeepCollectionEquality().hash(_outfitImages),createdAt,shareCount,viewCount);

@override
String toString() {
  return 'SharedOutfitModel(id: $id, name: $name, description: $description, style: $style, season: $season, itemImages: $itemImages, outfitImages: $outfitImages, createdAt: $createdAt, shareCount: $shareCount, viewCount: $viewCount)';
}


}

/// @nodoc
abstract mixin class _$SharedOutfitModelCopyWith<$Res> implements $SharedOutfitModelCopyWith<$Res> {
  factory _$SharedOutfitModelCopyWith(_SharedOutfitModel value, $Res Function(_SharedOutfitModel) _then) = __$SharedOutfitModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, Style style, Season season,@JsonKey(name: 'item_images') List<String> itemImages,@JsonKey(name: 'outfit_images') List<String>? outfitImages,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'share_count') int shareCount,@JsonKey(name: 'view_count') int viewCount
});




}
/// @nodoc
class __$SharedOutfitModelCopyWithImpl<$Res>
    implements _$SharedOutfitModelCopyWith<$Res> {
  __$SharedOutfitModelCopyWithImpl(this._self, this._then);

  final _SharedOutfitModel _self;
  final $Res Function(_SharedOutfitModel) _then;

/// Create a copy of SharedOutfitModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? style = null,Object? season = null,Object? itemImages = null,Object? outfitImages = freezed,Object? createdAt = null,Object? shareCount = null,Object? viewCount = null,}) {
  return _then(_SharedOutfitModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style,season: null == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as Season,itemImages: null == itemImages ? _self._itemImages : itemImages // ignore: cast_nullable_to_non_nullable
as List<String>,outfitImages: freezed == outfitImages ? _self._outfitImages : outfitImages // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OutfitVisualizationResult {

 String get id; String get status; String? get imageUrl;@JsonKey(name: 'image_base64') String? get imageBase64; String? get error;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of OutfitVisualizationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfitVisualizationResultCopyWith<OutfitVisualizationResult> get copyWith => _$OutfitVisualizationResultCopyWithImpl<OutfitVisualizationResult>(this as OutfitVisualizationResult, _$identity);

  /// Serializes this OutfitVisualizationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutfitVisualizationResult&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,imageUrl,imageBase64,error,createdAt);

@override
String toString() {
  return 'OutfitVisualizationResult(id: $id, status: $status, imageUrl: $imageUrl, imageBase64: $imageBase64, error: $error, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OutfitVisualizationResultCopyWith<$Res>  {
  factory $OutfitVisualizationResultCopyWith(OutfitVisualizationResult value, $Res Function(OutfitVisualizationResult) _then) = _$OutfitVisualizationResultCopyWithImpl;
@useResult
$Res call({
 String id, String status, String? imageUrl,@JsonKey(name: 'image_base64') String? imageBase64, String? error,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$OutfitVisualizationResultCopyWithImpl<$Res>
    implements $OutfitVisualizationResultCopyWith<$Res> {
  _$OutfitVisualizationResultCopyWithImpl(this._self, this._then);

  final OutfitVisualizationResult _self;
  final $Res Function(OutfitVisualizationResult) _then;

/// Create a copy of OutfitVisualizationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? imageUrl = freezed,Object? imageBase64 = freezed,Object? error = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutfitVisualizationResult].
extension OutfitVisualizationResultPatterns on OutfitVisualizationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutfitVisualizationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutfitVisualizationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutfitVisualizationResult value)  $default,){
final _that = this;
switch (_that) {
case _OutfitVisualizationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutfitVisualizationResult value)?  $default,){
final _that = this;
switch (_that) {
case _OutfitVisualizationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String? imageUrl, @JsonKey(name: 'image_base64')  String? imageBase64,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutfitVisualizationResult() when $default != null:
return $default(_that.id,_that.status,_that.imageUrl,_that.imageBase64,_that.error,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String? imageUrl, @JsonKey(name: 'image_base64')  String? imageBase64,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _OutfitVisualizationResult():
return $default(_that.id,_that.status,_that.imageUrl,_that.imageBase64,_that.error,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String? imageUrl, @JsonKey(name: 'image_base64')  String? imageBase64,  String? error, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OutfitVisualizationResult() when $default != null:
return $default(_that.id,_that.status,_that.imageUrl,_that.imageBase64,_that.error,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutfitVisualizationResult implements OutfitVisualizationResult {
  const _OutfitVisualizationResult({required this.id, required this.status, this.imageUrl, @JsonKey(name: 'image_base64') this.imageBase64, this.error, @JsonKey(name: 'created_at') this.createdAt});
  factory _OutfitVisualizationResult.fromJson(Map<String, dynamic> json) => _$OutfitVisualizationResultFromJson(json);

@override final  String id;
@override final  String status;
@override final  String? imageUrl;
@override@JsonKey(name: 'image_base64') final  String? imageBase64;
@override final  String? error;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of OutfitVisualizationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutfitVisualizationResultCopyWith<_OutfitVisualizationResult> get copyWith => __$OutfitVisualizationResultCopyWithImpl<_OutfitVisualizationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutfitVisualizationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutfitVisualizationResult&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,imageUrl,imageBase64,error,createdAt);

@override
String toString() {
  return 'OutfitVisualizationResult(id: $id, status: $status, imageUrl: $imageUrl, imageBase64: $imageBase64, error: $error, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OutfitVisualizationResultCopyWith<$Res> implements $OutfitVisualizationResultCopyWith<$Res> {
  factory _$OutfitVisualizationResultCopyWith(_OutfitVisualizationResult value, $Res Function(_OutfitVisualizationResult) _then) = __$OutfitVisualizationResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String? imageUrl,@JsonKey(name: 'image_base64') String? imageBase64, String? error,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$OutfitVisualizationResultCopyWithImpl<$Res>
    implements _$OutfitVisualizationResultCopyWith<$Res> {
  __$OutfitVisualizationResultCopyWithImpl(this._self, this._then);

  final _OutfitVisualizationResult _self;
  final $Res Function(_OutfitVisualizationResult) _then;

/// Create a copy of OutfitVisualizationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? imageUrl = freezed,Object? imageBase64 = freezed,Object? error = freezed,Object? createdAt = freezed,}) {
  return _then(_OutfitVisualizationResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$WearHistoryEntry {

 String get id;@JsonKey(name: 'outfit_id') String get outfitId;@JsonKey(name: 'worn_at') DateTime get wornAt; String? get notes;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of WearHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WearHistoryEntryCopyWith<WearHistoryEntry> get copyWith => _$WearHistoryEntryCopyWithImpl<WearHistoryEntry>(this as WearHistoryEntry, _$identity);

  /// Serializes this WearHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WearHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.wornAt, wornAt) || other.wornAt == wornAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,outfitId,wornAt,notes,createdAt);

@override
String toString() {
  return 'WearHistoryEntry(id: $id, outfitId: $outfitId, wornAt: $wornAt, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WearHistoryEntryCopyWith<$Res>  {
  factory $WearHistoryEntryCopyWith(WearHistoryEntry value, $Res Function(WearHistoryEntry) _then) = _$WearHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'outfit_id') String outfitId,@JsonKey(name: 'worn_at') DateTime wornAt, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$WearHistoryEntryCopyWithImpl<$Res>
    implements $WearHistoryEntryCopyWith<$Res> {
  _$WearHistoryEntryCopyWithImpl(this._self, this._then);

  final WearHistoryEntry _self;
  final $Res Function(WearHistoryEntry) _then;

/// Create a copy of WearHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? outfitId = null,Object? wornAt = null,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,outfitId: null == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as String,wornAt: null == wornAt ? _self.wornAt : wornAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WearHistoryEntry].
extension WearHistoryEntryPatterns on WearHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WearHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WearHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WearHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _WearHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WearHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WearHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'outfit_id')  String outfitId, @JsonKey(name: 'worn_at')  DateTime wornAt,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WearHistoryEntry() when $default != null:
return $default(_that.id,_that.outfitId,_that.wornAt,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'outfit_id')  String outfitId, @JsonKey(name: 'worn_at')  DateTime wornAt,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _WearHistoryEntry():
return $default(_that.id,_that.outfitId,_that.wornAt,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'outfit_id')  String outfitId, @JsonKey(name: 'worn_at')  DateTime wornAt,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WearHistoryEntry() when $default != null:
return $default(_that.id,_that.outfitId,_that.wornAt,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WearHistoryEntry implements WearHistoryEntry {
  const _WearHistoryEntry({required this.id, @JsonKey(name: 'outfit_id') required this.outfitId, @JsonKey(name: 'worn_at') required this.wornAt, this.notes, @JsonKey(name: 'created_at') this.createdAt});
  factory _WearHistoryEntry.fromJson(Map<String, dynamic> json) => _$WearHistoryEntryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'outfit_id') final  String outfitId;
@override@JsonKey(name: 'worn_at') final  DateTime wornAt;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of WearHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WearHistoryEntryCopyWith<_WearHistoryEntry> get copyWith => __$WearHistoryEntryCopyWithImpl<_WearHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WearHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WearHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.outfitId, outfitId) || other.outfitId == outfitId)&&(identical(other.wornAt, wornAt) || other.wornAt == wornAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,outfitId,wornAt,notes,createdAt);

@override
String toString() {
  return 'WearHistoryEntry(id: $id, outfitId: $outfitId, wornAt: $wornAt, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WearHistoryEntryCopyWith<$Res> implements $WearHistoryEntryCopyWith<$Res> {
  factory _$WearHistoryEntryCopyWith(_WearHistoryEntry value, $Res Function(_WearHistoryEntry) _then) = __$WearHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'outfit_id') String outfitId,@JsonKey(name: 'worn_at') DateTime wornAt, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$WearHistoryEntryCopyWithImpl<$Res>
    implements _$WearHistoryEntryCopyWith<$Res> {
  __$WearHistoryEntryCopyWithImpl(this._self, this._then);

  final _WearHistoryEntry _self;
  final $Res Function(_WearHistoryEntry) _then;

/// Create a copy of WearHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? outfitId = null,Object? wornAt = null,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_WearHistoryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,outfitId: null == outfitId ? _self.outfitId : outfitId // ignore: cast_nullable_to_non_nullable
as String,wornAt: null == wornAt ? _self.wornAt : wornAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
