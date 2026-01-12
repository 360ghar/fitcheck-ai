import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_profile_model.freezed.dart';
part 'body_profile_model.g.dart';

/// Body profile model
@freezed
class BodyProfileModel with _$BodyProfileModel {
  const factory BodyProfileModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'height_cm') required double heightCm,
    @JsonKey(name: 'weight_kg') required double weightKg,
    @JsonKey(name: 'body_shape') required String bodyShape,
    @JsonKey(name: 'skin_tone') required String skinTone,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BodyProfileModel;

  factory BodyProfileModel.fromJson(Map<String, dynamic> json) =>
      _$BodyProfileModelFromJson(json);
}

/// Request model for creating a body profile
@freezed
class CreateBodyProfileRequest with _$CreateBodyProfileRequest {
  const factory CreateBodyProfileRequest({
    required String name,
    @JsonKey(name: 'height_cm') required double heightCm,
    @JsonKey(name: 'weight_kg') required double weightKg,
    @JsonKey(name: 'body_shape') required String bodyShape,
    @JsonKey(name: 'skin_tone') required String skinTone,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _CreateBodyProfileRequest;

  factory CreateBodyProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBodyProfileRequestFromJson(json);
}

/// Request model for updating a body profile
@freezed
class UpdateBodyProfileRequest with _$UpdateBodyProfileRequest {
  const factory UpdateBodyProfileRequest({
    String? name,
    @JsonKey(name: 'height_cm') double? heightCm,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'body_shape') String? bodyShape,
    @JsonKey(name: 'skin_tone') String? skinTone,
    @JsonKey(name: 'is_default') bool? isDefault,
  }) = _UpdateBodyProfileRequest;

  factory UpdateBodyProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBodyProfileRequestFromJson(json);
}
