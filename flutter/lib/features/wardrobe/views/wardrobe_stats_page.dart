import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../controllers/wardrobe_controller.dart';
import '../repositories/item_repository.dart';

/// Wardrobe statistics dashboard page
/// Shows insights about the user's wardrobe including totals, categories, value, etc.
class WardrobeStatsPage extends StatefulWidget {
  const WardrobeStatsPage({super.key});

  @override
  State<WardrobeStatsPage> createState() => _WardrobeStatsPageState();
}

class _WardrobeStatsPageState extends State<WardrobeStatsPage> {
  final WardrobeController wardrobeController = Get.find<WardrobeController>();
  final ItemRepository _itemRepository = ItemRepository();

  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      isLoading.value = true;
      error.value = '';
      final statistics = await _itemRepository.getStatistics();
      stats.value = statistics;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStats,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  sliver: Obx(() {
                    if (isLoading.value) {
                      return _buildLoadingStats();
                    }

                    if (error.value.isNotEmpty) {
                      return _buildErrorState();
                    }

                    return _buildStatsContent();
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAppBar() {
    final tokens = AppUiTokens.of(context);

    return SliverAppBar(
      floating: true,
      elevation: 0,
      title: Text(
        'Wardrobe Stats',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStats,
        ),
      ],
    );
  }

  Widget _buildLoadingStats() {
    final tokens = AppUiTokens.of(context);

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildStatCardShimmer(tokens),
        const SizedBox(height: AppConstants.spacing12),
        _buildStatCardShimmer(tokens),
        const SizedBox(height: AppConstants.spacing12),
        _buildStatCardShimmer(tokens),
      ]),
    );
  }

  Widget _buildStatCardShimmer(AppUiTokens tokens) {
    return Shimmer.fromColors(
      baseColor: tokens.cardColor.withOpacity(0.4),
      highlightColor: tokens.cardColor.withOpacity(0.7),
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: tokens.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(color: tokens.cardBorderColor),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final tokens = AppUiTokens.of(context);

    return SliverFillRemaining(
      child: Center(
        child: AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: tokens.textMuted,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Failed to load stats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                error.value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing24),
              ElevatedButton.icon(
                onPressed: _loadStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    final statistics = stats.value;
    final itemsByCategory = statistics['items_by_category'] as Map<String, dynamic>? ?? {};
    final totalValue = (statistics['total_value'] as num?)?.toDouble() ?? 0.0;
    final mostWorn = statistics['most_worn_items'] as List? ?? [];
    final leastWorn = statistics['least_worn_items'] as List? ?? [];
    // Use server-derived total for consistency with itemsByCategory
    final totalItems = (statistics['total_items'] as int?) ??
        itemsByCategory.values.fold<int>(0, (sum, count) => sum + ((count as int?) ?? 0));

    return SliverList(
      delegate: SliverChildListDelegate([
        // Total Items Card
        _buildTotalItemsCard(totalItems, itemsByCategory),

        const SizedBox(height: AppConstants.spacing12),

        // Wardrobe Value Card
        _buildValueCard(totalValue),

        const SizedBox(height: AppConstants.spacing12),

        // Category Breakdown
        _buildCategoryBreakdown(itemsByCategory, totalItems),

        const SizedBox(height: AppConstants.spacing12),

        // Most Worn Items
        if (mostWorn.isNotEmpty) _buildItemsList('Most Worn', mostWorn, Icons.trending_up),

        const SizedBox(height: AppConstants.spacing12),

        // Least Worn Items
        if (leastWorn.isNotEmpty) _buildItemsList('Least Worn', leastWorn, Icons.trending_down),

        const SizedBox(height: AppConstants.spacing64), // Bottom padding
      ]),
    );
  }

  Widget _buildTotalItemsCard(int totalItems, Map<String, dynamic> itemsByCategory) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.textSecondary,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing6,
                ),
                decoration: BoxDecoration(
                  color: tokens.brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radius16),
                ),
                child: Text(
                  '$totalItems',
                  style: TextStyle(
                    color: tokens.brandColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Wrap(
            spacing: AppConstants.spacing8,
            runSpacing: AppConstants.spacing8,
            children: Category.values.map((category) {
              final count = itemsByCategory[category.displayName] as int? ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return _buildCategoryChip(category, count, tokens);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Category category, int count, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing12,
        vertical: AppConstants.spacing8,
      ),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 16,
            color: tokens.textMuted,
          ),
          const SizedBox(width: AppConstants.spacing6),
          Text(
            category.displayName,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AppConstants.spacing4),
          Text(
            '×$count',
            style: TextStyle(
              color: tokens.brandColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(double totalValue) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radius12),
            ),
            child: Icon(
              Icons.attach_money,
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Value',
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(Map<String, dynamic> itemsByCategory, int totalItems) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          ...Category.values.map((category) {
            final count = itemsByCategory[category.displayName] as int? ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return _buildCategoryBar(category, count, totalItems, tokens);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(Category category, int count, int total, AppUiTokens tokens) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: tokens.textMuted,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '$count (${(percentage * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: tokens.cardColor,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(String title, List items, IconData icon) {
    final tokens = AppUiTokens.of(context);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: tokens.brandColor),
              const SizedBox(width: AppConstants.spacing8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          ...items.take(5).map<Widget>((item) {
            final name = item['name'] as String? ?? 'Unknown';
            final timesWorn = item['times_worn'] as int? ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing8,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.cardColor,
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                    child: Text(
                      '$timesWorn wears',
                      style: TextStyle(
                        color: tokens.brandColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
