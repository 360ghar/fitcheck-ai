import 'package:json_annotation/json_annotation.dart';

part 'calendar_event_model.g.dart';

/// Safely parse DateTime from JSON, with fallback to current time
DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

@JsonSerializable()
class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'start_time', fromJson: _dateTimeFromJson)
  final DateTime startTime;
  @JsonKey(name: 'end_time', fromJson: _dateTimeFromJson)
  final DateTime endTime;
  final String? location;
  @JsonKey(name: 'is_all_day')
  final bool isAllDay;
  @JsonKey(name: 'outfit_id')
  final String? outfitId;
  @JsonKey(name: 'outfit_image_url')
  final String? outfitImageUrl;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.isAllDay = false,
    this.outfitId,
    this.outfitImageUrl,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventModelToJson(this);

  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAllDay,
    String? outfitId,
    String? outfitImageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      outfitId: outfitId ?? this.outfitId,
      outfitImageUrl: outfitImageUrl ?? this.outfitImageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
