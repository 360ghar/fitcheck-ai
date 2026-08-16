import 'dart:async';

import 'package:fitcheck_ai/features/calendar/controllers/calendar_controller.dart';
import 'package:fitcheck_ai/features/calendar/models/calendar_event_model.dart';
import 'package:fitcheck_ai/features/calendar/repositories/calendar_repository.dart';
import 'package:flutter/material.dart';
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

  testWidgets('generation is reserved before settleBuildPhase defers the call',
      (tester) async {
    // A10b-08 pin: the token must bump SYNCHRONOUSLY at the call, before
    // settleBuildPhase defers. Completing a stale future mid-build cannot
    // distinguish bump-before from bump-after — the apply is a microtask
    // and only runs after post-frame callbacks, so both implementations
    // would already have generation 2. Read debugFetchGeneration in the
    // same build as the call: bump-after would still be 0 here.
    final repo = FakeCalendarRepository();
    final controller = CalendarController(repository: repo);

    final pending = Completer<List<CalendarEventModel>>();
    repo.queueEvents(pending.future);

    var started = false;
    var genAfterCall = -1;
    Future<void>? fetch;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            if (!started) {
              started = true;
              fetch = controller.fetchEventsForMonth(DateTime(2026, 1));
              genAfterCall = controller.debugFetchGeneration;
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(genAfterCall, 1,
        reason: 'token must bump before settleBuildPhase defers the body');
    expect(repo.getEventsCalls, 1);

    pending.complete([_event('fresh', DateTime(2026, 1, 2))]);
    await fetch!;
    expect(controller.events.map((e) => e.id), ['fresh']);

    controller.dispose();
  });
}
