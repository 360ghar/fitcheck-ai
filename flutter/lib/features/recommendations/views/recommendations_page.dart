import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/models/item_model.dart';
import '../controllers/recommendations_controller.dart';
import '../widgets/find_matches_tab.dart';
import '../widgets/complete_look_tab.dart';
import '../widgets/weather_based_tab.dart';
import '../widgets/shopping_tab.dart';

/// Recommendations page with 4 tabs:
/// 1. Find Matches - Find items that match selected items
/// 2. Complete Look - Generate complete outfit suggestions
/// 3. Weather-Based - Get recommendations based on weather
/// 4. Shopping - Get shopping suggestions for wardrobe gaps
class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final RecommendationsController controller = Get.find<RecommendationsController>();
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar with tabs
              _buildAppBar(context, controller, tokens),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: const [
                    FindMatchesTab(),
                    CompleteLookTab(),
                    WeatherBasedTab(),
                    ShoppingTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAppBar(BuildContext context, RecommendationsController controller, AppUiTokens tokens) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Row(
            children: [
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              const Spacer(),
              Obx(() => IconButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.refreshCurrentTab(),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  )),
            ],
          ),
        ),

        // Tab bar
        TabBar(
          controller: controller.tabController,
          isScrollable: true,
          labelColor: tokens.brandColor,
          unselectedLabelColor: tokens.textMuted,
          indicatorColor: tokens.brandColor,
          tabs: const [
            Tab(text: 'Find Matches', icon: Icon(Icons.search)),
            Tab(text: 'Complete Look', icon: Icon(Icons.checkroom)),
            Tab(text: 'Weather', icon: Icon(Icons.wb_sunny)),
            Tab(text: 'Shopping', icon: Icon(Icons.shopping_bag)),
          ],
        ),
      ],
    );
  }
}

/// Selected items chips widget
class SelectedItemsChips extends StatelessWidget {
  final RxList<ItemModel> selectedItems;
  final Function(ItemModel) onRemove;

  const SelectedItemsChips({
    super.key,
    required this.selectedItems,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Obx(() {
      if (selectedItems.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selectedItems.length,
          itemBuilder: (context, index) {
            final item = selectedItems[index];
            return Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing8),
              child: Chip(
                label: Text(item.name),
                avatar: CircleAvatar(
                  backgroundImage: item.itemImages != null && item.itemImages!.isNotEmpty
                      ? NetworkImage(item.itemImages!.first.url)
                      : null,
                  child: item.itemImages == null || item.itemImages!.isEmpty
                      ? const Icon(Icons.image, size: 16)
                      : null,
                ),
                onDeleted: () => onRemove(item),
                backgroundColor: tokens.brandColor.withOpacity(0.1),
              ),
            );
          },
        ),
      );
    });
  }
}

/// Recommendation card widget
class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const RecommendationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final name = item['name']?.toString() ?? 'Unknown';
    final brand = item['brand']?.toString();
    final category = item['category']?.toString();
    final imageUrl = item['image_url']?.toString();
    final score = item['score'] as num? ?? 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: AppGlassCard(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or placeholder
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radius8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: tokens.cardColor.withOpacity(0.5),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: tokens.cardColor.withOpacity(0.5),
                          child: Icon(
                            _getCategoryIcon(category),
                            color: tokens.textMuted,
                          ),
                        ),
                      )
                    : Container(
                        color: tokens.cardColor.withOpacity(0.5),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: tokens.textMuted,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: AppConstants.spacing8),

            // Match score
            if (score > 0)
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
                  '${(score * 100).toInt()}% Match',
                  style: TextStyle(
                    color: tokens.brandColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: AppConstants.spacing4),

            // Name
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (brand != null) ...[
              const SizedBox(height: AppConstants.spacing4),
              Text(
                brand,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'tops':
        return Icons.checkroom;
      case 'bottoms':
        return Icons.work;
      case 'shoes':
        return Icons.hiking;
      case 'accessories':
        return Icons.shopping_bag;
      case 'outerwear':
        return Icons.dry_cleaning;
      default:
        return Icons.help;
    }
  }
}
