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
      id: json['id'] as String,
      sourceImageId: json['sourceImageId'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      material: json['material'] as String?,
      pattern: json['pattern'] as String?,
      description: json['description'] as String?,
      boundingBox: json['bounding_box'] as Map<String, dynamic>?,
      croppedImageBase64: json['cropped_image_base64'] as String?,
      generatedImageUrl: json['generated_image_url'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      status:
          $enumDecodeNullable(_$BatchItemStatusEnumMap, json['status']) ??
          BatchItemStatus.pending,
      isSelected: json['isSelected'] as bool? ?? true,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$BatchExtractedItemToJson(_BatchExtractedItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceImageId': instance.sourceImageId,
      'name': instance.name,
      'category': _$CategoryEnumMap[instance.category]!,
      'colors': instance.colors,
      'material': instance.material,
      'pattern': instance.pattern,
      'description': instance.description,
      'bounding_box': instance.boundingBox,
      'cropped_image_base64': instance.croppedImageBase64,
      'generated_image_url': instance.generatedImageUrl,
      'confidence': instance.confidence,
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
      id: json['id'] as String,
      imageBase64: json['image_base64'] as String,
    );

Map<String, dynamic> _$BatchImageInputToJson(_BatchImageInput instance) =>
    <String, dynamic>{'id': instance.id, 'image_base64': instance.imageBase64};

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
  extractedCount: (json['extracted_count'] as num?)?.toInt() ?? 0,
  generatedCount: (json['generated_count'] as num?)?.toInt() ?? 0,
  failedCount: (json['failed_count'] as num?)?.toInt() ?? 0,
  currentBatch: (json['current_batch'] as num?)?.toInt() ?? 0,
  totalBatches: (json['total_batches'] as num?)?.toInt() ?? 0,
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => BatchImageResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  detectedItems: (json['detected_items'] as List<dynamic>?)
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
  'extracted_count': instance.extractedCount,
  'generated_count': instance.generatedCount,
  'failed_count': instance.failedCount,
  'current_batch': instance.currentBatch,
  'total_batches': instance.totalBatches,
  'images': instance.images,
  'detected_items': instance.detectedItems,
  'error': instance.error,
};

_BatchImageResult _$BatchImageResultFromJson(Map<String, dynamic> json) =>
    _BatchImageResult(
      id: json['id'] as String,
      status: json['status'] as String,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$BatchImageResultToJson(_BatchImageResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'item_count': instance.itemCount,
      'error': instance.error,
    };
