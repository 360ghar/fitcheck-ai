import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/batch_extraction_controller.dart';
import '../widgets/batch_image_tile.dart';

/// Page for selecting multiple images for batch extraction
class BatchImageSelectorPage extends GetView<BatchExtractionController> {
  const BatchImageSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              'Select Images (${controller.selectedImages.length}/${BatchExtractionController.maxImages})',
            )),
        elevation: 0,
        actions: [
          Obx(() => controller.selectedImages.isNotEmpty
              ? TextButton(
                  onPressed: controller.clearAllImages,
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: tokens.textMuted),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Image grid
              Expanded(
                child: Obx(() {
                  if (controller.selectedImages.isEmpty) {
                    return _buildEmptyState(context, tokens);
                  }
                  return _buildImageGrid(context, tokens);
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

  Widget _buildEmptyState(BuildContext context, AppUiTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tokens.brandColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.collections_outlined,
                size: 40,
                color: tokens.brandColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'No Images Selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Select up to ${BatchExtractionController.maxImages} images to extract clothing items',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAddButton(
                  context,
                  tokens,
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: controller.pickFromGallery,
                ),
                const SizedBox(width: AppConstants.spacing16),
                _buildAddButton(
                  context,
                  tokens,
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: controller.pickFromCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    AppUiTokens tokens, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing20,
          vertical: AppConstants.spacing16,
        ),
        decoration: BoxDecoration(
          color: tokens.brandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(color: tokens.brandColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: tokens.brandColor, size: 28),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: TextStyle(
                color: tokens.brandColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, AppUiTokens tokens) {
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppConstants.spacing8,
            mainAxisSpacing: AppConstants.spacing8,
          ),
          itemCount: controller.selectedImages.length + 1, // +1 for add button
          itemBuilder: (context, index) {
            // Last item is the add button
            if (index == controller.selectedImages.length) {
              return _buildAddMoreTile(context, tokens);
            }

            final image = controller.selectedImages[index];
            return BatchImageTile(
              image: image,
              onRemove: () => controller.removeImage(image.id),
              showStatus: false,
            );
          },
        ));
  }

  Widget _buildAddMoreTile(BuildContext context, AppUiTokens tokens) {
    return Obx(() {
      if (controller.remainingSlots.value <= 0) {
        return const SizedBox.shrink();
      }

      return InkWell(
        onTap: () => _showAddImageOptions(context, tokens),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: Container(
          decoration: BoxDecoration(
            color: tokens.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            border: Border.all(
              color: tokens.cardBorderColor,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: tokens.textMuted,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Add',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showAddImageOptions(BuildContext context, AppUiTokens tokens) {
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius16),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppConstants.spacing16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            ListTile(
              leading: Icon(Icons.photo_library_outlined,
                  color: tokens.brandColor),
              title: Text('Choose from Gallery',
                  style: TextStyle(color: tokens.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                controller.pickFromGallery();
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.camera_alt_outlined, color: tokens.brandColor),
              title: Text('Take Photo',
                  style: TextStyle(color: tokens.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                controller.pickFromCamera();
              },
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],
        ),
      ),
    );
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
        final hasImages = controller.selectedImages.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info text
            if (hasImages)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        'AI will detect clothing items from each image',
                        style: TextStyle(
                          color: tokens.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasImages ? _startExtraction : null,
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
                  hasImages
                      ? 'Extract Items (${controller.selectedImages.length} ${controller.selectedImages.length == 1 ? 'image' : 'images'})'
                      : 'Select Images to Continue',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _startExtraction() {
    controller.startExtraction();
    Get.toNamed(Routes.wardrobeBatchProgress);
  }
}
