import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../models/item_model.dart';

/// Widget showing potential duplicate items
class DuplicateDetectionWidget extends StatelessWidget {
  final List<ItemModel> duplicates;
  final String newItemName;
  final VoidCallback onConfirmDuplicate;
  final VoidCallback onNotDuplicate;

  const DuplicateDetectionWidget({
    super.key,
    required this.duplicates,
    required this.newItemName,
    required this.onConfirmDuplicate,
    required this.onNotDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning header
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 32),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential Duplicate Found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      'We found ${duplicates.length} similar item(s) in your wardrobe',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // New item being added
        AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: tokens.brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  color: tokens.brandColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Item',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                    Text(
                      newItemName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing12),

        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: tokens.textMuted.withOpacity(0.3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing8),
              child: Text(
                'Similar items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ),
            Expanded(
              child: Divider(color: tokens.textMuted.withOpacity(0.3)),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacing12),

        // Duplicate items list
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.3,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: duplicates.length,
            itemBuilder: (context, index) {
              final item = duplicates[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
                child: _DuplicateItemCard(item: item),
              );
            },
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Action buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: onNotDuplicate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: tokens.brandColor,
              ),
              child: const Text('This is a Different Item'),
            ),

            const SizedBox(height: AppConstants.spacing8),

            OutlinedButton(
              onPressed: onConfirmDuplicate,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                'Yes, This is a Duplicate',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card showing a duplicate item
class _DuplicateItemCard extends StatelessWidget {
  final ItemModel item;

  const _DuplicateItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Row(
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.itemImages != null && item.itemImages!.isNotEmpty
                  ? AppImage(
                      imageUrl: item.itemImages!.first.url,
                      fit: BoxFit.contain,
                      enableZoom: false,
                      errorIcon: _getCategoryIcon(item.category),
                    )
                  : Container(
                      color: tokens.cardColor.withOpacity(0.5),
                      child: Icon(
                        _getCategoryIcon(item.category),
                        color: tokens.textMuted,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: AppConstants.spacing12),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                        vertical: AppConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.brandColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radius8),
                      ),
                      child: Text(
                        item.category.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.brandColor,
                              fontSize: 10,
                            ),
                      ),
                    ),
                    if (item.brand != null) ...[
                      const SizedBox(width: AppConstants.spacing8),
                      Text(
                        item.brand!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                    ],
                  ],
                ),
                if (item.colors != null && item.colors!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    item.colors!.join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
