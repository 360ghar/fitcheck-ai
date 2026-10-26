import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/extraction_jobs_provider.dart';
import '../widgets/extraction_progress_card.dart' show PaperProgressTrack;

/// Activity list: running scans with live progress plus recent finished
/// ones. A finished job opens its review; a running one resumes its
/// progress view. Jobs survive navigation and app restarts — this page is
/// where the user comes back to them.
class ExtractionJobsPage extends ConsumerWidget {
  const ExtractionJobsPage({super.key});

  void _open(BuildContext context, WidgetRef ref, TrackedJob job) {
    if (job.kind == TrackedJobKind.batch) {
      if (job.isComplete) {
        // The progress page auto-forwards a complete job to review.
        context.push(Routes.wardrobeBatchProgress, extra: job.jobId);
      } else if (job.isActive) {
        context.push(Routes.wardrobeBatchProgress, extra: job.jobId);
      }
      // Failed/cancelled batches have no review: nothing to open.
    } else {
      if (job.status == TrackedJobStatus.cancelled) return;
      context.push(Routes.wardrobeAdd, extra: job.jobId);
    }
  }

  /// The registry stops the job locally even when the server call fails;
  /// the failure is shown instead of escaping as an unhandled async error.
  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    String jobId,
  ) async {
    // Read before the await: the dialog is shown after the request fails.
    final title = context.l10n.jobsNotCancelled;
    try {
      await ref.read(extractionJobsProvider.notifier).cancel(jobId);
    } catch (e, stack) {
      ErrorHandler.showError(e, title: title, stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(extractionJobsProvider.select((s) => s.recent));

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.jobsTitle)),
        body: AppPageBackground(
          child: SafeArea(
            top: false,
            child: jobs.isEmpty
                ? AppEmptyState(
                    scene: PaperScenes.closet,
                    title: context.l10n.jobsEmptyTitle,
                    message: context.l10n.jobsEmptyBody,
                    actionLabel: context.l10n.quickAddPiece,
                    onAction: () => context.push(Routes.wardrobeAdd),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spacing16,
                      AppConstants.spacing8,
                      AppConstants.spacing16,
                      AppConstants.spacing32,
                    ),
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppConstants.spacing8),
                    itemBuilder: (context, i) => _JobCard(
                      job: jobs[i],
                      onOpen: () => _open(context, ref, jobs[i]),
                      onCancel: jobs[i].isActive
                          ? () => _cancel(context, ref, jobs[i].jobId)
                          : null,
                      onDismiss: jobs[i].isActive
                          ? null
                          : () => ref
                                .read(extractionJobsProvider.notifier)
                                .forget(jobs[i].jobId),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.onOpen,
    this.onCancel,
    this.onDismiss,
  });

  final TrackedJob job;
  final VoidCallback onOpen;
  final VoidCallback? onCancel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final statusIcon = switch (job.status) {
      TrackedJobStatus.running => SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: tokens.stock.accent,
          strokeCap: StrokeCap.round,
        ),
      ),
      TrackedJobStatus.complete => Icon(
        Icons.check_rounded,
        size: 22,
        color: tokens.success,
      ),
      TrackedJobStatus.failed => Icon(
        Icons.error_outline_rounded,
        size: 22,
        color: tokens.error,
      ),
      TrackedJobStatus.cancelled => Icon(
        Icons.cancel_outlined,
        size: 22,
        color: tokens.textMuted,
      ),
    };
    final actionLabel = switch (job.status) {
      TrackedJobStatus.running => l10n.jobsResume,
      TrackedJobStatus.complete => l10n.jobsReview,
      TrackedJobStatus.failed =>
        job.kind == TrackedJobKind.single ? l10n.actionRetry : null,
      TrackedJobStatus.cancelled => null,
    };

    return PaperSurface(
      onTap: actionLabel == null ? null : onOpen,
      semanticLabel: '${job.label}, ${job.progressText}',
      padding: const EdgeInsetsDirectional.only(
        start: AppConstants.spacing16,
        top: AppConstants.spacing12,
        end: AppConstants.spacing8,
        bottom: AppConstants.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              statusIcon,
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Text(
                  job.kind == TrackedJobKind.batch
                      ? '${job.label} batch'
                      : job.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall,
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  tooltip: context.l10n.jobsDismiss,
                  icon: Icon(Icons.close_rounded, color: tokens.textMuted),
                  onPressed: onDismiss,
                ),
            ],
          ),
          if (job.isActive) ...[
            const SizedBox(height: AppConstants.spacing8),
            _ProgressLine(job: job),
          ],
          const SizedBox(height: AppConstants.spacing4),
          Row(
            children: [
              Expanded(
                child: Text(
                  job.progressText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: job.status == TrackedJobStatus.failed
                        ? tokens.error
                        : tokens.textSecondary,
                  ),
                ),
              ),
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  child: Text(context.l10n.jobsStop),
                )
              else if (actionLabel != null)
                TextButton(onPressed: onOpen, child: Text(actionLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends ConsumerWidget {
  const _ProgressLine({required this.job});

  final TrackedJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-read the live job so the bar animates with the registry.
    final live =
        ref.watch(extractionJobsProvider.select((s) => s.job(job.jobId))) ??
        job;
    return PaperProgressTrack(
      value: live.progress,
      semanticLabel: live.progressText,
    );
  }
}
