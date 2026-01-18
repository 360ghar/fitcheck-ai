import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';
import '../models/photoshoot_models.dart';

/// Step 4: Results gallery
class PhotoshootResultsStep extends GetView<PhotoshootController> {
  const PhotoshootResultsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Column(
      children: [
        // Action bar
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.generatedImages.isNotEmpty &&
                              !controller.isDownloading.value
                          ? controller.downloadAll
                          : null,
                      icon: controller.isDownloading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download),
                      label: Text(controller.isDownloading.value
                          ? 'Downloading ${controller.downloadingIndex.value + 1}/${controller.generatedImages.length}'
                          : 'Download All (${controller.generatedImages.length})'),
                    )),
              ),
              const SizedBox(width: AppConstants.spacing12),
              OutlinedButton(
                onPressed: controller.reset,
                child: const Text('New'),
              ),
            ],
          ),
        ),

        // Image grid
        Expanded(
          child: Obx(() => GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing16,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spacing12,
                  mainAxisSpacing: AppConstants.spacing12,
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.generatedImages.length,
                itemBuilder: (context, index) {
                  final image = controller.generatedImages[index];
                  return _buildImageCard(context, tokens, image, index);
                },
              )),
        ),

        // Usage summary
        Obx(() => _buildUsageSummary(context, tokens)),
      ],
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    AppUiTokens tokens,
    GeneratedImage image,
    int index,
  ) {
    return AppGlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            child: _buildImageWidget(tokens, image, BoxFit.cover),
          ),

          // Index badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Download button
          Positioned(
            bottom: 8,
            right: 8,
            child: Obx(() {
              final isDownloadingThis = controller.isDownloading.value &&
                  controller.downloadingIndex.value == index;
              return Material(
                color: tokens.brandColor,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: controller.isDownloading.value
                      ? null
                      : () => controller.downloadImage(index),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: isDownloadingThis
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download, color: Colors.white, size: 20),
                  ),
                ),
              );
            }),
          ),

          // Full screen tap
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFullScreen(context, image, index),
                borderRadius: BorderRadius.circular(AppConstants.radius12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, GeneratedImage image, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImageWidget(AppUiTokens.of(context), image, BoxFit.contain),
              ),
            ),

            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),

            // Download button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.downloadImage(index);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSummary(BuildContext context, AppUiTokens tokens) {
    final usage = controller.usage.value;
    if (usage == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        border: Border(top: BorderSide(color: tokens.cardBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Text(
              '${controller.generatedImages.length} images generated  •  ${usage.remaining} remaining today',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(AppUiTokens tokens, GeneratedImage image, BoxFit fit) {
    final base64Data = image.imageBase64;
    if (base64Data != null && base64Data.isNotEmpty) {
      return Image.memory(
        base64Decode(base64Data),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _brokenImage(tokens),
      );
    }

    final url = image.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _brokenImage(tokens),
      );
    }

    return _brokenImage(tokens);
  }

  Widget _brokenImage(AppUiTokens tokens) {
    return Container(
      color: tokens.cardColor,
      child: Icon(
        Icons.broken_image,
        color: tokens.textMuted,
        size: 48,
      ),
    );
  }
}
