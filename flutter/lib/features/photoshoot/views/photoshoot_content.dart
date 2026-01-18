import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';
import 'photoshoot_upload_step.dart';
import 'photoshoot_configure_step.dart';
import 'photoshoot_generating_step.dart';
import 'photoshoot_results_step.dart';

/// Main content for Photoshoot tab (without Scaffold wrapper for IndexedStack)
class PhotoshootContent extends GetView<PhotoshootController> {
  const PhotoshootContent({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return AppPageBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Photoshoot',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Text('📸', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        _getSubtitle(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                      )),
                ],
              ),
            ),

            // Step indicator
            Obx(() => _buildStepIndicator(context, tokens)),

            // Content based on current step
            Expanded(
              child: Obx(() {
                switch (controller.currentStep.value) {
                  case PhotoshootStep.upload:
                    return const PhotoshootUploadStep();
                  case PhotoshootStep.configure:
                    return const PhotoshootConfigureStep();
                  case PhotoshootStep.generating:
                    return const PhotoshootGeneratingStep();
                  case PhotoshootStep.results:
                    return const PhotoshootResultsStep();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    switch (controller.currentStep.value) {
      case PhotoshootStep.upload:
        return 'Upload 1-4 photos of yourself';
      case PhotoshootStep.configure:
        return 'Choose your photoshoot style';
      case PhotoshootStep.generating:
        return 'Creating your images...';
      case PhotoshootStep.results:
        return '${controller.generatedImages.length} images ready!';
    }
  }

  Widget _buildStepIndicator(BuildContext context, AppUiTokens tokens) {
    final step = controller.currentStep.value;
    final steps = ['Upload', 'Configure', 'Generate', 'Results'];
    final currentIndex = PhotoshootStep.values.indexOf(step);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= currentIndex;
          final isCurrent = index == currentIndex;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? tokens.brandColor
                              : tokens.cardBorderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? tokens.brandColor : tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}
