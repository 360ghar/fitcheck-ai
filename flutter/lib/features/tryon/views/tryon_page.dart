import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/tryon_controller.dart';

/// Try-On Page - Virtual try-on feature
/// Allows users to upload clothing and visualize it on their avatar
class TryOnPage extends StatelessWidget {
  const TryOnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final TryOnController controller = Get.find<TryOnController>();
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Virtual Try-On',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                ),

                const SizedBox(height: AppConstants.spacing8),

                Text(
                  'See how clothes look on you',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                Obx(() {
                  if (controller.error.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      AppGlassCard(
                        padding: const EdgeInsets.all(AppConstants.spacing16),
                        child: Text(
                          controller.error.value,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: tokens.textMuted,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                    ],
                  );
                }),

                // Avatar upload section
                _buildAvatarSection(context, controller, tokens),

                const SizedBox(height: AppConstants.spacing24),

                // Clothing upload section
                _buildClothingSection(context, controller, tokens),

                const SizedBox(height: AppConstants.spacing24),

                // Options section
                _buildOptionsSection(context, controller, tokens),

                const SizedBox(height: AppConstants.spacing24),

                // Preview/Result section
                _buildPreviewSection(context, controller, tokens),

                const SizedBox(height: AppConstants.spacing32),

                // Generate button
                Obx(() => ElevatedButton.icon(
                      onPressed: controller.isGenerating.value ||
                              controller.clothingImage.value == null
                          ? null
                          : () => controller.generateTryOn(),
                      icon: controller.isGenerating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        controller.isGenerating.value
                            ? 'Generating...'
                            : 'Generate Try-On',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    )),

                if (controller.generatedImageUrl.value.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing16),
                  OutlinedButton.icon(
                    onPressed: controller.downloadResult,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAvatarSection(
    BuildContext context,
    TryOnController controller,
    AppUiTokens tokens,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Avatar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: [
              Obx(() {
                final avatarPath = controller.userAvatarUrl.value;
                final hasAvatar = avatarPath.isNotEmpty;
                final isRemote = avatarPath.startsWith('http');
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: tokens.brandColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: hasAvatar
                      ? ClipOval(
                          child: isRemote
                              ? Image.network(avatarPath, fit: BoxFit.cover)
                              : Image.file(
                                  File(avatarPath),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: tokens.brandColor,
                        ),
                );
              }),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload a full-body photo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Obx(() => ElevatedButton.icon(
                          onPressed: controller.isUploadingAvatar.value
                              ? null
                              : () => controller.uploadUserAvatar(),
                          icon: controller.isUploadingAvatar.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt),
                          label: Text(
                            controller.isUploadingAvatar.value ? 'Uploading...' : 'Upload Avatar',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(36),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClothingSection(
    BuildContext context,
    TryOnController controller,
    AppUiTokens tokens,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clothing Item',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Obx(() {
            final image = controller.clothingImage.value;
            if (image == null) {
              return Row(
                children: [
                  Expanded(
                    child: _buildUploadOption(
                      context: context,
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: controller.pickClothingImage,
                      tokens: tokens,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: _buildUploadOption(
                      context: context,
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: controller.pickClothingFromCamera,
                      tokens: tokens,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                  child: Image.file(
                    image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                OutlinedButton.icon(
                  onPressed: controller.reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Change Image'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUploadOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppUiTokens tokens,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.cardBorderColor),
          borderRadius: BorderRadius.circular(AppConstants.radius12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: tokens.brandColor),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(
    BuildContext context,
    TryOnController controller,
    AppUiTokens tokens,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Style dropdown
          Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedStyle.value,
                decoration: InputDecoration(
                  labelText: 'Style',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                ),
                items: TryOnController.styles.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(style.split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.selectedStyle.value = value;
                },
              )),

          const SizedBox(height: AppConstants.spacing12),

          // Background dropdown
          Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedBackground.value,
                decoration: InputDecoration(
                  labelText: 'Background',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                ),
                items: TryOnController.backgrounds.map((bg) {
                  return DropdownMenuItem(
                    value: bg,
                    child: Text(bg.split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.selectedBackground.value = value;
                },
              )),

          const SizedBox(height: AppConstants.spacing12),

          // Pose dropdown
          Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedPose.value,
                decoration: InputDecoration(
                  labelText: 'Pose',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                ),
                items: TryOnController.poses.map((pose) {
                  return DropdownMenuItem(
                    value: pose,
                    child: Text(pose.split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.selectedPose.value = value;
                },
              )),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(
    BuildContext context,
    TryOnController controller,
    AppUiTokens tokens,
  ) {
    return Obx(() {
      if (controller.generatedImageUrl.value.isEmpty &&
          controller.generatedImageBase64.value.isEmpty) {
        return AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing32),
          child: Column(
            children: [
              Icon(
                Icons.image_outlined,
                size: 64,
                color: tokens.textMuted,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Generated image will appear here',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ],
          ),
        );
      }

      if (controller.generatedImageUrl.value.isEmpty &&
          controller.generatedImageBase64.value.isNotEmpty) {
        return AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            child: Image.memory(
              base64Decode(controller.generatedImageBase64.value),
              fit: BoxFit.cover,
            ),
          ),
        );
      }

      return AppGlassCard(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          child: Image.network(
            controller.generatedImageUrl.value,
            fit: BoxFit.cover,
          ),
        ),
      );
    });
  }
}
