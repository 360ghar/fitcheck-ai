// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemModelImpl _$$ItemModelImplFromJson(Map<String, dynamic> json) =>
    _$ItemModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
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

Map<String, dynamic> _$$ItemModelImplToJson(_$ItemModelImpl instance) =>
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

_$ItemImageImpl _$$ItemImageImplFromJson(Map<String, dynamic> json) =>
    _$ItemImageImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      blurhash: json['blurhash'] as String?,
    );

Map<String, dynamic> _$$ItemImageImplToJson(_$ItemImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'is_primary': instance.isPrimary,
      'width': instance.width,
      'height': instance.height,
      'blurhash': instance.blurhash,
    };

_$CreateItemRequestImpl _$$CreateItemRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateItemRequestImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      condition: $enumDecodeNullable(_$ConditionEnumMap, json['condition']) ??
          Condition.clean,
      price: (json['price'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
      location: json['location'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$CreateItemRequestImplToJson(
        _$CreateItemRequestImpl instance) =>
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
    };

_$UpdateItemRequestImpl _$$UpdateItemRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateItemRequestImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: $enumDecodeNullable(_$CategoryEnumMap, json['category']),
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
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
    );

Map<String, dynamic> _$$UpdateItemRequestImplToJson(
        _$UpdateItemRequestImpl instance) =>
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
    };

_$ItemsListResponseImpl _$$ItemsListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ItemsListResponseImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$$ItemsListResponseImplToJson(
        _$ItemsListResponseImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'has_more': instance.hasMore,
    };

_$ExtractedItemImpl _$$ExtractedItemImplFromJson(Map<String, dynamic> json) =>
    _$ExtractedItemImpl(
      name: json['name'] as String,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      description: json['description'] as String?,
      boundingBox: json['bounding_box'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ExtractedItemImplToJson(_$ExtractedItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': _$CategoryEnumMap[instance.category]!,
      'colors': instance.colors,
      'material': instance.material,
      'pattern': instance.pattern,
      'description': instance.description,
      'bounding_box': instance.boundingBox,
    };

_$ExtractionResponseImpl _$$ExtractionResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ExtractionResponseImpl(
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

Map<String, dynamic> _$$ExtractionResponseImplToJson(
        _$ExtractionResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'items': instance.items,
      'imageUrl': instance.imageUrl,
      'error': instance.error,
      'created_at': instance.createdAt?.toIso8601String(),
    };
