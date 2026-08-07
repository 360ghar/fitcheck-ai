import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_network_image.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';

/// Step 3: Generation progress — live view.
/// Shows the scene being generated, a rolling ETA, and thumbnails as each
/// image completes (skeleton placeholders for pending slots). No fake
/// percentages: the progress bar reflects real completed-image counts.
class PhotoshootGeneratingStep extends StatefulWidget {
  const PhotoshootGeneratingStep({super.key});

  @override
  State<PhotoshootGeneratingStep> createState() =>
      _PhotoshootGeneratingStepState();
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

  String _formatEta(int seconds) {
    if (seconds <= 0) return '';
    if (seconds < 60) return '~${seconds}s left';
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return remainder > 0 ? '~${minutes}m ${remainder}s left' : '~${minutes}m left';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final controller = Get.find<PhotoshootController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated camera icon with continuous pulsing
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.9 +
                    (0.1 *
                        (1 +
                            math.sin(_pulseController.value * 2 * math.pi) /
                                2)),
                child: child,
              );
            },
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: tokens.brandColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_enhance,
                size: 44,
                color: tokens.brandColor,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacing24),

          // Status text
          Obx(() => Text(
                controller.generationStatus.value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
              )),

          // Current scene being generated
          Obx(() {
            final scene = controller.currentSceneLabel.value;
            if (scene.isEmpty || !controller.isGenerating.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Now: $scene',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            );
          }),

          const SizedBox(height: AppConstants.spacing16),

          // Progress indicator + ETA
          Obx(() => Column(
                children: [
                  LinearProgressIndicator(
                    value:
                        (controller.generationProgress.value / 100).clamp(0.0, 1.0),
                    backgroundColor: tokens.cardBorderColor,
                    valueColor: AlwaysStoppedAnimation(tokens.brandColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${controller.generationProgress.value}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                      Obx(() {
                        final eta = _formatEta(controller.etaSeconds.value);
                        if (eta.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            eta,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: tokens.textMuted),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              )),

          const SizedBox(height: AppConstants.spacing24),

          // Live gallery: filled slots + skeleton placeholders for pending ones
          Obx(() {
            final images = controller.generatedImages
                .toList()
              ..sort((a, b) => a.index.compareTo(b.index));
            final total = controller.numImages.value;
            final slots = <Widget>[];

            // Generated images first (sorted by index), then placeholders
            // for every slot that has not produced an image yet.
            final slotsByIndex = <int, Widget>{};
            for (final image in images) {
              slotsByIndex[image.index] = _GeneratedThumbnail(image: image);
            }
            for (var i = 0; i < total; i++) {
              slots.add(
                slotsByIndex[i] ??
                    _PendingSlot(
                      index: i,
                      pulseController: _pulseController,
                      brandColor: tokens.brandColor,
                    ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated so far',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3 / 4,
                  children: slots,
                ),
              ],
            );
          }),

          const SizedBox(height: AppConstants.spacing24),

          // Info card
          AppGlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: tokens.brandColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Text(
                        'AI is creating ${controller.numImages.value} unique '
                        'professional images just for you...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      )),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Visible cancel control (best-effort, returns to configure step)
          Obx(() {
            if (!controller.isGenerating.value) return const SizedBox.shrink();
            return OutlinedButton.icon(
              onPressed: () => controller.cancelGeneration(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
            );
          }),
        ],
      ),
    );
  }
}

/// A completed generated image thumbnail (network URL or base64 payload).
class _GeneratedThumbnail extends StatelessWidget {
  final dynamic image;
  const _GeneratedThumbnail({required this.image});

  @override
  Widget build(BuildContext context) {
    final imageUrl = image.imageUrl as String?;
    final base64 = image.imageBase64 as String?;
    final hasUrl = imageUrl != null && imageUrl.isNotEmpty;
    final hasBase64 = base64 != null && base64.isNotEmpty;

    Widget child;
    if (hasUrl) {
      child = AppNetworkImage(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (_, _, _) => _fallbackBox(context),
      );
    } else if (hasBase64) {
      child = Image.memory(
        base64Decode(base64),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallbackBox(context),
      );
    } else {
      child = _fallbackBox(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }

  Widget _fallbackBox(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.image, size: 24)),
    );
  }
}

/// Skeleton placeholder for a pending image slot (pulsing with the shared
/// animation controller so placeholders breathe together).
class _PendingSlot extends StatelessWidget {
  final int index;
  final AnimationController pulseController;
  final Color brandColor;
  const _PendingSlot({
    required this.index,
    required this.pulseController,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (context, child) {
          final t = 0.5 + 0.5 * math.sin(pulseController.value * 2 * math.pi);
          return Container(
            color: brandColor.withValues(alpha: 0.06 + 0.06 * t),
            alignment: Alignment.center,
            child: Icon(
              Icons.image_outlined,
              size: 22,
              color: brandColor.withValues(alpha: 0.3),
            ),
          );
        },
      ),
    );
  }
}
