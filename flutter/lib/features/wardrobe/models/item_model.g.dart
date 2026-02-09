// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => _ItemModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  category: $enumDecode(_$CategoryEnumMap, json['category']),
  colors: (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  brand: json['brand'] as String?,
  size: json['size'] as String?,
  material: json['material'] as String?,
  pattern: json['pattern'] as String?,
  condition: $enumDecode(_$ConditionEnumMap, json['condition']),
  price: (json['price'] as num?)?.toDouble(),
  purchaseDate: json['purchase_date'] == null
      ? null
      : DateTime.parse(json['purchase_date'] as String),
  location: json['location'] as String?,
  isFavorite: json['is_favorite'] as bool? ?? false,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  occasionTags: (json['occasion_tags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  itemImages: (json['item_images'] as List<dynamic>?)
      ?.map((e) => ItemImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  wornCount: (json['worn_count'] as num?)?.toInt() ?? 0,
  lastWornAt: json['last_worn_at'] == null
      ? null
      : DateTime.parse(json['last_worn_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ItemModelToJson(_ItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'category': _$CategoryEnumMap[instance.category]!,
      'colors': instance.colors,
      'brand': instance.brand,
      'size': instance.size,
      'material': instance.material,
      'pattern': instance.pattern,
      'condition': _$ConditionEnumMap[instance.condition]!,
      'price': instance.price,
      'purchase_date': instance.purchaseDate?.toIso8601String(),
      'location': instance.location,
      'is_favorite': instance.isFavorite,
      'tags': instance.tags,
      'occasion_tags': instance.occasionTags,
      'item_images': instance.itemImages,
      'worn_count': instance.wornCount,
      'last_worn_at': instance.lastWornAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$CategoryEnumMap = {
  Category.tops: 'tops',
  Category.bottoms: 'bottoms',
  Category.shoes: 'shoes',
  Category.accessories: 'accessories',
  Category.outerwear: 'outerwear',
  Category.swimwear: 'swimwear',
  Category.activewear: 'activewear',
  Category.other: 'other',
};

const _$ConditionEnumMap = {
  Condition.clean: 'clean',
  Condition.dirty: 'dirty',
  Condition.laundry: 'laundry',
  Condition.repair: 'repair',
  Condition.donate: 'donate',
};

_ItemImage _$ItemImageFromJson(Map<String, dynamic> json) => _ItemImage(
  id: json['id'] as String,
  url: json['url'] as String,
  isPrimary: json['is_primary'] as bool? ?? false,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  blurhash: json['blurhash'] as String?,
);

Map<String, dynamic> _$ItemImageToJson(_ItemImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'is_primary': instance.isPrimary,
      'width': instance.width,
      'height': instance.height,
      'blurhash': instance.blurhash,
    };

_CreateItemRequest _$CreateItemRequestFromJson(Map<String, dynamic> json) =>
    _CreateItemRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      condition:
          $enumDecodeNullable(_$ConditionEnumMap, json['condition']) ??
          Condition.clean,
      price: (json['price'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
      location: json['location'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      occasionTags: (json['occasion_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateItemRequestToJson(_CreateItemRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category': _$CategoryEnumMap[instance.category]!,
      'colors': instance.colors,
      'brand': instance.brand,
      'size': instance.size,
      'material': instance.material,
      'pattern': instance.pattern,
      'condition': _$ConditionEnumMap[instance.condition]!,
      'price': instance.price,
      'purchase_date': instance.purchaseDate?.toIso8601String(),
      'location': instance.location,
      'tags': instance.tags,
      'occasion_tags': instance.occasionTags,
    };

_UpdateItemRequest _$UpdateItemRequestFromJson(Map<String, dynamic> json) =>
    _UpdateItemRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: $enumDecodeNullable(_$CategoryEnumMap, json['category']),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      condition: $enumDecodeNullable(_$ConditionEnumMap, json['condition']),
      price: (json['price'] as num?)?.toDouble(),
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      location: json['location'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      occasionTags: (json['occasion_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UpdateItemRequestToJson(_UpdateItemRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category': _$CategoryEnumMap[instance.category],
      'colors': instance.colors,
      'brand': instance.brand,
      'size': instance.size,
      'material': instance.material,
      'pattern': instance.pattern,
      'condition': _$ConditionEnumMap[instance.condition],
      'price': instance.price,
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'location': instance.location,
      'tags': instance.tags,
      'occasion_tags': instance.occasionTags,
    };

_ItemsListResponse _$ItemsListResponseFromJson(Map<String, dynamic> json) =>
    _ItemsListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$ItemsListResponseToJson(_ItemsListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'has_more': instance.hasMore,
    };

_ExtractedItem _$ExtractedItemFromJson(Map<String, dynamic> json) =>
    _ExtractedItem(
      name: json['name'] as String,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      description: json['description'] as String?,
      boundingBox: json['bounding_box'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ExtractedItemToJson(_ExtractedItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': _$CategoryEnumMap[instance.category]!,
      'colors': instance.colors,
      'material': instance.material,
      'pattern': instance.pattern,
      'description': instance.description,
      'bounding_box': instance.boundingBox,
    };

_ExtractionResponse _$ExtractionResponseFromJson(Map<String, dynamic> json) =>
    _ExtractionResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ExtractedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      error: json['error'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ExtractionResponseToJson(_ExtractionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'items': instance.items,
      'imageUrl': instance.imageUrl,
      'error': instance.error,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) => _BoundingBox(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
);

Map<String, dynamic> _$BoundingBoxToJson(_BoundingBox instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

_ProductImageGenerationRequest _$ProductImageGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _ProductImageGenerationRequest(
  itemDescription: json['itemDescription'] as String,
  category: json['category'] as String,
  subCategory: json['subCategory'] as String?,
  colors: (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  material: json['material'] as String?,
  pattern: json['pattern'] as String?,
  background: json['background'] as String? ?? 'white',
  viewAngle: json['viewAngle'] as String? ?? 'front',
  includeShadows: json['includeShadows'] as bool? ?? false,
  saveToStorage: json['saveToStorage'] as bool? ?? false,
);

Map<String, dynamic> _$ProductImageGenerationRequestToJson(
  _ProductImageGenerationRequest instance,
) => <String, dynamic>{
  'itemDescription': instance.itemDescription,
  'category': instance.category,
  'subCategory': instance.subCategory,
  'colors': instance.colors,
  'material': instance.material,
  'pattern': instance.pattern,
  'background': instance.background,
  'viewAngle': instance.viewAngle,
  'includeShadows': instance.includeShadows,
  'saveToStorage': instance.saveToStorage,
};
