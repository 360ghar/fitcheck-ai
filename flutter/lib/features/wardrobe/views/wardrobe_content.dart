import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../controllers/wardrobe_controller.dart';
import '../repositories/item_repository.dart';
import '../models/item_model.dart';
import '../../../app/routes/app_routes.dart';

/// Wardrobe content without Scaffold wrapper (for IndexedStack in MainShellPage)
/// Note: FAB is handled by MainShellPage
class WardrobeContent extends StatefulWidget {
  const WardrobeContent({super.key});

  @override
  State<WardrobeContent> createState() => _WardrobeContentState();
}

class _WardrobeContentState extends State<WardrobeContent> {
  final WardrobeController controller = Get.find<WardrobeController>();
  final ItemRepository _itemRepository = ItemRepository();
  late final TextEditingController _searchController;
  late final Worker _searchWorker;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
    _searchWorker = ever(controller.searchQuery, (query) {
      if (_searchController.text != query) {
        _searchController.value = TextEditingValue(
          text: query,
          selection: TextSelection.collapsed(offset: query.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchWorker.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      controller.searchQuery.value.isNotEmpty ||
      controller.selectedCategories.isNotEmpty ||
      controller.selectedConditions.isNotEmpty ||
      controller.selectedColors.isNotEmpty ||
      controller.selectedOccasion.value.isNotEmpty ||
      controller.favoritesOnly.value;

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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(child: _buildCatalogueHeader()),
                  SliverToBoxAdapter(child: _buildSearchField()),
                  SliverToBoxAdapter(child: _buildCategoryChips()),

                  // Offline / error banner (persistent context, so an offline
                  // user never sees a misleading "empty closet" state).
                  Obx(() {
                    if (controller.error.value.isEmpty ||
                        controller.isLoading.value) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(
                      child: AppErrorBanner(message: controller.error.value),
                    );
                  }),

                  // Content
                  SliverPadding(
                    // Extra bottom inset so extended FAB + bottom nav don't cover last row
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spacing16,
                      AppConstants.spacing16,
                      AppConstants.spacing16,
                      AppConstants.spacing16 + 96,
                    ),
                    sliver: Obx(() {
                      if (controller.isLoading.value &&
                          controller.items.isEmpty) {
                        return const ShimmerGridLoader(
                          crossAxisCount: 2,
                          itemCount: 6,
                          childAspectRatio: 0.78,
                        );
                      }

                      if (controller.filteredItems.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildItems();
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

  Widget _buildCatalogueHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppCoreColors.editorialLinen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: Text(
                      'Closet',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppCoreColors.editorialInk,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => controller.selectedIds.isNotEmpty
                          ? IconButton(
                              tooltip: 'Delete selected',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _showDeleteConfirmation,
                            )
                          : IconButton(
                              tooltip: controller.viewMode.value == 'grid'
                                  ? 'List view'
                                  : 'Grid view',
                              icon: Icon(
                                controller.viewMode.value == 'grid'
                                    ? Icons.view_list_outlined
                                    : Icons.grid_view_outlined,
                              ),
                              onPressed: () => controller.setViewMode(
                                controller.viewMode.value == 'grid'
                                    ? 'list'
                                    : 'grid',
                              ),
                            ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Closet options',
                      onSelected: (value) {
                        if (value == 'filter') {
                          _showFilterBottomSheet();
                        } else if (value == 'sort') {
                          _showSortBottomSheet();
                        } else if (value == 'stats') {
                          Get.toNamed(Routes.wardrobeStats);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'filter', child: Text('Filter')),
                        PopupMenuItem(value: 'sort', child: Text('Sort')),
                        PopupMenuItem(
                          value: 'stats',
                          child: Text('Closet Stats'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => controller.selectedIds.isNotEmpty
                ? TextButton(
                    onPressed: controller.clearSelection,
                    child: Text('${controller.selectedCount} selected · Clear'),
                  )
                : Text(
                    '${controller.totalItems.value} '
                    '${controller.totalItems.value == 1 ? 'piece' : 'pieces'} '
                    '${_hasFilters ? 'found' : 'in your collection'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) => controller.searchQuery.value = value,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'Search your closet',
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon: controller.searchQuery.value.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close),
                          onPressed: () => controller.searchQuery.value = '',
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Filter closet',
            icon: const Icon(Icons.tune_outlined),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    _categoryChip(
                      'All',
                      selected: controller.selectedCategories.isEmpty,
                      onSelected: controller.clearAllFilters,
                    ),
                    // Counts belong to the server result. Loaded-page counts
                    // must not hide categories or suggest a complete inventory.
                    for (final category in Category.values)
                      _categoryChip(
                        category.displayName,
                        selected: controller.selectedCategories.contains(
                          category,
                        ),
                        onSelected: () =>
                            controller.toggleCategoryFilter(category),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outlineVariant,
          ),
          Obx(
            () => IconButton(
              tooltip:
                  'Sort: ${switch (controller.sortType.value) {
                    'oldest' => 'oldest first',
                    'name' => 'name A–Z',
                    'most_worn' => 'most worn',
                    _ => 'newest first',
                  }}',
              icon: const Icon(Icons.sort),
              onPressed: _showSortBottomSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(
    String label, {
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppCoreColors.editorialLinen,
        backgroundColor: theme.colorScheme.surface,
        showCheckmark: false,
        side: BorderSide.none,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: selected
              ? AppCoreColors.editorialInk
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildItems() {
    final items = controller.filteredItems;
    if (controller.viewMode.value == 'list') {
      return SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Align(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: AspectRatio(
                aspectRatio: 0.8,
                child: _buildItemTile(items[index]),
              ),
            ),
          ),
        ),
      );
    }

    // Image-only tiles do not need fewer columns when text is enlarged.
    // The surrounding search and filters still follow the user's text scale.
    return SliverLayoutBuilder(
      builder: (context, constraints) => SliverGrid.builder(
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.crossAxisExtent < 600
              ? 2
              : (constraints.crossAxisExtent / 200).floor().clamp(2, 4),
          mainAxisSpacing: 24,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) => _buildItemTile(items[index]),
      ),
    );
  }

  Widget _buildItemTile(ItemModel item) {
    final theme = Theme.of(context);
    final images = item.itemImages ?? [];
    final photo = images.isEmpty
        ? null
        : images.firstWhere(
            (image) => image.isPrimary,
            orElse: () => images.first,
          );
    return Obx(() {
      final selectionActive = controller.selectedIds.isNotEmpty;
      final selected = controller.selectedIds.contains(item.id);

      return Semantics(
        label: 'Closet item: ${item.name}',
        button: true,
        selected: selectionActive ? selected : null,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              if (selectionActive) {
                controller.toggleItemSelection(item);
              } else {
                Get.toNamed('/wardrobe/${item.id}');
              }
            },
            onLongPress: () {
              controller.setSelectedItem(item);
              _showItemOptions(item);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (photo == null || photo.url.trim().isEmpty)
                  _buildPlaceholder(item.category)
                else
                  AppImage(
                    imageUrl: photo.url,
                    fallbackUrl: photo.url,
                    fit: BoxFit.contain,
                    enableZoom: false,
                    backgroundColor: Colors.transparent,
                    placeholder: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: 'Loading item image',
                        ),
                      ),
                    ),
                    semanticLabel: 'Item photo',
                    errorWidget: _buildPlaceholder(item.category),
                    memCacheWidth: 500,
                    memCacheHeight: 650,
                    storagePath: photo.storagePath,
                    remintUrl: _itemRepository.remintImageUrl,
                  ),
                if (selectionActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPlaceholder(Category category) {
    return Center(
      child: Icon(
        _getCategoryIcon(category),
        semanticLabel: 'Image unavailable',
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final filtered = _hasFilters;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              filtered ? Icons.search_off_outlined : Icons.checkroom_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              filtered ? 'No matching pieces' : 'Your closet is empty',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Try another search or clear your filters.'
                  : 'Add your first piece to start your personal collection.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: filtered
                  ? controller.clearAllFilters
                  : _showAddItemOptions,
              icon: Icon(filtered ? Icons.filter_alt_off_outlined : Icons.add),
              label: Text(filtered ? 'Clear filters' : 'Add your first item'),
            ),
          ],
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
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        // isScrollControlled + scrollable content fix the audit failure: the
        // filter stack (~700px of chips + text field + actions) overflows the
        // default 9/16-height sheet cap. Keyboard insets need no extra padding
        // here: GetX 4.7.3's GetModalBottomSheetRoute already wraps the sheet
        // in Padding(viewInsets.bottom) (bottomsheet.dart buildPage), so
        // padding the insets a second time inside collapses the viewport on
        // small screens (verified empirically + in GetX source).
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Obx(
                    () => Wrap(
                      spacing: AppConstants.spacing8,
                      runSpacing: AppConstants.spacing8,
                      children: Category.values.map((category) {
                        final isSelected = controller.selectedCategories
                            .contains(category);
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
        ),
      ),
      isScrollControlled: true,
    ).then((_) {
      // Dispose after the sheet's exit transition finishes: disposing here
      // immediately trips a debug assert because the closing animation still
      // rebuilds the TextField (TextEditingController used after being
      // disposed). The route's reverse animation is ~200ms.
      Future.delayed(
        const Duration(milliseconds: 350),
        customUseCaseController.dispose,
      );
    });
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
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: SingleChildScrollView(
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
        ),
      ),
    );
  }

  void _showItemOptions(ItemModel item) {
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
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(
                      controller.selectedIds.contains(item.id)
                          ? 'Deselect item'
                          : 'Select item',
                    ),
                    onTap: () {
                      Get.back();
                      controller.toggleItemSelection(item);
                    },
                  ),
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
              ? 'Delete ${controller.selectedCount} items from your closet?'
              : 'Delete this item from your closet?',
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
