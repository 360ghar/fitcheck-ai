import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? fullName,
    String? avatarUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    UserPreferences? preferences,
    UserSettings? settings,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// User preferences
@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @JsonKey(name: 'favorite_colors') List<String>? favoriteColors,
    List<String>? styles,
    List<String>? brands,
    List<String>? occasions,
    Map<String, dynamic>? additionalData,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

/// User settings
@freezed
abstract class UserSettings with _$UserSettings {
  const factory UserSettings({
    String? location,
    String? timezone,
    String? units,
    @JsonKey(name: 'notifications_enabled') bool? notificationsEnabled,
    @JsonKey(name: 'email_notifications') bool? emailNotifications,
    Map<String, dynamic>? additionalData,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
