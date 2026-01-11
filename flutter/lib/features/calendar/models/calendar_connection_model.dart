import 'package:json_annotation/json_annotation.dart';

part 'calendar_connection_model.g.dart';

enum CalendarProvider { google, outlook, apple }

@JsonSerializable()
class CalendarConnectionModel {
  final String id;
  final CalendarProvider provider;
  final String email;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'is_connected')
  final bool isConnected;
  @JsonKey(name: 'is_sync_enabled')
  final bool isSyncEnabled;
  @JsonKey(name: 'last_sync_at')
  final DateTime? lastSyncAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  CalendarConnectionModel({
    required this.id,
    required this.provider,
    required this.email,
    this.displayName,
    this.isConnected = true,
    this.isSyncEnabled = true,
    this.lastSyncAt,
    this.createdAt,
  });

  factory CalendarConnectionModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarConnectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarConnectionModelToJson(this);

  CalendarConnectionModel copyWith({
    String? id,
    CalendarProvider? provider,
    String? email,
    String? displayName,
    bool? isConnected,
    bool? isSyncEnabled,
    DateTime? lastSyncAt,
    DateTime? createdAt,
  }) {
    return CalendarConnectionModel(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isConnected: isConnected ?? this.isConnected,
      isSyncEnabled: isSyncEnabled ?? this.isSyncEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
