import 'package:freezed_annotation/freezed_annotation.dart';

part 'photoshoot_models.freezed.dart';
part 'photoshoot_models.g.dart';

/// Available photoshoot use cases
enum PhotoshootUseCase {
  @JsonValue('linkedin')
  linkedin,
  @JsonValue('dating_app')
  datingApp,
  @JsonValue('model_portfolio')
  modelPortfolio,
  @JsonValue('instagram')
  instagram,
  @JsonValue('aesthetic')
  aesthetic,
  @JsonValue('custom')
  custom,
}

/// Extension for display labels and API value
extension PhotoshootUseCaseExtension on PhotoshootUseCase {
  /// Returns the API value for this use case (matches @JsonValue annotations)
  String get apiValue {
    switch (this) {
      case PhotoshootUseCase.linkedin:
        return 'linkedin';
      case PhotoshootUseCase.datingApp:
        return 'dating_app';
      case PhotoshootUseCase.modelPortfolio:
        return 'model_portfolio';
      case PhotoshootUseCase.instagram:
        return 'instagram';
      case PhotoshootUseCase.aesthetic:
        return 'aesthetic';
      case PhotoshootUseCase.custom:
        return 'custom';
    }
  }

  String get label {
    switch (this) {
      case PhotoshootUseCase.linkedin:
        return 'LinkedIn Profile';
      case PhotoshootUseCase.datingApp:
        return 'Dating App';
      case PhotoshootUseCase.modelPortfolio:
        return 'Model Portfolio';
      case PhotoshootUseCase.instagram:
        return 'Instagram Content';
      case PhotoshootUseCase.aesthetic:
        return 'Aesthetic';
      case PhotoshootUseCase.custom:
        return 'Custom Prompt';
    }
  }

  String get description {
    switch (this) {
      case PhotoshootUseCase.linkedin:
        return 'Professional headshots for business profiles';
      case PhotoshootUseCase.datingApp:
        return 'Casual, approachable photos for dating profiles';
      case PhotoshootUseCase.modelPortfolio:
        return 'High-fashion editorial style shots';
      case PhotoshootUseCase.instagram:
        return 'Trendy lifestyle and aesthetic content';
      case PhotoshootUseCase.aesthetic:
        return 'Artistic and visually striking photos';
      case PhotoshootUseCase.custom:
        return 'Write your own prompt for unique results';
    }
  }

  String get icon {
    switch (this) {
      case PhotoshootUseCase.linkedin:
        return '💼';
      case PhotoshootUseCase.datingApp:
        return '💕';
      case PhotoshootUseCase.modelPortfolio:
        return '📸';
      case PhotoshootUseCase.instagram:
        return '✨';
      case PhotoshootUseCase.aesthetic:
        return '🎭';
      case PhotoshootUseCase.custom:
        return '🎨';
    }
  }
}

/// Photoshoot generation status
enum PhotoshootStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('generating')
  generating,
  @JsonValue('complete')
  complete,
  @JsonValue('failed')
  failed,
}

/// Generated image model
@freezed
abstract class GeneratedImage with _$GeneratedImage {
  const factory GeneratedImage({
    required String id,
    required int index,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'image_base64') String? imageBase64,
  }) = _GeneratedImage;

  factory GeneratedImage.fromJson(Map<String, dynamic> json) =>
      _$GeneratedImageFromJson(json);
}

/// Photoshoot usage model
@freezed
abstract class PhotoshootUsage with _$PhotoshootUsage {
  const factory PhotoshootUsage({
    @JsonKey(name: 'used_today') @Default(0) int usedToday,
    @JsonKey(name: 'limit_today') @Default(10) int limitToday,
    @Default(0) int remaining,
    @JsonKey(name: 'plan_type') @Default('free') String planType,
    @JsonKey(name: 'resets_at') DateTime? resetsAt,
  }) = _PhotoshootUsage;

  factory PhotoshootUsage.fromJson(Map<String, dynamic> json) =>
      _$PhotoshootUsageFromJson(json);
}

/// Photoshoot generation request
@freezed
abstract class PhotoshootRequest with _$PhotoshootRequest {
  const factory PhotoshootRequest({
    required List<String> photos,
    @JsonKey(name: 'use_case') required PhotoshootUseCase useCase,
    @JsonKey(name: 'custom_prompt') String? customPrompt,
    @JsonKey(name: 'num_images') @Default(10) int numImages,
  }) = _PhotoshootRequest;

  factory PhotoshootRequest.fromJson(Map<String, dynamic> json) =>
      _$PhotoshootRequestFromJson(json);
}

/// Photoshoot result response
@freezed
abstract class PhotoshootResult with _$PhotoshootResult {
  const factory PhotoshootResult({
    @JsonKey(name: 'session_id') required String sessionId,
    required PhotoshootStatus status,
    @Default([]) List<GeneratedImage> images,
    PhotoshootUsage? usage,
    String? error,
  }) = _PhotoshootResult;

  factory PhotoshootResult.fromJson(Map<String, dynamic> json) =>
      _$PhotoshootResultFromJson(json);
}

/// Use case info from API
@freezed
abstract class UseCaseInfo with _$UseCaseInfo {
  const factory UseCaseInfo({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'example_prompts') @Default([]) List<String> examplePrompts,
  }) = _UseCaseInfo;

  factory UseCaseInfo.fromJson(Map<String, dynamic> json) =>
      _$UseCaseInfoFromJson(json);
}
