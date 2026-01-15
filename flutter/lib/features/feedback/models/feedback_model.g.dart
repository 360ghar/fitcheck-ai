// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => _DeviceInfo(
  platform: json['platform'] as String?,
  osVersion: json['os_version'] as String?,
  deviceModel: json['device_model'] as String?,
  screenSize: json['screen_size'] as String?,
);

Map<String, dynamic> _$DeviceInfoToJson(_DeviceInfo instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'os_version': instance.osVersion,
      'device_model': instance.deviceModel,
      'screen_size': instance.screenSize,
    };

_FeedbackResponse _$FeedbackResponseFromJson(Map<String, dynamic> json) =>
    _FeedbackResponse(
      id: json['id'] as String,
      category: $enumDecode(_$TicketCategoryEnumMap, json['category']),
      subject: json['subject'] as String,
      status: $enumDecode(_$TicketStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      message: json['message'] as String,
    );

Map<String, dynamic> _$FeedbackResponseToJson(_FeedbackResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$TicketCategoryEnumMap[instance.category]!,
      'subject': instance.subject,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'message': instance.message,
    };

const _$TicketCategoryEnumMap = {
  TicketCategory.bugReport: 'bug_report',
  TicketCategory.featureRequest: 'feature_request',
  TicketCategory.generalFeedback: 'general_feedback',
  TicketCategory.supportRequest: 'support_request',
};

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'open',
  TicketStatus.inProgress: 'in_progress',
  TicketStatus.resolved: 'resolved',
  TicketStatus.closed: 'closed',
};

_TicketListItem _$TicketListItemFromJson(Map<String, dynamic> json) =>
    _TicketListItem(
      id: json['id'] as String,
      category: $enumDecode(_$TicketCategoryEnumMap, json['category']),
      subject: json['subject'] as String,
      status: $enumDecode(_$TicketStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TicketListItemToJson(_TicketListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$TicketCategoryEnumMap[instance.category]!,
      'subject': instance.subject,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
    };
