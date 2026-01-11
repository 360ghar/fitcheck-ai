import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

/// Item model for wardrobe items
@freezed
class ItemModel with _$ItemModel {
  const factory ItemModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? description,
    required Category category,
    List<String>? colors,
    String? brand,
    String? size,
    String? material,
    String? pattern,
    required Condition condition,
    double? price,
    @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
    String? location,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    List<String>? tags,
    @JsonKey(name: 'item_images') List<ItemImage>? itemImages,
    @JsonKey(name: 'worn_count') @Default(0) int wornCount,
    @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);
}

/// Item image model
@freezed
class ItemImage with _$ItemImage {
  const factory ItemImage({
    required String id,
    required String url,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    int? width,
    int? height,
    String? blurhash,
  }) = _ItemImage;

  factory ItemImage.fromJson(Map<String, dynamic> json) =>
      _$ItemImageFromJson(json);
}

/// Create item request model
@freezed
class CreateItemRequest with _$CreateItemRequest {
  const factory CreateItemRequest({
    required String name,
    String? description,
    required Category category,
    List<String>? colors,
    String? brand,
    String? size,
    String? material,
    String? pattern,
    @Default(Condition.clean) Condition condition,
    double? price,
    @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
    String? location,
    List<String>? tags,
  }) = _CreateItemRequest;

  factory CreateItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateItemRequestFromJson(json);
}

/// Update item request model
@freezed
class UpdateItemRequest with _$UpdateItemRequest {
  const factory UpdateItemRequest({
    String? name,
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
    List<String>? tags,
  }) = _UpdateItemRequest;

  factory UpdateItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateItemRequestFromJson(json);
}

/// Items list response model
@freezed
class ItemsListResponse with _$ItemsListResponse {
  const factory ItemsListResponse({
    required List<ItemModel> items,
    required int total,
    required int page,
    required int limit,
    @JsonKey(name: 'has_more') required bool hasMore,
  }) = _ItemsListResponse;

  factory ItemsListResponse.fromJson(Map<String, dynamic> json) =>
      _$ItemsListResponseFromJson(json);
}

/// Extracted item from AI model
@freezed
class ExtractedItem with _$ExtractedItem {
  const factory ExtractedItem({
    required String name,
    required Category category,
    List<String>? colors,
    String? material,
    String? pattern,
    String? description,
    @JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox,
  }) = _ExtractedItem;

  factory ExtractedItem.fromJson(Map<String, dynamic> json) =>
      _$ExtractedItemFromJson(json);
}

/// AI extraction response model
@freezed
class ExtractionResponse with _$ExtractionResponse {
  const factory ExtractionResponse({
    required String id,
    required String status,
    List<ExtractedItem>? items,
    String? imageUrl,
    String? error,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ExtractionResponse;

  factory ExtractionResponse.fromJson(Map<String, dynamic> json) =>
      _$ExtractionResponseFromJson(json);
}
