import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/feedback_controller.dart';
import '../models/feedback_model.dart';

/// Feedback submission page
class FeedbackPage extends GetView<FeedbackController> {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Feedback'),
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchTickets(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Success message
                Obx(() {
                  if (!controller.showSuccess.value) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: AppConstants.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thank you for your feedback!',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                "We'll review it and get back to you if needed.",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.green.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Form card
                AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.feedback_outlined,
                            color: tokens.brandColor,
                          ),
                          const SizedBox(width: AppConstants.spacing12),
                          Text(
                            'Submit Feedback',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        'We value your input and read every submission',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing24),

                      // Category dropdown
                      Text(
                        'Category *',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Obx(() => DropdownButtonFormField<TicketCategory>(
                            value: controller.category.value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacing16,
                                vertical: AppConstants.spacing12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: TicketCategory.bugReport,
                                child: Row(
                                  children: [
                                    Icon(Icons.bug_report, color: Colors.red, size: 20),
                                    SizedBox(width: 12),
                                    Text('Bug Report'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: TicketCategory.featureRequest,
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                                    SizedBox(width: 12),
                                    Text('Feature Request'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: TicketCategory.generalFeedback,
                                child: Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline, color: Colors.blue, size: 20),
                                    SizedBox(width: 12),
                                    Text('General Feedback'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: TicketCategory.supportRequest,
                                child: Row(
                                  children: [
                                    Icon(Icons.help_outline, color: Colors.green, size: 20),
                                    SizedBox(width: 12),
                                    Text('Support Request'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.category.value = value;
                              }
                            },
                          )),

                      const SizedBox(height: AppConstants.spacing16),

                      // Subject field
                      Text(
                        'Subject *',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      TextFormField(
                        onChanged: (value) => controller.subject.value = value,
                        decoration: InputDecoration(
                          hintText: 'Brief summary of your feedback',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing16,
                            vertical: AppConstants.spacing12,
                          ),
                        ),
                        maxLength: 200,
                      ),

                      const SizedBox(height: AppConstants.spacing16),

                      // Description field
                      Text(
                        'Description *',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Obx(() {
                        String hint;
                        switch (controller.category.value) {
                          case TicketCategory.bugReport:
                            hint = 'Describe the bug: What happened? What did you expect? Steps to reproduce?';
                            break;
                          case TicketCategory.featureRequest:
                            hint = "Describe the feature you'd like and how it would help you";
                            break;
                          default:
                            hint = 'Share your thoughts, suggestions, or questions';
                        }
                        return TextFormField(
                          onChanged: (value) => controller.description.value = value,
                          decoration: InputDecoration(
                            hintText: hint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(AppConstants.spacing16),
                          ),
                          maxLines: 5,
                          maxLength: 5000,
                        );
                      }),

                      const SizedBox(height: AppConstants.spacing16),

                      // Attachments
                      Text(
                        'Attachments (optional)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Obx(() => Wrap(
                            spacing: AppConstants.spacing8,
                            runSpacing: AppConstants.spacing8,
                            children: [
                              ...controller.attachments.asMap().entries.map((entry) {
                                final index = entry.key;
                                final file = entry.value;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(file),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => controller.removeAttachment(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              if (controller.attachments.length < 5)
                                GestureDetector(
                                  onTap: () => _showAttachmentOptions(context),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: tokens.cardBorderColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          color: tokens.textMuted,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Add',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: tokens.textMuted,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          )),
                      Text(
                        'Up to 5 images, max 5MB each',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),

                      const SizedBox(height: AppConstants.spacing24),

                      // Submit button
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: controller.isSubmitting.value ? null : controller.submit,
                              icon: controller.isSubmitting.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(
                                controller.isSubmitting.value ? 'Submitting...' : 'Submit Feedback',
                              ),
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Ticket history
                Obx(() {
                  if (controller.isLoadingTickets.value && controller.tickets.isEmpty) {
                    return AppGlassCard(
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history, color: tokens.brandColor),
                              const SizedBox(width: AppConstants.spacing12),
                              Text(
                                'Your Submissions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing16),
                          const ShimmerListTile(hasLeading: true, hasSubtitle: true),
                          const SizedBox(height: AppConstants.spacing8),
                          const ShimmerListTile(hasLeading: true, hasSubtitle: true),
                        ],
                      ),
                    );
                  }
                  if (controller.tickets.isEmpty) return const SizedBox.shrink();
                  return AppGlassCard(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, color: tokens.brandColor),
                            const SizedBox(width: AppConstants.spacing12),
                            Text(
                              'Your Submissions',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacing16),
                        ...controller.tickets.map((ticket) => _buildTicketItem(context, ticket, tokens)),
                      ],
                    ),
                  );
                }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                controller.takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketItem(BuildContext context, TicketListItem ticket, AppUiTokens tokens) {
    IconData icon;
    Color color;
    switch (ticket.category) {
      case TicketCategory.bugReport:
        icon = Icons.bug_report;
        color = Colors.red;
        break;
      case TicketCategory.featureRequest:
        icon = Icons.lightbulb_outline;
        color = Colors.amber;
        break;
      case TicketCategory.generalFeedback:
        icon = Icons.chat_bubble_outline;
        color = Colors.blue;
        break;
      case TicketCategory.supportRequest:
        icon = Icons.help_outline;
        color = Colors.green;
        break;
    }

    String statusLabel;
    Color statusColor;
    switch (ticket.status) {
      case TicketStatus.open:
        statusLabel = 'Open';
        statusColor = Colors.blue;
        break;
      case TicketStatus.inProgress:
        statusLabel = 'In Progress';
        statusColor = Colors.orange;
        break;
      case TicketStatus.resolved:
        statusLabel = 'Resolved';
        statusColor = Colors.green;
        break;
      case TicketStatus.closed:
        statusLabel = 'Closed';
        statusColor = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: tokens.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(ticket.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
