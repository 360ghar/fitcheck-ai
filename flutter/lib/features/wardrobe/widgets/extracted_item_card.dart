import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/widgets/app_network_image.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/batch_extraction_models.dart';
import 'bounding_box_painter.dart';

/// Card widget displaying an extracted item for review
class ExtractedItemCard extends StatelessWidget {
  const ExtractedItemCard({
    super.key,
    required this.item,
    required this.sourceImagePath,
    this.isSelected = true,
    this.onToggleSelection,
    this.onEdit,
    this.onRemove,
  });

  final BatchExtractedItem item;
  final String sourceImagePath;
  final bool isSelected;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with bounding box
          _buildImageSection(context, tokens),

          // Item details
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and selection
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onToggleSelection != null)
                      Checkbox(
                        value: isSelected,
                        semanticLabel: 'Include ${item.name}',
                        onChanged: (_) => onToggleSelection!(),
                      ),
                  ],
                ),

                if (item.personLabel != null &&
                    item.personLabel!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.isCurrentUserPerson
                          ? '${item.personLabel} (You)'
                          : item.personLabel!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacing4),

                // Category
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.brandColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.category.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tokens.brandColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Colors
                if (item.colors.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.colors.take(4).map((color) {
                      return Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _parseColor(color),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: tokens.cardBorderColor),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Status indicator
                if (item.status == BatchItemStatus.failed) ...[
                  const SizedBox(height: AppConstants.spacing8),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.error ?? 'Generation failed',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Confidence
                if (item.confidence != null) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    '${(item.confidence! * 100).toStringAsFixed(0)}% confidence',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, AppUiTokens tokens) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius12 - 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Generated image or source image with bounding box
            if (item.generatedImageUrl != null)
              AppNetworkImage(
                item.generatedImageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) =>
                    _buildSourceImage(tokens),
              )
            else
              _buildSourceImage(tokens),

            // Remove button
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filled(
                  tooltip: 'Remove ${item.name}',
                  onPressed: onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),

            // Edit button
            if (onEdit != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: IconButton.filled(
                  tooltip: 'Edit ${item.name}',
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.edit),
                ),
              ),

            // Status overlay for generating
            if (item.status == BatchItemStatus.generating)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceImage(AppUiTokens tokens) {
    final boundingBoxes = <Map<String, dynamic>>[];
    if (item.boundingBox != null) {
      boundingBoxes.add({...item.boundingBox!, 'label': item.name});
    }

    // contain + imageFilePath so percent boxes map to the letterboxed image.
    return ColoredBox(
      color: tokens.cardColor,
      child: BoundingBoxOverlay(
        boundingBoxes: boundingBoxes,
        showLabels: false,
        imageFilePath: sourceImagePath,
        child: Image.file(
          File(sourceImagePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: tokens.cardColor,
              child: Icon(
                Icons.image_outlined,
                color: tokens.textMuted,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }

  Color _parseColor(String colorName) {
    final colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'black': Colors.black,
      'white': Colors.white,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'navy': const Color(0xFF000080),
      'beige': const Color(0xFFF5F5DC),
      'cream': const Color(0xFFFFFDD0),
      'khaki': const Color(0xFFC3B091),
      'tan': const Color(0xFFD2B48C),
      'maroon': const Color(0xFF800000),
      'olive': const Color(0xFF808000),
      'teal': Colors.teal,
      'cyan': Colors.cyan,
    };

    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }
}
