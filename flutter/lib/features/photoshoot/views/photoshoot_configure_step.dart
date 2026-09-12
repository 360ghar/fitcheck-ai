import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
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
            'Choose the direction',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),

          Obx(() => _buildUseCaseSelector(context, tokens)),

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
                  'Your idea',
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
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),
              ],
            );
          }),

          // Aspect ratio selection
          Text(
            'Image format',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),

          Obx(() => _buildAspectRatioSelector(context, tokens)),

          const SizedBox(height: AppConstants.spacing24),

          // Image count slider
          Text(
            'How many photos?',
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
          LayoutBuilder(
            builder: (context, constraints) {
              final back = OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                child: const Text('Back'),
              );
              final generate = Obx(
                () => ElevatedButton(
                  onPressed: controller.canGenerate
                      ? controller.nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text('Generate ${controller.numImages.value} Images'),
                ),
              );
              if (constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(14) > 20) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [generate, const SizedBox(height: 8), back],
                );
              }
              return Row(
                children: [
                  Expanded(child: back),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(flex: 2, child: generate),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUseCaseSelector(BuildContext context, AppUiTokens tokens) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final useCase in PhotoshootUseCase.values)
          ChoiceChip(
            label: Text(useCase.label),
            selected: controller.selectedUseCase.value == useCase,
            selectedColor: AppCoreColors.editorialSage,
            checkmarkColor: AppCoreColors.editorialInk,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: controller.selectedUseCase.value == useCase
                  ? AppCoreColors.editorialInk
                  : tokens.textPrimary,
            ),
            onSelected: (_) => controller.setUseCase(useCase),
          ),
      ],
    );
  }

  Widget _buildImageSlider(BuildContext context, AppUiTokens tokens) {
    final remaining = controller.remainingToday;
    final maxImages = controller.effectiveMaxImages;

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 4,
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
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
    final isPro = RegExp(
      r'^pro[_-]?',
      caseSensitive: false,
    ).hasMatch(usage.planType);

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Row(
        children: [
          Icon(
            isPro ? Icons.star : Icons.info_outline,
            color: isPro
                ? Theme.of(context).colorScheme.primary
                : tokens.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPro
                  ? 'Pro: ${usage.remaining} of ${usage.limitToday} images remaining'
                  : 'Free: ${usage.remaining} of ${usage.limitToday} images remaining',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          ),
          // Upgrade CTA is hidden when the paywall is disabled (iOS v1,
          // App Store Guideline 3.1.1 anti-steering). Benign usage text stays.
          if (!isPro && EnvConfig.paywallEnabled)
            TextButton(
              onPressed: () => Get.toNamed(Routes.subscription),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildAspectRatioSelector(BuildContext context, AppUiTokens tokens) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final ratio in PhotoshootAspectRatio.values)
          ChoiceChip(
            label: Text(ratio.ratio),
            tooltip: ratio.label,
            selected: controller.selectedAspectRatio.value == ratio,
            selectedColor: AppCoreColors.editorialSage,
            checkmarkColor: AppCoreColors.editorialInk,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: controller.selectedAspectRatio.value == ratio
                  ? AppCoreColors.editorialInk
                  : tokens.textPrimary,
            ),
            onSelected: (_) => controller.setAspectRatio(ratio),
          ),
      ],
    );
  }
}
