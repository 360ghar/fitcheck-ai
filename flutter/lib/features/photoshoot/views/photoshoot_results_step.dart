import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
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
        title: 'No photos came back',
        message: 'The shoot finished without images. Try again.',
        actionLabel: 'Try again',
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
              child: const Text('New style'),
            ),
            const SizedBox(width: AppConstants.spacing8),
            TextButton(
              onPressed: notifier.reset,
              child: const Text('New photos'),
            ),
          ],
        ),
        if (s.usage != null) ...[
          const SizedBox(height: AppConstants.spacing4),
          Text(
            '${s.usage!.remaining} left today',
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
            label: 'Open photo ${index + 1}',
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
              tooltip: 'Report photo',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => showReportContentSheet(
                contentType: 'AI photoshoot image',
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
              tooltip: 'Save to gallery',
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
                  tooltip: 'Close',
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
                  label: const Text('Save to gallery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            'Photo ${index + 1} failed',
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
                : const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
