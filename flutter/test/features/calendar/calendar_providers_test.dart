import 'dart:async';

import 'package:fitcheck_ai/core/exceptions/app_exceptions.dart';
import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/features/calendar/models/calendar_connection_model.dart';
import 'package:fitcheck_ai/features/calendar/models/calendar_event_model.dart';
import 'package:fitcheck_ai/features/calendar/providers/calendar_providers.dart';
import 'package:fitcheck_ai/features/calendar/repositories/calendar_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarEventModel event(String id, DateTime start) => CalendarEventModel(
  id: id,
  title: id,
  startTime: start,
  endTime: start.add(const Duration(hours: 1)),
);

/// Month fetches resolve from queued futures, so tests can finish them out
/// of order.
class FakeCalendarRepository extends CalendarRepository {
  final eventResults = <Future<List<CalendarEventModel>> Function()>[];
  int getEventsCalls = 0;
  int creates = 0;
  Completer<void>? createGate;
  Object? connectionsError;

  @override
  Future<List<CalendarEventModel>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    getEventsCalls++;
    return eventResults.isEmpty ? Future.value([]) : eventResults.removeAt(0)();
  }

  @override
  Future<List<CalendarConnectionModel>> getConnections() async {
    if (connectionsError != null) throw connectionsError!;
    return [];
  }

  @override
  Future<CalendarEventModel> createEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
    bool isAllDay = false,
    String? outfitId,
  }) async {
    creates++;
    await createGate?.future;
    return event('new-$creates', startTime);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCalendarRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeCalendarRepository();
    container = ProviderContainer(
      retry: noRetry,
      overrides: [calendarRepositoryProvider.overrideWithValue(repo)],
    );
    container.listen(calendarEventsProvider, (_, _) {});
  });
  tearDown(() => container.dispose());

  List<String> ids() => [
    for (final e in container.read(calendarEventsProvider).value ?? []) e.id,
  ];
  CalendarMonth month() => container.read(calendarMonthProvider.notifier);

  test('a stale month response cannot overwrite the shown month', () async {
    final january = Completer<List<CalendarEventModel>>();
    final february = Completer<List<CalendarEventModel>>();
    await container.read(calendarEventsProvider.future);
    repo.eventResults.addAll([() => january.future, () => february.future]);

    month().show(DateTime(2026, 1));
    container.read(calendarEventsProvider);
    month().show(DateTime(2026, 2));
    final feb = container.read(calendarEventsProvider.future);

    january.complete([event('jan', DateTime(2026, 1, 10))]);
    await Future<void>.delayed(Duration.zero);
    expect(ids(), isNot(contains('jan')));

    february.complete([event('feb', DateTime(2026, 2, 10))]);
    await feb;
    expect(ids(), ['feb']);
    expect(container.read(calendarEventsProvider).isLoading, isFalse);
  });

  test('revisiting a month fetches it again', () async {
    await container.read(calendarEventsProvider.future);
    final before = repo.getEventsCalls;
    for (final m in [5, 6, 5]) {
      month().show(DateTime(2026, m));
      await container.read(calendarEventsProvider.future);
    }
    expect(repo.getEventsCalls - before, 3);

    // The same month again sends nothing.
    month().show(DateTime(2026, 5, 20));
    await container.read(calendarEventsProvider.future);
    expect(repo.getEventsCalls - before, 3);
  });

  test('two quick taps on create make one event', () async {
    await container.read(calendarEventsProvider.future);
    repo.createGate = Completer<void>();
    final notifier = container.read(calendarEventsProvider.notifier);
    final start = DateTime(2026, 9, 23, 9);

    Future<CalendarEventModel?> create() => notifier.create(
      title: 'Dinner',
      startTime: start,
      endTime: start.add(const Duration(hours: 2)),
    );
    final first = create();
    final second = create();
    repo.createGate!.complete();

    expect(await second, isNull);
    expect((await first)?.id, 'new-1');
    expect(repo.creates, 1);
    expect(ids(), ['new-1']);
  });

  test('a connections failure leaves the events untouched', () async {
    repo.connectionsError = const ServerException(
      message: 'boom',
      statusCode: 500,
    );
    repo.eventResults.add(() async => [event('e', DateTime(2026, 9, 1))]);
    container.invalidate(calendarEventsProvider);
    await container.read(calendarEventsProvider.future);

    container.listen(calendarConnectionsProvider, (_, _) {});
    await expectLater(
      container.read(calendarConnectionsProvider.future),
      throwsA(isA<ServerException>()),
    );

    expect(container.read(calendarEventsProvider).hasError, isFalse);
    expect(ids(), ['e']);
  });

  test('events group by local day, sorted by start', () {
    final byDay = eventsByDay([
      event('late', DateTime(2026, 9, 23, 18)),
      event('early', DateTime(2026, 9, 23, 8)),
    ]);
    expect(byDay[DateTime(2026, 9, 23)]!.map((e) => e.id), ['early', 'late']);
  });
}
