import 'package:fitcheck_ai/features/calendar/repositories/calendar_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar update payload preserves both all-day values', () {
    final repository = CalendarRepository();

    expect(
      repository.buildUpdateEventPayload(isAllDay: true)['is_all_day'],
      true,
    );
    expect(
      repository.buildUpdateEventPayload(isAllDay: false)['is_all_day'],
      false,
    );
  });

  test('update payload sends empty location/description as explicit clears', () {
    // The edit dialog passes '' when the user clears these fields; null means
    // "not provided" and is dropped. The backend stores '' for keys that are
    // present, so the keys must survive the payload build.
    final repository = CalendarRepository();

    final payload = repository.buildUpdateEventPayload(
      description: '',
      location: '',
    );

    expect(payload.containsKey('description'), isTrue,
        reason: 'cleared description must be sent as ""');
    expect(payload['description'], '');
    expect(payload.containsKey('location'), isTrue,
        reason: 'cleared location must be sent as ""');
    expect(payload['location'], '');
  });
}
