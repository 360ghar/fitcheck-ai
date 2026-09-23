import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/photoshoot_models.dart';
import '../providers/photoshoot_provider.dart';
import 'photoshoot_image.dart';

/// Step 3: live progress. Finished images fill their slots as they arrive;
/// pending slots are skeletons. The bar follows real completed counts.
class PhotoshootGeneratingStep extends ConsumerWidget {
  const PhotoshootGeneratingStep({super.key});

  static String _eta(int seconds) {
    if (seconds <= 0) return '';
    if (seconds < 60) return 'About ${seconds}s left';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? 'About ${m}m ${s}s left' : 'About ${m}m left';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(photoshootProvider);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final eta = _eta(s.etaSeconds);
    final byIndex = {for (final img in s.images) img.index: img};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaperSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      s.status.isEmpty ? 'Starting' : s.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Text(
                    '${s.progress}%',
                    style: text.titleMedium?.copyWith(
                      color: tokens.stock.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (s.progress / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                ),
              ),
              if (s.sceneLabel.isNotEmpty || eta.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  [
                    if (s.sceneLabel.isNotEmpty) 'Now: ${s.sceneLabel}',
                    if (eta.isNotEmpty) eta,
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing20),
        SkeletonPulse(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppConstants.spacing12,
              crossAxisSpacing: AppConstants.spacing12,
              childAspectRatio: 3 / 4,
            ),
            itemCount: s.numImages,
            itemBuilder: (context, i) =>
                _Slot(image: byIndex[i], failed: s.failedIndices.contains(i)),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        Center(
          child: TextButton(
            onPressed: s.jobId.isEmpty || s.cancelling
                ? null
                : () => ref.read(photoshootProvider.notifier).cancel(),
            style: TextButton.styleFrom(minimumSize: const Size(120, 48)),
            child: Text(s.cancelling ? 'Cancelling' : 'Cancel'),
          ),
        ),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.image, required this.failed});

  final GeneratedImage? image;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    if (image != null) {
      return PaperSurface(
        padding: EdgeInsets.zero,
        grain: false,
        clipBehavior: Clip.antiAlias,
        child: PhotoshootImage(image: image!),
      );
    }
    if (failed) {
      return PaperSurface(
        lift: 0,
        color: tokens.stock.sunk,
        padding: EdgeInsets.zero,
        semanticLabel: 'Failed',
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: tokens.textMuted,
            size: 24,
          ),
        ),
      );
    }
    return const SkeletonBox(borderRadius: AppConstants.radius12);
  }
}
