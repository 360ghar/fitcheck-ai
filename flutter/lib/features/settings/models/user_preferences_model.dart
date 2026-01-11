import 'package:json_annotation/json_annotation.dart';

part 'user_preferences_model.g.dart';

enum AppThemeMode { system, light, dark }

enum TemperatureUnit { celsius, fahrenheit }

@JsonSerializable()
class UserPreferencesModel {
  final String? id;
  @JsonKey(name: 'theme_mode')
  final AppThemeMode? themeMode;
  @JsonKey(name: 'temperature_unit')
  final TemperatureUnit? temperatureUnit;
  @JsonKey(name: 'notifications_enabled')
  final bool? notificationsEnabled;
  @JsonKey(name: 'email_notifications_enabled')
  final bool? emailNotificationsEnabled;
  @JsonKey(name: 'outfit_reminders_enabled')
  final bool? outfitRemindersEnabled;
  @JsonKey(name: 'weekly_summary_enabled')
  final bool? weeklySummaryEnabled;
  @JsonKey(name: 'preferred_styles')
  final List<String>? preferredStyles;
  @JsonKey(name: 'preferred_colors')
  final List<String>? preferredColors;
  @JsonKey(name: 'disliked_styles')
  final List<String>? dislikedStyles;
  @JsonKey(name: 'disliked_colors')
  final List<String>? dislikedColors;
  @JsonKey(name: 'default_outfit_id')
  final String? defaultOutfitId;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserPreferencesModel({
    this.id,
    this.themeMode,
    this.temperatureUnit,
    this.notificationsEnabled,
    this.emailNotificationsEnabled,
    this.outfitRemindersEnabled,
    this.weeklySummaryEnabled,
    this.preferredStyles,
    this.preferredColors,
    this.dislikedStyles,
    this.dislikedColors,
    this.defaultOutfitId,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesModelToJson(this);

  UserPreferencesModel copyWith({
    String? id,
    AppThemeMode? themeMode,
    TemperatureUnit? temperatureUnit,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? outfitRemindersEnabled,
    bool? weeklySummaryEnabled,
    List<String>? preferredStyles,
    List<String>? preferredColors,
    List<String>? dislikedStyles,
    List<String>? dislikedColors,
    String? defaultOutfitId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      outfitRemindersEnabled: outfitRemindersEnabled ?? this.outfitRemindersEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      preferredStyles: preferredStyles ?? this.preferredStyles,
      preferredColors: preferredColors ?? this.preferredColors,
      dislikedStyles: dislikedStyles ?? this.dislikedStyles,
      dislikedColors: dislikedColors ?? this.dislikedColors,
      defaultOutfitId: defaultOutfitId ?? this.defaultOutfitId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
