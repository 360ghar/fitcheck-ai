import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/calendar_event_model.dart';
import '../models/calendar_connection_model.dart';

/// Calendar repository - handles all calendar API calls
class CalendarRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Unwrap `{ "data": { ... }, "message": "OK" }` API envelopes.
  Map<String, dynamic> _extractDataMap(dynamic payload) {
    if (payload is! Map) return <String, dynamic>{};
    final root = Map<String, dynamic>.from(payload);
    final data = root['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    // Some callers pass the data map itself (no envelope)
    if (!root.containsKey('message')) {
      return root;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(dynamic payload, String key) {
    final data = _extractDataMap(payload);
    final list = data[key];
    if (list is List) return list;
    // Fallback: top-level key (legacy)
    if (payload is Map && payload[key] is List) {
      return payload[key] as List;
    }
    return const [];
  }

  CalendarConnectionModel _parseConnection(Map<String, dynamic> raw) {
    // API returns { id, provider, email?, connected_at }; model expects richer shape.
    final providerRaw = (raw['provider'] ?? 'local').toString().toLowerCase();
    final provider = switch (providerRaw) {
      'google' => CalendarProvider.google,
      'outlook' => CalendarProvider.outlook,
      'apple' => CalendarProvider.apple,
      'local' => CalendarProvider.local,
      // Unknown providers default to local (in-app planning, not external OAuth)
      _ => CalendarProvider.local,
    };
    final isActive = raw['is_active'] as bool? ?? true;
    final isConnected = raw['is_connected'] as bool? ?? isActive;

    return CalendarConnectionModel(
      id: raw['id'] as String,
      provider: provider,
      email: (raw['email'] as String?) ?? '',
      displayName: raw['display_name'] as String?,
      isConnected: isConnected,
      isSyncEnabled: raw['is_sync_enabled'] as bool? ?? true,
      lastSyncAt: raw['last_sync_at'] != null
          ? DateTime.tryParse(raw['last_sync_at'].toString())
          : null,
      createdAt: raw['created_at'] != null
          ? DateTime.tryParse(raw['created_at'].toString())
          : (raw['connected_at'] != null
              ? DateTime.tryParse(raw['connected_at'].toString())
              : null),
    );
  }

  /// Get all calendar connections
  Future<List<CalendarConnectionModel>> getConnections() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.calendar}/connections',
      );

      final list = _extractList(response.data, 'connections');
      return list
          .whereType<Map>()
          .map((e) => _parseConnection(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Connect calendar provider (OAuth / local)
  Future<CalendarConnectionModel> connectCalendar({
    required CalendarProvider provider,
    required String authCode,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.calendar}/connect',
        data: {
          'provider': provider.name,
          'auth_code': authCode,
        },
      );
      // API: { data: { id, provider, email, connected_at }, message }
      final data = _extractDataMap(response.data);
      return _parseConnection(data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Disconnect calendar
  Future<void> disconnectCalendar(String connectionId) async {
    try {
      await _apiClient.delete('${ApiConstants.calendar}/connections/$connectionId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Get events for date range
  Future<List<CalendarEventModel>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '${ApiConstants.calendar}/events',
        queryParameters: queryParams,
      );

      final list = _extractList(response.data, 'events');
      return list
          .whereType<Map>()
          .map((e) => CalendarEventModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Create event with optional outfit
  Future<CalendarEventModel> createEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
    bool isAllDay = false,
    String? outfitId,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.calendar}/events',
        data: {
          'title': title,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          if (description != null) 'description': description,
          if (location != null) 'location': location,
          // is_all_day may not exist on DB; only send if true to reduce schema-drift risk
          if (isAllDay) 'is_all_day': isAllDay,
          if (outfitId != null) 'outfit_id': outfitId,
        },
      );
      // API: { data: <event row>, message: "Created" }
      final data = _extractDataMap(response.data);
      // Some versions nest under event
      final eventMap = data['event'] is Map
          ? Map<String, dynamic>.from(data['event'] as Map)
          : data;
      return CalendarEventModel.fromJson(eventMap);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Update event
  Future<CalendarEventModel> updateEvent(
    String eventId, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? location,
    bool? isAllDay,
    String? outfitId,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (startTime != null) data['start_time'] = startTime.toIso8601String();
    if (endTime != null) data['end_time'] = endTime.toIso8601String();
    if (description != null) data['description'] = description;
    if (location != null) data['location'] = location;
    // Avoid writing is_all_day until schema is guaranteed
    if (outfitId != null) data['outfit_id'] = outfitId;

    try {
      final response =
          await _apiClient.put('${ApiConstants.calendar}/events/$eventId', data: data);
      final payload = _extractDataMap(response.data);
      final eventMap = payload['event'] is Map
          ? Map<String, dynamic>.from(payload['event'] as Map)
          : payload;
      return CalendarEventModel.fromJson(eventMap);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _apiClient.delete('${ApiConstants.calendar}/events/$eventId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Link outfit to event.
  /// API returns partial `{ id, outfit_id, updated_at }` — returns outfitId only.
  Future<String> linkOutfit(String eventId, String outfitId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.calendar}/events/$eventId/outfit',
        data: {'outfit_id': outfitId},
      );
      final data = _extractDataMap(response.data);
      return (data['outfit_id'] as String?) ?? outfitId;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Remove outfit from event. Returns success; outfit cleared.
  Future<void> removeOutfit(String eventId) async {
    try {
      await _apiClient.delete('${ApiConstants.calendar}/events/$eventId/outfit');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
