import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart';
import '../controllers/wardrobe_controller.dart';
import '../models/item_model.dart';

/// Detail page for a single wardrobe item
class ItemDetailPage extends StatelessWidget {
  final String itemId;

  const ItemDetailPage({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final WardrobeController wardrobeController = Get.find<WardrobeController>();

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Content
              Obx(() {
                final item = wardrobeController.items.firstWhereOrNull(
                  (i) => i.id == itemId,
                );

                if (item == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CustomScrollView(
                  slivers: [
                    // Image header
                    _buildImageHeader(item, tokens),

                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and favorite
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: tokens.textPrimary,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: wardrobeController.isFavoriting(item.id)
                                      ? null
                                      : () => wardrobeController.toggleFavorite(item.id),
                                  icon: wardrobeController.isFavoriting(item.id)
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: item.isFavorite ? Colors.red : null,
                                          size: 28,
                                        ),
                                ),
                              ],
                            ),

                            if (item.description != null) ...[
                              const SizedBox(height: AppConstants.spacing8),
                              Text(
                                item.description!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: tokens.textMuted,
                                    ),
                              ),
                            ],

                            const SizedBox(height: AppConstants.spacing16),

                            // Category and condition
                            Wrap(
                              spacing: AppConstants.spacing8,
                              runSpacing: AppConstants.spacing8,
                              children: [
                                _buildChip(context, item.category.displayName, tokens),
                                _buildChip(context, item.condition.displayName, tokens),
                                if (item.brand != null) _buildChip(context, item.brand!, tokens),
                                if (item.size != null)
                                  _buildChip(context, 'Size: ${item.size!}', tokens),
                              ],
                            ),

                            if (item.colors != null && item.colors!.isNotEmpty) ...[
                              const SizedBox(height: AppConstants.spacing16),
                              Text(
                                'Colors',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: tokens.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppConstants.spacing8),
                              Wrap(
                                spacing: AppConstants.spacing8,
                                runSpacing: AppConstants.spacing8,
                                children: item.colors!
                                    .map((color) => _buildChip(context, color, tokens))
                                    .toList(),
                              ),
                            ],

                            const SizedBox(height: AppConstants.spacing24),

                            // Details section
                            _buildDetailsSection(context, item, tokens),

                            const SizedBox(height: AppConstants.spacing24),

                            // Stats section
                            _buildStatsSection(context, item, tokens, wardrobeController),

                            const SizedBox(height: AppConstants.spacing24),

                            // Tags section
                            if (item.tags != null && item.tags!.isNotEmpty) ...[
                              Text(
                                'Tags',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: tokens.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppConstants.spacing8),
                              Wrap(
                                spacing: AppConstants.spacing8,
                                runSpacing: AppConstants.spacing8,
                                children: item.tags!.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor: tokens.brandColor.withOpacity(0.1),
                                    labelStyle: TextStyle(color: tokens.brandColor),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: AppConstants.spacing24),
                            ],

                            // Metadata
                            _buildMetadataSection(context, item, tokens),

                            const SizedBox(height: 100), // Space for bottom actions
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Back button
              Positioned(
                top: AppConstants.spacing8,
                left: AppConstants.spacing8,
                child: Container(
                  decoration: BoxDecoration(
                    color: tokens.cardColor.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),

              // Bottom action bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomActionBar(context, tokens),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(ItemModel item, AppUiTokens tokens) {
    final hasImages = item.itemImages != null && item.itemImages!.isNotEmpty;
    final imageUrls = hasImages
        ? item.itemImages!.map((img) => img.url).toList()
        : <String>[];

    return SliverAppBar(
      expandedHeight: 350,
      pinned: false,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: tokens.isDarkMode
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
          child: hasImages
              ? AppImage(
                  imageUrl: imageUrls.first,
                  fit: BoxFit.contain,
                  backgroundColor: tokens.isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  enableZoom: true,
                  galleryUrls: imageUrls,
                  errorIcon: _getCategoryIcon(item.category),
                )
              : Center(
                  child: Icon(
                    _getCategoryIcon(item.category),
                    size: 64,
                    color: tokens.textMuted,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    ItemModel item,
    AppUiTokens tokens,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        AppGlassCard(
          child: Column(
            children: [
              if (item.material != null)
                _buildDetailRow(context, 'Material', item.material!, tokens),
              if (item.pattern != null)
                _buildDetailRow(context, 'Pattern', item.pattern!, tokens),
              if (item.location != null)
                _buildDetailRow(context, 'Location', item.location!, tokens),
              if (item.price != null)
                _buildDetailRow(
                  context,
                  'Price',
                  '\$${item.price!.toStringAsFixed(2)}',
                  tokens,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    AppUiTokens tokens,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    ItemModel item,
    AppUiTokens tokens,
    WardrobeController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage Stats',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        AppGlassCard(
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Times Worn',
                  '${item.wornCount}',
                  Icons.checkroom,
                  tokens,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: tokens.cardBorderColor,
              ),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Last Worn',
                  item.lastWornAt != null
                      ? _formatDate(item.lastWornAt!)
                      : 'Never',
                  Icons.calendar_today,
                  tokens,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    AppUiTokens tokens,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        children: [
          Icon(icon, color: tokens.brandColor, size: 20),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(
    BuildContext context,
    ItemModel item,
    AppUiTokens tokens,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Information',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        AppGlassCard(
          child: Column(
            children: [
              if (item.purchaseDate != null)
                _buildDetailRow(context, 'Purchased', _formatDate(item.purchaseDate!), tokens),
              if (item.createdAt != null)
                _buildDetailRow(context, 'Added', _formatDate(item.createdAt!), tokens),
              if (item.updatedAt != null)
                _buildDetailRow(context, 'Updated', _formatDate(item.updatedAt!), tokens),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, AppUiTokens tokens) {
    final WardrobeController controller = Get.find<WardrobeController>();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to edit page
                  Get.toNamed('/wardrobe/$itemId/edit');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isMarkingWorn(itemId)
                    ? null
                    : () => controller.markAsWorn(itemId),
                icon: controller.isMarkingWorn(itemId)
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.checkroom),
                label: Text(controller.isMarkingWorn(itemId) ? 'Marking...' : 'Mark Worn'),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing12,
        vertical: AppConstants.spacing6,
      ),
      decoration: BoxDecoration(
        color: tokens.brandColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(color: tokens.brandColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.brandColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} months ago';
    return '${(difference.inDays / 365).floor()} years ago';
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
