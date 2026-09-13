import 'dart:io';

import 'package:fitcheck_ai/features/feedback/controllers/feedback_controller.dart';
import 'package:fitcheck_ai/features/feedback/models/feedback_model.dart';
import 'package:fitcheck_ai/features/feedback/repositories/feedback_repository.dart';
import 'package:fitcheck_ai/features/feedback/views/feedback_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeFeedbackRepository extends FeedbackRepository {
  bool failTickets = false;
  int submitCalls = 0;
  Object? submitError;

  @override
  Future<List<TicketListItem>> getMyTickets({int limit = 20, int offset = 0}) {
    if (failTickets) return Future.error(Exception('support unavailable'));
    return Future.value(const <TicketListItem>[]);
  }

  @override
  Future<FeedbackResponse> submitFeedback({
    required TicketCategory category,
    required String subject,
    required String description,
    String? contactEmail,
    List<File>? attachments,
  }) async {
    submitCalls++;
    final error = submitError;
    if (error != null) throw error;
    return FeedbackResponse(
      id: 'ticket-1',
      category: category,
      subject: subject,
      status: TicketStatus.open,
      createdAt: DateTime(2026),
      message: 'created',
    );
  }
}

/// Pumps the REAL FeedbackPage so the page's own validators and submit flow
/// are exercised — bare host TextFormFields would carry no validators at all.
Future<FeedbackController> _pumpFeedbackPage(
  WidgetTester tester,
  FakeFeedbackRepository repository,
) async {
  final controller = Get.put(FeedbackController(repository: repository));
  await tester.pumpWidget(const GetMaterialApp(home: FeedbackPage()));
  await tester.pump();
  return controller;
}

/// Drains any queued Get snackbar (its dismiss timer runs on the fake clock;
/// tearing down mid-animation leaks the snackbar's ticker) and unmounts the
/// tree before Get disposes the controller.
Future<void> _drainAndUnmount(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  await tester.pumpWidget(const SizedBox.shrink());
  Get.reset();
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

  testWidgets('validators mirror the backend minimum lengths', (tester) async {
    final repository = FakeFeedbackRepository();
    final controller = await _pumpFeedbackPage(tester, repository);

    await tester.enterText(find.byType(TextFormField).at(0), 'ab');
    await tester.enterText(find.byType(TextFormField).at(1), 'too short');
    await tester.pump();

    await controller.submit();
    await tester.pump();

    expect(find.text('Subject must be at least 3 characters'), findsOneWidget);
    expect(
      find.text('Description must be at least 10 characters'),
      findsOneWidget,
    );
    expect(
      repository.submitCalls,
      0,
      reason: 'a too-short payload must be rejected before reaching the API',
    );

    await _drainAndUnmount(tester);
  });

  testWidgets('submit failure surfaces the server message', (tester) async {
    final repository = FakeFeedbackRepository()
      ..submitError = Exception('Device info must be valid JSON');
    final controller = await _pumpFeedbackPage(tester, repository);

    await tester.enterText(find.byType(TextFormField).at(0), 'Valid subject');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'A long enough description',
    );
    await tester.pump();

    await controller.submit();
    await tester.pump();

    expect(repository.submitCalls, 1);
    expect(
      controller.error.value,
      contains('Device info must be valid JSON'),
      reason: 'the fixed "Please try again" string hid the actual failure',
    );

    await _drainAndUnmount(tester);
  });
}
