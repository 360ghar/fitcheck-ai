import 'dart:async';

import 'package:fitcheck_ai/features/calendar/controllers/calendar_controller.dart';
import 'package:fitcheck_ai/features/calendar/models/calendar_event_model.dart';
import 'package:fitcheck_ai/features/calendar/repositories/calendar_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test double for [CalendarRepository] driven by queued futures so tests can
/// resolve month fetches out of order (no network / Supabase involvement).
class FakeCalendarRepository extends CalendarRepository {
  final List<Future<List<CalendarEventModel>>> _eventResults = [];
  int getEventsCalls = 0;

  void queueEvents(Future<List<CalendarEventModel>> future) {
    _eventResults.add(future);
  }

  @override
  Future<List<CalendarEventModel>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    getEventsCalls += 1;
    return _eventResults.removeAt(0);
  }
}

CalendarEventModel _event(String id, DateTime start) => CalendarEventModel(
  id: id,
  title: id,
  startTime: start,
  endTime: start.add(const Duration(hours: 1)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Each test builds its own controller/repository.
  });

  test('stale month response cannot overwrite the focused month', () async {
    final repo = FakeCalendarRepository();
    final controller = CalendarController(repository: repo);

    final january = Completer<List<CalendarEventModel>>();
    final february = Completer<List<CalendarEventModel>>();
    repo.queueEvents(january.future);
    repo.queueEvents(february.future);

    // User is on January; the fetch is in flight.
    final janFetch = controller.fetchEventsForMonth(DateTime(2026, 1));
    // Navigation to February starts while January is still in flight.
    final febFetch = controller.fetchEventsForMonth(DateTime(2026, 2));

    // The stale January response lands AFTER February was requested — it must
    // be dropped, not clobber February's events.
    january.complete([_event('jan-event', DateTime(2026, 1, 10))]);
    await janFetch;
    expect(controller.events, isEmpty, reason: 'stale month must be dropped');

    february.complete([_event('feb-event', DateTime(2026, 2, 10))]);
    await febFetch;
    expect(controller.events.map((e) => e.id), ['feb-event']);
    expect(controller.isLoadingEvents, isFalse);

    controller.dispose();
  });

  test('generation is reserved before settleBuildPhase defers the call',
      () async {
    // Regression pin for A10b-08: the invalidation token must be bumped
    // BEFORE the first await (settleBuildPhase), so a navigation during a
    // build frame invalidates an already-running request immediately.
    final repo = FakeCalendarRepository();
    final controller = CalendarController(repository: repo);

    final january = Completer<List<CalendarEventModel>>();
    repo.queueEvents(january.future);

    final janFetch = controller.fetchEventsForMonth(DateTime(2026, 1));
    // Even with no month change, an explicit second navigation to the same
    // month supersedes the first in-flight request.
    final again = Completer<List<CalendarEventModel>>();
    repo.queueEvents(again.future);
    final secondFetch = controller.fetchEventsForMonth(DateTime(2026, 1));

    january.complete([_event('stale', DateTime(2026, 1, 1))]);
    await janFetch;
    expect(controller.events, isEmpty);

    again.complete([_event('fresh', DateTime(2026, 1, 2))]);
    await secondFetch;
    expect(controller.events.map((e) => e.id), ['fresh']);

    controller.dispose();
  });
}
