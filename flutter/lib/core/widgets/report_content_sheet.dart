import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import 'app_ui.dart';
import '../../features/feedback/models/feedback_model.dart';
import '../../features/feedback/repositories/feedback_repository.dart';

/// Reusable bottom sheet that lets a user report objectionable user-generated
/// content (Apple Guideline 1.2). Reports are filed through the existing
/// support-ticket system so the team can review and act on them.
///
/// Open via [showReportContentSheet].
Future<void> showReportContentSheet({
  required String contentType,
  required String contentId,
}) {
  return Get.bottomSheet<void>(
    ReportContentSheet(contentType: contentType, contentId: contentId),
    isScrollControlled: true,
  );
}

class ReportContentSheet extends StatefulWidget {
  final String contentType;
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
  static const List<String> _reasons = [
    'Inappropriate or offensive',
    'Nudity or sexual content',
    'Harassment or abuse',
    'Impersonation',
    'Other',
  ];

  final FeedbackRepository _repository = FeedbackRepository();
  final TextEditingController _detailsController = TextEditingController();

  String _selectedReason = _reasons.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final details = _detailsController.text.trim();
    try {
      await _repository.submitFeedback(
        category: TicketCategory.supportRequest,
        subject: 'Content report: ${widget.contentType} ${widget.contentId}',
        description:
            '$_selectedReason\n\n$details\n\nReported via in-app report.',
      );

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        'Report Submitted',
        'Thank you. Our team will review this content.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      Get.snackbar(
        'Error',
        'Failed to submit report. Please try again.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppConstants.spacing24,
            right: AppConstants.spacing24,
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
                        'Report Content',
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
                  'Tell us what\'s wrong with this ${widget.contentType}. '
                  'Our team reviews every report.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: AppConstants.spacing16),
                ..._reasons.map(
                  (reason) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(reason),
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedReason = value);
                            }
                          },
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                TextField(
                  controller: _detailsController,
                  enabled: !_isSubmitting,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional details (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Report'),
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
