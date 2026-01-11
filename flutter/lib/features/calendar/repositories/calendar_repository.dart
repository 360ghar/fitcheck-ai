import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../models/calendar_event_model.dart';
import '../models/calendar_connection_model.dart';

/// Calendar repository - handles all calendar API calls
class CalendarRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all calendar connections
  Future<List<CalendarConnectionModel>> getConnections() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.calendar,
      ); // Uses base /calendar endpoint

      final List<dynamic> data = response.data is Map
          ? response.data['connections'] ?? []
          : response.data;

      return data
          .map((e) => CalendarConnectionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Connect calendar provider (OAuth)
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
      final data = response.data is Map ? response.data['connection'] : response.data;
      return CalendarConnectionModel.fromJson(data as Map<String, dynamic>);
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

      final List<dynamic> data = response.data is Map
          ? response.data['events'] ?? []
          : response.data;

      return data
          .map((e) => CalendarEventModel.fromJson(e as Map<String, dynamic>))
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
          'is_all_day': isAllDay,
          if (outfitId != null) 'outfit_id': outfitId,
        },
      );
      final data = response.data is Map ? response.data['event'] : response.data;
      return CalendarEventModel.fromJson(data as Map<String, dynamic>);
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
    if (isAllDay != null) data['is_all_day'] = isAllDay;
    if (outfitId != null) data['outfit_id'] = outfitId;

    try {
      final response = await _apiClient.put('${ApiConstants.calendar}/events/$eventId', data: data);
      final eventData = response.data is Map ? response.data['event'] : response.data;
      return CalendarEventModel.fromJson(eventData as Map<String, dynamic>);
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

  /// Link outfit to event
  Future<CalendarEventModel> linkOutfit(String eventId, String outfitId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.calendar}/events/$eventId/outfit',
        data: {'outfit_id': outfitId},
      );
      final data = response.data is Map ? response.data['event'] : response.data;
      return CalendarEventModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Remove outfit from event
  Future<CalendarEventModel> removeOutfit(String eventId) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.calendar}/events/$eventId/outfit');
      final data = response.data is Map ? response.data['event'] : response.data;
      return CalendarEventModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

}
