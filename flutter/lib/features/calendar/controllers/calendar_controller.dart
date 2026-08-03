import 'dart:async';
import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../models/calendar_connection_model.dart';
import '../repositories/calendar_repository.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Calendar controller - manages calendar state and operations
class CalendarController extends GetxController {
  final CalendarRepository _repository = CalendarRepository();

  // Workers for cleanup
  final List<Worker> _workers = [];

  // State
  final RxList<CalendarConnectionModel> connections = <CalendarConnectionModel>[].obs;
  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;
  final RxMap<DateTime, List<CalendarEventModel>> eventsByDate =
      <DateTime, List<CalendarEventModel>>{}.obs;

  // Calendar state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  final RxString calendarFormat = 'month'.obs;

  // Loading states
  final RxBool isLoadingConnections = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isConnecting = false.obs;
  final RxString error = ''.obs;

  // Action-specific loading states
  final RxBool isCreatingEvent = false.obs;
  final RxBool isUpdatingEvent = false.obs;
  final RxMap<String, bool> isDeletingEventMap = <String, bool>{}.obs;
  final RxMap<String, bool> isDisconnectingMap = <String, bool>{}.obs;
  final RxMap<String, bool> isLinkingOutfitMap = <String, bool>{}.obs;
  final RxMap<String, bool> isRemovingOutfitMap = <String, bool>{}.obs;

  // Loading state helpers
  bool isDeletingEvent(String id) => isDeletingEventMap[id] ?? false;
  bool isDisconnecting(String id) => isDisconnectingMap[id] ?? false;
  bool isLinkingOutfit(String id) => isLinkingOutfitMap[id] ?? false;
  bool isRemovingOutfit(String id) => isRemovingOutfitMap[id] ?? false;

  // Getters
  bool get hasError => error.value.isNotEmpty;
  List<CalendarEventModel> get selectedDateEvents {
    final key = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
    return eventsByDate[key] ?? [];
  }

  bool get hasConnectedCalendar => connections.any((c) => c.isConnected);

  @override
  void onInit() {
    super.onInit();
    fetchConnections();
    fetchEventsForMonth(focusedDate.value);

    // Refresh events when focused date changes - store worker for cleanup
    _workers.add(
      ever(focusedDate, (date) => fetchEventsForMonth(date)),
    );
  }

  @override
  void onClose() {
    // Clean up all workers to prevent memory leaks
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  /// Fetch calendar connections
  Future<void> fetchConnections() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      isLoadingConnections.value = true;
      error.value = '';
      connections.value = await _repository.getConnections();
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
    } finally {
      isLoadingConnections.value = false;
    }
  }

  /// Fetch events for a month range
  Future<void> fetchEventsForMonth(DateTime date) async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      isLoadingEvents.value = true;
      error.value = '';

      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      events.value = await _repository.getEvents(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      _groupEventsByDate();
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      // Don't show snackbar on initial load
    } finally {
      isLoadingEvents.value = false;
    }
  }

  void _groupEventsByDate() {
    eventsByDate.clear();
    for (final event in events) {
      // Normalize to the local calendar day. The API may return UTC
      // timestamps (Z suffix); grouping on the raw UTC fields would shift
      // evening events onto the next day for timezones behind UTC, which
      // would not match the grid's local-day keys.
      final local = event.startTime.toLocal();
      final key = DateTime(local.year, local.month, local.day);
      eventsByDate[key] = [...eventsByDate[key] ?? [], event];
    }
  }

  /// Select a date
  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  /// Change focused date (for month navigation)
  void changeFocusedDate(DateTime date) {
    focusedDate.value = date;
  }

  /// Change calendar format (month, week, day)
  void changeFormat(String format) {
    calendarFormat.value = format;
  }

  /// Connect calendar (OAuth not shipped yet — do not imply a real connection)
  Future<void> connectCalendar(CalendarProvider provider) async {
    // Avoid fake loading; surface a clear unavailable state
    ErrorHandler.showInfo('Connecting ${provider.name} calendars is not available in this version. You can still create events locally.', title: 'Not available yet');
  }

  /// Disconnect calendar
  Future<void> disconnectCalendar(String connectionId) async {
    isDisconnectingMap[connectionId] = true;
    try {
      await _repository.disconnectCalendar(connectionId);
      connections.removeWhere((c) => c.id == connectionId);
      ErrorHandler.showSuccess('Calendar disconnected successfully', title: 'Disconnected');
    } catch (e) {
      ErrorHandler.showError('Failed to disconnect calendar', title: 'Error');
    } finally {
      isDisconnectingMap.remove(connectionId);
    }
  }

  /// Create event
  Future<void> createEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
    bool isAllDay = false,
    String? outfitId,
  }) async {
    isCreatingEvent.value = true;
    try {
      final newEvent = await _repository.createEvent(
        title: title,
        startTime: startTime,
        endTime: endTime,
        description: description,
        location: location,
        isAllDay: isAllDay,
        outfitId: outfitId,
      );

      events.add(newEvent);
      _groupEventsByDate();

      ErrorHandler.showSuccess('Your event has been added', title: 'Event Created');
      Get.back();
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isCreatingEvent.value = false;
    }
  }

  /// Update event
  Future<void> updateEvent(
    String eventId, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? location,
    bool? isAllDay,
    String? outfitId,
  }) async {
    isUpdatingEvent.value = true;
    try {
      final updatedEvent = await _repository.updateEvent(
        eventId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        description: description,
        location: location,
        isAllDay: isAllDay,
        outfitId: outfitId,
      );
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index] = updatedEvent;
        _groupEventsByDate();
      }
      Get.back();
      ErrorHandler.showSuccess('Event updated successfully', title: 'Updated');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isUpdatingEvent.value = false;
    }
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    isDeletingEventMap[eventId] = true;
    try {
      await _repository.deleteEvent(eventId);
      events.removeWhere((e) => e.id == eventId);
      _groupEventsByDate();
      Get.back();
      ErrorHandler.showSuccess('Event removed', title: 'Deleted');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isDeletingEventMap.remove(eventId);
    }
  }

  /// Link outfit to event
  Future<void> linkOutfit(String eventId, String outfitId) async {
    isLinkingOutfitMap[eventId] = true;
    try {
      final linkedOutfitId = await _repository.linkOutfit(eventId, outfitId);
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index] = events[index].copyWith(outfitId: linkedOutfitId);
        _groupEventsByDate();
      }
      Get.back();
      ErrorHandler.showInfo('Outfit linked to event', title: 'Linked');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isLinkingOutfitMap.remove(eventId);
    }
  }

  /// Remove outfit from event
  Future<void> removeOutfit(String eventId) async {
    isRemovingOutfitMap[eventId] = true;
    try {
      await _repository.removeOutfit(eventId);
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index] = events[index].copyWith(
          clearOutfitId: true,
          clearOutfitImageUrl: true,
        );
        _groupEventsByDate();
      }
      ErrorHandler.showSuccess('Outfit removed from event', title: 'Removed');
    } catch (e) {
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
    } finally {
      isRemovingOutfitMap.remove(eventId);
    }
  }

  void clearError() {
    error.value = '';
  }
}
