import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../controllers/outfit_list_controller.dart';
import '../controllers/outfit_generation_controller.dart';

/// Outfits page
class OutfitsPage extends StatefulWidget {
  const OutfitsPage({super.key});

  @override
  State<OutfitsPage> createState() => _OutfitsPageState();
}

class _OutfitsPageState extends State<OutfitsPage> {
  final OutfitListController controller = Get.find<OutfitListController>();
  final OutfitGenerationController generationController = Get.find<OutfitGenerationController>();

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                sliver: Obx(() {
                  if (controller.isLoading.value && controller.outfits.isEmpty) {
                    return _buildLoadingGrid();
                  }

                  if (controller.filteredOutfits.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildOutfitsGrid();
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAppBar() {
    final tokens = AppUiTokens.of(context);

    return SliverAppBar(
      floating: true,
      elevation: 0,
      title: Text(
        'Outfits',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'filter') {
              _showFilterBottomSheet();
            } else if (value == 'favorites') {
              controller.favoritesOnly.toggle();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'favorites',
              child: Row(
                children: [
                  Obx(() => Icon(
                    controller.favoritesOnly.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                  )),
                  const SizedBox(width: AppConstants.spacing8),
                  const Text('Favorites Only'),
                ],
              ),
            ),
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
          ],
        ),
      ],
    );
  }

  Widget _buildOutfitsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.spacing12,
        crossAxisSpacing: AppConstants.spacing12,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final outfit = controller.filteredOutfits[index];
          return _buildOutfitCard(outfit);
        },
        childCount: controller.filteredOutfits.length,
      ),
    );
  }

  Widget _buildOutfitCard(dynamic outfit) {
    final tokens = AppUiTokens.of(context);

    return GestureDetector(
      onTap: () => Get.toNamed('/outfits/${outfit.id}'),
      onLongPress: () => _showOutfitDetail(outfit),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(
            color: tokens.cardBorderColor,
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
            // Outfit image/items preview
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radius16 - 1),
                child: outfit.outfitImages != null && outfit.outfitImages!.isNotEmpty
                    ? AppImage(
                        imageUrl: outfit.outfitImages!.first.url,
                        fit: BoxFit.contain,
                        enableZoom: false,
                        galleryUrls: outfit.outfitImages!.map<String>((img) => img.url as String).toList(),
                        backgroundColor: tokens.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            // Favorite indicator
            if (outfit.isFavorite)
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
                    size: 14,
                  ),
                ),
              ),

            // Draft indicator
            if (outfit.isDraft)
              Positioned(
                top: AppConstants.spacing8,
                left: AppConstants.spacing8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing8,
                    vertical: AppConstants.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.radius8),
                  ),
                  child: Text(
                    'Draft',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Outfit info at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppConstants.radius16),
                    bottomRight: Radius.circular(AppConstants.radius16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (outfit.style != null)
                      Text(
                        outfit.style!.displayName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final tokens = AppUiTokens.of(context);

    return Container(
      color: tokens.cardColor.withOpacity(0.6),
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.white54),
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
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: tokens.cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppConstants.radius16),
              border: Border.all(color: tokens.cardBorderColor),
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
                Icons.auto_awesome,
                size: 64,
                color: tokens.textMuted,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'No outfits yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Create your first outfit from your wardrobe',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/outfits/build'),
      icon: const Icon(Icons.add),
      label: const Text('Create Outfit'),
    );
  }

  void _showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Search Outfits'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by name or style...',
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
                Obx(() => Wrap(
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
                    )),
                const SizedBox(height: AppConstants.spacing24),
                Text(
                  'Filter by Season',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.spacing16),
                Obx(() => Wrap(
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
                    )),
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

  void _showOutfitDetail(dynamic outfit) {
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
                  outfit.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: outfit.isFavorite ? Colors.red : null,
                ),
                title: Text(outfit.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
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
    );
  }

  void _showCreateOutfitDialog() {
    // TODO: Implement outfit creation dialog
    Get.snackbar(
      'Coming Soon',
      'Outfit creation will be available soon',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showDeleteConfirmation(String outfitId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Outfit?'),
        content: const Text('This outfit will be removed from your collection.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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
