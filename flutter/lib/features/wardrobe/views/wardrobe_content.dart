import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/constants/use_cases.dart';
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
        child: Obx(
          () => RefreshIndicator(
            onRefresh: () => controller.fetchItems(refresh: true),
            child: InfiniteScrollWrapper(
              onLoadMore: () => controller.fetchItems(),
              hasMore: controller.hasMore.value,
              isLoadingMore: controller.isLoadingMore.value,
              child: CustomScrollView(
                slivers: [
                  // App bar
                  _buildAppBar(),

                  // Category filter chips
                  SliverToBoxAdapter(child: _buildCategoryChips()),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    sliver: Obx(() {
                      if (controller.isLoading.value &&
                          controller.items.isEmpty) {
                        return const ShimmerGridLoader(
                          crossAxisCount: 2,
                          itemCount: 6,
                          childAspectRatio: 0.75,
                        );
                      }

                      if (controller.filteredItems.isEmpty) {
                        return _buildEmptyState();
                      }

                      return controller.viewMode.value == 'grid'
                          ? _buildItemsGrid()
                          : _buildItemsList();
                    }),
                  ),

                  // Load more indicator
                  Obx(
                    () => SliverLoadingMoreIndicator(
                      isLoading: controller.isLoadingMore.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        Obx(
          () => controller.selectedIds.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(),
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showSearchDialog(),
                ),
        ),
        Obx(
          () => controller.selectedIds.isNotEmpty
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
                ),
        ),
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

  Widget _buildCategoryChips() {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          final allSelected = controller.selectedCategories.isEmpty;

          return Row(
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacing8),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('All'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: allSelected
                              ? Colors.white.withOpacity(0.2)
                              : tokens.textMuted.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.items.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: allSelected
                                ? Colors.white
                                : tokens.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  selected: allSelected,
                  onSelected: (_) => controller.clearAllFilters(),
                  selectedColor: tokens.brandColor,
                  labelStyle: TextStyle(
                    color: allSelected ? Colors.white : tokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  showCheckmark: false,
                  side: BorderSide(
                    color: allSelected
                        ? tokens.brandColor
                        : tokens.cardBorderColor,
                  ),
                ),
              ),
              // Category chips
              ...Category.values.map((category) {
                final isSelected = controller.selectedCategories.contains(
                  category,
                );
                final count = controller.items
                    .where((item) => item.category == category)
                    .length;

                if (count == 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spacing8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : tokens.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(category.displayName),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : tokens.textMuted.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : tokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.toggleCategoryFilter(category),
                    selectedColor: tokens.brandColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : tokens.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected
                          ? tokens.brandColor
                          : tokens.cardBorderColor,
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ),
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
      delegate: SliverChildBuilderDelegate((context, index) {
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
      }, childCount: controller.filteredItems.length),
    );
  }

  Widget _buildItemsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
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
          child: _buildListItemCard(item, isSelected),
        );
      }, childCount: controller.filteredItems.length),
    );
  }

  Widget _buildListItemCard(dynamic item, bool isSelected) {
    final tokens = AppUiTokens.of(context);
    final hasImages = item.itemImages != null && item.itemImages!.isNotEmpty;
    final imageUrls = hasImages
        ? item.itemImages!.map<String>((img) => img.url as String).toList()
        : <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(
          color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.cardShadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item image thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radius16 - 1),
              bottomLeft: Radius.circular(AppConstants.radius16 - 1),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: hasImages
                  ? AppImage(
                      imageUrl: imageUrls.first,
                      fit: BoxFit.cover,
                      backgroundColor: tokens.isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      enableZoom: controller.selectedIds.isEmpty,
                      galleryUrls: imageUrls,
                      memCacheWidth: 200,
                      memCacheHeight: 200,
                      errorIcon: _getCategoryIcon(item.category),
                    )
                  : _buildPlaceholder(item.category),
            ),
          ),

          // Item details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(item.category),
                        size: 14,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.category.displayName,
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (item.brand != null && item.brand!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      item.brand!,
                      style: TextStyle(color: tokens.textMuted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Indicators (favorite, selection)
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacing12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isFavorite)
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing4),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                if (isSelected) ...[
                  const SizedBox(width: AppConstants.spacing8),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing4),
                    decoration: BoxDecoration(
                      color: tokens.brandColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
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

  Widget _buildItemCard(dynamic item, bool isSelected) {
    final tokens = AppUiTokens.of(context);
    final hasImages = item.itemImages != null && item.itemImages!.isNotEmpty;
    final imageUrls = hasImages
        ? item.itemImages!.map<String>((img) => img.url as String).toList()
        : <String>[];

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(
          color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
          width: isSelected ? 2 : 1,
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
          // Item image using AppImage with BoxFit.contain
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius16 - 1),
              child: hasImages
                  ? AppImage(
                      imageUrl: imageUrls.first,
                      fit: BoxFit.contain,
                      backgroundColor: tokens.isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      enableZoom: controller.selectedIds.isEmpty,
                      galleryUrls: imageUrls,
                      memCacheWidth: 400,
                      memCacheHeight: 600,
                      errorIcon: _getCategoryIcon(item.category),
                    )
                  : _buildPlaceholder(item.category),
            ),
          ),

          // Category badge
          Positioned(
            top: AppConstants.spacing8,
            left: AppConstants.spacing8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing8,
                vertical: AppConstants.spacing4,
              ),
              decoration: BoxDecoration(
                color: tokens.cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppConstants.radius8),
                border: Border.all(color: tokens.cardBorderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(item.category),
                    size: 12,
                    color: tokens.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.category.displayName,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),

          // Selection indicator
          if (isSelected)
            Positioned(
              top: AppConstants.spacing8,
              right: item.isFavorite
                  ? AppConstants.spacing8 + 30
                  : AppConstants.spacing8,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing4),
                decoration: BoxDecoration(
                  color: tokens.brandColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),

          // Item name at bottom with gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing12,
                vertical: AppConstants.spacing8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState() {
    final tokens = AppUiTokens.of(context);

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: AppGlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated-style icon container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: tokens.brandColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.checkroom_outlined,
                    size: 48,
                    color: tokens.brandColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),
                Text(
                  'Your wardrobe is empty',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  'Start building your digital closet by adding\nyour first clothing item',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing24),
                ElevatedButton.icon(
                  onPressed: () => _showAddItemOptions(),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Your First Item'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing24,
                      vertical: AppConstants.spacing16,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  'Take a photo or upload from gallery',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
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
    final customUseCaseController = TextEditingController();

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
              Text('Filters', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Category',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Obx(
                () => Wrap(
                  spacing: AppConstants.spacing8,
                  runSpacing: AppConstants.spacing8,
                  children: Category.values.map((category) {
                    final isSelected = controller.selectedCategories.contains(
                      category,
                    );
                    return FilterChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (_) =>
                          controller.toggleCategoryFilter(category),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Use Case',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Obx(
                () => Wrap(
                  spacing: AppConstants.spacing8,
                  runSpacing: AppConstants.spacing8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: controller.selectedOccasion.value.isEmpty,
                      onSelected: (_) => controller.setOccasionFilter(''),
                    ),
                    ...UseCases.defaults.map((useCase) {
                      final isSelected =
                          controller.selectedOccasion.value == useCase;
                      return ChoiceChip(
                        label: Text(UseCases.displayLabel(useCase)),
                        selected: isSelected,
                        onSelected: (_) =>
                            controller.setOccasionFilter(useCase),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customUseCaseController,
                      decoration: const InputDecoration(
                        labelText: 'Custom use case',
                        hintText: 'e.g., brunch',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) {
                        final value = UseCases.normalize(
                          customUseCaseController.text,
                        );
                        controller.setOccasionFilter(value);
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  OutlinedButton(
                    onPressed: () {
                      final value = UseCases.normalize(
                        customUseCaseController.text,
                      );
                      controller.setOccasionFilter(value);
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
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
          TextButton(onPressed: () => Get.back(), child: const Text('Done')),
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
                title: Text(
                  item.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                ),
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
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
