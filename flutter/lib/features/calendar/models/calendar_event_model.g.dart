// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventModel _$CalendarEventModelFromJson(Map<String, dynamic> json) =>
    CalendarEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: _dateTimeFromJson(json['start_time']),
      endTime: _dateTimeFromJson(json['end_time']),
      location: json['location'] as String?,
      isAllDay: json['is_all_day'] as bool? ?? false,
      outfitId: json['outfit_id'] as String?,
      outfitImageUrl: json['outfit_image_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CalendarEventModelToJson(CalendarEventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'location': instance.location,
      'is_all_day': instance.isAllDay,
      'outfit_id': instance.outfitId,
      'outfit_image_url': instance.outfitImageUrl,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
