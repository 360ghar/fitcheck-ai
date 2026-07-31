import 'package:fitcheck_ai/features/feedback/controllers/feedback_controller.dart';
import 'package:fitcheck_ai/features/feedback/models/feedback_model.dart';
import 'package:fitcheck_ai/features/feedback/repositories/feedback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFeedbackRepository extends FeedbackRepository {
  bool failTickets = false;

  @override
  Future<List<TicketListItem>> getMyTickets({int limit = 20, int offset = 0}) {
    if (failTickets) return Future.error(Exception('support unavailable'));
    return Future.value(const <TicketListItem>[]);
  }
}

void main() {
  test('ticket history errors are visible in controller state', () async {
    final controller = FeedbackController(
      repository: FakeFeedbackRepository()..failTickets = true,
    );

    await controller.fetchTickets();

    expect(controller.error.value, contains('support unavailable'));
    controller.onClose();
  });

  testWidgets('success reset callback does not write after disposal', (
    tester,
  ) async {
    final controller = FeedbackController(repository: FakeFeedbackRepository())
      ..showSuccess.value = true;

    controller.scheduleSuccessDismissal(duration: Duration.zero);
    controller.onClose();
    await tester.pump();

    expect(controller.showSuccess.value, isTrue);
  });
}
