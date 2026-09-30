import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/widgets/garment_glyph.dart';
import '../providers/outfit_providers.dart';

/// Up to four piece photos for an outfit with no image of its own.
class OutfitCollage extends StatelessWidget {
  const OutfitCollage({
    super.key,
    required this.pieces,
    this.glyphSize = 96,
    this.memCacheWidth = 360,
    this.spacing = AppConstants.spacing8,
  });

  final List<ItemModel> pieces;

  /// Size of the category glyph shown for a piece without a photo.
  final double glyphSize;
  final int memCacheWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final shown = pieces.take(4).toList();
    if (shown.isEmpty) {
      return Center(
        child: Icon(
          Icons.style_outlined,
          size: glyphSize.clamp(40, 64).toDouble(),
          color: PaperTokens.of(context).textMuted,
        ),
      );
    }
    Widget tile(ItemModel p) => Expanded(
      child: OutfitPieceImage(
        item: p,
        glyphSize: glyphSize,
        memCacheWidth: memCacheWidth,
      ),
    );
    // Rows share the box height, so a short card never clips the last row.
    // Two pieces stand side by side at full height.
    final rows = shown.length <= 2
        ? [shown]
        : [shown.take(2).toList(), shown.skip(2).toList()];
    return Padding(
      padding: EdgeInsets.all(spacing),
      child: Column(
        spacing: spacing,
        children: [
          for (final row in rows)
            Expanded(
              child: Row(
                spacing: spacing,
                children: [
                  for (final p in row) tile(p),
                  if (rows.length > 1 && row.length == 1)
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One piece's primary photo, or its category glyph when it has none.
class OutfitPieceImage extends ConsumerWidget {
  const OutfitPieceImage({
    super.key,
    required this.item,
    this.glyphSize = 96,
    this.memCacheWidth = 360,
  });

  final ItemModel item;
  final double glyphSize;
  final int memCacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = item.primaryImage;
    final tokens = PaperTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radius8),
      child: ColoredBox(
        color: image == null ? tokens.stock.tint : tokens.stock.card,
        child: image == null
            ? Center(
                child: GarmentGlyph(category: item.category, size: glyphSize),
              )
            : AppImage(
                imageUrl: image.url,
                fit: BoxFit.contain,
                enableZoom: false,
                memCacheWidth: memCacheWidth,
                storagePath: image.storagePath,
                remintUrl: ref.read(outfitRepositoryProvider).remintImageUrl,
                semanticLabel: item.name,
              ),
      ),
    );
  }
}
