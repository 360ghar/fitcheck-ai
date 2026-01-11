import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/batch_extraction_controller.dart';
import '../models/batch_extraction_models.dart';
import '../widgets/extraction_progress_card.dart';

/// Page showing batch extraction and generation progress
class BatchExtractionProgressPage extends GetView<BatchExtractionController> {
  const BatchExtractionProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelConfirmation(context, tokens);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Processing'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showCancelConfirmation(context, tokens),
          ),
        ),
        body: AppPageBackground(
          child: SafeArea(
            child: Obx(() {
              // Navigate to review when complete
              if (controller.isComplete) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.offNamed(Routes.wardrobeBatchReview);
                });
              }

              return Column(
                children: [
                  // Progress header
                  _buildProgressHeader(context, tokens),

                  // Image list
                  Expanded(
                    child: _buildImageList(context, tokens),
                  ),

                  // Bottom status bar
                  _buildBottomBar(context, tokens),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, AppUiTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Obx(() {
        final isExtracting = controller.isExtracting || controller.isUploading;
        final isGenerating = controller.isGenerating;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase indicator
            Row(
              children: [
                _buildPhaseChip(
                  context,
                  tokens,
                  label: 'Extract',
                  isActive: isExtracting,
                  isComplete: !isExtracting && (isGenerating || controller.isComplete),
                ),
                const SizedBox(width: AppConstants.spacing8),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: tokens.textMuted,
                ),
                const SizedBox(width: AppConstants.spacing8),
                _buildPhaseChip(
                  context,
                  tokens,
                  label: 'Generate',
                  isActive: isGenerating,
                  isComplete: controller.isComplete,
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacing16),

            // Progress bar
            _buildProgressBar(context, tokens),

            const SizedBox(height: AppConstants.spacing8),

            // Status text
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),

            // Batch indicator for generation phase
            if (isGenerating && controller.totalBatches.value > 0) ...[
              const SizedBox(height: AppConstants.spacing4),
              Text(
                'Batch ${controller.currentBatch.value}/${controller.totalBatches.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.brandColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildPhaseChip(
    BuildContext context,
    AppUiTokens tokens, {
    required String label,
    required bool isActive,
    required bool isComplete,
  }) {
    Color bgColor;
    Color textColor;
    IconData? icon;

    if (isComplete) {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
      icon = Icons.check;
    } else if (isActive) {
      bgColor = tokens.brandColor.withOpacity(0.1);
      textColor = tokens.brandColor;
    } else {
      bgColor = tokens.textMuted.withOpacity(0.1);
      textColor = tokens.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing12,
        vertical: AppConstants.spacing8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          if (isActive && !isComplete) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, AppUiTokens tokens) {
    return Obx(() {
      double progress;
      if (controller.isUploading) {
        progress = controller.uploadProgress.value;
      } else if (controller.isExtracting) {
        final total = controller.selectedImages.length;
        progress = total > 0 ? controller.extractedCount.value / total : 0;
      } else if (controller.isGenerating) {
        final total = controller.totalItems.value;
        progress = total > 0 ? controller.generatedCount.value / total : 0;
      } else if (controller.isComplete) {
        progress = 1.0;
      } else {
        progress = 0;
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: tokens.textMuted.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(tokens.brandColor),
          minHeight: 8,
        ),
      );
    });
  }

  String _getStatusText() {
    if (controller.isUploading) {
      return 'Uploading images...';
    } else if (controller.isExtracting) {
      return '${controller.extractedCount.value}/${controller.selectedImages.length} images processed';
    } else if (controller.isGenerating) {
      return '${controller.generatedCount.value}/${controller.totalItems.value} items generated';
    } else if (controller.isComplete) {
      return 'Processing complete!';
    } else if (controller.isFailed) {
      return 'Processing failed';
    } else if (controller.isCancelled) {
      return 'Processing cancelled';
    }
    return 'Starting...';
  }

  Widget _buildImageList(BuildContext context, AppUiTokens tokens) {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return Center(
          child: Text(
            'No images',
            style: TextStyle(color: tokens.textMuted),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing8,
        ),
        itemCount: controller.selectedImages.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppConstants.spacing8),
        itemBuilder: (context, index) {
          final image = controller.selectedImages[index];
          return ExtractionProgressCard(
            image: image,
          );
        },
      );
    });
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
        // Show error message if any
        if (controller.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.reset();
                        Get.offNamed(Routes.wardrobeBatchAdd);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.brandColor,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Show cancel button during processing
        if (controller.isProcessing) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showCancelConfirmation(context, tokens),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing16,
                ),
              ),
              child: const Text('Cancel'),
            ),
          );
        }

        // Show continue button when cancelled
        if (controller.isCancelled) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandColor,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing16,
                ),
              ),
              child: const Text('Back'),
            ),
          );
        }

        // Stats summary
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              tokens,
              label: 'Images',
              value: '${controller.selectedImages.length}',
            ),
            _buildStatItem(
              context,
              tokens,
              label: 'Extracted',
              value: '${controller.extractedCount.value}',
              color: Colors.green,
            ),
            _buildStatItem(
              context,
              tokens,
              label: 'Failed',
              value: '${controller.failedCount.value}',
              color: controller.failedCount.value > 0 ? Colors.red : null,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    AppUiTokens tokens, {
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color ?? tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textMuted,
              ),
        ),
      ],
    );
  }

  void _showCancelConfirmation(BuildContext context, AppUiTokens tokens) {
    if (!controller.isProcessing) {
      Get.back();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.cardColor,
        title: Text(
          'Cancel Processing?',
          style: TextStyle(color: tokens.textPrimary),
        ),
        content: Text(
          'Are you sure you want to cancel? Any progress will be lost.',
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
              style: TextStyle(color: tokens.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.cancelExtraction();
              Get.back();
            },
            child: const Text(
              'Cancel Processing',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
