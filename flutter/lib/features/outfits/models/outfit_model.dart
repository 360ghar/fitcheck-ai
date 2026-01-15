import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../../wardrobe/models/item_model.dart';

part 'outfit_model.freezed.dart';
part 'outfit_model.g.dart';

/// Outfit model
@freezed
abstract class OutfitModel with _$OutfitModel {
  const factory OutfitModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? description,
    @JsonKey(name: 'item_ids') required List<String> itemIds,
    Style? style,
    Season? season,
    String? occasion,
    List<String>? tags,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    @JsonKey(name: 'is_draft') @Default(false) bool isDraft,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'worn_count') @Default(0) int wornCount,
    @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
    @JsonKey(name: 'outfit_images') List<OutfitImage>? outfitImages,
    List<ItemModel>? items,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _OutfitModel;

  factory OutfitModel.fromJson(Map<String, dynamic> json) =>
      _$OutfitModelFromJson(json);
}

/// Outfit image model
@freezed
abstract class OutfitImage with _$OutfitImage {
  const factory OutfitImage({
    required String id,
    required String url,
    String? type,
    String? pose,
    String? lighting,
    @JsonKey(name: 'body_profile_id') String? bodyProfileId,
    @JsonKey(name: 'is_generated') @Default(false) bool isGenerated,
    int? width,
    int? height,
    String? blurhash,
  }) = _OutfitImage;

  factory OutfitImage.fromJson(Map<String, dynamic> json) =>
      _$OutfitImageFromJson(json);
}

/// Create outfit request model
@freezed
abstract class CreateOutfitRequest with _$CreateOutfitRequest {
  const factory CreateOutfitRequest({
    required String name,
    String? description,
    required List<String> itemIds,
    Style? style,
    Season? season,
    String? occasion,
    List<String>? tags,
  }) = _CreateOutfitRequest;

  factory CreateOutfitRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOutfitRequestFromJson(json);
}

/// Update outfit request model
@freezed
abstract class UpdateOutfitRequest with _$UpdateOutfitRequest {
  const factory UpdateOutfitRequest({
    String? name,
    String? description,
    List<String>? itemIds,
    Style? style,
    Season? season,
    String? occasion,
    List<String>? tags,
    bool? isFavorite,
    bool? isDraft,
    bool? isPublic,
  }) = _UpdateOutfitRequest;

  factory UpdateOutfitRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateOutfitRequestFromJson(json);
}

/// Outfits list response model
@freezed
abstract class OutfitsListResponse with _$OutfitsListResponse {
  const factory OutfitsListResponse({
    required List<OutfitModel> outfits,
    required int total,
    required int page,
    required int limit,
    @JsonKey(name: 'has_more') required bool hasMore,
  }) = _OutfitsListResponse;

  factory OutfitsListResponse.fromJson(Map<String, dynamic> json) =>
      _$OutfitsListResponseFromJson(json);
}

/// AI generation request model
@freezed
abstract class AIGenerationRequest with _$AIGenerationRequest {
  const factory AIGenerationRequest({
    @JsonKey(name: 'outfit_id') required String outfitId,
    String? pose,
    String? lighting,
    @JsonKey(name: 'body_profile_id') String? bodyProfileId,
  }) = _AIGenerationRequest;

  factory AIGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$AIGenerationRequestFromJson(json);
}

/// AI generation status model
@freezed
abstract class GenerationStatus with _$GenerationStatus {
  const factory GenerationStatus({
    required String id,
    required String status,
    double? progress,
    String? message,
    String? imageUrl,
    String? error,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _GenerationStatus;

  factory GenerationStatus.fromJson(Map<String, dynamic> json) =>
      _$GenerationStatusFromJson(json);
}

/// Shared outfit model
@freezed
abstract class SharedOutfitModel with _$SharedOutfitModel {
  const factory SharedOutfitModel({
    required String id,
    required String name,
    String? description,
    required Style style,
    required Season season,
    @JsonKey(name: 'item_images') required List<String> itemImages,
    @JsonKey(name: 'outfit_images') List<String>? outfitImages,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'share_count') @Default(0) int shareCount,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
  }) = _SharedOutfitModel;

  factory SharedOutfitModel.fromJson(Map<String, dynamic> json) =>
      _$SharedOutfitModelFromJson(json);
}

/// Outfit visualization result from AI
@freezed
abstract class OutfitVisualizationResult with _$OutfitVisualizationResult {
  const factory OutfitVisualizationResult({
    required String id,
    required String status,
    String? imageUrl,
    @JsonKey(name: 'image_base64') String? imageBase64,
    String? error,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _OutfitVisualizationResult;

  factory OutfitVisualizationResult.fromJson(Map<String, dynamic> json) =>
      _$OutfitVisualizationResultFromJson(json);
}

/// Wear history entry model
@freezed
abstract class WearHistoryEntry with _$WearHistoryEntry {
  const factory WearHistoryEntry({
    required String id,
    @JsonKey(name: 'outfit_id') required String outfitId,
    @JsonKey(name: 'worn_at') required DateTime wornAt,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _WearHistoryEntry;

  factory WearHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$WearHistoryEntryFromJson(json);
}
