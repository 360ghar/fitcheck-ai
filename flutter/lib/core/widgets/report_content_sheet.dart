import 'package:flutter/material.dart';

import '../../features/feedback/models/feedback_model.dart';
import '../../features/feedback/repositories/feedback_repository.dart';
import '../constants/app_constants.dart';
import '../i18n/l10n.dart';
import '../providers.dart';
import '../utils/error_handler.dart';
import 'app_ui.dart';

/// What kind of content is being reported.
///
/// The [ticketLabel] is deliberately English and never shown to the user: it is
/// what reaches the support ticket, so a moderator triaging reports reads one
/// stable vocabulary instead of forty-three translations of "AI try-on image".
/// The user sees [l10nLabel] in their own language.
enum ReportContentType {
  tryOnImage('AI try-on image'),
  sharedOutfit('shared outfit'),
  photoshootImage('AI photoshoot image');

  const ReportContentType(this.ticketLabel);

  final String ticketLabel;

  String l10nLabel(BuildContext context) => switch (this) {
    ReportContentType.tryOnImage => context.l10n.reportContentTryOnImage,
    ReportContentType.sharedOutfit => context.l10n.reportContentSharedOutfit,
    ReportContentType.photoshootImage =>
      context.l10n.reportContentPhotoshootImage,
  };
}

/// The reasons, with a stable English token for the ticket and a localized
/// label for the user. Same split as [ReportContentType], same reason.
enum _ReportReason {
  inappropriate('Inappropriate or offensive'),
  nudity('Nudity or sexual content'),
  harassment('Harassment or abuse'),
  impersonation('Impersonation'),
  other('Other');

  const _ReportReason(this.token);

  final String token;

  String label(BuildContext context) => switch (this) {
    _ReportReason.inappropriate => context.l10n.reportReasonInappropriate,
    _ReportReason.nudity => context.l10n.reportReasonNudity,
    _ReportReason.harassment => context.l10n.reportReasonHarassment,
    _ReportReason.impersonation => context.l10n.reportReasonImpersonation,
    _ReportReason.other => context.l10n.reportReasonOther,
  };
}

/// The support-ticket payload for a content report.
///
/// Deliberately pure and separate from the widget. The whole point of the
/// English tokens in [ReportContentType.ticketLabel] and [_ReportReason.token]
/// is that a moderator reads one stable vocabulary no matter which of the 43
/// languages the reporter was using, and that is exactly the kind of invariant
/// that quietly rots when it is only reachable through a widget pump and a
/// network call. Exposed for tests.
@visibleForTesting
({String subject, String description, TicketCategory category}) buildReportTicket({
  required ReportContentType contentType,
  required String contentId,
  required String reasonToken,
  required String details,
}) {
  return (
    subject: 'Content report: ${contentType.ticketLabel} $contentId',
    // A report with no extra detail should read as two blocks, not four: an
    // empty `details` used to leave two blank lines between the reason and the
    // trailer.
    description: details.isEmpty
        ? '$reasonToken\n\nReported via in-app report.'
        : '$reasonToken\n\n$details\n\nReported via in-app report.',
    category: TicketCategory.supportRequest,
  );
}

/// Reusable bottom sheet that lets a user report objectionable user-generated
/// content (Apple Guideline 1.2). Reports are filed through the existing
/// support-ticket system so the team can review and act on them.
///
/// Every user-visible string comes from the ARB catalogs. This is the app's
/// App Review compliance control, so shipping it in English inside a
/// 50-locale app would undermine the one flow the reviewer is most likely to
/// open.
///
/// Open via [showReportContentSheet].
Future<void> showReportContentSheet({
  required ReportContentType contentType,
  required String contentId,
}) async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        ReportContentSheet(contentType: contentType, contentId: contentId),
  );
}

class ReportContentSheet extends StatefulWidget {
  final ReportContentType contentType;
  final String contentId;

  const ReportContentSheet({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  @override
  State<ReportContentSheet> createState() => _ReportContentSheetState();
}

class _ReportContentSheetState extends State<ReportContentSheet> {
  final FeedbackRepository _repository = FeedbackRepository();
  final TextEditingController _detailsController = TextEditingController();

  _ReportReason _selectedReason = _ReportReason.inappropriate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final l10n = context.l10n;
    final details = _detailsController.text.trim();
    try {
      final ticket = buildReportTicket(
        contentType: widget.contentType,
        contentId: widget.contentId,
        reasonToken: _selectedReason.token,
        details: details,
      );
      await _repository.submitFeedback(
        category: ticket.category,
        subject: ticket.subject,
        // The reason token stays English for triage; `details` is whatever the
        // user typed, in their own language, which is expected and fine.
        description: ticket.description,
      );

      if (mounted) Navigator.pop(context);
      ErrorHandler.showInfo(
        l10n.reportSubmittedBody,
        title: l10n.reportSubmittedTitle,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      ErrorHandler.showError(
        l10n.reportFailedBody,
        title: l10n.reportFailedTitle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final l10n = context.l10n;

    // Material, not a decorated Container: RadioListTile paints its ink splash
    // on the nearest Material ancestor, and a Container's BoxDecoration sits
    // between the two and swallows it. Flutter asserts on that in debug and the
    // splash is simply invisible in release.
    return Material(
      color: tokens.cardColor,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radius24),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          // Directional: an Arabic or Hebrew user must get the same 24pt gutter
          // on the reading edge, not a mirrored one.
          padding: EdgeInsetsDirectional.only(
            start: AppConstants.spacing24,
            end: AppConstants.spacing24,
            top: AppConstants.spacing24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                AppConstants.spacing24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: tokens.brandColor),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Text(
                        l10n.reportTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  l10n.reportIntro(widget.contentType.l10nLabel(context)),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: AppConstants.spacing16),
                RadioGroup<_ReportReason>(
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedReason = value);
                  },
                  child: Column(
                    children: [
                      for (final reason in _ReportReason.values)
                        RadioListTile<_ReportReason>(
                          value: reason,
                          title: Text(reason.label(context)),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                TextField(
                  controller: _detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.reportDetailsLabel,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.reportSubmit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
