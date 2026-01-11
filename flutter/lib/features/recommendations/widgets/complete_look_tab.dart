import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../../wardrobe/models/item_model.dart';
import '../controllers/recommendations_controller.dart';
import '../views/recommendations_page.dart';

/// Complete Look Tab - Generate complete outfit suggestions
class CompleteLookTab extends StatelessWidget {
  const CompleteLookTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final RecommendationsController controller = Get.find<RecommendationsController>();

    return Column(
      children: [
        // Selected items
        SelectedItemsChips(
          selectedItems: controller.selectedItems,
          onRemove: (item) => controller.toggleItemSelection(item),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Options
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<Style>(
                      value: controller.completeLookStyle.value,
                      decoration: InputDecoration(
                        labelText: 'Style',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radius12),
                        ),
                      ),
                      items: Style.values.map((style) {
                        return DropdownMenuItem(
                          value: style,
                          child: Text(style.displayName),
                        );
                      }).toList(),
                      onChanged: controller.selectedItems.isEmpty
                          ? null
                          : (value) {
                              controller.completeLookStyle.value = value;
                            },
                    )),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.selectedItems.isEmpty ||
                              controller.isLoadingCompleteLooks.value
                          ? null
                          : () => controller.fetchCompleteLooks(),
                      icon: controller.isLoadingCompleteLooks.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        controller.isLoadingCompleteLooks.value ? 'Generating...' : 'Generate',
                      ),
                    )),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing24),

        // Results or empty state
        Expanded(
          child: Obx(() {
            if (controller.selectedItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checkroom,
                      size: 64,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      'Select items to complete the look',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'We\'ll suggest items to complete your outfit',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              );
            }

            if (controller.completeLookError.value.isNotEmpty) {
              return Center(
                child: AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      Text(
                        controller.completeLookError.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      TextButton(
                        onPressed: controller.fetchCompleteLooks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final looks = controller.completeLooks;

            if (looks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      'No suggestions available',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              itemCount: looks.length,
              itemBuilder: (context, index) {
                final look = looks[index];
                final items = look['items'] as List<ItemModel>? ?? [];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                  child: _buildLookCard(context, items, look, tokens),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLookCard(
    BuildContext context,
    List<ItemModel> items,
    Map<String, dynamic> look,
    AppUiTokens tokens,
  ) {
    final description = look['description']?.toString();
    final matchScore = look['match_score'];
    final scoreLabel = matchScore is num ? '${matchScore.toInt()}% match' : null;

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null || scoreLabel != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    description ?? 'Complete look suggestion',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (scoreLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing8,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.brandColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                    ),
                    child: Text(
                      scoreLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.brandColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: AppConstants.spacing12),
          if (items.isEmpty)
            Text(
              'No items returned for this look',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            )
          else
            Wrap(
              spacing: AppConstants.spacing12,
              runSpacing: AppConstants.spacing12,
              children: items.map((item) {
                return _buildItemMiniCard(context, item, tokens);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildItemMiniCard(
    BuildContext context,
    ItemModel item,
    AppUiTokens tokens,
  ) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: item.itemImages != null && item.itemImages!.isNotEmpty
                ? Image.network(
                    item.itemImages!.first.url,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 120,
                    height: 120,
                    color: tokens.cardColor.withOpacity(0.5),
                    child: Icon(
                      _getCategoryIcon(item.category),
                      color: tokens.textMuted,
                    ),
                  ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            item.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.category.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
