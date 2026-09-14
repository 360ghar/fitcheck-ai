import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/photoshoot_controller.dart';
import 'photoshoot_upload_step.dart';
import 'photoshoot_configure_step.dart';
import 'photoshoot_generating_step.dart';
import 'photoshoot_results_step.dart';

/// Photoshoot is a retained tool inside Studio; its current step owns scrolling.
class PhotoshootContent extends GetView<PhotoshootController> {
  const PhotoshootContent({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    return AppPageBackground(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Obx(() {
                final index = controller.currentStep.value.index;
                const labels = [
                  'Add photos',
                  'Choose a style',
                  'Generate photos',
                  'Your results',
                ];
                return Semantics(
                  liveRegion: true,
                  label: 'Step ${index + 1} of 4 · ${labels[index]}',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Leave room for the active form when the keyboard or
                      // landscape orientation reduces the tool viewport.
                      if (constraints.maxHeight >= 260) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                labels[index],
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${index + 1} / 4',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: tokens.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      ExcludeSemantics(
                        child: Row(
                          children: List.generate(
                            4,
                            (step) => Expanded(
                              child: Container(
                                height: 3,
                                margin: EdgeInsets.only(
                                  right: step == 3 ? 0 : 4,
                                ),
                                color: step <= index
                                    ? AppCoreColors.editorialSage
                                    : tokens.cardBorderColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Expanded(
              child: Obx(
                () => switch (controller.currentStep.value) {
                  PhotoshootStep.upload => const PhotoshootUploadStep(),
                  PhotoshootStep.configure => const PhotoshootConfigureStep(),
                  PhotoshootStep.generating => const PhotoshootGeneratingStep(),
                  PhotoshootStep.results => const PhotoshootResultsStep(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
