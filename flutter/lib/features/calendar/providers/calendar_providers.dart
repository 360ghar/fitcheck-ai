import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/paged_state.dart';
import '../../../core/utils/error_handler.dart';
import '../models/calendar_connection_model.dart';
import '../models/calendar_event_model.dart';
import '../repositories/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => CalendarRepository(),
);

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// The month the grid shows (first day, local time).
final calendarMonthProvider =
    NotifierProvider.autoDispose<CalendarMonth, DateTime>(CalendarMonth.new);

class CalendarMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  /// Shows the month of [date]. The same month sends no new request.
  void show(DateTime date) {
    final month = DateTime(date.year, date.month);
    if (month != state) state = month;
  }

  void previous() => state = DateTime(state.year, state.month - 1);
  void next() => state = DateTime(state.year, state.month + 1);
}

/// The day whose events the list shows.
final calendarSelectedDayProvider =
    NotifierProvider.autoDispose<CalendarSelectedDay, DateTime>(
      CalendarSelectedDay.new,
    );

class CalendarSelectedDay extends Notifier<DateTime> {
  @override
  DateTime build() => _day(DateTime.now());

  void select(DateTime date) => state = _day(date);
}

/// Groups events by their local calendar day. The API sends UTC instants,
/// so grouping on the raw fields would move evening events to the next day
/// for time zones behind UTC.
Map<DateTime, List<CalendarEventModel>> eventsByDay(
  List<CalendarEventModel> events,
) {
  final byDay = <DateTime, List<CalendarEventModel>>{};
  for (final e in events) {
    (byDay[_day(e.startTime.toLocal())] ??= []).add(e);
  }
  for (final list in byDay.values) {
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  return byDay;
}

/// Events of the shown month. A month change rebuilds it, and Riverpod
/// drops the response of the older month.
final calendarEventsProvider =
    AsyncNotifierProvider.autoDispose<
      CalendarEventsNotifier,
      List<CalendarEventModel>
    >(CalendarEventsNotifier.new);

/// Event ids with a running delete, link or unlink.
final calendarBusyProvider = NotifierProvider.autoDispose<BusyIds, Set<String>>(
  BusyIds.new,
);

class CalendarEventsNotifier extends AsyncNotifier<List<CalendarEventModel>> {
  CalendarRepository get _repository => ref.read(calendarRepositoryProvider);
  bool _saving = false;

  @override
  Future<List<CalendarEventModel>> build() =>
      _load(ref.watch(calendarMonthProvider));

  Future<List<CalendarEventModel>> _load(DateTime month) =>
      _repository.getEvents(
        startDate: month,
        endDate: DateTime(month.year, month.month + 1, 0, 23, 59, 59),
      );

  /// Reloads and keeps the current events on screen while it runs.
  Future<void> refresh() async {
    final month = ref.read(calendarMonthProvider);
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() => _load(month));
    if (ref.mounted && month == ref.read(calendarMonthProvider)) state = next;
  }

  void _put(CalendarEventModel event) {
    final events = state.value ?? const [];
    state = AsyncData([
      for (final e in events)
        if (e.id != event.id) e,
      event,
    ]);
  }

  /// Creates an event. Returns it, or null when the request fails or another
  /// save is running, so a double tap never creates two events.
  Future<CalendarEventModel?> create({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
    bool isAllDay = false,
  }) => _save(() async {
    final event = await _repository.createEvent(
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      location: location,
      isAllDay: isAllDay,
    );
    ErrorHandler.showSuccess('Event added', title: 'Planned');
    return event;
  });

  /// Updates an event. Pass '' to clear [location] or [description].
  Future<CalendarEventModel?> edit(
    String id, {
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
    required String location,
    required bool isAllDay,
  }) => _save(() async {
    final event = await _repository.updateEvent(
      id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      location: location,
      isAllDay: isAllDay,
    );
    ErrorHandler.showSuccess('Event saved', title: 'Saved');
    return event;
  });

  Future<CalendarEventModel?> _save(
    Future<CalendarEventModel> Function() request,
  ) async {
    if (_saving) return null;
    _saving = true;
    try {
      final event = await request();
      if (ref.mounted) _put(event);
      return event;
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Event not saved', stackTrace: stack);
      return null;
    } finally {
      _saving = false;
    }
  }

  /// Deletes an event. Returns true on success.
  Future<bool> delete(String id) async {
    final done = await ref.read(calendarBusyProvider.notifier).run(
      id,
      () async {
        try {
          await _repository.deleteEvent(id);
          if (ref.mounted) {
            state = AsyncData([
              for (final e in state.value ?? const <CalendarEventModel>[])
                if (e.id != id) e,
            ]);
          }
          ErrorHandler.showSuccess('Event removed', title: 'Deleted');
          return true;
        } catch (e, stack) {
          ErrorHandler.showError(
            e,
            title: 'Event not deleted',
            stackTrace: stack,
          );
          return false;
        }
      },
    );
    return done ?? false;
  }

  Future<void> linkOutfit(String eventId, String outfitId) =>
      _changeOutfit(eventId, 'Outfit not linked', () async {
        final linked = await _repository.linkOutfit(eventId, outfitId);
        ErrorHandler.showSuccess('Outfit linked', title: 'Linked');
        return (CalendarEventModel e) => e.copyWith(outfitId: linked);
      });

  Future<void> removeOutfit(String eventId) =>
      _changeOutfit(eventId, 'Outfit not removed', () async {
        await _repository.removeOutfit(eventId);
        ErrorHandler.showSuccess('Outfit removed', title: 'Removed');
        return (CalendarEventModel e) =>
            e.copyWith(clearOutfitId: true, clearOutfitImageUrl: true);
      });

  Future<void> _changeOutfit(
    String eventId,
    String failure,
    Future<CalendarEventModel Function(CalendarEventModel)> Function() request,
  ) async {
    await ref.read(calendarBusyProvider.notifier).run(eventId, () async {
      try {
        final change = await request();
        if (!ref.mounted) return;
        final event = state.value?.where((e) => e.id == eventId).firstOrNull;
        if (event != null) _put(change(event));
      } catch (e, stack) {
        ErrorHandler.showError(e, title: failure, stackTrace: stack);
      }
    });
  }
}

/// Connected calendars. Its errors never touch the events list.
final calendarConnectionsProvider =
    AsyncNotifierProvider.autoDispose<
      CalendarConnectionsNotifier,
      List<CalendarConnectionModel>
    >(CalendarConnectionsNotifier.new);

class CalendarConnectionsNotifier
    extends AsyncNotifier<List<CalendarConnectionModel>> {
  @override
  Future<List<CalendarConnectionModel>> build() =>
      ref.read(calendarRepositoryProvider).getConnections();

  Future<void> disconnect(String id) async {
    await ref.read(calendarBusyProvider.notifier).run(id, () async {
      try {
        await ref.read(calendarRepositoryProvider).disconnectCalendar(id);
        if (ref.mounted) {
          state = AsyncData([
            for (final c in state.value ?? const <CalendarConnectionModel>[])
              if (c.id != id) c,
          ]);
        }
        ErrorHandler.showSuccess(
          'Calendar disconnected',
          title: 'Disconnected',
        );
      } catch (e, stack) {
        ErrorHandler.showError(
          e,
          title: 'Calendar not disconnected',
          stackTrace: stack,
        );
      }
    });
  }
}
