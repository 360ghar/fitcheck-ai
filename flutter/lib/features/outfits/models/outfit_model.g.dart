// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OutfitModelImpl _$$OutfitModelImplFromJson(Map<String, dynamic> json) =>
    _$OutfitModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      itemIds:
          (json['item_ids'] as List<dynamic>).map((e) => e as String).toList(),
      style: $enumDecodeNullable(_$StyleEnumMap, json['style']),
      season: $enumDecodeNullable(_$SeasonEnumMap, json['season']),
      occasion: json['occasion'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      isDraft: json['is_draft'] as bool? ?? false,
      isPublic: json['is_public'] as bool? ?? false,
      wornCount: (json['worn_count'] as num?)?.toInt() ?? 0,
      lastWornAt: json['last_worn_at'] == null
          ? null
          : DateTime.parse(json['last_worn_at'] as String),
      outfitImages: (json['outfit_images'] as List<dynamic>?)
          ?.map((e) => OutfitImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$OutfitModelImplToJson(_$OutfitModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'item_ids': instance.itemIds,
      'style': _$StyleEnumMap[instance.style],
      'season': _$SeasonEnumMap[instance.season],
      'occasion': instance.occasion,
      'tags': instance.tags,
      'is_favorite': instance.isFavorite,
      'is_draft': instance.isDraft,
      'is_public': instance.isPublic,
      'worn_count': instance.wornCount,
      'last_worn_at': instance.lastWornAt?.toIso8601String(),
      'outfit_images': instance.outfitImages,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$StyleEnumMap = {
  Style.casual: 'casual',
  Style.formal: 'formal',
  Style.business: 'business',
  Style.sporty: 'sporty',
  Style.bohemian: 'bohemian',
  Style.streetwear: 'streetwear',
  Style.vintage: 'vintage',
  Style.minimalist: 'minimalist',
  Style.romantic: 'romantic',
  Style.edgy: 'edgy',
  Style.preppy: 'preppy',
  Style.artsy: 'artsy',
  Style.other: 'other',
};

const _$SeasonEnumMap = {
  Season.spring: 'spring',
  Season.summer: 'summer',
  Season.fall: 'fall',
  Season.winter: 'winter',
  Season.allSeason: 'allSeason',
};

_$OutfitImageImpl _$$OutfitImageImplFromJson(Map<String, dynamic> json) =>
    _$OutfitImageImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String?,
      pose: json['pose'] as String?,
      lighting: json['lighting'] as String?,
      bodyProfileId: json['body_profile_id'] as String?,
      isGenerated: json['is_generated'] as bool? ?? false,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      blurhash: json['blurhash'] as String?,
    );

Map<String, dynamic> _$$OutfitImageImplToJson(_$OutfitImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'pose': instance.pose,
      'lighting': instance.lighting,
      'body_profile_id': instance.bodyProfileId,
      'is_generated': instance.isGenerated,
      'width': instance.width,
      'height': instance.height,
      'blurhash': instance.blurhash,
    };

_$CreateOutfitRequestImpl _$$CreateOutfitRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateOutfitRequestImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      itemIds:
          (json['itemIds'] as List<dynamic>).map((e) => e as String).toList(),
      style: $enumDecodeNullable(_$StyleEnumMap, json['style']),
      season: $enumDecodeNullable(_$SeasonEnumMap, json['season']),
      occasion: json['occasion'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$CreateOutfitRequestImplToJson(
        _$CreateOutfitRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'itemIds': instance.itemIds,
      'style': _$StyleEnumMap[instance.style],
      'season': _$SeasonEnumMap[instance.season],
      'occasion': instance.occasion,
      'tags': instance.tags,
    };

_$UpdateOutfitRequestImpl _$$UpdateOutfitRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateOutfitRequestImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      itemIds:
          (json['itemIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
      style: $enumDecodeNullable(_$StyleEnumMap, json['style']),
      season: $enumDecodeNullable(_$SeasonEnumMap, json['season']),
      occasion: json['occasion'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isFavorite: json['isFavorite'] as bool?,
      isDraft: json['isDraft'] as bool?,
      isPublic: json['isPublic'] as bool?,
    );

Map<String, dynamic> _$$UpdateOutfitRequestImplToJson(
        _$UpdateOutfitRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'itemIds': instance.itemIds,
      'style': _$StyleEnumMap[instance.style],
      'season': _$SeasonEnumMap[instance.season],
      'occasion': instance.occasion,
      'tags': instance.tags,
      'isFavorite': instance.isFavorite,
      'isDraft': instance.isDraft,
      'isPublic': instance.isPublic,
    };

_$OutfitsListResponseImpl _$$OutfitsListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$OutfitsListResponseImpl(
      outfits: (json['outfits'] as List<dynamic>)
          .map((e) => OutfitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$$OutfitsListResponseImplToJson(
        _$OutfitsListResponseImpl instance) =>
    <String, dynamic>{
      'outfits': instance.outfits,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'has_more': instance.hasMore,
    };

_$AIGenerationRequestImpl _$$AIGenerationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AIGenerationRequestImpl(
      outfitId: json['outfit_id'] as String,
      pose: json['pose'] as String?,
      lighting: json['lighting'] as String?,
      bodyProfileId: json['body_profile_id'] as String?,
    );

Map<String, dynamic> _$$AIGenerationRequestImplToJson(
        _$AIGenerationRequestImpl instance) =>
    <String, dynamic>{
      'outfit_id': instance.outfitId,
      'pose': instance.pose,
      'lighting': instance.lighting,
      'body_profile_id': instance.bodyProfileId,
    };

_$GenerationStatusImpl _$$GenerationStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$GenerationStatusImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toDouble(),
      message: json['message'] as String?,
      imageUrl: json['imageUrl'] as String?,
      error: json['error'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$$GenerationStatusImplToJson(
        _$GenerationStatusImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'progress': instance.progress,
      'message': instance.message,
      'imageUrl': instance.imageUrl,
      'error': instance.error,
      'created_at': instance.createdAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };

_$SharedOutfitModelImpl _$$SharedOutfitModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SharedOutfitModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      style: $enumDecode(_$StyleEnumMap, json['style']),
      season: $enumDecode(_$SeasonEnumMap, json['season']),
      itemImages: (json['item_images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      outfitImages: (json['outfit_images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SharedOutfitModelImplToJson(
        _$SharedOutfitModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'style': _$StyleEnumMap[instance.style]!,
      'season': _$SeasonEnumMap[instance.season]!,
      'item_images': instance.itemImages,
      'outfit_images': instance.outfitImages,
      'created_at': instance.createdAt.toIso8601String(),
      'share_count': instance.shareCount,
      'view_count': instance.viewCount,
    };

_$OutfitVisualizationResultImpl _$$OutfitVisualizationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$OutfitVisualizationResultImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String?,
      imageBase64: json['image_base64'] as String?,
      error: json['error'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$OutfitVisualizationResultImplToJson(
        _$OutfitVisualizationResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'imageUrl': instance.imageUrl,
      'image_base64': instance.imageBase64,
      'error': instance.error,
      'created_at': instance.createdAt?.toIso8601String(),
    };
