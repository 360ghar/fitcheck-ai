import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_handler.dart';
import '../models/feedback_model.dart';
import '../repositories/feedback_repository.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => FeedbackRepository(),
);

final feedbackTicketsProvider =
    AsyncNotifierProvider.autoDispose<
      FeedbackTicketsNotifier,
      List<TicketListItem>
    >(FeedbackTicketsNotifier.new);

/// The user's past submissions, and sending a new one.
class FeedbackTicketsNotifier extends AsyncNotifier<List<TicketListItem>> {
  FeedbackRepository get _repository => ref.read(feedbackRepositoryProvider);

  @override
  Future<List<TicketListItem>> build() => _repository.getMyTickets();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getMyTickets);
  }

  /// Sends feedback. Returns true on success; the error is shown otherwise,
  /// with the server's reason (for example a 422 message).
  Future<bool> submit({
    required TicketCategory category,
    required String subject,
    required String description,
    List<File> attachments = const [],
  }) async {
    try {
      await _repository.submitFeedback(
        category: category,
        subject: subject,
        description: description,
        attachments: attachments.isEmpty ? null : attachments,
      );
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not sent', stackTrace: stack);
      return false;
    }
    ErrorHandler.showSuccess(
      'Thanks. We read every message and reply if we need more.',
      title: 'Feedback sent',
    );
    if (ref.mounted) await refresh();
    return true;
  }
}
