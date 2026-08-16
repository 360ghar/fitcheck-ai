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
    // Regression pin for A10b-08: the invalidation token must be bumped
    // BEFORE the first await (settleBuildPhase). A plain `test()` can never
    // exercise the deferral path — `settleBuildPhase` returns
    // `Future.value(true)` immediately when no frame is running, so a
    // bump-after-await implementation passes identically. Here both fetches
    // run against REAL build frames:
    //
    //   frame 1: the first navigation starts mid-frame, is deferred by
    //            settleBuildPhase, and its request fires after the flush.
    //   frame 2: a second navigation lands mid-frame. With bump-before the
    //            token is bumped SYNCHRONOUSLY at the call, so the stale
    //            first response — completed right after the navigation in the
    //            same frame, before the second fetch's deferred body could
    //            ever resume — is dropped at apply time. A bump-after-await
    //            implementation would still hold the old token and apply it.
    final repo = FakeCalendarRepository();
    final controller = CalendarController(repository: repo);

    final stale = Completer<List<CalendarEventModel>>();
    final fresh = Completer<List<CalendarEventModel>>();
    repo.queueEvents(stale.future);
    repo.queueEvents(fresh.future);

    bool startedFirst = false;
    bool startedSecond = false;
    Future<void>? firstFetch;
    Future<void>? secondFetch;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            if (!startedFirst) {
              startedFirst = true;
              firstFetch = controller.fetchEventsForMonth(DateTime(2026, 1));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // The frame flushed: the first fetch resumed past settleBuildPhase and
    // its repository request is in flight.
    expect(repo.getEventsCalls, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            if (!startedSecond) {
              startedSecond = true;
              // Navigation lands mid-frame; the token bumps synchronously.
              secondFetch = controller.fetchEventsForMonth(DateTime(2026, 1));
              // The stale response completes in the SAME frame, before the
              // second fetch's deferred body resumes.
              stale.complete([_event('stale', DateTime(2026, 1, 1))]);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // The superseding fetch's deferred body resumed and fired its request.
    expect(repo.getEventsCalls, 2);

    await firstFetch!;
    expect(controller.events, isEmpty,
        reason: 'the stale in-flight response must be dropped after the '
            'mid-frame navigation');

    fresh.complete([_event('fresh', DateTime(2026, 1, 2))]);
    await secondFetch!;
    expect(controller.events.map((e) => e.id), ['fresh']);
    expect(controller.isLoadingEvents, isFalse);

    controller.dispose();
  });
}
