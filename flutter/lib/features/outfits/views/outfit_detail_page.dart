import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../controllers/outfit_controller.dart';
import '../models/outfit_model.dart';

/// Detail page for a single outfit
class OutfitDetailPage extends StatelessWidget {
  final String outfitId;

  const OutfitDetailPage({
    super.key,
    required this.outfitId,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final OutfitsController controller = Get.find<OutfitsController>();

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: Obx(() {
            final outfit = controller.outfits.firstWhereOrNull((o) => o.id == outfitId);

            if (outfit == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // Image header
                _buildImageHeader(outfit, tokens, controller),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and actions
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                outfit.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: tokens.textPrimary,
                                    ),
                              ),
                            ),
                            // Favorite button
                            IconButton(
                              onPressed: () => controller.toggleFavorite(outfit.id),
                              icon: Icon(
                                outfit.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: outfit.isFavorite ? Colors.red : null,
                                size: 28,
                              ),
                            ),
                            // More options
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    Get.toNamed('/outfits/${outfit.id}/edit');
                                    break;
                                  case 'share':
                                    _shareOutfit(outfit, controller);
                                    break;
                                  case 'duplicate':
                                    controller.duplicateOutfit(outfit.id);
                                    break;
                                  case 'delete':
                                    _showDeleteDialog(outfit, controller);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: AppConstants.spacing8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share),
                                      SizedBox(width: AppConstants.spacing8),
                                      Text('Share'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy),
                                      SizedBox(width: AppConstants.spacing8),
                                      Text('Duplicate'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: AppConstants.spacing8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        if (outfit.description != null) ...[
                          const SizedBox(height: AppConstants.spacing8),
                          Text(
                            outfit.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: tokens.textMuted,
                                ),
                          ),
                        ],

                        const SizedBox(height: AppConstants.spacing16),

                        // Tags row
                        Wrap(
                          spacing: AppConstants.spacing8,
                          runSpacing: AppConstants.spacing8,
                          children: [
                            if (outfit.style != null)
                              _buildChip(context, outfit.style!.displayName, tokens),
                            if (outfit.season != null)
                              _buildChip(context, outfit.season!.displayName, tokens),
                            if (outfit.occasion != null)
                              _buildChip(context, outfit.occasion!, tokens),
                          ],
                        ),

                        const SizedBox(height: AppConstants.spacing24),

                        // Items section
                        _buildItemsSection(context, outfit, tokens, controller),

                        const SizedBox(height: AppConstants.spacing24),

                        // Stats section
                        _buildStatsSection(context, outfit, tokens, controller),

                        const SizedBox(height: AppConstants.spacing24),

                        // Wear history
                        _buildWearHistorySection(context, outfit, tokens),

                        const SizedBox(height: 100), // Space for bottom action bar
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(tokens),
    );
  }

  Widget _buildImageHeader(OutfitModel outfit, AppUiTokens tokens, OutfitsController controller) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: outfit.outfitImages != null && outfit.outfitImages!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: outfit.outfitImages!.first.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: tokens.cardColor,
                ),
                errorWidget: (context, url, error) => Container(
                  color: tokens.cardColor,
                  child: Icon(
                    Icons.checkroom,
                    size: 64,
                    color: tokens.textMuted,
                  ),
                ),
              )
            : Container(
                color: tokens.cardColor,
                child: Icon(
                  Icons.checkroom,
                  size: 64,
                  color: tokens.textMuted,
                ),
              ),
      ),
    );

    // Back button is handled by Scaffold automatically
    // but we could add custom overlay buttons here if needed
  }

  Widget _buildItemsSection(BuildContext context, OutfitModel outfit, AppUiTokens tokens, OutfitsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${outfit.itemIds.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacing12),
        AppGlassCard(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppConstants.spacing8,
              crossAxisSpacing: AppConstants.spacing8,
              childAspectRatio: 0.75,
            ),
            itemCount: outfit.itemIds.length,
            itemBuilder: (context, index) {
              // In a real app, you'd fetch the actual item details
              // For now, showing placeholder
              return Container(
                decoration: BoxDecoration(
                  color: tokens.cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                  border: Border.all(color: tokens.cardBorderColor),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    color: tokens.textMuted,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, OutfitModel outfit, AppUiTokens tokens, OutfitsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stats',
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
                  '${outfit.wornCount}',
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
                  outfit.lastWornAt != null
                      ? _formatDate(outfit.lastWornAt!)
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

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, AppUiTokens tokens) {
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

  Widget _buildWearHistorySection(BuildContext context, OutfitModel outfit, AppUiTokens tokens) {
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
              if (outfit.createdAt != null)
                _buildDetailRow(context, 'Created', _formatDate(outfit.createdAt!), tokens),
              if (outfit.updatedAt != null)
                _buildDetailRow(context, 'Updated', _formatDate(outfit.updatedAt!), tokens),
              _buildDetailRow(
                context,
                'Status',
                outfit.isDraft ? 'Draft' : outfit.isPublic ? 'Public' : 'Private',
                tokens,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, AppUiTokens tokens) {
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

  Widget _buildBottomActionBar(AppUiTokens tokens) {
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
        child: ElevatedButton.icon(
          onPressed: () {
            final OutfitsController controller = Get.find<OutfitsController>();
            controller.markAsWorn(outfitId);
          },
          icon: const Icon(Icons.checkroom),
          label: const Text('Mark as Worn'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
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

  void _shareOutfit(OutfitModel outfit, OutfitsController controller) async {
    // Generate share link
    // For now, just share the text
    final text = 'Check out my outfit "${outfit.name}" on FitCheck AI!';
    await Share.share(text);
  }

  void _showDeleteDialog(OutfitModel outfit, OutfitsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Outfit?'),
        content: Text('Are you sure you want to delete "${outfit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await controller.deleteOutfit(outfit.id);
                Get.back();
                Get.snackbar(
                  'Deleted',
                  'Outfit removed successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  e.toString().replaceAll('Exception: ', ''),
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
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
}
