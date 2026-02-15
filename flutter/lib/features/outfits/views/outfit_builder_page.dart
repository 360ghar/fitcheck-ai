import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../controllers/outfit_builder_controller.dart';

/// Outfit builder page - Create and visualize outfits
class OutfitBuilderPage extends StatelessWidget {
  const OutfitBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final OutfitBuilderController controller = Get.put(OutfitBuilderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Outfit'),
        elevation: 0,
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isSaving.value
                    ? null
                    : controller.selectedItems.isEmpty
                        ? null
                        : () => controller.saveOutfit(),
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              )),
        ],
      ),
      body: AppPageBackground(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.availableItems.isEmpty) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shimmer for outfit details form
                          const ShimmerCard(height: 120),
                          const SizedBox(height: AppConstants.spacing16),
                          // Shimmer for section header
                          const ShimmerBox(width: 180, height: 20),
                          const SizedBox(height: AppConstants.spacing12),
                          // Shimmer for selected items row
                          const ShimmerCard(height: 100),
                          const SizedBox(height: AppConstants.spacing16),
                          // Shimmer for search filter
                          const ShimmerCard(height: 56),
                          const SizedBox(height: AppConstants.spacing16),
                          // Shimmer for items grid
                          ShimmerGridLoaderBox(
                            crossAxisCount: 3,
                            itemCount: 9,
                            childAspectRatio: 0.75,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Outfit details form
                      _buildOutfitDetails(context, controller, tokens),

                      // Section header
                      _buildSectionHeader(context, controller, tokens),

                      // Selected items thumbnail row
                      _buildSelectedItemsRow(context, controller, tokens),

                      // Search and filter
                      _buildSearchFilter(context, controller, tokens),

                      // Wardrobe items grid
                      _buildWardrobeGrid(context, controller, tokens),
                    ],
                  ),
                );
              }),
            ),

            // Sticky bottom bar
            _buildBottomBar(context, controller, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitDetails(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        children: [
          // Name input
          TextField(
            onChanged: (value) => controller.name.value = value,
            decoration: InputDecoration(
              labelText: 'Outfit Name *',
              hintText: 'My Casual Outfit',
              filled: true,
              fillColor: tokens.cardColor.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacing12),

          // Style and Season dropdowns
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<Style>(
                      value: controller.selectedStyle.value,
                      decoration: InputDecoration(
                        labelText: 'Style',
                        filled: true,
                        fillColor: tokens.cardColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radius12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing12,
                          vertical: AppConstants.spacing8,
                        ),
                      ),
                      items: Style.values.map((style) {
                        return DropdownMenuItem(
                          value: style,
                          child: Text(style.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) controller.selectedStyle.value = value;
                      },
                    )),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Obx(() => DropdownButtonFormField<Season>(
                      value: controller.selectedSeason.value,
                      decoration: InputDecoration(
                        labelText: 'Season',
                        filled: true,
                        fillColor: tokens.cardColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radius12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing12,
                          vertical: AppConstants.spacing8,
                        ),
                      ),
                      items: Season.values.map((season) {
                        return DropdownMenuItem(
                          value: season,
                          child: Text(season.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) controller.selectedSeason.value = value;
                      },
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add items to your outfit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Obx(() => controller.selectedItems.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing12,
                    vertical: AppConstants.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                  ),
                  child: Text(
                    '${controller.selectedItems.length} selected',
                    style: TextStyle(
                      color: tokens.brandColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSelectedItemsRow(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      decoration: BoxDecoration(
        color: tokens.cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: tokens.cardBorderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Obx(() {
        if (controller.selectedItems.isEmpty) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: tokens.textMuted,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing8),
                Text(
                  'Tap items below to add',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppConstants.spacing12),
          itemCount: controller.selectedItems.length,
          itemBuilder: (context, index) {
            final outfitItem = controller.selectedItems[index];
            return _buildSelectedThumbnail(context, outfitItem, controller, tokens);
          },
        );
      }),
    );
  }

  Widget _buildSelectedThumbnail(
    BuildContext context,
    OutfitBuilderItem outfitItem,
    OutfitBuilderController controller,
    AppUiTokens tokens,
  ) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: AppConstants.spacing8),
      child: Stack(
        children: [
          // Item image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: tokens.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.radius8),
              border: Border.all(color: tokens.brandColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius8 - 2),
              child: outfitItem.item.itemImages != null &&
                      outfitItem.item.itemImages!.isNotEmpty
                  ? AppImage(
                      imageUrl: outfitItem.item.itemImages!.first.url,
                      fit: BoxFit.cover,
                      enableZoom: false,
                      errorIcon: _getCategoryIcon(outfitItem.item.category),
                    )
                  : Icon(
                      _getCategoryIcon(outfitItem.item.category),
                      color: tokens.textMuted,
                      size: 24,
                    ),
            ),
          ),

          // Remove button
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => controller.removeItem(outfitItem.id),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.cardColor, width: 2),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search items...',
                filled: true,
                fillColor: tokens.cardColor.withOpacity(0.5),
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing12,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppConstants.spacing12),

          // Category filter
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.categoryFilter.value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: tokens.cardColor.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing8,
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All')),
                    ...Category.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat.name,
                        child: Text(cat.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.categoryFilter.value = value;
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeGrid(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Obx(() {
      final items = controller.filteredItems;

      if (items.isEmpty) {
        return Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(
            'No items available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppConstants.spacing12,
            crossAxisSpacing: AppConstants.spacing12,
            childAspectRatio: 0.75,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildWardrobeItemCard(context, item, controller, tokens);
          },
        ),
      );
    });
  }

  Widget _buildWardrobeItemCard(
    BuildContext context,
    dynamic item,
    OutfitBuilderController controller,
    AppUiTokens tokens,
  ) {
    return Obx(() {
      final isSelected = controller.isItemSelected(item.id);

      return InkWell(
        onTap: () => controller.toggleItem(item),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: Container(
          decoration: BoxDecoration(
            color: tokens.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            border: Border.all(
              color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: tokens.brandColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Item image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radius12),
                      ),
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

                  // Item name
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing8),
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Selection indicator
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: tokens.brandColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Obx(() {
      if (controller.selectedItems.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.only(
          left: AppConstants.spacing16,
          right: AppConstants.spacing16,
          top: AppConstants.spacing12,
          bottom: AppConstants.spacing12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: tokens.cardColor,
          border: Border(
            top: BorderSide(color: tokens.cardBorderColor),
          ),
        ),
        child: Row(
          children: [
            // Selected count
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing12,
                vertical: AppConstants.spacing8,
              ),
              decoration: BoxDecoration(
                color: tokens.brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radius8),
              ),
              child: Text(
                '${controller.selectedItems.length} item${controller.selectedItems.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: tokens.brandColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(width: AppConstants.spacing12),

            // Generate AI Preview button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isGenerating.value
                    ? null
                    : () => controller.generateAIOutfit(),
                icon: controller.isGenerating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(controller.isGenerating.value
                    ? 'Generating...'
                    : 'Generate AI Preview'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      );
    });
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
