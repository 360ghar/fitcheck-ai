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
}
