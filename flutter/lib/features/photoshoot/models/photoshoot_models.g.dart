// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photoshoot_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GeneratedImage _$GeneratedImageFromJson(Map<String, dynamic> json) =>
    _GeneratedImage(
      id: json['id'] as String,
      index: (json['index'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      imageBase64: json['image_base64'] as String?,
    );

Map<String, dynamic> _$GeneratedImageToJson(_GeneratedImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'index': instance.index,
      'image_url': instance.imageUrl,
      'image_base64': instance.imageBase64,
    };

_PhotoshootUsage _$PhotoshootUsageFromJson(Map<String, dynamic> json) =>
    _PhotoshootUsage(
      usedToday: (json['used_today'] as num?)?.toInt() ?? 0,
      limitToday: (json['limit_today'] as num?)?.toInt() ?? 10,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      planType: json['plan_type'] as String? ?? 'free',
      resetsAt: json['resets_at'] == null
          ? null
          : DateTime.parse(json['resets_at'] as String),
    );

Map<String, dynamic> _$PhotoshootUsageToJson(_PhotoshootUsage instance) =>
    <String, dynamic>{
      'used_today': instance.usedToday,
      'limit_today': instance.limitToday,
      'remaining': instance.remaining,
      'plan_type': instance.planType,
      'resets_at': instance.resetsAt?.toIso8601String(),
    };

_PhotoshootRequest _$PhotoshootRequestFromJson(Map<String, dynamic> json) =>
    _PhotoshootRequest(
      photos: (json['photos'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      useCase: $enumDecode(_$PhotoshootUseCaseEnumMap, json['use_case']),
      customPrompt: json['custom_prompt'] as String?,
      numImages: (json['num_images'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$PhotoshootRequestToJson(_PhotoshootRequest instance) =>
    <String, dynamic>{
      'photos': instance.photos,
      'use_case': _$PhotoshootUseCaseEnumMap[instance.useCase]!,
      'custom_prompt': instance.customPrompt,
      'num_images': instance.numImages,
    };

const _$PhotoshootUseCaseEnumMap = {
  PhotoshootUseCase.linkedin: 'linkedin',
  PhotoshootUseCase.datingApp: 'dating_app',
  PhotoshootUseCase.modelPortfolio: 'model_portfolio',
  PhotoshootUseCase.instagram: 'instagram',
  PhotoshootUseCase.aesthetic: 'aesthetic',
  PhotoshootUseCase.custom: 'custom',
};

_PhotoshootResult _$PhotoshootResultFromJson(Map<String, dynamic> json) =>
    _PhotoshootResult(
      sessionId: json['session_id'] as String,
      status: $enumDecode(_$PhotoshootStatusEnumMap, json['status']),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => GeneratedImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      usage: json['usage'] == null
          ? null
          : PhotoshootUsage.fromJson(json['usage'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$PhotoshootResultToJson(_PhotoshootResult instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'status': _$PhotoshootStatusEnumMap[instance.status]!,
      'images': instance.images,
      'usage': instance.usage,
      'error': instance.error,
    };

const _$PhotoshootStatusEnumMap = {
  PhotoshootStatus.pending: 'pending',
  PhotoshootStatus.generating: 'generating',
  PhotoshootStatus.complete: 'complete',
  PhotoshootStatus.failed: 'failed',
};

_UseCaseInfo _$UseCaseInfoFromJson(Map<String, dynamic> json) => _UseCaseInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  examplePrompts:
      (json['example_prompts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UseCaseInfoToJson(_UseCaseInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'example_prompts': instance.examplePrompts,
    };

_PhotoshootJobResponse _$PhotoshootJobResponseFromJson(
  Map<String, dynamic> json,
) => _PhotoshootJobResponse(
  jobId: json['job_id'] as String,
  status: json['status'] as String,
  message: json['message'] as String?,
);

Map<String, dynamic> _$PhotoshootJobResponseToJson(
  _PhotoshootJobResponse instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'status': instance.status,
  'message': instance.message,
};

_PhotoshootJobStatusResponse _$PhotoshootJobStatusResponseFromJson(
  Map<String, dynamic> json,
) => _PhotoshootJobStatusResponse(
  jobId: json['job_id'] as String,
  status: json['status'] as String,
  generatedCount: (json['generated_count'] as num?)?.toInt() ?? 0,
  totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
  currentBatch: (json['current_batch'] as num?)?.toInt() ?? 0,
  totalBatches: (json['total_batches'] as num?)?.toInt() ?? 0,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => GeneratedImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  usage: json['usage'] == null
      ? null
      : PhotoshootUsage.fromJson(json['usage'] as Map<String, dynamic>),
  error: json['error'] as String?,
);

Map<String, dynamic> _$PhotoshootJobStatusResponseToJson(
  _PhotoshootJobStatusResponse instance,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'status': instance.status,
  'generated_count': instance.generatedCount,
  'total_count': instance.totalCount,
  'current_batch': instance.currentBatch,
  'total_batches': instance.totalBatches,
  'images': instance.images,
  'usage': instance.usage,
  'error': instance.error,
};
