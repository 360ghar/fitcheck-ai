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
          // Photo grid
          Obx(() => _buildPhotoGrid(context, tokens)),

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

  Widget _buildPhotoGrid(BuildContext context, AppUiTokens tokens) {
    final photos = controller.selectedPhotos;
    final maxPhotos = PhotoshootController.maxPhotos;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacing12,
        mainAxisSpacing: AppConstants.spacing12,
        childAspectRatio: 1,
      ),
      itemCount: maxPhotos,
      itemBuilder: (context, index) {
        final hasPhoto = index < photos.length;

        return AppGlassCard(
          padding: EdgeInsets.zero,
          child: hasPhoto
              ? _buildPhotoTile(context, tokens, photos[index], index)
              : _buildEmptyTile(context, tokens, index),
        );
      },
    );
  }

  Widget _buildPhotoTile(
    BuildContext context,
    AppUiTokens tokens,
    File photo,
    int index,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          child: Image.file(
            photo,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => controller.removePhoto(index),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTile(BuildContext context, AppUiTokens tokens, int index) {
    return InkWell(
      onTap: controller.pickPhotos,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 32,
            color: tokens.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Photo ${index + 1}',
            style: TextStyle(
              fontSize: 12,
              color: tokens.textMuted.withOpacity(0.5),
            ),
          ),
        ],
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
