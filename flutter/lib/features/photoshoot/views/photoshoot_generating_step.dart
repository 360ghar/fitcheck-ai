import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';

/// Step 3: Generation progress
class PhotoshootGeneratingStep extends StatefulWidget {
  const PhotoshootGeneratingStep({super.key});

  @override
  State<PhotoshootGeneratingStep> createState() => _PhotoshootGeneratingStepState();
}

class _PhotoshootGeneratingStepState extends State<PhotoshootGeneratingStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final controller = Get.find<PhotoshootController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated camera icon with continuous pulsing
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + (0.1 * (1 + math.sin(_pulseController.value * 2 * math.pi)) / 2),
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: tokens.brandColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_enhance,
                  size: 60,
                  color: tokens.brandColor,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacing32),

            // Status text
            Obx(() => Text(
                  controller.generationStatus.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                )),

            const SizedBox(height: AppConstants.spacing16),

            // Progress indicator
            Obx(() => Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.generationProgress.value / 100,
                      backgroundColor: tokens.cardBorderColor,
                      valueColor: AlwaysStoppedAnimation(tokens.brandColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.generationProgress.value}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                )),

            const SizedBox(height: AppConstants.spacing32),

            // Info text
            AppGlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: tokens.brandColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => Text(
                          'AI is creating ${controller.numImages.value} unique professional images just for you...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: tokens.textMuted,
                              ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
