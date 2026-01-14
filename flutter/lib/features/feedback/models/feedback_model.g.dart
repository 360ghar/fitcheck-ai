// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceInfoImpl _$$DeviceInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeviceInfoImpl(
      platform: json['platform'] as String?,
      osVersion: json['os_version'] as String?,
      deviceModel: json['device_model'] as String?,
      screenSize: json['screen_size'] as String?,
    );

Map<String, dynamic> _$$DeviceInfoImplToJson(_$DeviceInfoImpl instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'os_version': instance.osVersion,
      'device_model': instance.deviceModel,
      'screen_size': instance.screenSize,
    };

_$FeedbackResponseImpl _$$FeedbackResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$FeedbackResponseImpl(
      id: json['id'] as String,
      category: $enumDecode(_$TicketCategoryEnumMap, json['category']),
      subject: json['subject'] as String,
      status: $enumDecode(_$TicketStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      message: json['message'] as String,
    );

Map<String, dynamic> _$$FeedbackResponseImplToJson(
        _$FeedbackResponseImpl instance) =>
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

_$TicketListItemImpl _$$TicketListItemImplFromJson(Map<String, dynamic> json) =>
    _$TicketListItemImpl(
      id: json['id'] as String,
      category: $enumDecode(_$TicketCategoryEnumMap, json['category']),
      subject: json['subject'] as String,
      status: $enumDecode(_$TicketStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TicketListItemImplToJson(
        _$TicketListItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$TicketCategoryEnumMap[instance.category]!,
      'subject': instance.subject,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
    };
