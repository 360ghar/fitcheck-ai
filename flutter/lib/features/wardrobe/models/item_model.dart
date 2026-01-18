import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

/// Item model for wardrobe items
@freezed
abstract class ItemModel with _$ItemModel {
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
abstract class ItemImage with _$ItemImage {
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
abstract class CreateItemRequest with _$CreateItemRequest {
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
abstract class UpdateItemRequest with _$UpdateItemRequest {
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
abstract class ItemsListResponse with _$ItemsListResponse {
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
abstract class ExtractedItem with _$ExtractedItem {
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
abstract class ExtractionResponse with _$ExtractionResponse {
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

/// Bounding box for detected items in an image
@freezed
abstract class BoundingBox with _$BoundingBox {
  const factory BoundingBox({
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _BoundingBox;

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);
}

/// Detected item data from synchronous AI extraction (actual backend format)
@freezed
abstract class DetectedItemData with _$DetectedItemData {
  const factory DetectedItemData({
    required String tempId,
    required String category,
    @JsonKey(name: 'sub_category') String? subCategory,
    List<String>? colors,
    String? material,
    String? pattern,
    String? brand,
    required double confidence,
    @JsonKey(name: 'detailed_description') String? detailedDescription,
    @Default('detected') String status,
  }) = _DetectedItemData;

  factory DetectedItemData.fromJson(Map<String, dynamic> json) {
    // Defensive parsing to handle backend inconsistencies
    return DetectedItemData(
      tempId: json['temp_id']?.toString() ?? 'unknown',
      category: json['category']?.toString() ?? 'other',
      subCategory: json['sub_category']?.toString(),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e?.toString())
          .where((s) => s != null)
          .cast<String>()
          .toList(),
      material: json['material']?.toString(),
      pattern: json['pattern']?.toString(),
      brand: json['brand']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      detailedDescription: json['detailed_description']?.toString(),
      status: json['status']?.toString() ?? 'detected',
    );
  }
}

/// Synchronous AI extraction response (actual backend format)
/// Backend returns this immediately from /api/v1/ai/extract-items
@freezed
abstract class SyncExtractionResponse with _$SyncExtractionResponse {
  const factory SyncExtractionResponse({
    required List<DetectedItemData> items,
    @JsonKey(name: 'overall_confidence') required double overallConfidence,
    @JsonKey(name: 'image_description') String? imageDescription,
    @JsonKey(name: 'item_count') required int itemCount,
    @JsonKey(name: 'requires_review') @Default(true) bool requiresReview,
  }) = _SyncExtractionResponse;

  factory SyncExtractionResponse.fromJson(Map<String, dynamic> json) {
    // Defensive parsing to handle backend inconsistencies
    final itemsList = json['items'] as List<dynamic>?;
    final items = itemsList?.map((e) {
      if (e is Map<String, dynamic>) {
        return DetectedItemData.fromJson(e);
      }
      return null;
    }).where((e) => e != null).cast<DetectedItemData>().toList() ?? [];

    return SyncExtractionResponse(
      items: items,
      overallConfidence: (json['overall_confidence'] as num?)?.toDouble() ?? 0.0,
      imageDescription: json['image_description'] as String?,
      itemCount: (json['item_count'] as num?)?.toInt() ?? items.length,
      requiresReview: json['requires_review'] as bool? ?? true,
    );
  }
}

/// Request to generate a product image for a detected item
@freezed
abstract class ProductImageGenerationRequest with _$ProductImageGenerationRequest {
  const factory ProductImageGenerationRequest({
    required String itemDescription,
    required String category,
    String? subCategory,
    List<String>? colors,
    String? material,
    String? pattern,
    @Default('white') String background,
    @Default('front') String viewAngle,
    @Default(false) bool includeShadows,
    @Default(false) bool saveToStorage,
  }) = _ProductImageGenerationRequest;

  factory ProductImageGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$ProductImageGenerationRequestFromJson(json);
}

/// Response from product image generation API
@freezed
abstract class ProductImageGenerationResponse with _$ProductImageGenerationResponse {
  const factory ProductImageGenerationResponse({
    @JsonKey(name: 'image_base64') required String imageBase64,
    String? imageUrl,
    String? storagePath,
    required String prompt,
    required String model,
    required String provider,
  }) = _ProductImageGenerationResponse;

  factory ProductImageGenerationResponse.fromJson(Map<String, dynamic> json) {
    return ProductImageGenerationResponse(
      imageBase64: json['image_base64']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      storagePath: json['storage_path']?.toString(),
      prompt: json['prompt']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
    );
  }
}

/// Enhanced DetectedItemData with product image generation support
@freezed
abstract class DetectedItemDataWithImage with _$DetectedItemDataWithImage {
  const factory DetectedItemDataWithImage({
    required String tempId,
    required String category,
    @JsonKey(name: 'sub_category') String? subCategory,
    List<String>? colors,
    String? material,
    String? pattern,
    String? brand,
    required double confidence,
    @JsonKey(name: 'detailed_description') String? detailedDescription,
    @Default('detected') String status,
    /// Generated product image (data URL format: data:image/png;base64,...)
    String? generatedImageUrl,
    /// Error message if generation failed
    String? generationError,
    /// User-editable name
    String? name,
    /// User-editable tags
    List<String>? tags,
  }) = _DetectedItemDataWithImage;

  factory DetectedItemDataWithImage.fromJson(Map<String, dynamic> json) {
    return DetectedItemDataWithImage(
      tempId: json['temp_id']?.toString() ?? 'unknown',
      category: json['category']?.toString() ?? 'other',
      subCategory: json['sub_category']?.toString(),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e?.toString())
          .where((s) => s != null)
          .cast<String>()
          .toList(),
      material: json['material']?.toString(),
      pattern: json['pattern']?.toString(),
      brand: json['brand']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      detailedDescription: json['detailed_description']?.toString(),
      status: json['status']?.toString() ?? 'detected',
      generatedImageUrl: json['generated_image_url']?.toString() ?? json['generatedImageUrl']?.toString(),
      generationError: json['generation_error']?.toString() ?? json['generationError']?.toString(),
      name: json['name']?.toString(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e?.toString())
          .where((s) => s != null)
          .cast<String>()
          .toList(),
    );
  }
}
