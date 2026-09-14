import 'package:flutter/material.dart';

import 'app_image.dart';

/// One photo inside an [OutfitStackCollage].
///
/// A core-level pair (not `ItemImage`) so `core/` never imports feature
/// models — callers map their own image types onto this.
class CollagePhoto {
  const CollagePhoto({required this.url, this.storagePath});

  final String url;
  final String? storagePath;
}

/// Up-to-4 garment cutouts in a 2-up grid, used wherever an outfit is shown
/// without a generated photo: the Home feature slot and saved combinations
/// without their own image.
///
/// Tiles use `BoxFit.contain` (garment cutouts rely on it — never `cover`),
/// presigned-safe loading (`storagePath` + `remintUrl` retry once), and a
/// reduced memory cache suited to small tiles.
class OutfitStackCollage extends StatelessWidget {
  const OutfitStackCollage({
    super.key,
    required this.photos,
    required this.remintUrl,
    this.backgroundColor,
    this.semanticLabel,
  });

  /// Candidate photos; only the first four render.
  final List<CollagePhoto> photos;

  /// Fresh-URL minter for expired presigned URLs (see `AppImage.remintUrl`).
  final Future<String?> Function(String storagePath)? remintUrl;

  final Color? backgroundColor;

  /// Screen-reader label for the composition (individual tiles are excluded
  /// to avoid spamming navigation).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final visible = photos.take(4).toList();
    if (visible.isEmpty) {
      return Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    final columns = visible.length > 2 ? 2 : 1;
    final rows = (visible.length / columns).ceil();
    final grid = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (var row = 0; row < rows; row++)
            Expanded(
              child: Row(
                children: [
                  for (var column = 0; column < columns; column++)
                    Expanded(
                      child: row * columns + column >= visible.length
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.all(4),
                              child: AppImage(
                                imageUrl: visible[row * columns + column].url,
                                storagePath:
                                    visible[row * columns + column].storagePath,
                                remintUrl: remintUrl,
                                fit: BoxFit.contain,
                                enableZoom: false,
                                backgroundColor: backgroundColor ??
                                    Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                memCacheWidth: 350,
                              ),
                            ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
    if (semanticLabel == null) return grid;
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(child: grid),
    );
  }
}
