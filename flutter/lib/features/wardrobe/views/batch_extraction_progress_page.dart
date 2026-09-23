import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';
import '../providers/batch_extraction_provider.dart';
import '../widgets/extraction_progress_card.dart';

/// Batch progress: finding pieces in each photo, then studio photos. Opens
/// the review once the job completes.
class BatchExtractionProgressPage extends ConsumerStatefulWidget {
  const BatchExtractionProgressPage({super.key});

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
  }

  /// Back to the selection with the photos kept.
  void _backToPhotos() {
    ref.read(batchExtractionProvider.notifier).resetJob();
    Navigator.pop(context);
  }

  Future<void> _confirmLeave() async {
    final notifier = ref.read(batchExtractionProvider.notifier);
    if (!ref.read(batchExtractionProvider).isProcessing) {
      _backToPhotos();
      return;
    }
    final stop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop finding pieces?'),
        content: const Text('Progress on these photos is lost.'),
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
          if (!didPop) _confirmLeave();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add several photos'),
            leading: IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close_rounded),
              onPressed: _confirmLeave,
            ),
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
                          onCancel: _confirmLeave,
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
      child = TextButton(onPressed: onCancel, child: const Text('Cancel'));
    } else if (failed) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => context.pushReplacement(Routes.wardrobeBatchReview),
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
