import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/providers/wardrobe_providers.dart';
import '../../wardrobe/widgets/garment_glyph.dart';
import '../providers/recommendations_providers.dart';

/// Outer padding of every tab.
const tabPadding = EdgeInsets.fromLTRB(
  AppConstants.spacing16,
  AppConstants.spacing16,
  AppConstants.spacing16,
  AppConstants.spacing32,
);

/// Two columns of piece cards.
const pieceGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,
  mainAxisSpacing: AppConstants.spacing12 + 3,
  crossAxisSpacing: AppConstants.spacing12,
  childAspectRatio: 0.78,
);

/// Opens the closet picker for Find matches and Complete a look.
Future<void> showPiecePicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.88,
        child: _PiecePickerSheet(),
      ),
    );

class _PiecePickerSheet extends ConsumerWidget {
  const _PiecePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(recommendationPickerItemsProvider);
    final selection = ref.watch(recommendationSelectionProvider);
    final notifier = ref.read(recommendationSelectionProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final full = selection.length >= RecommendationSelection.maxPieces;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing20,
            AppConstants.spacing16,
            AppConstants.spacing8,
            AppConstants.spacing8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pick up to three pieces', style: text.headlineSmall),
                    Text(
                      '${selection.length} of ${RecommendationSelection.maxPieces} picked',
                      style: text.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (items) {
            AsyncValue(:final value?) when value.isEmpty => AppEmptyState(
              scene: PaperScenes.closet,
              title: 'Your closet is empty',
              message: 'Add a few pieces first, then come back for matches.',
            ),
            AsyncValue(:final value?) => GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing16,
                AppConstants.spacing8,
                AppConstants.spacing16,
                AppConstants.spacing24,
              ),
              // Cropped item cutouts: 4 columns on a phone. The taller
              // ratio keeps a near-square image above the two text lines.
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 104,
                mainAxisSpacing: AppConstants.spacing8,
                crossAxisSpacing: AppConstants.spacing8,
                childAspectRatio: 0.62,
              ),
              itemCount: value.length,
              itemBuilder: (context, i) {
                final item = value[i];
                final selected = selection.any((s) => s.id == item.id);
                return PieceCard.item(
                  item,
                  selected: selected,
                  onTap: selected || !full ? () => notifier.toggle(item) : null,
                );
              },
            ),
            AsyncValue(:final error?) => AppErrorState(
              error: error,
              onRetry: () => ref.invalidate(recommendationPickerItemsProvider),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(AppConstants.spacing16),
              child: SkeletonGridLoaderBox(
                crossAxisCount: 3,
                itemCount: 9,
                childAspectRatio: 0.78,
              ),
            ),
          },
        ),
      ],
    );
  }
}

/// The chosen pieces as small cards, with a way to change them.
class SelectionBar extends ConsumerWidget {
  const SelectionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(recommendationSelectionProvider);
    final notifier = ref.read(recommendationSelectionProvider.notifier);
    Widget thumb(ItemModel item) => Tooltip(
      message: 'Remove ${item.name}',
      child: SizedBox(
        width: 56,
        child: PaperSurface(
          padding: EdgeInsets.zero,
          grain: false,
          lift: 0.6,
          clipBehavior: Clip.antiAlias,
          semanticLabel: 'Remove ${item.name}',
          onTap: () => notifier.toggle(item),
          child: _PieceImage(
            url: item.primaryImage?.url,
            storagePath: item.primaryImage?.storagePath,
            category: item.category,
            label: item.name,
            glyphSize: 28,
          ),
        ),
      ),
    );
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 64,
            // One piece also shows its name, so it is clear what is matched.
            child: selection.length == 1
                ? Row(
                    children: [
                      thumb(selection.first),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: Text(
                          selection.first.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: selection.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppConstants.spacing12),
                    itemBuilder: (context, i) => thumb(selection[i]),
                  ),
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
        TextButton.icon(
          onPressed: () => showPiecePicker(context),
          icon: const Icon(Icons.swap_horiz_rounded, size: 20),
          label: const Text('Change'),
        ),
      ],
    );
  }
}

/// A piece as a paper card: photo (or garment glyph) over a name and caption.
class PieceCard extends StatelessWidget {
  const PieceCard({
    super.key,
    required this.title,
    this.caption,
    this.accentCaption = false,
    this.imageUrl,
    this.storagePath,
    this.category,
    this.selected = false,
    this.onTap,
  });

  PieceCard.item(
    ItemModel item, {
    Key? key,
    bool selected = false,
    VoidCallback? onTap,
  }) : this(
         key: key,
         title: item.name,
         caption: item.category.displayName,
         imageUrl: item.primaryImage?.url,
         storagePath: item.primaryImage?.storagePath,
         category: item.category,
         selected: selected,
         onTap: onTap,
       );

  final String title;
  final String? caption;

  /// Sets the caption in the stock accent (for a match score).
  final bool accentCaption;
  final String? imageUrl;
  final String? storagePath;
  final Category? category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      child: PaperSurface(
        padding: EdgeInsets.zero,
        grain: false,
        clipBehavior: Clip.antiAlias,
        color: selected ? tokens.stock.tint : null,
        onTap: onTap,
        semanticLabel: [title, ?caption].join(', '),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PieceImage(
                    url: imageUrl,
                    storagePath: storagePath,
                    category: category,
                    label: title,
                  ),
                  if (selected)
                    Positioned(
                      top: AppConstants.spacing8,
                      right: AppConstants.spacing8,
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 22,
                        color: tokens.stock.accent,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing12,
                AppConstants.spacing8,
                AppConstants.spacing8,
                AppConstants.spacing8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  if (caption != null)
                    Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: accentCaption
                          ? text.labelLarge?.copyWith(
                              color: tokens.stock.accent,
                            )
                          : text.bodySmall?.copyWith(
                              color: tokens.textSecondary,
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

class _PieceImage extends ConsumerWidget {
  const _PieceImage({
    required this.url,
    required this.storagePath,
    required this.category,
    required this.label,
    this.glyphSize = 44,
  });

  final String? url;
  final String? storagePath;
  final Category? category;
  final String label;
  final double glyphSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sunk = PaperTokens.of(context).stock.sunk;
    final glyph = Center(
      child: GarmentGlyph(
        category: category ?? Category.other,
        size: glyphSize,
      ),
    );
    return ColoredBox(
      color: sunk,
      child: url == null || url!.isEmpty
          ? glyph
          : AppImage(
              imageUrl: url,
              fit: BoxFit.contain,
              enableZoom: false,
              memCacheWidth: 400,
              backgroundColor: sunk,
              storagePath: storagePath,
              remintUrl: ref.read(itemRepositoryProvider).remintImageUrl,
              errorWidget: glyph,
              semanticLabel: label,
            ),
    );
  }
}
