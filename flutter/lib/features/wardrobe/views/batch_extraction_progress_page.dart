import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';
import '../providers/batch_extraction_provider.dart';
import '../providers/extraction_jobs_provider.dart';
import '../widgets/extraction_progress_card.dart';

/// Batch progress: finding pieces in each photo, then studio photos. Opens
/// the review once the job completes. [resumeJobId] reattaches to a
/// registry-owned job (jobs list, shade notification) instead of requiring a
/// fresh start from the selector.
///
/// Leaving this page never stops the scan: the registry owns the job and the
/// shade notifies when it finishes.
class BatchExtractionProgressPage extends ConsumerStatefulWidget {
  const BatchExtractionProgressPage({super.key, this.resumeJobId});

  final String? resumeJobId;

  @override
  ConsumerState<BatchExtractionProgressPage> createState() =>
      _BatchExtractionProgressPageState();
}

class _BatchExtractionProgressPageState
    extends ConsumerState<BatchExtractionProgressPage> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(batchExtractionProvider.select((s) => s.isComplete), (
      _,
      complete,
    ) {
      if (complete &&
          ref.read(batchExtractionProvider.notifier).claimReviewNavigation()) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.pushReplacement(Routes.wardrobeBatchReview),
        );
      }
    }, fireImmediately: true);
    // Reattach to a backgrounded job: an explicit resume id wins, otherwise
    // the latest active batch job. Nothing to resume closes the page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(batchExtractionProvider.notifier);
      final current = ref.read(batchExtractionProvider).jobId;
      final requested = widget.resumeJobId;
      if (current.isNotEmpty) {
        // Already showing a job: keep it unless a different one was asked
        // for (e.g. a notification for another scan). Detach without
        // cancelling, then fall through to attach the requested job.
        if (requested == null || requested == current) return;
        notifier.resetJob();
      }
      final jobs = ref.read(extractionJobsProvider);
      final resumeId =
          requested ??
          jobs.active
              .where((job) => job.kind == TrackedJobKind.batch)
              .lastOrNull
              ?.jobId;
      if (resumeId == null || resumeId.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }
      notifier.attachToJob(resumeId);
    });
  }

  /// Back to the selection with the photos kept. The scan keeps running in
  /// the background (banner + shade notification on finish).
  void _backToPhotos() {
    final wasProcessing = ref.read(batchExtractionProvider).isProcessing;
    ref.read(batchExtractionProvider.notifier).resetJob();
    if (wasProcessing) {
      ErrorHandler.showInfo(
        'Still working. We will let you know when your pieces are ready.',
        title: 'Running in background',
      );
    }
    Navigator.pop(context);
  }

  /// Explicit stop: confirms first, because this really cancels the job.
  Future<void> _confirmStop() async {
    final notifier = ref.read(batchExtractionProvider.notifier);
    if (!ref.read(batchExtractionProvider).isProcessing) {
      _backToPhotos();
      return;
    }
    final stop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop finding pieces?'),
        content: const Text(
          'The scan stops and nothing is saved. Pieces already found stay in your activity until you dismiss them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(context).error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (stop != true || !mounted) return;
    await notifier.cancelExtraction();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final (failed, hasItems, error) = ref.watch(
      batchExtractionProvider.select(
        (s) => (s.isFailed, s.items.isNotEmpty, s.error),
      ),
    );

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _backToPhotos();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add several photos'),
            leading: IconButton(
              tooltip: 'Run in background',
              icon: const Icon(Icons.close_rounded),
              onPressed: _backToPhotos,
            ),
            actions: [
              TextButton(
                onPressed: () => context.push(Routes.wardrobeJobs),
                child: const Text('Scans'),
              ),
            ],
          ),
          body: AppPageBackground(
            child: SafeArea(
              top: false,
              child: failed && !hasItems
                  ? AppErrorState(
                      error: error.isEmpty ? 'Finding pieces failed.' : error,
                      onRetry: _backToPhotos,
                    )
                  : Column(
                      children: [
                        if (failed)
                          AppErrorBanner(
                            message: error.isEmpty
                                ? 'Finding pieces stopped early.'
                                : error,
                          ),
                        const _ProgressHeader(),
                        const Expanded(child: _PhotoList()),
                        _BottomBar(
                          onBack: _backToPhotos,
                          onCancel: _confirmStop,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends ConsumerWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(batchExtractionProvider);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final photos = s.images.length;

    final (step, title, detail) = switch (s.status) {
      BatchJobStatus.uploading => (
        'Step 1 of 2',
        'Uploading photos',
        '${(s.uploadProgress * photos).round()} of $photos photos prepared',
      ),
      BatchJobStatus.extracting || BatchJobStatus.idle => (
        'Step 1 of 2',
        'Finding pieces',
        '${s.extractedCount + s.failedCount} of $photos photos checked'
            '${s.items.isEmpty ? '' : ' · ${s.items.length} pieces so far'}',
      ),
      BatchJobStatus.generating => (
        'Step 2 of 2',
        'Making studio photos',
        '${s.generatedCount} of ${s.totalItems} studio photos ready'
            '${s.totalBatches > 0 && s.currentBatch > 0 ? ' · batch ${s.currentBatch} of ${s.totalBatches}' : ''}',
      ),
      BatchJobStatus.complete => ('Done', 'All done', 'Opening your pieces'),
      BatchJobStatus.failed => (
        'Stopped',
        'Finding pieces stopped',
        '${s.items.length} pieces found before it stopped',
      ),
      BatchJobStatus.cancelled => (
        'Stopped',
        'Cancelled',
        'Nothing was saved.',
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: PaperSurface(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step,
              style: text.bodySmall?.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(title, style: text.headlineSmall),
            const SizedBox(height: AppConstants.spacing16),
            PaperProgressTrack(value: s.progress, semanticLabel: title),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              detail,
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoList extends ConsumerWidget {
  const _PhotoList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(batchExtractionProvider.select((s) => s.images));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing16,
      ),
      itemCount: images.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppConstants.spacing8),
      itemBuilder: (context, i) => ExtractionProgressCard(image: images[i]),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.onBack, required this.onCancel});

  final VoidCallback onBack;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (processing, failed, cancelled, count) = ref.watch(
      batchExtractionProvider.select(
        (s) => (s.isProcessing, s.isFailed, s.isCancelled, s.items.length),
      ),
    );
    final Widget child;
    if (processing) {
      // Pieces stream in before the job finishes: review early while the
      // rest generate, or stop the scan outright.
      child = count > 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.pushReplacement(Routes.wardrobeBatchReview),
                  child: Text(
                    count == 1
                        ? 'Review 1 piece now'
                        : 'Review $count pieces now',
                  ),
                ),
                TextButton(onPressed: onCancel, child: const Text('Stop')),
              ],
            )
          : TextButton(onPressed: onCancel, child: const Text('Stop'));
    } else if (failed) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () =>
                context.pushReplacement(Routes.wardrobeBatchReview),
            child: Text(count == 1 ? 'Review 1 piece' : 'Review $count pieces'),
          ),
          TextButton(onPressed: onBack, child: const Text('Try again')),
        ],
      );
    } else if (cancelled) {
      child = ElevatedButton(
        onPressed: onBack,
        child: const Text('Back to photos'),
      );
    } else {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          AppConstants.spacing4,
          AppConstants.spacing16,
          AppConstants.spacing8,
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
