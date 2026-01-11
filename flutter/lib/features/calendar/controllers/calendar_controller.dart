import 'dart:async';
import 'package:get/get.dart';
import '../models/calendar_event_model.dart';
import '../models/calendar_connection_model.dart';
import '../repositories/calendar_repository.dart';

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

  // Getters
  bool get hasError => error.value.isNotEmpty;
  List<CalendarEventModel> get selectedDateEvents {
    final key = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
    return eventsByDate.value[key] ?? [];
  }

  bool get hasConnectedCalendar => connections.value.any((c) => c.isConnected);

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
    try {
      isLoadingConnections.value = true;
      error.value = '';
      connections.value = await _repository.getConnections();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingConnections.value = false;
    }
  }

  /// Fetch events for a month range
  Future<void> fetchEventsForMonth(DateTime date) async {
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
      error.value = e.toString();
      // Don't show snackbar on initial load
    } finally {
      isLoadingEvents.value = false;
    }
  }

  void _groupEventsByDate() {
    eventsByDate.clear();
    for (final event in events) {
      final key = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
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

  /// Connect calendar (OAuth flow placeholder)
  Future<void> connectCalendar(CalendarProvider provider) async {
    try {
      isConnecting.value = true;
      // TODO: Implement OAuth flow for Google/Apple calendar
      Get.snackbar(
        'Coming Soon',
        'Calendar connection via ${provider.name} will be available soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnecting.value = false;
    }
  }

  /// Disconnect calendar
  Future<void> disconnectCalendar(String connectionId) async {
    try {
      await _repository.disconnectCalendar(connectionId);
      connections.removeWhere((c) => c.id == connectionId);
      Get.snackbar(
        'Disconnected',
        'Calendar disconnected successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to disconnect calendar',
        snackPosition: SnackPosition.BOTTOM,
      );
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

      Get.snackbar(
        'Event Created',
        'Your event has been added',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
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
      Get.snackbar(
        'Updated',
        'Event updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _repository.deleteEvent(eventId);
      events.removeWhere((e) => e.id == eventId);
      _groupEventsByDate();
      Get.back();
      Get.snackbar(
        'Deleted',
        'Event removed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Link outfit to event
  Future<void> linkOutfit(String eventId, String outfitId) async {
    try {
      final updatedEvent = await _repository.linkOutfit(eventId, outfitId);
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index] = updatedEvent;
        _groupEventsByDate();
      }
      Get.back();
      Get.snackbar(
        'Linked',
        'Outfit linked to event',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove outfit from event
  Future<void> removeOutfit(String eventId) async {
    try {
      final updatedEvent = await _repository.removeOutfit(eventId);
      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index] = updatedEvent;
        _groupEventsByDate();
      }
      Get.snackbar(
        'Removed',
        'Outfit removed from event',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearError() {
    error.value = '';
  }
}
