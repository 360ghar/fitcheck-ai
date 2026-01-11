import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../controllers/wardrobe_controller.dart';

/// Wardrobe content without Scaffold wrapper (for IndexedStack in MainShellPage)
/// Note: FAB is handled by MainShellPage
class WardrobeContent extends StatefulWidget {
  const WardrobeContent({super.key});

  @override
  State<WardrobeContent> createState() => _WardrobeContentState();
}

class _WardrobeContentState extends State<WardrobeContent> {
  final WardrobeController controller = Get.find<WardrobeController>();

  @override
  Widget build(BuildContext context) {
    return AppPageBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            _buildAppBar(),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              sliver: Obx(() {
                if (controller.isLoading.value && controller.items.isEmpty) {
                  return _buildLoadingGrid();
                }

                if (controller.filteredItems.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildItemsGrid();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final tokens = AppUiTokens.of(context);

    return SliverAppBar(
      floating: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Wardrobe',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
      ),
      actions: [
        Obx(() => controller.selectedIds.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(),
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(),
              )),
        Obx(() => controller.selectedIds.isNotEmpty
            ? TextButton(
                onPressed: controller.clearSelection,
                child: Text('${controller.selectedCount} selected'),
              )
            : IconButton(
                icon: Icon(
                  controller.viewMode.value == 'grid'
                      ? Icons.view_list
                      : Icons.grid_on,
                ),
                onPressed: () => controller.setViewMode(
                  controller.viewMode.value == 'grid' ? 'list' : 'grid',
                ),
              )),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'filter') {
              _showFilterBottomSheet();
            } else if (value == 'sort') {
              _showSortBottomSheet();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'filter',
              child: Row(
                children: [
                  Icon(Icons.filter_list),
                  SizedBox(width: AppConstants.spacing8),
                  Text('Filter'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort',
              child: Row(
                children: [
                  Icon(Icons.sort),
                  SizedBox(width: AppConstants.spacing8),
                  Text('Sort'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.spacing12,
        crossAxisSpacing: AppConstants.spacing12,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = controller.filteredItems[index];
          final isSelected = controller.selectedIds.contains(item.id);

          return GestureDetector(
            onTap: () {
              if (controller.selectedIds.isNotEmpty) {
                controller.toggleItemSelection(item);
              } else {
                Get.toNamed('/wardrobe/${item.id}');
              }
            },
            onLongPress: () {
              controller.setSelectedItem(item);
              _showItemOptions(item);
            },
            child: _buildItemCard(item, isSelected),
          );
        },
        childCount: controller.filteredItems.length,
      ),
    );
  }

  Widget _buildItemCard(dynamic item, bool isSelected) {
    final tokens = AppUiTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(
          color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.cardShadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Item image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius16),
              child: item.itemImages != null && item.itemImages!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.itemImages!.first.url,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      memCacheHeight: 600,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: tokens.cardColor.withOpacity(0.4),
                        highlightColor: tokens.cardColor.withOpacity(0.7),
                        period: const Duration(milliseconds: 1200),
                        child: Container(
                          color: tokens.cardColor.withOpacity(0.3),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(item.category),
                    )
                  : _buildPlaceholder(item.category),
            ),
          ),

          // Favorite indicator
          if (item.isFavorite)
            Positioned(
              top: AppConstants.spacing8,
              right: AppConstants.spacing8,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          // Selection indicator
          if (isSelected)
            Positioned(
              top: AppConstants.spacing8,
              left: AppConstants.spacing8,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing4),
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

          // Item name at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacing8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radius16),
                  bottomRight: Radius.circular(AppConstants.radius16),
                ),
              ),
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Category category) {
    final tokens = AppUiTokens.of(context);

    return Container(
      color: tokens.cardColor.withOpacity(0.6),
      child: Center(
        child: Icon(
          _getCategoryIcon(category),
          size: 48,
          color: tokens.textMuted,
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    final tokens = AppUiTokens.of(context);

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.spacing12,
        crossAxisSpacing: AppConstants.spacing12,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: tokens.cardColor.withOpacity(0.4),
            highlightColor: tokens.cardColor.withOpacity(0.7),
            period: const Duration(milliseconds: 1200),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.cardColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppConstants.radius16),
                border: Border.all(color: tokens.cardBorderColor),
              ),
            ),
          );
        },
        childCount: 6,
      ),
    );
  }

  Widget _buildEmptyState() {
    final tokens = AppUiTokens.of(context);

    return SliverFillRemaining(
      child: Center(
        child: AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2,
                size: 64,
                color: tokens.textMuted,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Your wardrobe is empty',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Add your first item to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              ElevatedButton.icon(
                onPressed: () => _showAddItemOptions(),
                icon: const Icon(Icons.add),
                label: const Text('Add First Item'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing24,
                    vertical: AppConstants.spacing16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemOptions() {
    Get.toNamed('/wardrobe/add');
  }

  void _showFilterBottomSheet() {
    final tokens = AppUiTokens.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Obx(() => Wrap(
                    spacing: AppConstants.spacing8,
                    runSpacing: AppConstants.spacing8,
                    children: Category.values.map((category) {
                      final isSelected =
                          controller.selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category.displayName),
                        selected: isSelected,
                        onSelected: (_) =>
                            controller.toggleCategoryFilter(category),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: AppConstants.spacing24),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      controller.clearAllFilters();
                      Get.back();
                    },
                    child: const Text('Clear All'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    final tokens = AppUiTokens.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Newest First'),
                trailing: controller.sortType.value == 'newest'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setSortType('newest');
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('Oldest First'),
                trailing: controller.sortType.value == 'oldest'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setSortType('oldest');
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('Name (A-Z)'),
                trailing: controller.sortType.value == 'name'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setSortType('name');
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('Most Worn'),
                trailing: controller.sortType.value == 'most_worn'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setSortType('most_worn');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Search Wardrobe'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by name or brand...',
          ),
          onChanged: (value) {
            controller.searchQuery.value = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(dynamic item) {
    final tokens = AppUiTokens.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? Colors.red : null,
                ),
                title: Text(item.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                onTap: () {
                  Get.back();
                  controller.toggleFavorite(item.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Get.back();
                  Get.toNamed('/wardrobe/${item.id}/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation(itemId: item.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation({String? itemId}) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Items?'),
        content: Text(
          itemId == null
              ? 'Delete ${controller.selectedCount} items from your wardrobe?'
              : 'Delete this item from your wardrobe?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (itemId == null) {
                controller.batchDeleteSelected();
              } else {
                controller.deleteItem(itemId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
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
