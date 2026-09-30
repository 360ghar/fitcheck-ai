import 'dart:io';

import 'package:fitcheck_ai/core/providers.dart' show noRetry;
import 'package:fitcheck_ai/core/services/notification_service.dart'
    show scaffoldMessengerKey;
import 'package:fitcheck_ai/features/feedback/models/feedback_model.dart';
import 'package:fitcheck_ai/features/feedback/providers/feedback_provider.dart';
import 'package:fitcheck_ai/features/feedback/repositories/feedback_repository.dart';
import 'package:fitcheck_ai/features/feedback/views/feedback_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFeedbackRepository extends FeedbackRepository {
  bool failTickets = false;
  int submitCalls = 0;
  int ticketCalls = 0;
  Object? submitError;

  @override
  Future<List<TicketListItem>> getMyTickets({int limit = 20, int offset = 0}) {
    ticketCalls++;
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

/// Pumps the real FeedbackPage so its validators and submit flow run.
Future<void> _pump(WidgetTester tester, FakeFeedbackRepository repo) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: [feedbackRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: FeedbackPage(),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _fill(WidgetTester tester, String subject, String details) async {
  await tester.enterText(find.byType(TextFormField).at(0), subject);
  await tester.enterText(find.byType(TextFormField).at(1), details);
  await tester.tap(find.text('Send'));
  await tester.pump();
}

void main() {
  testWidgets('ticket history errors show a retry banner', (tester) async {
    final repo = FakeFeedbackRepository()..failTickets = true;
    await _pump(tester, repo);

    // The banner shows stable copy, never the raw backend diagnostic.
    expect(find.text("Couldn't refresh. Showing what we have."), findsOneWidget);
    expect(find.text('support unavailable'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('validators mirror the backend minimum lengths', (tester) async {
    final repo = FakeFeedbackRepository();
    await _pump(tester, repo);

    await _fill(tester, 'ab', 'too short');

    expect(find.text('Subject must be at least 3 characters'), findsOneWidget);
    expect(
      find.text('Description must be at least 10 characters'),
      findsOneWidget,
    );
    expect(repo.submitCalls, 0, reason: 'rejected before reaching the API');
  });

  testWidgets('submit failure surfaces the server message', (tester) async {
    final repo = FakeFeedbackRepository()
      ..submitError = Exception('Device info must be valid JSON');
    await _pump(tester, repo);

    await _fill(tester, 'Valid subject', 'A long enough description');
    await tester.pump();

    expect(repo.submitCalls, 1);
    expect(find.text('Device info must be valid JSON'), findsOneWidget);
    // The typed text stays for another try.
    expect(find.text('Valid subject'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a sent message clears the form and reloads tickets', (
    tester,
  ) async {
    final repo = FakeFeedbackRepository();
    await _pump(tester, repo);

    await _fill(tester, 'Valid subject', 'A long enough description');
    await tester.pump();

    expect(repo.submitCalls, 1);
    expect(repo.ticketCalls, 2);
    expect(find.text('Valid subject'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
  });
}
