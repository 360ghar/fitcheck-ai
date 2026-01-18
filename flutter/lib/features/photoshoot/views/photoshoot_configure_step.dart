import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';
import '../models/photoshoot_models.dart';

/// Step 2: Configure use case and image count
class PhotoshootConfigureStep extends GetView<PhotoshootController> {
  const PhotoshootConfigureStep({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Use case selection
          Text(
            'Choose Your Style',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Use case grid
          _buildUseCaseGrid(context, tokens),

          const SizedBox(height: AppConstants.spacing24),

          // Custom prompt (if custom selected)
          Obx(() {
            if (controller.selectedUseCase.value != PhotoshootUseCase.custom) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Prompt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                TextField(
                  controller: controller.customPromptController,
                  onChanged: controller.setCustomPrompt,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe the style you want...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radius12),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),
              ],
            );
          }),

          // Image count slider
          Text(
            'Number of Images',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.spacing8),

          Obx(() => _buildImageSlider(context, tokens)),

          const SizedBox(height: AppConstants.spacing24),

          // Usage info
          Obx(() => _buildUsageInfo(context, tokens)),

          const SizedBox(height: AppConstants.spacing24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.canGenerate ? controller.nextStep : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text('Generate ${controller.numImages.value} Images'),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUseCaseGrid(BuildContext context, AppUiTokens tokens) {
    final useCases = PhotoshootUseCase.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacing12,
        mainAxisSpacing: AppConstants.spacing12,
        childAspectRatio: 1.4,
      ),
      itemCount: useCases.length,
      itemBuilder: (context, index) {
        final useCase = useCases[index];
        return Obx(() => _buildUseCaseCard(context, tokens, useCase));
      },
    );
  }

  Widget _buildUseCaseCard(
    BuildContext context,
    AppUiTokens tokens,
    PhotoshootUseCase useCase,
  ) {
    final isSelected = controller.selectedUseCase.value == useCase;

    return InkWell(
      onTap: () => controller.setUseCase(useCase),
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(
            color: isSelected ? tokens.brandColor : tokens.cardBorderColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? tokens.brandColor.withOpacity(0.1)
              : tokens.cardColor,
        ),
        padding: const EdgeInsets.all(AppConstants.spacing12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              useCase.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              useCase.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? tokens.brandColor : tokens.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(BuildContext context, AppUiTokens tokens) {
    final remaining = controller.remainingToday;
    final maxImages = controller.effectiveMaxImages;

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.numImages.value} images',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.brandColor,
                    ),
              ),
              Text(
                '$remaining remaining today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Handle edge case when maxImages == minImages (divisions would be 0)
          if (maxImages > PhotoshootController.minImages)
            Slider(
              value: controller.numImages.value.toDouble(),
              min: PhotoshootController.minImages.toDouble(),
              max: maxImages.toDouble(),
              divisions: maxImages - PhotoshootController.minImages,
              label: '${controller.numImages.value}',
              onChanged: (value) => controller.setNumImages(value.round()),
            )
          else
            // When only 1 image is available, show a disabled slider
            Slider(
              value: PhotoshootController.minImages.toDouble(),
              min: PhotoshootController.minImages.toDouble(),
              max: PhotoshootController.minImages.toDouble(),
              onChanged: null,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${PhotoshootController.minImages}',
                style: TextStyle(fontSize: 12, color: tokens.textMuted),
              ),
              Text(
                '$maxImages',
                style: TextStyle(fontSize: 12, color: tokens.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfo(BuildContext context, AppUiTokens tokens) {
    final usage = controller.usage.value;
    if (usage == null) return const SizedBox.shrink();

    // Check if user is on a pro plan (matches pro_monthly, pro_yearly, etc.)
    final isPro = RegExp(r'^pro[_-]?', caseSensitive: false).hasMatch(usage.planType);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Row(
        children: [
          Icon(
            isPro ? Icons.star : Icons.info_outline,
            color: isPro ? Colors.amber : tokens.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPro
                  ? 'Pro: ${usage.remaining} of ${usage.limitToday} images remaining'
                  : 'Free: ${usage.remaining} of ${usage.limitToday} images remaining',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ),
          if (!isPro)
            TextButton(
              onPressed: () => Get.toNamed(Routes.subscription),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }
}
