import 'package:flutter/material.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/dashboard_models.dart';
import '../../wardrobe/repositories/item_repository.dart';

/// An editorial spread built around the user's actual daily outfit.
class TodayEdit extends StatelessWidget {
  const TodayEdit({
    super.key,
    this.outfit,
    this.hasItems = false,
    this.itemPhotos = const [],
    required this.onOpen,
  });

  final DashboardOutfitOfTheDay? outfit;
  final bool hasItems;

  /// Suggested-item cutouts. When non-empty these replace the outfit image:
  /// stacked garments read as "today's pieces" better than one flat photo.
  /// Empty keeps the previous behavior (outfit image, then asset fallback).
  final List<CollagePhoto> itemPhotos;

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final photo = outfit?.imageUrl;
    final hasPhoto = photo != null && photo.isNotEmpty;
    final text = Theme.of(context).textTheme;
    final label = outfit == null
        ? hasItems
              ? 'Create an outfit'
              : 'Add your first pieces'
        : 'Explore this outfit';

    return Material(
      color: AppCoreColors.editorialRose,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = MediaQuery.textScalerOf(context).scale(14) > 16;
                final compact = constraints.maxWidth < 330;
                final image = itemPhotos.isNotEmpty
                    ? OutfitStackCollage(
                        photos: itemPhotos,
                        remintUrl: ItemRepository().remintImageUrl,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        semanticLabel: outfit?.name != null
                            ? 'Suggested pieces for ${outfit!.name}'
                            : 'Suggested pieces for today',
                      )
                    : hasPhoto
                    ? AppImage(
                        imageUrl: photo,
                        storagePath: outfit?.storagePath,
                        remintUrl: ItemRepository().remintImageUrl,
                        fit: BoxFit.contain,
                        enableZoom: false,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        memCacheWidth: 1000,
                        memCacheHeight: 1200,
                      )
                    : Image.asset(
                        'assets/images/wardrobe-editorial.webp',
                        fit: BoxFit.cover,
                        semanticLabel: 'Wardrobe inspiration',
                      );
                final headline = Padding(
                  padding: EdgeInsets.all(
                    stacked ? (compact ? 12 : 16) : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.auto_awesome_outlined,
                        color: AppCoreColors.editorialInk,
                        size: 24,
                      ),
                      // Fixed-height phone row: tighter headline so the
                      // three-line display fits the 220px cap.
                      SizedBox(height: stacked ? (compact ? 12 : 20) : 8),
                      Text(
                        stacked ? 'Your next look.' : 'Your\nnext\nlook.',
                        style: text.displaySmall?.copyWith(
                          color: AppCoreColors.editorialInk,
                          fontSize: stacked ? (compact ? 32 : 38) : 24,
                          height: 1.08,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: stacked ? (compact ? 12 : 20) : 8),
                      Text(
                        hasPhoto
                            ? 'From your wardrobe. For today.'
                            : 'Style inspiration. Make it yours.',
                        style: text.bodySmall?.copyWith(
                          color: AppCoreColors.editorialInk,
                        ),
                      ),
                    ],
                  ),
                );
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      headline,
                      AspectRatio(aspectRatio: 1, child: image),
                    ],
                  );
                }
                return SizedBox(
                  // Fixed compact height on phones so shortcuts reach the
                  // first viewport; large-text stacks keep natural height.
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: headline),
                      Expanded(flex: 6, child: image),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (outfit?.name != null) ...[
                          Text(
                            outfit!.name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              color: AppCoreColors.editorialInk,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          label,
                          style: text.labelLarge?.copyWith(
                            color: AppCoreColors.editorialInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppCoreColors.editorialInk,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
