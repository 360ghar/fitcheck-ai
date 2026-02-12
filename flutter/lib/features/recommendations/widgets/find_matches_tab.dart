import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../controllers/recommendations_controller.dart';
import '../views/recommendations_page.dart';

/// Find Matches Tab - Find items that match selected items
class FindMatchesTab extends StatelessWidget {
  const FindMatchesTab({super.key});

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

        // Available items to select
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          child: Obx(() {
            if (controller.isLoadingItems.value) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(width: AppConstants.spacing12),
                itemBuilder: (context, index) => const ShimmerBox(
                  width: 80,
                  height: 80,
                  borderRadius: AppConstants.radius8,
                ),
              );
            }

            if (controller.itemsError.value.isNotEmpty) {
              return Center(
                child: Text(
                  controller.itemsError.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              );
            }

            if (controller.availableItems.isEmpty) {
              return Center(
                child: Text(
                  'Add wardrobe items to get matching suggestions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.availableItems.length,
              itemBuilder: (context, index) {
                final item = controller.availableItems[index];
                final isSelected = controller.selectedItems.any((i) => i.id == item.id);

                return GestureDetector(
                  onTap: () => controller.toggleItemSelection(item),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: AppConstants.spacing12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                      child: item.itemImages != null && item.itemImages!.isNotEmpty
                          ? AppImage(
                              imageUrl: item.itemImages!.first.url,
                              fit: BoxFit.contain,
                              enableZoom: false,
                              errorIcon: _getCategoryIcon(item.category),
                            )
                          : Icon(
                              _getCategoryIcon(item.category),
                              color: tokens.textMuted,
                            ),
                    ),
                  ),
                );
              },
            );
          }),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Search and filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => controller.matchesSearchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search matches...',
                    filled: true,
                    fillColor: tokens.cardColor.withValues(alpha: 0.5),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.matchesCategoryFilter.value,
                      onChanged: (value) {
                        if (value != null) controller.matchesCategoryFilter.value = value;
                      },
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All')),
                        ...Category.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat.name,
                            child: Text(cat.displayName),
                          );
                        }),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Results
        Expanded(
          child: Obx(() {
            if (controller.isLoadingMatches.value) {
              return Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: ShimmerGridLoaderBox(
                  crossAxisCount: 2,
                  itemCount: 6,
                  childAspectRatio: 0.75,
                ),
              );
            }

            if (controller.matchesError.value.isNotEmpty) {
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
                        controller.matchesError.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      TextButton(
                        onPressed: controller.refreshCurrentTab,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.selectedItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 64,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      'Select items to find matches',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'Tap items above to add them',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              );
            }

            final filteredItems = controller.filteredMatchingItems;

            if (filteredItems.isEmpty) {
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
                      'No matching items found',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.spacing12,
                crossAxisSpacing: AppConstants.spacing12,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return RecommendationCard(
                  item: item,
                  onTap: () => _showItemDetails(item, context),
                  onFavorite: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Favoriting recommendations will be available in a future update',
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 2),
                  );
                },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showItemDetails(Map<String, dynamic> item, BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: AppUiTokens.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item['name']?.toString() ?? 'Unknown Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              if (item['reason'] != null) ...[
                Text(
                  'Why it matches:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(item['reason'].toString()),
                const SizedBox(height: AppConstants.spacing16),
              ],
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
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
