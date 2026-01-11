import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/services/notification_service.dart';
import '../controllers/outfit_list_controller.dart';
import '../models/outfit_model.dart';
import '../repositories/outfit_repository.dart';

/// Detail page for a single outfit
class OutfitDetailPage extends StatefulWidget {
  final String outfitId;

  const OutfitDetailPage({
    super.key,
    required this.outfitId,
  });

  @override
  State<OutfitDetailPage> createState() => _OutfitDetailPageState();
}

class _OutfitDetailPageState extends State<OutfitDetailPage> {
  int _currentImageIndex = 0;
  late final PageController _pageController;
  late final OutfitListController _controller;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = Get.find<OutfitListController>();
    _loadOutfit();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadOutfit() async {
    final outfit = _controller.outfits.firstWhereOrNull((o) => o.id == widget.outfitId);
    if (outfit == null) {
      await _controller.fetchOutfitById(widget.outfitId);
    }
  }

  Future<void> _refreshOutfit() async {
    await _controller.refreshOutfitById(widget.outfitId);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Obx(() {
                final outfit = _controller.outfits.firstWhereOrNull((o) => o.id == widget.outfitId);

                // Loading state
                if (outfit == null && _controller.isFetchingSingle.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (outfit == null && _controller.singleFetchError.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacing24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: tokens.textMuted),
                          const SizedBox(height: AppConstants.spacing16),
                          Text(
                            'Failed to load outfit',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing8),
                          Text(
                            _controller.singleFetchError.value,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.spacing16),
                          ElevatedButton.icon(
                            onPressed: () => _controller.fetchOutfitById(widget.outfitId),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Not found state
                if (outfit == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: tokens.textMuted),
                        const SizedBox(height: AppConstants.spacing16),
                        Text(
                          'Outfit not found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing16),
                        TextButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                // Success state with RefreshIndicator
                return RefreshIndicator(
                  onRefresh: _refreshOutfit,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Image header with carousel
                      _buildImageHeader(outfit, tokens),

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
                                  Obx(() => _controller.isFavoriting(outfit.id)
                                      ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: Padding(
                                            padding: EdgeInsets.all(4),
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () => _controller.toggleFavorite(outfit.id),
                                          icon: Icon(
                                            outfit.isFavorite ? Icons.favorite : Icons.favorite_border,
                                            color: outfit.isFavorite ? Colors.red : null,
                                            size: 28,
                                          ),
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
                                          _shareOutfit(outfit);
                                          break;
                                        case 'duplicate':
                                          _controller.duplicateOutfit(outfit.id);
                                          break;
                                        case 'delete':
                                          _showDeleteDialog(outfit);
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
                              _buildItemsSection(context, outfit, tokens),

                              const SizedBox(height: AppConstants.spacing24),

                              // Stats section
                              _buildStatsSection(context, outfit, tokens),

                              const SizedBox(height: AppConstants.spacing24),

                              // Wear history section
                              _buildWearHistorySection(context, outfit, tokens),

                              const SizedBox(height: AppConstants.spacing24),

                              // Information section
                              _buildInformationSection(context, outfit, tokens),

                              const SizedBox(height: 100), // Space for bottom action bar
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(tokens),
    );
  }

  Widget _buildImageHeader(OutfitModel outfit, AppUiTokens tokens) {
    final hasImages = outfit.outfitImages != null && outfit.outfitImages!.isNotEmpty;
    final imageUrls = hasImages
        ? outfit.outfitImages!.map((img) => img.url).toList()
        : <String>[];
    final hasMultipleImages = imageUrls.length > 1;

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
              ? Stack(
                  children: [
                    // Image carousel
                    PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return AppImage(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.contain,
                          backgroundColor: tokens.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          enableZoom: true,
                          galleryUrls: imageUrls,
                          initialGalleryIndex: index,
                        );
                      },
                    ),
                    // Page indicator
                    if (hasMultipleImages)
                      Positioned(
                        bottom: AppConstants.spacing16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageUrls.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentImageIndex
                                    ? tokens.brandColor
                                    : tokens.textMuted.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Center(
                  child: Icon(
                    Icons.checkroom,
                    size: 64,
                    color: tokens.textMuted,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, OutfitModel outfit, AppUiTokens tokens) {
    final items = outfit.items ?? [];
    final itemCount = items.isNotEmpty ? items.length : outfit.itemIds.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items ($itemCount)',
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
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // Use actual item data if available
              if (index < items.length) {
                final item = items[index];
                final hasImage = item.itemImages != null && item.itemImages!.isNotEmpty;
                final imageUrl = hasImage ? item.itemImages!.first.url : null;

                return GestureDetector(
                  onTap: () => Get.toNamed('/wardrobe/${item.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                      border: Border.all(color: tokens.cardBorderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasImage && imageUrl != null
                        ? AppImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            enableZoom: false,
                          )
                        : Center(
                            child: Icon(
                              Icons.checkroom,
                              color: tokens.textMuted,
                            ),
                          ),
                  ),
                );
              }

              // Fallback placeholder for items without data
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

  Widget _buildStatsSection(BuildContext context, OutfitModel outfit, AppUiTokens tokens) {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wear History',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
            ),
            if (outfit.wornCount > 0)
              Text(
                '${outfit.wornCount} times',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing12),
        Obx(() {
          final history = _controller.wearHistoryCache[outfit.id] ?? [];
          final isLoading = _controller.isLoadingWearHistory.value;

          if (outfit.wornCount == 0) {
            return AppGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Row(
                  children: [
                    Icon(Icons.history, color: tokens.textMuted),
                    const SizedBox(width: AppConstants.spacing12),
                    Text(
                      'No wear history yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (isLoading && history.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.spacing16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (history.isEmpty) {
            // Load history if not cached
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.fetchWearHistory(outfit.id);
            });
            return const SizedBox.shrink();
          }

          return AppGlassCard(
            child: Column(
              children: [
                for (int i = 0; i < history.length && i < 5; i++)
                  _buildWearHistoryItem(context, history[i], tokens, isLast: i == history.length - 1 || i == 4),
                if (history.length > 5)
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing12),
                    child: TextButton(
                      onPressed: () => _showFullWearHistory(context, history, tokens),
                      child: Text('View all ${history.length} entries'),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWearHistoryItem(BuildContext context, WearHistoryEntry entry, AppUiTokens tokens, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
            vertical: AppConstants.spacing12,
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.brandColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatWearDate(entry.wornAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      _formatDate(entry.wornAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.checkroom, color: tokens.textMuted, size: 16),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 36, color: tokens.cardBorderColor),
      ],
    );
  }

  String _formatWearDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showFullWearHistory(BuildContext context, List<WearHistoryEntry> history, AppUiTokens tokens) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Full Wear History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: tokens.cardBorderColor),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) => _buildWearHistoryItem(
                  context,
                  history[index],
                  tokens,
                  isLast: index == history.length - 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationSection(BuildContext context, OutfitModel outfit, AppUiTokens tokens) {
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
        child: Obx(() => ElevatedButton.icon(
          onPressed: _controller.isMarkingWorn(widget.outfitId)
              ? null
              : () => _controller.markAsWorn(widget.outfitId),
          icon: _controller.isMarkingWorn(widget.outfitId)
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.checkroom),
          label: Text(_controller.isMarkingWorn(widget.outfitId) ? 'Marking...' : 'Mark as Worn'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        )),
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

  void _shareOutfit(OutfitModel outfit) async {
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Get share URL from API
      final repository = OutfitRepository();
      final shareUrl = await repository.shareOutfit(outfit.id);

      // Prepare share text
      final shareText = 'Check out my outfit "${outfit.name}" on FitCheck AI!\n\n$shareUrl';

      // Check if outfit has images
      final hasImages = outfit.outfitImages != null && outfit.outfitImages!.isNotEmpty;

      if (hasImages) {
        final imageUrl = outfit.outfitImages!.first.url;

        try {
          // Download image to temp file using Dio
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/outfit_share_${outfit.id}.png');

          final dio = Dio();
          await dio.download(imageUrl, tempFile.path);

          // Close loading dialog
          Get.back();

          // Share with image
          await Share.shareXFiles(
            [XFile(tempFile.path)],
            text: shareText,
            subject: 'Check out my outfit!',
          );

          // Clean up temp file
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          // Fallback to text-only if image download fails
          Get.back();
          await Share.share(shareText, subject: 'Check out my outfit!');
        }
      } else {
        // No image, share text only
        Get.back();
        await Share.share(shareText, subject: 'Check out my outfit!');
      }
    } catch (e) {
      Get.back();
      NotificationService.instance.showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void _showDeleteDialog(OutfitModel outfit) {
    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('Delete Outfit?'),
        content: Text('Are you sure you want to delete "${outfit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: _controller.isDeleting(outfit.id) ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _controller.isDeleting(outfit.id) ? null : () async {
              try {
                await _controller.deleteOutfit(outfit.id);
                Get.back();
                Get.back();
              } catch (e) {
                // Error already shown by controller
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).colorScheme.error,
            ),
            child: _controller.isDeleting(outfit.id)
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Delete'),
          ),
        ],
      )),
      barrierDismissible: false,
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
