import 'package:json_annotation/json_annotation.dart';

part 'calendar_event_model.g.dart';

/// Safely parse DateTime from JSON, with fallback to current time.
///
/// The backend stores UTC wall-clock instants in TIMESTAMP columns WITHOUT a
/// timezone (calendar_events.start_time/end_time). PostgREST returns those as
/// naive strings — `DateTime.tryParse` would treat them as LOCAL time and
/// shift every event by the device's UTC offset (and all-day events onto an
/// adjacent date). Treat a string WITHOUT a timezone designator as UTC so the
/// parsed instant matches the instant the client originally sent.
DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  final raw = value.toString();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return DateTime.now();
  if (!raw.endsWith('Z') && !raw.contains('+')) {
    // Naive string from a timezone-free column holding UTC wall-clock.
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }
  return parsed;
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
    bool clearOutfitId = false,
    String? outfitImageUrl,
    bool clearOutfitImageUrl = false,
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
      outfitId: clearOutfitId ? null : (outfitId ?? this.outfitId),
      outfitImageUrl:
          clearOutfitImageUrl ? null : (outfitImageUrl ?? this.outfitImageUrl),
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
