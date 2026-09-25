import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/photoshoot_provider.dart';

/// Step 1: up to four photos of the user.
class PhotoshootUploadStep extends ConsumerWidget {
  const PhotoshootUploadStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoshootProvider.select((s) => s.photos));
    final notifier = ref.read(photoshootProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final full = photos.length >= PhotoshootNotifier.maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (photos.isEmpty)
          PaperSurface(
            onTap: notifier.pickPhotos,
            semanticLabel: 'Add photos from your gallery',
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing24,
              vertical: AppConstants.spacing32,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: tokens.stock.accent,
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  'Add 1 to 4 photos of yourself',
                  style: text.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Tap to choose from your gallery',
                  style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          _Thumbnails(photos: photos, canAdd: !full),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (photos.isNotEmpty)
              TextButton.icon(
                onPressed: full ? null : notifier.pickPhotos,
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                label: const Text('Gallery'),
              ),
            TextButton.icon(
              onPressed: full ? null : notifier.pickFromCamera,
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: const Text('Use camera'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing16),
        const _Tips(),
        const SizedBox(height: AppConstants.spacing24),
        ElevatedButton(
          onPressed: photos.isEmpty ? null : notifier.goToConfigure,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(
            photos.isEmpty
                ? 'Add a photo to continue'
                : 'Continue with ${photos.length} '
                      '${photos.length == 1 ? 'photo' : 'photos'}',
          ),
        ),
      ],
    );
  }
}

class _Thumbnails extends ConsumerWidget {
  const _Thumbnails({required this.photos, required this.canAdd});

  final List<File> photos;
  final bool canAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(photoshootProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${photos.length} of ${PhotoshootNotifier.maxPhotos} photos',
          style: text.bodySmall?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppConstants.spacing8),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppConstants.spacing12,
          crossAxisSpacing: AppConstants.spacing12,
          children: [
            for (final (i, photo) in photos.indexed)
              PaperSurface(
                padding: EdgeInsets.zero,
                grain: false,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(photo, fit: BoxFit.cover, cacheWidth: 240),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        tooltip: 'Remove photo ${i + 1}',
                        onPressed: () => notifier.removePhoto(i),
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              offset: Offset(0.5, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (canAdd)
              PaperSurface(
                onTap: notifier.pickPhotos,
                semanticLabel: 'Add another photo',
                padding: EdgeInsets.zero,
                color: tokens.stock.sunk,
                lift: 0,
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 28,
                    color: tokens.stock.accent,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return PaperSurface(
      lift: 0,
      color: tokens.stock.tint,
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 20,
            color: tokens.stock.accent,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For the best results',
                  style: text.titleSmall?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Use clear, well-lit photos of your face from a few angles. '
                  'Skip sunglasses and hats.',
                  style: text.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
