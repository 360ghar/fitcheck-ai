import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/review/review_milestones.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/report_content_sheet.dart';
import '../models/photoshoot_models.dart';
import '../providers/photoshoot_provider.dart';
import 'photoshoot_image.dart';

/// Step 4: the gallery, with a retry on each failed slot.
class PhotoshootResultsStep extends ConsumerWidget {
  const PhotoshootResultsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(photoshootProvider);
    final notifier = ref.read(photoshootProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final failed = [...s.failedIndices]..sort();

    if (s.images.isEmpty && failed.isEmpty) {
      return AppEmptyState(
        scene: PaperScenes.studio,
        title: context.l10n.photoshootNoPhotosTitle,
        message: context.l10n.photoshootNoPhotosBody,
        actionLabel: context.l10n.tryOnTryAgain,
        onAction: () => notifier.reset(keepPhotos: true),
      );
    }

    final count = s.images.length;
    // Slots in their original order, failed ones in place.
    final slots = <int>{
      for (final img in s.images) img.index,
      ...failed,
    }.toList()..sort();
    final byIndex = {for (final img in s.images) img.index: img};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The first finished photoshoot is the best moment this app has.
        // Nothing here decides whether to ask; ReviewPrompt owns every rule
        // (first session, cooldown, once per milestone) and this call is
        // idempotent, so a rebuild cannot produce a second sheet.
        _ReviewMoment(
          imageCount: count,
          partialSuccess: s.partialSuccess,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppConstants.spacing12 + 3,
            crossAxisSpacing: AppConstants.spacing12,
            childAspectRatio: 3 / 4,
          ),
          itemCount: slots.length,
          itemBuilder: (context, i) {
            final image = byIndex[slots[i]];
            return image == null
                ? _FailedCard(index: slots[i])
                : _ImageCard(index: s.images.indexOf(image), image: image);
          },
        ),
        const SizedBox(height: AppConstants.spacing24),
        ElevatedButton.icon(
          onPressed: count == 0 || s.isDownloading
              ? null
              : notifier.downloadAll,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          icon: s.downloadingAll
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 20),
          label: Text(
            s.downloadingAll
                ? 'Saving ${(s.downloadingIndex ?? 0) + 1} of $count'
                : 'Save all $count to gallery',
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => notifier.reset(keepPhotos: true),
              child: Text(context.l10n.photoshootNewStyle),
            ),
            const SizedBox(width: AppConstants.spacing8),
            TextButton(
              onPressed: notifier.reset,
              child: Text(context.l10n.photoshootNewPhotos),
            ),
          ],
        ),
        if (s.usage != null) ...[
          const SizedBox(height: AppConstants.spacing4),
          Text(
            context.l10n.photoshootImagesLeftToday(s.usage!.remaining),
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// White glyph with a solid offset edge, readable over any photo.
const _onPhoto = [Shadow(color: Colors.black87, offset: Offset(0.5, 1))];

class _ImageCard extends ConsumerWidget {
  const _ImageCard({required this.index, required this.image});

  final int index;
  final GeneratedImage image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(
      photoshootProvider.select((s) => s.downloadingIndex == index),
    );
    final busy = ref.watch(photoshootProvider.select((s) => s.isDownloading));
    final notifier = ref.read(photoshootProvider.notifier);
    return PaperSurface(
      padding: EdgeInsets.zero,
      grain: false,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            button: true,
            label: context.l10n.photoshootOpenPhoto(index + 1),
            child: GestureDetector(
              onTap: () => _showFullScreen(context, ref),
              child: PhotoshootImage(image: image),
            ),
          ),
          // Apple Guideline 1.2: generated images must be reportable.
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: context.l10n.photoshootReportPhoto,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => showReportContentSheet(
                contentType: ReportContentType.photoshootImage,
                contentId: image.id,
              ),
              icon: const Icon(
                Icons.flag_outlined,
                size: 20,
                color: Colors.white,
                shadows: _onPhoto,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              tooltip: context.l10n.photoshootSaveToGallery,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: busy ? null : () => notifier.downloadImage(index),
              icon: saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.download_rounded,
                      size: 22,
                      color: Colors.white,
                      shadows: _onPhoto,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(AppConstants.spacing16),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(dialogContext).height * 0.75,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: PhotoshootImage(image: image, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: context.l10n.actionClose,
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    shadows: _onPhoto,
                  ),
                ),
              ),
              Positioned(
                left: AppConstants.spacing16,
                right: AppConstants.spacing16,
                bottom: AppConstants.spacing16,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(photoshootProvider.notifier).downloadImage(index);
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: Text(context.l10n.photoshootSaveToGallery),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reports a finished photoshoot to the review prompt once, after the frame
/// that shows the results is on screen.
///
/// A widget rather than a call in `build` because the ask must land after the
/// images are painted: `InAppReview.requestReview()` is a system sheet, and
/// presenting it while the gallery is still laying out shows it over a
/// half-drawn screen.
class _ReviewMoment extends ConsumerStatefulWidget {
  const _ReviewMoment({required this.imageCount, required this.partialSuccess});

  final int imageCount;
  final bool partialSuccess;

  @override
  ConsumerState<_ReviewMoment> createState() => _ReviewMomentState();
}

class _ReviewMomentState extends ConsumerState<_ReviewMoment> {
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    if (widget.imageCount == 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _reported) return;
      _reported = true;
      // Partial success is not an error, but the user is looking at missing
      // slots, so it is not the delight moment either.
      unawaited(
        ref
            .read(reviewMilestonesProvider)
            .photoshootFinished(
              imageCount: widget.imageCount,
              partialSuccess: widget.partialSuccess,
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _FailedCard extends ConsumerWidget {
  const _FailedCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final retrying = ref.watch(
      photoshootProvider.select((s) => s.retryingIndex),
    );
    final isThis = retrying == index;
    return PaperSurface(
      lift: 0,
      color: tokens.stock.sunk,
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 28, color: tokens.textMuted),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            context.l10n.photoshootPhotoNumberFailed(index + 1),
            textAlign: TextAlign.center,
            style: text.titleSmall?.copyWith(color: tokens.textPrimary),
          ),
          const SizedBox(height: AppConstants.spacing8),
          TextButton(
            onPressed: retrying == null
                ? () => ref
                      .read(photoshootProvider.notifier)
                      .retryFailedSlot(index)
                : null,
            child: isThis
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.actionRetry),
          ),
        ],
      ),
    );
  }
}
