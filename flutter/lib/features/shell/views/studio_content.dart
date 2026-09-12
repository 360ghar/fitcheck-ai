import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_ui.dart';
import '../../photoshoot/views/photoshoot_content.dart';
import '../../tryon/views/tryon_content.dart';
import '../controllers/main_shell_controller.dart';

/// Both tools retain inputs, scroll position and results after switching.
class StudioContent extends GetView<MainShellController> {
  const StudioContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppPageBackground(
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scaffold consumes keyboard insets before this subtree. Use the
              // remaining height to keep the active form usable as well.
              if (constraints.maxHeight >= 440 &&
                  MediaQuery.viewInsetsOf(context).bottom == 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (constraints.maxHeight >= 600)
                        Text(
                          'FITCHECK AI',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.4,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        'Studio',
                        style: constraints.maxHeight < 600
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Obx(
                      () => SegmentedButton<int>(
                        style: ButtonStyle(
                          minimumSize: const WidgetStatePropertyAll(
                            Size(48, 48),
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          side: const WidgetStatePropertyAll(BorderSide.none),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AppCoreColors.editorialSage
                                : Colors.transparent,
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AppCoreColors.editorialInk
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          textStyle: WidgetStatePropertyAll(
                            theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 0, label: Text('Photoshoot')),
                          ButtonSegment(value: 1, label: Text('Try-on')),
                        ],
                        selected: {controller.studioTool.value},
                        onSelectionChanged: (selection) =>
                            controller.changeStudioTool(selection.single),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final selected = controller.studioTool.value;
                  return IndexedStack(
                    index: selected,
                    children: List.generate(
                      2,
                      (index) => TickerMode(
                        enabled: selected == index,
                        child: !controller.loadedStudioTools.contains(index)
                            ? const SizedBox.shrink()
                            : index == 0
                            ? const PhotoshootContent()
                            : const TryOnContent(),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
