import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../controllers/outfit_list_controller.dart';
import '../controllers/outfit_generation_controller.dart';
import '../repositories/outfit_repository.dart';
import '../models/outfit_model.dart';
import '../../../app/routes/app_routes.dart';
import 'outfit_detail_page.dart';

/// Outfits content without Scaffold wrapper (for IndexedStack in MainShellPage)
/// Note: FAB is handled by MainShellPage
class OutfitsContent extends StatefulWidget {
  const OutfitsContent({super.key});

  @override
  State<OutfitsContent> createState() => _OutfitsContentState();
}

class _OutfitsContentState extends State<OutfitsContent> {
  final OutfitListController controller = Get.find<OutfitListController>();
  final OutfitGenerationController generationController =
      Get.find<OutfitGenerationController>();
  final OutfitRepository _outfitRepository = OutfitRepository();
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
      controller.selectedStyles.isNotEmpty ||
      controller.selectedSeasons.isNotEmpty ||
      controller.favoritesOnly.value ||
      controller.draftsOnly.value;

  @override
  Widget build(BuildContext context) {
    return AppPageBackground(
      child: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            onRefresh: () => controller.fetchOutfits(refresh: true),
            child: InfiniteScrollWrapper(
              onLoadMore: () => controller.fetchOutfits(),
              hasMore: controller.hasMore.value,
              isLoadingMore: controller.isLoadingMore.value,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(child: _buildLookbookHeader()),
                  SliverToBoxAdapter(child: _buildSearchField()),
                  SliverToBoxAdapter(child: _buildCollectionControls()),
                  // Offline / error banner (persistent context, so an offline
                  // user never sees a misleading "No outfits yet" state).
                  Obx(() {
                    if (controller.error.value.isEmpty ||
                        controller.isLoading.value) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(
                      child: AppErrorBanner(message: controller.error.value),
                    );
                  }),
                  // Extra bottom inset so extended FAB + bottom nav don't cover last row
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spacing16,
                      AppConstants.spacing16,
                      AppConstants.spacing16,
                      AppConstants.spacing16 + 96,
                    ),
                    sliver: Obx(() {
                      if (controller.isLoading.value &&
                          controller.outfits.isEmpty) {
                        return const ShimmerGridLoader(
                          crossAxisCount: 2,
                          itemCount: 6,
                          childAspectRatio: 0.85,
                        );
                      }

                      if (controller.filteredOutfits.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildOutfitsGrid();
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

  Widget _buildLookbookHeader() {
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
                    color: AppCoreColors.editorialSlate,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: Text(
                      'Lookbook',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppCoreColors.editorialInk,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Outfit options',
                  onSelected: (value) {
                    if (value == 'filter') {
                      _showFilterBottomSheet();
                    } else if (value == 'favorites') {
                      controller.favoritesOnly.toggle();
                    } else if (value == 'collections') {
                      Get.toNamed(Routes.outfitCollections);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'favorites',
                      child: Text('Favorites Only'),
                    ),
                    PopupMenuItem(value: 'filter', child: Text('Filter')),
                    PopupMenuItem(
                      value: 'collections',
                      child: Text('Collections'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '${controller.totalOutfits.value} '
              '${_hasFilters ? 'matching' : 'saved'} '
              '${controller.totalOutfits.value == 1 ? 'look' : 'looks'}',
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
                  hintText: 'Find a look',
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
            tooltip: 'Filter outfits',
            icon: const Icon(Icons.tune_outlined),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              _collectionChip(
                'All looks',
                selected:
                    !controller.favoritesOnly.value &&
                    !controller.draftsOnly.value,
                onSelected: controller.clearAllFilters,
              ),
              _collectionChip(
                'Favorites',
                selected: controller.favoritesOnly.value,
                onSelected: controller.favoritesOnly.toggle,
              ),
              _collectionChip(
                'Drafts',
                selected: controller.draftsOnly.value,
                onSelected: controller.draftsOnly.toggle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _collectionChip(
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
        selectedColor: AppCoreColors.editorialSlate,
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

  Widget _buildOutfitsGrid() {
    return SliverProductGrid(
      itemCount: controller.filteredOutfits.length,
      itemBuilder: (context, index) =>
          _buildOutfitCard(controller.filteredOutfits[index]),
    );
  }

  Widget _buildOutfitCard(OutfitModel outfit) {
    final theme = Theme.of(context);
    final images = outfit.outfitImages ?? [];
    final photo = images.isEmpty ? null : images.first;
    return Semantics(
      label: 'Outfit: ${outfit.name}',
      button: true,
      child: InkWell(
        onTap: () => _openOutfitDetailModal(outfit),
        onLongPress: () => _showOutfitDetail(outfit),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 0.75,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: photo == null
                          ? _buildComposition(outfit)
                          : AppImage(
                              imageUrl: photo.url,
                              fallbackUrl: photo.url,
                              fit: BoxFit.contain,
                              enableZoom: false,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              memCacheWidth: 500,
                              memCacheHeight: 650,
                              storagePath: photo.storagePath,
                              remintUrl: _outfitRepository.remintImageUrl,
                            ),
                    ),
                    if (outfit.isFavorite)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.surface,
                          child: Icon(
                            Icons.favorite,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              outfit.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                '${outfit.itemIds.length} ${outfit.itemIds.length == 1 ? 'piece' : 'pieces'}',
                if (outfit.isDraft) 'Draft',
                if (outfit.style != null) outfit.style!.displayName,
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposition(OutfitModel outfit) {
    // The list endpoint already includes item photos. Use those existing
    // assets when a saved combination has no generated outfit image.
    final photos = (outfit.items ?? [])
        .where((item) => item.itemImages?.isNotEmpty == true)
        .map((item) => item.itemImages!.first)
        .take(4)
        .toList();
    if (photos.isEmpty) {
      return Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    final columns = photos.length > 2 ? 2 : 1;
    final rows = (photos.length / columns).ceil();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (var row = 0; row < rows; row++)
            Expanded(
              child: Row(
                children: [
                  for (var column = 0; column < columns; column++)
                    Expanded(
                      child: row * columns + column >= photos.length
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.all(4),
                              child: AppImage(
                                imageUrl: photos[row * columns + column].url,
                                storagePath:
                                    photos[row * columns + column].storagePath,
                                remintUrl: _outfitRepository.remintImageUrl,
                                fit: BoxFit.contain,
                                enableZoom: false,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                memCacheWidth: 350,
                              ),
                            ),
                    ),
                ],
              ),
            ),
        ],
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
              filtered ? Icons.search_off_outlined : Icons.style_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              filtered ? 'No matching looks' : 'No outfits yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Try another search or clear your filters.'
                  : 'Bring your favorite pieces together. Save a look for every plan.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (filtered) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: controller.clearAllFilters,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Style',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.spacing16),
                Obx(
                  () => Wrap(
                    spacing: AppConstants.spacing8,
                    runSpacing: AppConstants.spacing8,
                    children: Style.values.map((style) {
                      return FilterChip(
                        label: Text(style.displayName),
                        selected: controller.selectedStyles.contains(style),
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedStyles.add(style);
                          } else {
                            controller.selectedStyles.remove(style);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),
                Text(
                  'Filter by Season',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.spacing16),
                Obx(
                  () => Wrap(
                    spacing: AppConstants.spacing8,
                    runSpacing: AppConstants.spacing8,
                    children: Season.values.map((season) {
                      return FilterChip(
                        label: Text(season.displayName),
                        selected: controller.selectedSeasons.contains(season),
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedSeasons.add(season);
                          } else {
                            controller.selectedSeasons.remove(season);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => controller.clearAllFilters(),
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
    );
  }

  /// Opens the outfit in a modal sheet (reference video UX) instead of pushing
  /// a full-screen route. Long-press still surfaces the quick-actions sheet.
  void _openOutfitDetailModal(OutfitModel outfit) {
    final tokens = AppUiTokens.of(context);
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius24),
        ),
        child: SizedBox(
          height: Get.height * 0.9,
          child: OutfitDetailPage(outfitId: outfit.id),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: tokens.cardColor,
    );
  }

  void _showOutfitDetail(OutfitModel outfit) {
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
                    leading: Icon(
                      outfit.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: outfit.isFavorite ? Colors.red : null,
                    ),
                    title: Text(
                      outfit.isFavorite
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                    ),
                    onTap: () {
                      Get.back();
                      controller.toggleFavorite(outfit.id);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/outfits/${outfit.id}/edit');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('Share'),
                    onTap: () {
                      Get.back();
                      generationController.shareOutfit(outfit.id);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete'),
                    onTap: () {
                      Get.back();
                      _showDeleteConfirmation(outfit.id);
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

  void _showDeleteConfirmation(String outfitId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Outfit?'),
        content: const Text(
          'This outfit will be removed from your collection.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteOutfit(outfitId);
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
}
