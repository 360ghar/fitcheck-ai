import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../controllers/outfit_builder_controller.dart';

/// Card displaying an item on the outfit canvas
/// Supports visibility toggle, remove, and layer management
class OutfitCanvasItemCard extends StatelessWidget {
  final OutfitBuilderItem outfitItem;
  final bool isVisible;
  final int layer;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onToggleVisibility;
  final Function(bool) onMoveLayer;

  const OutfitCanvasItemCard({
    super.key,
    required this.outfitItem,
    required this.isVisible,
    required this.layer,
    required this.onTap,
    required this.onRemove,
    required this.onToggleVisibility,
    required this.onMoveLayer,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: tokens.cardColor.withOpacity(isVisible ? 1 : 0.6),
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(
            color: tokens.brandColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius12),
              child: SizedBox(
                width: 96,
                height: 96,
                child: outfitItem.item.itemImages != null &&
                        outfitItem.item.itemImages!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: outfitItem.item.itemImages!.first.url,
                        fit: BoxFit.cover,
                        color: isVisible ? null : Colors.black54,
                        colorBlendMode: isVisible ? null : BlendMode.srcOver,
                      )
                    : Container(
                        color: tokens.cardColor.withOpacity(0.5),
                        child: Icon(
                          _getCategoryIcon(outfitItem.item.category),
                          color: tokens.textMuted,
                        ),
                      ),
              ),
            ),

            // Layer indicator
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                ),
                child: Text(
                  'L$layer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Controls
            Positioned(
              top: 4,
              right: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Remove button
                  Material(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(AppConstants.radius8),
                    child: InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Visibility toggle
                  Material(
                    color: isVisible ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(AppConstants.radius8),
                    child: InkWell(
                      onTap: onToggleVisibility,
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Layer controls
                  Material(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(AppConstants.radius8),
                    child: InkWell(
                      onTap: () => onMoveLayer(false),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                      child: const SizedBox(
                        width: 24,
                        height: 20,
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Material(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(AppConstants.radius8),
                    child: InkWell(
                      onTap: () => onMoveLayer(true),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                      child: const SizedBox(
                        width: 24,
                        height: 20,
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
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

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.tops:
        return Icons.checkroom;
      case Category.bottoms:
        return Icons.work;
      case Category.shoes:
        return Icons.hiking;
      case Category.accessories:
        return Icons.shopping_bag;
      case Category.outerwear:
        return Icons.dry_cleaning;
      case Category.swimwear:
        return Icons.water_drop;
      case Category.activewear:
        return Icons.directions_run;
      case Category.other:
        return Icons.help;
    }
  }
}
