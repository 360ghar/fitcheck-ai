import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';

/// Step 1: Photo upload
class PhotoshootUploadStep extends GetView<PhotoshootController> {
  const PhotoshootUploadStep({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo upload area - conditional based on selection
          Obx(() {
            final photos = controller.selectedPhotos;
            if (photos.isEmpty) {
              return _buildUploadPlaceholder(context, tokens);
            }
            return _buildPhotoPreview(context, tokens);
          }),

          const SizedBox(height: AppConstants.spacing24),

          // Add photo buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickPhotos,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Tips
          AppGlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: tokens.brandColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tips for best results',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTip(context, tokens, '• Clear, well-lit face photos'),
                _buildTip(context, tokens, '• Multiple angles work better'),
                _buildTip(context, tokens, '• Avoid sunglasses or face obstructions'),
                _buildTip(context, tokens, '• Higher quality = better results'),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacing24),

          // Next button
          Obx(() => ElevatedButton(
                onPressed:
                    controller.selectedPhotos.isNotEmpty ? controller.nextStep : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  controller.selectedPhotos.isEmpty
                      ? 'Add Photos to Continue'
                      : 'Continue (${controller.selectedPhotos.length} photos)',
                ),
              )),
        ],
      ),
    );
  }

  /// Compact upload placeholder shown when no photos selected
  Widget _buildUploadPlaceholder(BuildContext context, AppUiTokens tokens) {
    return InkWell(
      onTap: controller.pickPhotos,
      borderRadius: BorderRadius.circular(AppConstants.radius16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          border: Border.all(
            color: tokens.textMuted.withOpacity(0.3),
            width: 2,
          ),
          color: tokens.cardColor.withOpacity(0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: tokens.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Upload 1-4 photos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select from gallery',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal photo preview shown when photos are selected
  Widget _buildPhotoPreview(BuildContext context, AppUiTokens tokens) {
    final photos = controller.selectedPhotos;
    final canAddMore = photos.length < PhotoshootController.maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count indicator
        Text(
          '${photos.length}/${PhotoshootController.maxPhotos} photos',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textMuted,
              ),
        ),
        const SizedBox(height: 8),
        // Horizontal scrollable thumbnails
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length + (canAddMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index < photos.length) {
                return _buildThumbnail(context, tokens, photos[index], index);
              }
              return _buildAddMoreTile(context, tokens);
            },
          ),
        ),
      ],
    );
  }

  /// Individual photo thumbnail with remove button
  Widget _buildThumbnail(
    BuildContext context,
    AppUiTokens tokens,
    File photo,
    int index,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          child: Image.file(
            photo,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  /// Add more photos tile
  Widget _buildAddMoreTile(BuildContext context, AppUiTokens tokens) {
    return InkWell(
      onTap: controller.pickPhotos,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(color: tokens.cardBorderColor),
          color: tokens.cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: tokens.textMuted, size: 28),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(fontSize: 12, color: tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, AppUiTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.textMuted,
            ),
      ),
    );
  }
}
