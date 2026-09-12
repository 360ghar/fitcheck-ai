import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/report_content_sheet.dart';
import '../controllers/photoshoot_controller.dart';
import '../models/photoshoot_models.dart';

/// Results remain scrollable with long captions, failed slots and large text.
class PhotoshootResultsStep extends GetView<PhotoshootController> {
  const PhotoshootResultsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final images = controller.generatedImages.toList();
      final failed = controller.failedIndices.toList()..sort();
      final downloading = controller.isDownloading.value;
      final usage = controller.usage.value;
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: images.isNotEmpty && !downloading
                        ? controller.downloadAll
                        : null,
                    icon: downloading
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(
                      downloading
                          ? 'Downloading ${controller.downloadingIndex.value + 1}/${images.length}'
                          : 'Download All (${images.length})',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: downloading
                            ? null
                            : () => controller.reset(keepPhotos: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('New style'),
                      ),
                      OutlinedButton.icon(
                        onPressed: downloading ? null : controller.reset,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('New photos'),
                      ),
                    ],
                  ),
                  if (controller.partialSuccess.value && failed.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '${failed.length} photos could not be generated. Retry them below.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: scheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverProductGrid(
              itemCount: images.length + failed.length,
              itemBuilder: (context, index) => index < images.length
                  ? _imageCard(context, images[index], index, images)
                  : _failedCard(context, failed[index - images.length]),
            ),
          ),
          if (usage != null)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${images.length} images generated · ${usage.remaining} remaining today',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      );
    });
  }

  Widget _imageCard(
    BuildContext context,
    GeneratedImage image,
    int index,
    List<GeneratedImage> images,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return AppGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: .8,
            child: AppImage(
              imageUrl: _imageUrl(image),
              galleryUrls: images.map(_imageUrl).toList(),
              initialGalleryIndex: index,
              semanticLabel: image.label ?? 'Photoshoot photo ${index + 1}',
              fit: BoxFit.contain,
              backgroundColor: scheme.surfaceContainerHighest,
              memCacheWidth: 600,
              memCacheHeight: 750,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Text(
              image.label ?? 'Photo ${index + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Report photo ${index + 1}',
                  onPressed: () => showReportContentSheet(
                    contentType: 'AI photoshoot image',
                    contentId: image.id,
                  ),
                  icon: const Icon(Icons.flag_outlined),
                ),
                Obx(
                  () => IconButton(
                    tooltip: 'Download photo ${index + 1}',
                    onPressed: controller.isDownloading.value
                        ? null
                        : () => controller.downloadImage(index),
                    icon:
                        controller.isDownloading.value &&
                            controller.downloadingIndex.value == index
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _failedCard(BuildContext context, int index) {
    final scheme = Theme.of(context).colorScheme;
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.error_outline, color: scheme.error, size: 32),
          const SizedBox(height: 12),
          Text(
            'Photo ${index + 1} failed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Try again to complete your photoshoot.'),
          const SizedBox(height: 16),
          Obx(() {
            final retrying = controller.retryingFailedIndex.value;
            return OutlinedButton.icon(
              onPressed: retrying == -1
                  ? () => controller.retryFailedSlot(index)
                  : null,
              icon: retrying == index
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(retrying == index ? 'Retrying…' : 'Retry'),
            );
          }),
        ],
      ),
    );
  }

  String _imageUrl(GeneratedImage image) {
    final bytes = image.imageBase64;
    return bytes != null && bytes.isNotEmpty
        ? 'data:image/png;base64,$bytes'
        : image.imageUrl ?? '';
  }
}
