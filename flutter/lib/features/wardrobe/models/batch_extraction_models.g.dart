// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_extraction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BatchImage _$BatchImageFromJson(Map<String, dynamic> json) => _BatchImage(
  id: json['id'] as String,
  filePath: json['filePath'] as String,
  base64Data: json['base64Data'] as String?,
  thumbnailPath: json['thumbnailPath'] as String?,
  status:
      $enumDecodeNullable(_$BatchImageStatusEnumMap, json['status']) ??
      BatchImageStatus.pending,
  error: json['error'] as String?,
  extractedItems:
      (json['extractedItems'] as List<dynamic>?)
          ?.map((e) => BatchExtractedItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BatchImageToJson(_BatchImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filePath': instance.filePath,
      'base64Data': instance.base64Data,
      'thumbnailPath': instance.thumbnailPath,
      'status': _$BatchImageStatusEnumMap[instance.status]!,
      'error': instance.error,
      'extractedItems': instance.extractedItems,
    };

const _$BatchImageStatusEnumMap = {
  BatchImageStatus.pending: 'pending',
  BatchImageStatus.uploading: 'uploading',
  BatchImageStatus.extracting: 'extracting',
  BatchImageStatus.extracted: 'extracted',
  BatchImageStatus.generating: 'generating',
  BatchImageStatus.generated: 'generated',
  BatchImageStatus.failed: 'failed',
};

_BatchExtractionJob _$BatchExtractionJobFromJson(Map<String, dynamic> json) =>
    _BatchExtractionJob(
      jobId: json['jobId'] as String,
      status: $enumDecode(_$BatchJobStatusEnumMap, json['status']),
      totalImages: (json['totalImages'] as num).toInt(),
      extractedCount: (json['extractedCount'] as num?)?.toInt() ?? 0,
      generatedCount: (json['generatedCount'] as num?)?.toInt() ?? 0,
      failedCount: (json['failedCount'] as num?)?.toInt() ?? 0,
      currentBatch: (json['currentBatch'] as num?)?.toInt() ?? 0,
      totalBatches: (json['totalBatches'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$BatchExtractionJobToJson(_BatchExtractionJob instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'status': _$BatchJobStatusEnumMap[instance.status]!,
      'totalImages': instance.totalImages,
      'extractedCount': instance.extractedCount,
      'generatedCount': instance.generatedCount,
      'failedCount': instance.failedCount,
      'currentBatch': instance.currentBatch,
      'totalBatches': instance.totalBatches,
      'error': instance.error,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$BatchJobStatusEnumMap = {
  BatchJobStatus.idle: 'idle',
  BatchJobStatus.uploading: 'uploading',
  BatchJobStatus.extracting: 'extracting',
  BatchJobStatus.generating: 'generating',
  BatchJobStatus.complete: 'complete',
  BatchJobStatus.failed: 'failed',
  BatchJobStatus.cancelled: 'cancelled',
};

_BatchExtractedItem _$BatchExtractedItemFromJson(Map<String, dynamic> json) =>
    _BatchExtractedItem(
      id: json['temp_id'] as String,
      sourceImageId: json['image_id'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      subCategory: json['sub_category'] as String?,
      colors:
          (json['colors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      boundingBox: json['bounding_box'] as Map<String, dynamic>?,
      croppedImageBase64: json['cropped_image_base64'] as String?,
      generatedImageBase64: json['generated_image_base64'] as String?,
      generatedImageUrl: json['generated_image_url'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      personId: json['person_id'] as String?,
      personLabel: json['person_label'] as String?,
      isCurrentUserPerson: json['is_current_user_person'] as bool? ?? false,
      includeInWardrobe: json['include_in_wardrobe'] as bool? ?? true,
      status:
          $enumDecodeNullable(
            _$BatchItemStatusEnumMap,
            json['status'],
            unknownValue: BatchItemStatus.pending,
          ) ??
          BatchItemStatus.pending,
      isSelected: json['isSelected'] as bool? ?? true,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$BatchExtractedItemToJson(_BatchExtractedItem instance) =>
    <String, dynamic>{
      'temp_id': instance.id,
      'image_id': instance.sourceImageId,
      'name': instance.name,
      'category': _$CategoryEnumMap[instance.category]!,
      'sub_category': instance.subCategory,
      'colors': instance.colors,
      'material': instance.material,
      'pattern': instance.pattern,
      'brand': instance.brand,
      'description': instance.description,
      'bounding_box': instance.boundingBox,
      'cropped_image_base64': instance.croppedImageBase64,
      'generated_image_base64': instance.generatedImageBase64,
      'generated_image_url': instance.generatedImageUrl,
      'confidence': instance.confidence,
      'person_id': instance.personId,
      'person_label': instance.personLabel,
      'is_current_user_person': instance.isCurrentUserPerson,
      'include_in_wardrobe': instance.includeInWardrobe,
      'status': _$BatchItemStatusEnumMap[instance.status]!,
      'isSelected': instance.isSelected,
      'error': instance.error,
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

const _$BatchItemStatusEnumMap = {
  BatchItemStatus.detected: 'detected',
  BatchItemStatus.pending: 'pending',
  BatchItemStatus.generating: 'generating',
  BatchItemStatus.generated: 'generated',
  BatchItemStatus.failed: 'failed',
};

_SSEEvent _$SSEEventFromJson(Map<String, dynamic> json) => _SSEEvent(
  type: json['type'] as String,
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SSEEventToJson(_SSEEvent instance) => <String, dynamic>{
  'type': instance.type,
  'data': instance.data,
};

_BatchExtractionRequest _$BatchExtractionRequestFromJson(
  Map<String, dynamic> json,
) => _BatchExtractionRequest(
  images: (json['images'] as List<dynamic>)
      .map((e) => BatchImageInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  autoGenerate: json['auto_generate'] as bool? ?? true,
  generationBatchSize: (json['generation_batch_size'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$BatchExtractionRequestToJson(
  _BatchExtractionRequest instance,
) => <String, dynamic>{
  'images': instance.images,
  'auto_generate': instance.autoGenerate,
  'generation_batch_size': instance.generationBatchSize,
};

_BatchImageInput _$BatchImageInputFromJson(Map<String, dynamic> json) =>
    _BatchImageInput(
      imageId: json['image_id'] as String,
      imageBase64: json['image_base64'] as String,
    );

Map<String, dynamic> _$BatchImageInputToJson(_BatchImageInput instance) =>
    <String, dynamic>{
      'image_id': instance.imageId,
      'image_base64': instance.imageBase64,
    };

_BatchExtractionResponse _$BatchExtractionResponseFromJson(
  Map<String, dynamic> json,
) => _BatchExtractionResponse(
  jobId: json['job_id'] as String,
  status: json['status'] as String,
  totalImages: (json['total_images'] as num).toInt(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$BatchExtractionResponseToJson(
  _BatchExtractionResponse instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'status': instance.status,
  'total_images': instance.totalImages,
  'message': instance.message,
};

_BatchJobStatusResponse _$BatchJobStatusResponseFromJson(
  Map<String, dynamic> json,
) => _BatchJobStatusResponse(
  jobId: json['job_id'] as String,
  status: json['status'] as String,
  totalImages: (json['total_images'] as num).toInt(),
  extractedCount: (json['extractions_completed'] as num?)?.toInt() ?? 0,
  generatedCount: (json['generations_completed'] as num?)?.toInt() ?? 0,
  failedCount: (json['extractions_failed'] as num?)?.toInt() ?? 0,
  generationFailedCount: (json['generations_failed'] as num?)?.toInt() ?? 0,
  currentBatch: (json['current_batch'] as num?)?.toInt() ?? 0,
  totalBatches: (json['total_batches'] as num?)?.toInt() ?? 0,
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => BatchImageResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  detectedItems: (json['items'] as List<dynamic>?)
      ?.map((e) => BatchExtractedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  error: json['error'] as String?,
);

Map<String, dynamic> _$BatchJobStatusResponseToJson(
  _BatchJobStatusResponse instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'status': instance.status,
  'total_images': instance.totalImages,
  'extractions_completed': instance.extractedCount,
  'generations_completed': instance.generatedCount,
  'extractions_failed': instance.failedCount,
  'generations_failed': instance.generationFailedCount,
  'current_batch': instance.currentBatch,
  'total_batches': instance.totalBatches,
  'images': instance.images,
  'items': instance.detectedItems,
  'error': instance.error,
};

_BatchImageResult _$BatchImageResultFromJson(Map<String, dynamic> json) =>
    _BatchImageResult(
      id: json['image_id'] as String,
      status: json['status'] as String,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$BatchImageResultToJson(_BatchImageResult instance) =>
    <String, dynamic>{
      'image_id': instance.id,
      'status': instance.status,
      'item_count': instance.itemCount,
      'error': instance.error,
    };

_SingleExtractionJob _$SingleExtractionJobFromJson(Map<String, dynamic> json) =>
    _SingleExtractionJob(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      totalImages: (json['total_images'] as num).toInt(),
      sseUrl: json['sse_url'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SingleExtractionJobToJson(
  _SingleExtractionJob instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'status': instance.status,
  'total_images': instance.totalImages,
  'sse_url': instance.sseUrl,
  'message': instance.message,
};
