import '../../../domain/enums/category.dart';

enum SocialPlatform {
  instagram,
  facebook;

  static SocialPlatform fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'facebook':
        return SocialPlatform.facebook;
      case 'instagram':
      default:
        return SocialPlatform.instagram;
    }
  }

  String get value => name;

  String get label =>
      this == SocialPlatform.instagram ? 'Instagram' : 'Facebook';
}

enum SocialImportJobStatus {
  created,
  discovering,
  awaitingAuth,
  processing,
  pausedRateLimited,
  completed,
  cancelled,
  failed;

  static SocialImportJobStatus fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'created':
        return SocialImportJobStatus.created;
      case 'discovering':
        return SocialImportJobStatus.discovering;
      case 'awaiting_auth':
        return SocialImportJobStatus.awaitingAuth;
      case 'processing':
        return SocialImportJobStatus.processing;
      case 'paused_rate_limited':
        return SocialImportJobStatus.pausedRateLimited;
      case 'completed':
        return SocialImportJobStatus.completed;
      case 'cancelled':
        return SocialImportJobStatus.cancelled;
      case 'failed':
        return SocialImportJobStatus.failed;
      default:
        return SocialImportJobStatus.created;
    }
  }

  String get value {
    switch (this) {
      case SocialImportJobStatus.awaitingAuth:
        return 'awaiting_auth';
      case SocialImportJobStatus.pausedRateLimited:
        return 'paused_rate_limited';
      default:
        return name;
    }
  }
}

enum SocialImportPhotoStatus {
  queued,
  processing,
  awaitingReview,
  bufferedReady,
  approved,
  rejected,
  failed;

  static SocialImportPhotoStatus fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'queued':
        return SocialImportPhotoStatus.queued;
      case 'processing':
        return SocialImportPhotoStatus.processing;
      case 'awaiting_review':
        return SocialImportPhotoStatus.awaitingReview;
      case 'buffered_ready':
        return SocialImportPhotoStatus.bufferedReady;
      case 'approved':
        return SocialImportPhotoStatus.approved;
      case 'rejected':
        return SocialImportPhotoStatus.rejected;
      case 'failed':
        return SocialImportPhotoStatus.failed;
      default:
        return SocialImportPhotoStatus.queued;
    }
  }
}

enum SocialImportItemStatus {
  generated,
  edited,
  failed,
  saved,
  discarded;

  static SocialImportItemStatus fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'generated':
        return SocialImportItemStatus.generated;
      case 'edited':
        return SocialImportItemStatus.edited;
      case 'failed':
        return SocialImportItemStatus.failed;
      case 'saved':
        return SocialImportItemStatus.saved;
      case 'discarded':
        return SocialImportItemStatus.discarded;
      default:
        return SocialImportItemStatus.generated;
    }
  }
}

class SocialImportJobStartResponse {
  final String jobId;
  final SocialImportJobStatus status;
  final SocialPlatform platform;
  final String sourceUrl;
  final String normalizedUrl;
  final String? message;

  const SocialImportJobStartResponse({
    required this.jobId,
    required this.status,
    required this.platform,
    required this.sourceUrl,
    required this.normalizedUrl,
    this.message,
  });

  factory SocialImportJobStartResponse.fromJson(Map<String, dynamic> json) {
    return SocialImportJobStartResponse(
      jobId: json['job_id']?.toString() ?? '',
      status: SocialImportJobStatus.fromString(json['status']?.toString()),
      platform: SocialPlatform.fromString(json['platform']?.toString()),
      sourceUrl: json['source_url']?.toString() ?? '',
      normalizedUrl: json['normalized_url']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }
}

class SocialImportOAuthConnectResponse {
  final String authUrl;
  final int expiresInSeconds;
  final String provider;

  const SocialImportOAuthConnectResponse({
    required this.authUrl,
    required this.expiresInSeconds,
    required this.provider,
  });

  factory SocialImportOAuthConnectResponse.fromJson(Map<String, dynamic> json) {
    return SocialImportOAuthConnectResponse(
      authUrl: json['auth_url']?.toString() ?? '',
      expiresInSeconds: _toInt(json['expires_in_seconds']),
      provider: json['provider']?.toString() ?? 'meta',
    );
  }
}

class SocialImportItem {
  final String id;
  final String tempId;
  final String? name;
  final Category category;
  final String? subCategory;
  final List<String> colors;
  final String? material;
  final String? pattern;
  final String? brand;
  final double confidence;
  final Map<String, dynamic>? boundingBox;
  final String? detailedDescription;
  final String? generatedImageUrl;
  final String? generatedStoragePath;
  final String? generationError;
  final SocialImportItemStatus status;
  final String? savedItemId;

  const SocialImportItem({
    required this.id,
    required this.tempId,
    required this.category,
    this.name,
    this.subCategory,
    this.colors = const [],
    this.material,
    this.pattern,
    this.brand,
    this.confidence = 0,
    this.boundingBox,
    this.detailedDescription,
    this.generatedImageUrl,
    this.generatedStoragePath,
    this.generationError,
    this.status = SocialImportItemStatus.generated,
    this.savedItemId,
  });

