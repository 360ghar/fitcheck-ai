import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../core/widgets/app_ui.dart';
import '../../settings/widgets/paper_group.dart';
import '../models/feedback_model.dart';
import '../providers/feedback_provider.dart';

const _maxAttachments = 5;
const _maxAttachmentBytes = 5 * 1024 * 1024;

String _categoryLabel(TicketCategory c) => switch (c) {
  TicketCategory.bugReport => 'Something broke',
  TicketCategory.featureRequest => 'An idea',
  TicketCategory.generalFeedback => 'General',
  TicketCategory.supportRequest => 'I need help',
};

/// Send feedback and see what you sent before.
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  final List<File> _attachments = [];
  TicketCategory _category = TicketCategory.generalFeedback;
  bool _submitting = false;

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_attachments.length >= _maxAttachments) {
      ErrorHandler.showValidation(
        'You can add up to 5 images.',
        title: 'Limit reached',
      );
      return;
    }
    // Explain first, then send the user to Settings on a permanent denial;
    // otherwise image_picker throws and the button does nothing.
    final allowed = source == ImageSource.camera
        ? await PermissionHelper.confirmCameraRationale()
        : await PermissionHelper.confirmPhotoRationale();
    if (!allowed) return;
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final file = File(picked.path);
      if (await file.length() > _maxAttachmentBytes) {
        ErrorHandler.showValidation(
          'Choose an image under 5 MB.',
          title: 'Image too large',
        );
        return;
      }
      if (mounted) setState(() => _attachments.add(file));
    } catch (_) {
      await PermissionHelper.showDeniedRecovery(
        permissionName: source == ImageSource.camera ? 'Camera' : 'Photos',
      );
    }
  }

  void _chooseSource() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final sent = await ref
        .read(feedbackTicketsProvider.notifier)
        .submit(
          category: _category,
          subject: _subject.text.trim(),
          description: _description.text.trim(),
          attachments: [..._attachments],
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (sent) {
        _category = TicketCategory.generalFeedback;
        _subject.clear();
        _description.clear();
        _attachments.clear();
        _formKey.currentState?.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: const Text('Send feedback')),
        body: AppPageBackground(
          child: RefreshIndicator(
            onRefresh: ref.read(feedbackTicketsProvider.notifier).refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppConstants.spacing16,
                AppConstants.spacing8,
                AppConstants.spacing16,
                AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                _form(context),
                const SizedBox(height: AppConstants.spacing24),
                const _Tickets(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final hint = switch (_category) {
      TicketCategory.bugReport =>
        'What happened, and what did you expect? Steps help us fix it.',
      TicketCategory.featureRequest => 'What would you like, and why?',
      _ => 'Tell us what you think, or ask a question.',
    };

    return PaperSurface(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('What is it about?', style: text.headlineSmall),
            const SizedBox(height: AppConstants.spacing12),
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: [
                for (final c in TicketCategory.values)
                  ChoiceChip(
                    label: Text(_categoryLabel(c)),
                    selected: _category == c,
                    showCheckmark: false,
                    onSelected: _submitting
                        ? null
                        : (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing20),
            TextFormField(
              controller: _subject,
              enabled: !_submitting,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Subject'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Add a subject';
                // Mirrors the backend's min_length=3.
                if (text.length < 3) {
                  return 'Subject must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacing8),
            TextFormField(
              controller: _description,
              enabled: !_submitting,
              minLines: 4,
              maxLines: 8,
              maxLength: 5000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Details',
                hintText: hint,
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Add some details';
                // Mirrors the backend's min_length=10.
                if (text.length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacing8),
            if (_attachments.isNotEmpty) ...[
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: [
                  for (final (i, file) in _attachments.indexed)
                    _Thumbnail(
                      file: file,
                      index: i,
                      onRemove: _submitting
                          ? null
                          : () => setState(() => _attachments.removeAt(i)),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing8),
            ],
            Row(
              children: [
                TextButton.icon(
                  // Flush with the fields above.
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(right: AppConstants.spacing8),
                  ),
                  onPressed:
                      _submitting || _attachments.length >= _maxAttachments
                      ? null
                      : _chooseSource,
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 20,
                  ),
                  label: const Text('Add a screenshot'),
                ),
                const SizedBox(width: AppConstants.spacing8),
                Expanded(
                  child: Text(
                    'Up to 5, 5 MB each',
                    style: text.bodySmall?.copyWith(color: tokens.textMuted),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.file, required this.index, this.onRemove});

  final File file;
  final int index;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: Image.file(file, fit: BoxFit.cover),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove image ${index + 1}',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
              style: IconButton.styleFrom(
                // Black over a photo keeps the mark readable on any image.
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                minimumSize: const Size(44, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tickets extends ConsumerWidget {
  const _Tickets();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(feedbackTicketsProvider);
    final notifier = ref.read(feedbackTicketsProvider.notifier);
    final tokens = PaperTokens.of(context);

    final value = tickets.value;
    if (value == null) {
      if (tickets.hasError && !tickets.isLoading) {
        return AppErrorBanner(error: tickets.error, onRetry: notifier.refresh);
      }
      return const SkeletonPulse(
        child: SkeletonBox(height: 140, borderRadius: AppConstants.radius12),
      );
    }
    if (value.isEmpty) {
      return const AppEmptyState(
        scene: PaperScenes.studio,
        title: 'Nothing sent yet',
        message: 'What you send shows up here with its status.',
      );
    }

    (String, Color) status(TicketStatus s) => switch (s) {
      TicketStatus.open => ('Open', tokens.stock.accent),
      TicketStatus.inProgress => ('In progress', tokens.warning),
      TicketStatus.resolved => ('Resolved', tokens.success),
      TicketStatus.closed => ('Closed', tokens.textMuted),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tickets.hasError && !tickets.isLoading)
          AppErrorBanner(error: tickets.error, onRetry: notifier.refresh),
        PaperGroup(
          title: 'What you sent',
          children: [
            for (final ticket in value)
              ListTile(
                title: Text(
                  ticket.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_categoryLabel(ticket.category)} · '
                  '${AppDateUtils.formatDate(ticket.createdAt)}',
                  style: TextStyle(color: tokens.textMuted),
                ),
                trailing: Text(
                  status(ticket.status).$1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: status(ticket.status).$2,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
