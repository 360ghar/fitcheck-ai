import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/batch_extraction_controller.dart';
import '../widgets/extracted_item_card.dart';

/// Page for reviewing and saving extracted items
class BatchItemReviewPage extends GetView<BatchExtractionController> {
  const BatchItemReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Items'),
        elevation: 0,
        actions: [
          Obx(() {
            final allSelected = controller.extractedItems.every(
              (item) => item.isSelected,
            );
            return TextButton(
              onPressed: allSelected
                  ? controller.deselectAllItems
                  : controller.selectAllItems,
              child: Text(
                allSelected ? 'Deselect All' : 'Select All',
                style: TextStyle(color: tokens.brandColor),
              ),
            );
          }),
        ],
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Summary header
              _buildSummaryHeader(context, tokens),

              // Items grid
              Expanded(
                child: Obx(() {
                  if (controller.extractedItems.isEmpty) {
                    return _buildEmptyState(context, tokens);
                  }
                  return _buildItemsGrid(context, tokens);
                }),
              ),

              // Bottom action bar
              _buildBottomBar(context, tokens),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Obx(() {
        final total = controller.extractedItems.length;
        final selected = controller.selectedItemCount;
        final imagesCount = controller.selectedImages.length;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total items from $imagesCount images',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$selected selected to save',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            // Info icon
            IconButton(
              onPressed: () => _showInfoDialog(context, tokens),
              icon: Icon(
                Icons.info_outline,
                color: tokens.textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppUiTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 64,
              color: tokens.textMuted,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'No Items Detected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'We couldn\'t find any clothing items in your images. Try again with different photos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            ElevatedButton(
              onPressed: () {
                controller.reset();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandColor,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, AppUiTokens tokens) {
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.spacing12,
            mainAxisSpacing: AppConstants.spacing12,
            childAspectRatio: 0.65,
          ),
          itemCount: controller.extractedItems.length,
          itemBuilder: (context, index) {
            final item = controller.extractedItems[index];

            // Find source image path
            final sourceImage = controller.selectedImages.firstWhereOrNull(
              (img) => img.id == item.sourceImageId,
            );

            return ExtractedItemCard(
              item: item,
              sourceImagePath: sourceImage?.filePath ?? '',
              isSelected: item.isSelected,
              onToggleSelection: () => controller.toggleItemSelection(item.id),
              onRemove: () => _removeItem(context, tokens, item.id),
            );
          },
        ));
  }

  Widget _buildBottomBar(BuildContext context, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: tokens.navBackground,
        border: Border(
          top: BorderSide(color: tokens.navBorder),
        ),
      ),
      child: Obx(() {
        final selectedCount = controller.selectedItemCount;
        final hasSelection = selectedCount > 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelection ? () => _saveItems(context, tokens) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                ),
                child: Text(
                  hasSelection
                      ? 'Save $selectedCount ${selectedCount == 1 ? 'Item' : 'Items'}'
                      : 'Select Items to Save',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacing8),

            // Cancel button
            TextButton(
              onPressed: () => _showDiscardConfirmation(context, tokens),
              child: Text(
                'Discard All',
                style: TextStyle(color: tokens.textMuted),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _removeItem(BuildContext context, AppUiTokens tokens, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Text(
          'Remove Item?',
          style: TextStyle(color: tokens.textPrimary),
        ),
        content: Text(
          'This item will not be saved to your wardrobe.',
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: tokens.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.extractedItems.removeWhere(
                (item) => item.id == itemId,
              );
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveItems(BuildContext context, AppUiTokens tokens) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
            ),
            const SizedBox(width: AppConstants.spacing16),
            Text(
              'Saving items...',
              style: TextStyle(color: tokens.textPrimary),
            ),
          ],
        ),
      ),
    );

    try {
      final savedItems = await controller.saveSelectedItems();
      Navigator.pop(context); // Close loading dialog

      if (savedItems.isNotEmpty) {
        // Show success and go back to wardrobe
        Get.snackbar(
          'Success',
          '${savedItems.length} items added to your wardrobe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        controller.reset();
        Get.until((route) => route.isFirst);
      } else {
        Get.snackbar(
          'Error',
          'Failed to save items. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to save items: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDiscardConfirmation(BuildContext context, AppUiTokens tokens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Text(
          'Discard All Items?',
          style: TextStyle(color: tokens.textPrimary),
        ),
        content: Text(
          'All detected items will be discarded. This action cannot be undone.',
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: tokens.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.reset();
              Get.until((route) => route.isFirst);
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, AppUiTokens tokens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Text(
          'Review Your Items',
          style: TextStyle(color: tokens.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              tokens,
              Icons.check_box,
              'Select items you want to save',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              tokens,
              Icons.close,
              'Remove items you don\'t need',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              tokens,
              Icons.save,
              'Save selected items to your wardrobe',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: tokens.brandColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    AppUiTokens tokens,
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: tokens.brandColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: tokens.textSecondary),
          ),
        ),
      ],
    );
  }
}
