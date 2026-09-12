import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';

/// The upload task pairs a labelled example with the user's own photo set.
class PhotoshootUploadStep extends GetView<PhotoshootController> {
  const PhotoshootUploadStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const PageStorageKey('photoshoot-upload'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Obx(() {
        final photos = controller.selectedPhotos;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (photos.isEmpty)
              _buildIntroduction(context)
            else ...[
              Text('Your photo set', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '${photos.length} of ${PhotoshootController.maxPhotos} photos added',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildPhotoPreview(context),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: controller.pickPhotos,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Add from photos'),
              ),
              TextButton.icon(
                onPressed: controller.pickFromCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take a photo'),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('A good starting point', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Use natural light and keep your face visible. A few different angles help.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: controller.nextStep,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Choose your style'),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildIntroduction(BuildContext context) {
    final theme = Theme.of(context);
    final task = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Start with you.', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Add 1–4 photos. Choose a style. Create your next shoot.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: controller.pickPhotos,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add photos'),
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: controller.pickFromCamera,
          icon: const Icon(Icons.camera_alt_outlined, size: 20),
          label: const Text('Use camera'),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        final example = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: stack ? 1.4 : 0.68,
                child: Image.asset(
                  'assets/images/studio-example.webp',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.6),
                  semanticLabel:
                      'Example fashion photo, not a generated result',
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppCoreColors.editorialInk,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Example photo',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [example, const SizedBox(height: 20), task],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: (constraints.maxWidth * 0.44).clamp(140, 260),
              child: example,
            ),
            const SizedBox(width: 20),
            Expanded(child: task),
          ],
        );
      },
    );
  }

  Widget _buildPhotoPreview(BuildContext context) {
    final photos = controller.selectedPhotos;
    final canAddMore = photos.length < PhotoshootController.maxPhotos;
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length + (canAddMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == photos.length) {
            return SizedBox(
              width: 132,
              child: OutlinedButton(
                onPressed: controller.pickPhotos,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.add), SizedBox(height: 8), Text('Add')],
                ),
              ),
            );
          }
          return _buildThumbnail(photos[index], index);
        },
      ),
    );
  }

  Widget _buildThumbnail(File photo, int index) {
    return SizedBox(
      width: 132,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              photo,
              fit: BoxFit.cover,
              cacheWidth: 400,
              semanticLabel: 'Your photo ${index + 1}',
              errorBuilder: (_, _, _) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove photo ${index + 1}',
              onPressed: () => controller.removePhoto(index),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppCoreColors.editorialInk,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
