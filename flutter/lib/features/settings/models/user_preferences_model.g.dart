// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferencesModel _$UserPreferencesModelFromJson(
        Map<String, dynamic> json) =>
    UserPreferencesModel(
      id: json['id'] as String?,
      themeMode: $enumDecodeNullable(_$AppThemeModeEnumMap, json['theme_mode']),
      temperatureUnit: $enumDecodeNullable(
          _$TemperatureUnitEnumMap, json['temperature_unit']),
      notificationsEnabled: json['notifications_enabled'] as bool?,
      emailNotificationsEnabled: json['email_notifications_enabled'] as bool?,
      outfitRemindersEnabled: json['outfit_reminders_enabled'] as bool?,
      weeklySummaryEnabled: json['weekly_summary_enabled'] as bool?,
      preferredStyles: (json['preferred_styles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredColors: (json['preferred_colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dislikedStyles: (json['disliked_styles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dislikedColors: (json['disliked_colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      defaultOutfitId: json['default_outfit_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserPreferencesModelToJson(
        UserPreferencesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'theme_mode': _$AppThemeModeEnumMap[instance.themeMode],
      'temperature_unit': _$TemperatureUnitEnumMap[instance.temperatureUnit],
      'notifications_enabled': instance.notificationsEnabled,
      'email_notifications_enabled': instance.emailNotificationsEnabled,
      'outfit_reminders_enabled': instance.outfitRemindersEnabled,
      'weekly_summary_enabled': instance.weeklySummaryEnabled,
      'preferred_styles': instance.preferredStyles,
      'preferred_colors': instance.preferredColors,
      'disliked_styles': instance.dislikedStyles,
      'disliked_colors': instance.dislikedColors,
      'default_outfit_id': instance.defaultOutfitId,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};

const _$TemperatureUnitEnumMap = {
  TemperatureUnit.celsius: 'celsius',
  TemperatureUnit.fahrenheit: 'fahrenheit',
};
