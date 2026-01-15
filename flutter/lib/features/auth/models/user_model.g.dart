// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  preferences: json['preferences'] == null
      ? null
      : UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
  settings: json['settings'] == null
      ? null
      : UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'preferences': instance.preferences,
      'settings': instance.settings,
    };

_UserPreferences _$UserPreferencesFromJson(
  Map<String, dynamic> json,
) => _UserPreferences(
  favoriteColors: (json['favorite_colors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  styles: (json['styles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  brands: (json['brands'] as List<dynamic>?)?.map((e) => e as String).toList(),
  occasions: (json['occasions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  additionalData: json['additionalData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'favorite_colors': instance.favoriteColors,
      'styles': instance.styles,
      'brands': instance.brands,
      'occasions': instance.occasions,
      'additionalData': instance.additionalData,
    };

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      location: json['location'] as String?,
      timezone: json['timezone'] as String?,
      units: json['units'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool?,
      emailNotifications: json['email_notifications'] as bool?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'location': instance.location,
      'timezone': instance.timezone,
      'units': instance.units,
      'notifications_enabled': instance.notificationsEnabled,
      'email_notifications': instance.emailNotifications,
      'additionalData': instance.additionalData,
    };
