// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BodyProfileModel _$BodyProfileModelFromJson(Map<String, dynamic> json) =>
    _BodyProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      heightCm: (json['height_cm'] as num).toDouble(),
      weightKg: (json['weight_kg'] as num).toDouble(),
      bodyShape: json['body_shape'] as String,
      skinTone: json['skin_tone'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BodyProfileModelToJson(_BodyProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
      'body_shape': instance.bodyShape,
      'skin_tone': instance.skinTone,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_CreateBodyProfileRequest _$CreateBodyProfileRequestFromJson(
  Map<String, dynamic> json,
) => _CreateBodyProfileRequest(
  name: json['name'] as String,
  heightCm: (json['height_cm'] as num).toDouble(),
  weightKg: (json['weight_kg'] as num).toDouble(),
  bodyShape: json['body_shape'] as String,
  skinTone: json['skin_tone'] as String,
  isDefault: json['is_default'] as bool? ?? false,
);

Map<String, dynamic> _$CreateBodyProfileRequestToJson(
  _CreateBodyProfileRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'height_cm': instance.heightCm,
  'weight_kg': instance.weightKg,
  'body_shape': instance.bodyShape,
  'skin_tone': instance.skinTone,
  'is_default': instance.isDefault,
};

_UpdateBodyProfileRequest _$UpdateBodyProfileRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateBodyProfileRequest(
  name: json['name'] as String?,
  heightCm: (json['height_cm'] as num?)?.toDouble(),
  weightKg: (json['weight_kg'] as num?)?.toDouble(),
  bodyShape: json['body_shape'] as String?,
  skinTone: json['skin_tone'] as String?,
  isDefault: json['is_default'] as bool?,
);

Map<String, dynamic> _$UpdateBodyProfileRequestToJson(
  _UpdateBodyProfileRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'height_cm': instance.heightCm,
  'weight_kg': instance.weightKg,
  'body_shape': instance.bodyShape,
  'skin_tone': instance.skinTone,
  'is_default': instance.isDefault,
};
