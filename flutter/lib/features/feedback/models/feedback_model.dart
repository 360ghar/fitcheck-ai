import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_model.freezed.dart';
part 'feedback_model.g.dart';

/// Ticket categories
enum TicketCategory {
  @JsonValue('bug_report')
  bugReport,
  @JsonValue('feature_request')
  featureRequest,
  @JsonValue('general_feedback')
  generalFeedback,
  @JsonValue('support_request')
  supportRequest,
}

/// Ticket status values
enum TicketStatus {
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed,
}

/// Device info for context
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    String? platform,
    @JsonKey(name: 'os_version') String? osVersion,
    @JsonKey(name: 'device_model') String? deviceModel,
    @JsonKey(name: 'screen_size') String? screenSize,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

/// Response after creating feedback
@freezed
class FeedbackResponse with _$FeedbackResponse {
  const factory FeedbackResponse({
    required String id,
    required TicketCategory category,
    required String subject,
    required TicketStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required String message,
  }) = _FeedbackResponse;

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedbackResponseFromJson(json);
}

/// Ticket in list view
@freezed
class TicketListItem with _$TicketListItem {
  const factory TicketListItem({
    required String id,
    required TicketCategory category,
    required String subject,
    required TicketStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TicketListItem;

  factory TicketListItem.fromJson(Map<String, dynamic> json) =>
      _$TicketListItemFromJson(json);
}
