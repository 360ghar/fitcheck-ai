import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../controllers/outfit_builder_controller.dart';
import '../widgets/outfit_canvas_item_card.dart';

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
            // Outfit details form
            _buildOutfitDetails(controller, tokens),

            // Canvas and wardrobe panel
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.availableItems.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildMainContent(context, controller, tokens);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitDetails(OutfitBuilderController controller, AppUiTokens tokens) {
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

  Widget _buildMainContent(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Row(
      children: [
        // Canvas area (left side - larger)
        Expanded(
          flex: 2,
          child: _buildCanvasArea(context, controller, tokens),
        ),

        // Wardrobe panel (right side)
        SizedBox(
          width: 280,
          child: _buildWardrobePanel(context, controller, tokens),
        ),
      ],
    );
  }

  Widget _buildCanvasArea(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: tokens.cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(
          color: tokens.cardBorderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Obx(() {
        if (controller.selectedItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 64,
                  color: tokens.textMuted,
                ),
                const SizedBox(height: AppConstants.spacing16),
                Text(
                  'Add items to your outfit',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  'Select items from the wardrobe panel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Outfit items on canvas
            ...controller.selectedItems.map((outfitItem) {
              return Positioned(
                left: outfitItem.position.dx,
                top: outfitItem.position.dy,
                child: OutfitCanvasItemCard(
                  outfitItem: outfitItem,
                  isVisible: outfitItem.isVisible,
                  layer: outfitItem.layer,
                  onTap: () {},
                  onRemove: () => controller.removeItem(outfitItem.id),
                  onToggleVisibility: () => controller.toggleVisibility(outfitItem.id),
                  onMoveLayer: (up) => controller.moveLayer(outfitItem.id, up),
                ),
              );
            }),

            // Generated image overlay
            if (controller.generatedImageUrl.value.isNotEmpty)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: _buildGeneratedImage(
                          controller.generatedImageUrl.value,
                        ),
                      ),
                      Positioned(
                        top: AppConstants.spacing16,
                        right: AppConstants.spacing16,
                        child: IconButton(
                          onPressed: () => controller.generatedImageUrl.value = '',
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildWardrobePanel(BuildContext context, OutfitBuilderController controller, AppUiTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.cardColor.withOpacity(0.5),
        border: Border(
          left: BorderSide(color: tokens.cardBorderColor),
        ),
      ),
      child: Column(
        children: [
          // Search and filter
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    filled: true,
                    fillColor: tokens.cardColor,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing16,
                      vertical: AppConstants.spacing12,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing12),

                // Category filter
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.categoryFilter.value,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: tokens.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radius12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing12,
                          vertical: AppConstants.spacing8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All Categories')),
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
              ],
            ),
          ),

          // Items list
          Expanded(
            child: Obx(() {
              final items = controller.filteredItems;

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No items available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppConstants.spacing8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConstants.spacing8,
                  crossAxisSpacing: AppConstants.spacing8,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildWardrobeItemCard(context, item, controller, tokens);
                },
              );
            }),
          ),

          // Action buttons
          Obx(() => Container(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  children: [
                    // Generate AI button
                    if (controller.selectedItems.isNotEmpty)
                      ElevatedButton.icon(
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
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),

                    if (controller.selectedItems.isNotEmpty)
                      const SizedBox(height: AppConstants.spacing8),

                    // Selected count
                    if (controller.selectedItems.isNotEmpty)
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
                          '${controller.selectedItems.length} item(s) selected',
                          style: TextStyle(
                            color: tokens.brandColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWardrobeItemCard(
    BuildContext context,
    dynamic item,
    OutfitBuilderController controller,
    AppUiTokens tokens,
  ) {
    return InkWell(
      onTap: () => controller.addItem(item),
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: Column(
          children: [
            // Item image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radius12),
                ),
                child: item.itemImages != null && item.itemImages!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.itemImages!.first.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: tokens.cardColor.withOpacity(0.5),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          _getCategoryIcon(item.category),
                          color: tokens.textMuted,
                        ),
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

  Widget _buildGeneratedImage(String source) {
    if (source.startsWith('data:image')) {
      final base64Data = source.split(',').last;
      return Image.memory(
        base64Decode(base64Data),
        fit: BoxFit.contain,
      );
    }
    return Image.network(
      source,
      fit: BoxFit.contain,
    );
  }
}
