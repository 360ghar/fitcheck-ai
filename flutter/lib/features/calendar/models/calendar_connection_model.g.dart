// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_connection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarConnectionModel _$CalendarConnectionModelFromJson(
  Map<String, dynamic> json,
) => CalendarConnectionModel(
  id: json['id'] as String,
  provider: $enumDecode(_$CalendarProviderEnumMap, json['provider']),
  email: json['email'] as String,
  displayName: json['display_name'] as String?,
  isConnected: json['is_connected'] as bool? ?? true,
  isSyncEnabled: json['is_sync_enabled'] as bool? ?? true,
  lastSyncAt: json['last_sync_at'] == null
      ? null
      : DateTime.parse(json['last_sync_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CalendarConnectionModelToJson(
  CalendarConnectionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'provider': _$CalendarProviderEnumMap[instance.provider]!,
  'email': instance.email,
  'display_name': instance.displayName,
  'is_connected': instance.isConnected,
  'is_sync_enabled': instance.isSyncEnabled,
  'last_sync_at': instance.lastSyncAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};

const _$CalendarProviderEnumMap = {
  CalendarProvider.google: 'google',
  CalendarProvider.outlook: 'outlook',
  CalendarProvider.apple: 'apple',
};
