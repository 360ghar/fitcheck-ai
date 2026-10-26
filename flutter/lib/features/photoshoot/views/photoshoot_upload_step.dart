import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
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
            semanticLabel: context.l10n.photoshootAddPhotosSemantic,
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
                  context.l10n.photoshootUploadTitle,
                  style: text.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  context.l10n.photoshootUploadBody,
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
                label: Text(context.l10n.photoshootGallery),
              ),
            TextButton.icon(
              onPressed: full ? null : notifier.pickFromCamera,
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: Text(context.l10n.photoshootUseCamera),
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
                ? context.l10n.photoshootAddToContinue
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
          context.l10n.photoshootSelectedOfMax(
        photos.length,
        PhotoshootNotifier.maxPhotos,
      ),
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
                        tooltip: context.l10n.photoshootRemovePhotoNumber(i + 1),
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
                semanticLabel: context.l10n.photoshootAddAnotherPhoto,
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
                  context.l10n.photoshootTipsTitle,
                  style: text.titleSmall?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  context.l10n.photoshootTipsBody,
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