  factory SocialImportItem.fromJson(Map<String, dynamic> json) {
    final categoryRaw = (json['category']?.toString() ?? 'other').toLowerCase();
    return SocialImportItem(
      id: json['id']?.toString() ?? '',
      tempId: json['temp_id']?.toString() ?? '',
      name: _toNullableString(json['name']),
      category: Category.fromString(categoryRaw),
      subCategory: _toNullableString(json['sub_category']),
      colors: _toStringList(json['colors']),
      material: _toNullableString(json['material']),
      pattern: _toNullableString(json['pattern']),
      brand: _toNullableString(json['brand']),
      confidence: _toDouble(json['confidence']),
      boundingBox: _toMap(json['bounding_box']),
      detailedDescription: _toNullableString(json['detailed_description']),
      generatedImageUrl: _toNullableString(json['generated_image_url']),
      generatedStoragePath: _toNullableString(json['generated_storage_path']),
      generationError: _toNullableString(json['generation_error']),
      status: SocialImportItemStatus.fromString(json['status']?.toString()),
      savedItemId: _toNullableString(json['saved_item_id']),
    );
  }
}

class SocialImportPhoto {
  final String id;
  final int ordinal;
  final String sourcePhotoUrl;
  final String? sourceThumbUrl;
  final SocialImportPhotoStatus status;
  final String? errorMessage;
  final List<SocialImportItem> items;

  const SocialImportPhoto({
    required this.id,
    required this.ordinal,
    required this.sourcePhotoUrl,
    required this.status,
    this.sourceThumbUrl,
    this.errorMessage,
    this.items = const [],
  });

  factory SocialImportPhoto.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    return SocialImportPhoto(
      id: json['id']?.toString() ?? '',
      ordinal: _toInt(json['ordinal']),
      sourcePhotoUrl: json['source_photo_url']?.toString() ?? '',
      sourceThumbUrl: _toNullableString(json['source_thumb_url']),
      status: SocialImportPhotoStatus.fromString(json['status']?.toString()),
      errorMessage: _toNullableString(json['error_message']),
      items: itemsRaw is List
          ? itemsRaw
                .whereType<Map<String, dynamic>>()
                .map(SocialImportItem.fromJson)
                .toList()
          : const [],
    );
  }
}

class SocialImportJobData {
  final String id;
  final SocialImportJobStatus status;
  final SocialPlatform platform;
  final String sourceUrl;
  final String normalizedUrl;
  final int totalPhotos;
  final int discoveredPhotos;
  final int processedPhotos;
  final int approvedPhotos;
  final int rejectedPhotos;
  final int failedPhotos;
  final bool authRequired;
  final bool discoveryCompleted;
  final String? errorMessage;
  final SocialImportPhoto? awaitingReviewPhoto;
  final SocialImportPhoto? bufferedPhoto;
  final SocialImportPhoto? processingPhoto;
  final int queuedCount;
  // Auth-related metadata for handling 2FA and other auth flows
  final String? authReason;
  final String? twoFactorIdentifier;
  final String? checkpointUrl;

  const SocialImportJobData({
    required this.id,
    required this.status,
    required this.platform,
    required this.sourceUrl,
    required this.normalizedUrl,
    required this.totalPhotos,
    required this.discoveredPhotos,
    required this.processedPhotos,
    required this.approvedPhotos,
    required this.rejectedPhotos,
    required this.failedPhotos,
    required this.authRequired,
    required this.discoveryCompleted,
    required this.queuedCount,
    this.errorMessage,
    this.awaitingReviewPhoto,
    this.bufferedPhoto,
    this.processingPhoto,
    this.authReason,
    this.twoFactorIdentifier,
    this.checkpointUrl,
  });

  factory SocialImportJobData.fromJson(Map<String, dynamic> json) {
    return SocialImportJobData(
      id: json['id']?.toString() ?? '',
      status: SocialImportJobStatus.fromString(json['status']?.toString()),
      platform: SocialPlatform.fromString(json['platform']?.toString()),
      sourceUrl: json['source_url']?.toString() ?? '',
      normalizedUrl: json['normalized_url']?.toString() ?? '',
      totalPhotos: _toInt(json['total_photos']),
      discoveredPhotos: _toInt(json['discovered_photos']),
      processedPhotos: _toInt(json['processed_photos']),
      approvedPhotos: _toInt(json['approved_photos']),
      rejectedPhotos: _toInt(json['rejected_photos']),
      failedPhotos: _toInt(json['failed_photos']),
      authRequired: _toBool(json['auth_required']),
      discoveryCompleted: _toBool(json['discovery_completed']),
      errorMessage: _toNullableString(json['error_message']),
      awaitingReviewPhoto: _toMap(json['awaiting_review_photo']) != null
          ? SocialImportPhoto.fromJson(_toMap(json['awaiting_review_photo'])!)
          : null,
      bufferedPhoto: _toMap(json['buffered_photo']) != null
          ? SocialImportPhoto.fromJson(_toMap(json['buffered_photo'])!)
          : null,
      processingPhoto: _toMap(json['processing_photo']) != null
          ? SocialImportPhoto.fromJson(_toMap(json['processing_photo'])!)
          : null,
      queuedCount: _toInt(json['queued_count']),
      // Auth metadata fields
      authReason: _toNullableString(json['auth_reason'] ?? json['reason']),
      twoFactorIdentifier: _toNullableString(json['two_factor_identifier']),
      checkpointUrl: _toNullableString(json['checkpoint_url']),
    );
  }

  bool get isTerminal {
    return status == SocialImportJobStatus.completed ||
        status == SocialImportJobStatus.cancelled ||
        status == SocialImportJobStatus.failed;
  }
}

class SocialImportSSEEvent {
  final String type;
  final Map<String, dynamic> data;
  final int? id;

  const SocialImportSSEEvent({required this.type, required this.data, this.id});
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}

String? _toNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value.trim()];
  }
  return const [];
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}
