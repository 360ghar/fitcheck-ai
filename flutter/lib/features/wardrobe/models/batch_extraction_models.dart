import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/enums/category.dart';

part 'batch_extraction_models.freezed.dart';
part 'batch_extraction_models.g.dart';

/// Status for individual images in the batch
enum BatchImageStatus {
  pending,
  uploading,
  extracting,
  extracted,
  generating,
  generated,
  failed,
}

/// Status for the overall batch job
enum BatchJobStatus {
  idle,
  uploading,
  extracting,
  generating,
  complete,
  failed,
  cancelled,
}

/// Image in a batch extraction job
@freezed
abstract class BatchImage with _$BatchImage {
  const factory BatchImage({
    required String id,
    required String filePath,
    String? base64Data,
    String? thumbnailPath,
    @Default(BatchImageStatus.pending) BatchImageStatus status,
    String? error,
    @Default([]) List<BatchExtractedItem> extractedItems,
  }) = _BatchImage;

  factory BatchImage.fromJson(Map<String, dynamic> json) =>
      _$BatchImageFromJson(json);
}

/// Batch extraction job state
@freezed
abstract class BatchExtractionJob with _$BatchExtractionJob {
  const factory BatchExtractionJob({
    required String jobId,
    required BatchJobStatus status,
    required int totalImages,
    @Default(0) int extractedCount,
    @Default(0) int generatedCount,
    @Default(0) int failedCount,
    @Default(0) int currentBatch,
    @Default(0) int totalBatches,
    String? error,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _BatchExtractionJob;

  factory BatchExtractionJob.fromJson(Map<String, dynamic> json) =>
      _$BatchExtractionJobFromJson(json);
}

/// Extracted item from batch processing with source reference
@freezed
abstract class BatchExtractedItem with _$BatchExtractedItem {
  const factory BatchExtractedItem({
    @JsonKey(name: 'temp_id') required String id,
    @JsonKey(name: 'image_id') required String sourceImageId,
    required String name,
    required Category category,
    @JsonKey(name: 'sub_category') String? subCategory,
    @Default([]) List<String> colors,
    String? material,
    String? pattern,
    String? brand,
    String? description,
    @JsonKey(name: 'bounding_box') Map<String, dynamic>? boundingBox,
    @JsonKey(name: 'cropped_image_base64') String? croppedImageBase64,
    @JsonKey(name: 'generated_image_base64') String? generatedImageBase64,
    @JsonKey(name: 'generated_image_url') String? generatedImageUrl,
    double? confidence,
    @JsonKey(name: 'person_id') String? personId,
    @JsonKey(name: 'person_label') String? personLabel,
    @JsonKey(name: 'is_current_user_person')
    @Default(false)
    bool isCurrentUserPerson,
    @JsonKey(name: 'include_in_wardrobe') @Default(true) bool includeInWardrobe,
    @JsonKey(unknownEnumValue: BatchItemStatus.pending)
    @Default(BatchItemStatus.pending)
    BatchItemStatus status,
    @Default(true) bool isSelected,
    String? error,
  }) = _BatchExtractedItem;

  factory BatchExtractedItem.fromJson(Map<String, dynamic> json) =>
      _$BatchExtractedItemFromJson(_normalizeBatchExtractedItemJson(json));
}

/// Status for individual extracted items
enum BatchItemStatus { detected, pending, generating, generated, failed }

/// SSE event from batch extraction
@freezed
abstract class SSEEvent with _$SSEEvent {
  const factory SSEEvent({required String type, Map<String, dynamic>? data}) =
      _SSEEvent;

  factory SSEEvent.fromJson(Map<String, dynamic> json) =>
      _$SSEEventFromJson(json);
}

/// Request to start batch extraction
@freezed
abstract class BatchExtractionRequest with _$BatchExtractionRequest {
  const factory BatchExtractionRequest({
    required List<BatchImageInput> images,
    @JsonKey(name: 'auto_generate') @Default(true) bool autoGenerate,
    @JsonKey(name: 'generation_batch_size') @Default(5) int generationBatchSize,
  }) = _BatchExtractionRequest;

  factory BatchExtractionRequest.fromJson(Map<String, dynamic> json) =>
      _$BatchExtractionRequestFromJson(json);
}

/// Input image for batch extraction request
@freezed
abstract class BatchImageInput with _$BatchImageInput {
  const factory BatchImageInput({
    @JsonKey(name: 'image_id') required String imageId,
    @JsonKey(name: 'image_base64') required String imageBase64,
  }) = _BatchImageInput;

  factory BatchImageInput.fromJson(Map<String, dynamic> json) =>
      _$BatchImageInputFromJson(json);
}

/// Response from starting batch extraction
@freezed
abstract class BatchExtractionResponse with _$BatchExtractionResponse {
  const factory BatchExtractionResponse({
    @JsonKey(name: 'job_id') required String jobId,
    required String status,
    @JsonKey(name: 'total_images') required int totalImages,
    String? message,
  }) = _BatchExtractionResponse;

  factory BatchExtractionResponse.fromJson(Map<String, dynamic> json) =>
      _$BatchExtractionResponseFromJson(json);
}

/// Status response for batch extraction job
@freezed
abstract class BatchJobStatusResponse with _$BatchJobStatusResponse {
  const factory BatchJobStatusResponse({
    @JsonKey(name: 'job_id') required String jobId,
    required String status,
    @JsonKey(name: 'total_images') required int totalImages,
    @JsonKey(name: 'extractions_completed') @Default(0) int extractedCount,
    @JsonKey(name: 'generations_completed') @Default(0) int generatedCount,
    @JsonKey(name: 'extractions_failed') @Default(0) int failedCount,
    @JsonKey(name: 'generations_failed') @Default(0) int generationFailedCount,
    @JsonKey(name: 'current_batch') @Default(0) int currentBatch,
    @JsonKey(name: 'total_batches') @Default(0) int totalBatches,
    List<BatchImageResult>? images,
    @JsonKey(name: 'items') List<BatchExtractedItem>? detectedItems,
    String? error,
  }) = _BatchJobStatusResponse;

  factory BatchJobStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$BatchJobStatusResponseFromJson(json);
}

/// Result for a single image in batch
@freezed
abstract class BatchImageResult with _$BatchImageResult {
  const factory BatchImageResult({
    @JsonKey(name: 'image_id') required String id,
    required String status,
    @JsonKey(name: 'item_count') @Default(0) int itemCount,
    String? error,
  }) = _BatchImageResult;

  factory BatchImageResult.fromJson(Map<String, dynamic> json) =>
      _$BatchImageResultFromJson(json);
}

Map<String, dynamic> _normalizeBatchExtractedItemJson(
  Map<String, dynamic> json,
) {
  final normalized = Map<String, dynamic>.from(json);

  final category = normalized['category']?.toString().toLowerCase();
  normalized['category'] = Category.fromString(category ?? 'other').value;

  final rawStatus = normalized['status']?.toString().toLowerCase();
  const validStatuses = {
    'detected',
    'pending',
    'generating',
    'generated',
    'failed',
  };
  normalized['status'] = validStatuses.contains(rawStatus)
      ? rawStatus
      : 'detected';

  normalized['name'] ??=
      normalized['sub_category']?.toString() ??
      normalized['category']?.toString() ??
      'New Item';

  if (normalized['description'] == null &&
      normalized['detailed_description'] != null) {
    normalized['description'] = normalized['detailed_description'];
  }

  final include = normalized['include_in_wardrobe'];
  if (include is bool) {
    normalized['isSelected'] = include;
  } else if (normalized['isSelected'] == null) {
    normalized['isSelected'] = true;
  }

  return normalized;
}

/// Single-item extraction job response
/// Reuses batch infrastructure for single image processing
@freezed
abstract class SingleExtractionJob with _$SingleExtractionJob {
  const factory SingleExtractionJob({
    @JsonKey(name: 'job_id') required String jobId,
    required String status,
    @JsonKey(name: 'total_images') required int totalImages,
    @JsonKey(name: 'sse_url') required String sseUrl,
    String? message,
  }) = _SingleExtractionJob;

  factory SingleExtractionJob.fromJson(Map<String, dynamic> json) =>
      _$SingleExtractionJobFromJson(json);
}
