import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/tryon_controller.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/repositories/item_repository.dart';

/// Show full-screen viewer for a File image (local clothing image)
void showFullScreenFileImage(BuildContext context, File imageFile) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Image Viewer',
    barrierColor: Colors.black.withOpacity(0.9),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _FullScreenFileImageViewer(imageFile: imageFile);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Show full-screen viewer for a network image
void showFullScreenNetworkImage(BuildContext context, String imageUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Image Viewer',
    barrierColor: Colors.black.withOpacity(0.9),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _FullScreenNetworkImageViewer(imageUrl: imageUrl);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Show full-screen viewer for a base64 image
void showFullScreenImageFromBase64(BuildContext context, String base64Image) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Image Viewer',
    barrierColor: Colors.black.withOpacity(0.9),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _FullScreenBase64ImageViewer(base64Image: base64Image);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Try-On content without Scaffold wrapper (for IndexedStack in MainShellPage)
class TryOnContent extends StatelessWidget {
  const TryOnContent({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final TryOnController controller = Get.find<TryOnController>();

    return AppPageBackground(
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

              Obx(() {
                if (controller.generatedImageUrl.value.isNotEmpty) {
                  return Column(
                    children: [
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
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
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
            final images = controller.clothingImages;
            final wardrobeItem = controller.selectedWardrobeItem.value;
            if (image == null) {
              // Show three options: Gallery, Camera, Wardrobe
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadOption(
                          context: context,
                          icon: Icons.photo_library,
                          label: 'Gallery (Multiple)',
                          subtitle: 'Select multiple clothes',
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
                          subtitle: 'Add photos one by one',
                          onTap: controller.pickClothingFromCamera,
                          tokens: tokens,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  // Wardrobe option - full width
                  _buildUploadOption(
                    context: context,
                    icon: Icons.checkroom_rounded,
                    label: 'From Wardrobe',
                    onTap: () => _showWardrobePicker(context, controller),
                    tokens: tokens,
                    isFullWidth: true,
                  ),
                ],
              );
            }

            // Show selected image(s) with navigation
            return Column(
              children: [
                // Image viewer with navigation
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                      child: GestureDetector(
                        onTap: () => showFullScreenFileImage(context, image),
                        child: Image.file(
                          image,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Navigation arrows when multiple images
                    if (images.length > 1) ...[
                      // Previous button
                      Positioned(
                        left: AppConstants.spacing8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left),
                            iconSize: 32,
                            color: tokens.textPrimary,
                            style: IconButton.styleFrom(
                              backgroundColor: tokens.cardColor.withOpacity(0.7),
                            ),
                            onPressed: controller.previousImage,
                          ),
                        ),
                      ),
                      // Next button
                      Positioned(
                        right: AppConstants.spacing8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right),
                            iconSize: 32,
                            color: tokens.textPrimary,
                            style: IconButton.styleFrom(
                              backgroundColor: tokens.cardColor.withOpacity(0.7),
                            ),
                            onPressed: controller.nextImage,
                          ),
                        ),
                      ),
                      // Image counter badge
                      Positioned(
                            top: AppConstants.spacing8,
                            left: AppConstants.spacing8,
                            right: AppConstants.spacing8,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing12,
                                  vertical: AppConstants.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.cardColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                                ),
                                child: Text(
                                  controller.currentImageDisplay,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.spacing8),
                // Info text
                if (wardrobeItem != null)
                  Text(
                    'From your wardrobe: ${wardrobeItem.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                  )
                else if (controller.selectedWardrobeItems.isNotEmpty)
                  Text(
                    '${controller.selectedWardrobeItems.length} wardrobe items selected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  )
                else if (images.length > 1)
                  Text(
                    '${images.length} items selected • Swipe or tap arrows to browse',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                  ),
                const SizedBox(height: AppConstants.spacing12),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.reset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Change'),
                      ),
                    ),
                    if (images.length > 1) ...[
                      const SizedBox(width: AppConstants.spacing8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.removeCurrentImage,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Remove', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ],
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
    bool isFullWidth = false,
    String? subtitle,
  }) {
    if (isFullWidth) {
      // Full width option with horizontal layout (for Wardrobe)
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            border: Border.all(color: tokens.cardBorderColor),
            borderRadius: BorderRadius.circular(AppConstants.radius12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: tokens.brandColor),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Compact option with vertical layout (for Gallery/Camera)
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
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Show wardrobe item picker bottom sheet
  Future<void> _showWardrobePicker(
    BuildContext context,
    TryOnController controller,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WardrobePickerSheet(controller: controller),
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
            child: GestureDetector(
              onTap: () => showFullScreenImageFromBase64(
                context,
                controller.generatedImageBase64.value,
              ),
              child: Image.memory(
                base64Decode(controller.generatedImageBase64.value),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }

      return AppGlassCard(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          child: GestureDetector(
            onTap: () => showFullScreenNetworkImage(
              context,
              controller.generatedImageUrl.value,
            ),
            child: Image.network(
              controller.generatedImageUrl.value,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    });
  }
}

/// Wardrobe item picker bottom sheet
class _WardrobePickerSheet extends StatefulWidget {
  final TryOnController controller;

  const _WardrobePickerSheet({required this.controller});

  @override
  State<_WardrobePickerSheet> createState() => _WardrobePickerSheetState();
}

class _WardrobePickerSheetState extends State<_WardrobePickerSheet> {
  final ItemRepository _itemRepository = ItemRepository();
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      isLoading.value = true;
      final response = await _itemRepository.getItems(limit: 100);
      items.value = response.items;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  List<ItemModel> get _filteredItems {
    if (searchQuery.value.isEmpty) return items;
    return items.where((item) {
      return item.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: tokens.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                Icon(Icons.checkroom_rounded, color: tokens.brandColor),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select from Wardrobe',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      // Show count of selected items
                      Obx(() {
                        final count = widget.controller.selectedWardrobeItems.length;
                        if (count > 0) {
                          return Text(
                            '$count item${count > 1 ? 's' : ''} selected',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: tokens.brandColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                // Done button
                TextButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                  style: TextButton.styleFrom(
                    foregroundColor: tokens.brandColor,
                  ),
                ),
              ],
            ),
          ),

          // Selected items horizontal list
          Obx(() {
            final selectedItems = widget.controller.selectedWardrobeItems;
            if (selectedItems.isEmpty) return const SizedBox.shrink();

            return Container(
              height: 90,
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  final imageUrl = item.itemImages?.isNotEmpty == true
                      ? item.itemImages!.first.url
                      : null;

                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radius8),
                          child: imageUrl != null
                              ? GestureDetector(
                                  onTap: () => showFullScreenNetworkImage(context, imageUrl),
                                  child: Image.network(
                                    imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: tokens.cardColor,
                                        child: Icon(Icons.image_not_supported,
                                          size: 24, color: tokens.textMuted),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  color: tokens.cardColor,
                                  child: Icon(Icons.image_not_supported,
                                    size: 24, color: tokens.textMuted),
                                ),
                        ),
                        // Remove button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => widget.controller.removeWardrobeItem(item.id),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                ),
              ),
              onChanged: (value) => searchQuery.value = value,
            ),
          ),

          const SizedBox(height: AppConstants.spacing12),

          // Items list
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: tokens.textMuted),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'Failed to load items',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      ElevatedButton(
                        onPressed: _loadItems,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (_filteredItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: tokens.textMuted),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        searchQuery.value.isEmpty
                            ? 'No items in your wardrobe'
                            : 'No items found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spacing12,
                  mainAxisSpacing: AppConstants.spacing12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = widget.controller.isWardrobeItemSelected(item.id);
                  return _WardrobeItemTile(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => widget.controller.pickClothingFromWardrobe(item),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Individual wardrobe item tile
class _WardrobeItemTile extends StatelessWidget {
  final ItemModel item;
  final bool isSelected;
  final VoidCallback onTap;

  const _WardrobeItemTile({
    required this.item,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    final imageUrl = item.itemImages?.isNotEmpty == true
        ? item.itemImages!.first.url
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radius12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.radius12),
                    ),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: tokens.cardColor,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 32,
                                  color: tokens.textMuted,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: tokens.cardColor,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: tokens.textMuted,
                            ),
                          ),
                  ),
                ),

                // Item info
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.category.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Selection indicator
            if (isSelected)
              Positioned(
                top: AppConstants.spacing8,
                right: AppConstants.spacing8,
                child: CircleAvatar(
                  backgroundColor: tokens.brandColor,
                  radius: 16,
                  child: const Icon(Icons.check, size: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen viewer for File (local) images
class _FullScreenFileImageViewer extends StatelessWidget {
  final File imageFile;

  const _FullScreenFileImageViewer({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from propagating to dismiss
                child: PhotoView(
                  imageProvider: FileImage(imageFile),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppConstants.spacing8,
              right: AppConstants.spacing16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.all(AppConstants.spacing8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen viewer for network images
class _FullScreenNetworkImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenNetworkImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from propagating to dismiss
                child: PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                  loadingBuilder: (context, event) => Center(
                    child: CircularProgressIndicator(
                      value: event == null
                          ? null
                          : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                      color: Colors.white,
                    ),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppConstants.spacing8,
              right: AppConstants.spacing16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.all(AppConstants.spacing8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen viewer for base64 images
class _FullScreenBase64ImageViewer extends StatelessWidget {
  final String base64Image;

  const _FullScreenBase64ImageViewer({required this.base64Image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from propagating to dismiss
                child: PhotoView(
                  imageProvider: MemoryImage(base64Decode(base64Image)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppConstants.spacing8,
              right: AppConstants.spacing16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.all(AppConstants.spacing8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
