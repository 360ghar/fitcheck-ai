import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final actions = [
      ('Add pieces', 'Grow your closet', Icons.add, Routes.wardrobeAdd),
      (
        'Create outfit',
        'Put a look together',
        Icons.auto_awesome_outlined,
        Routes.outfitBuilder,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(title: 'Make it yours'),
        const SizedBox(height: 12),
        Material(
          color: AppCoreColors.editorialLinen,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0)
                  const Divider(
                    indent: 20,
                    endIndent: 20,
                    color: AppCoreColors.borderLight,
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Icon(
                    actions[i].$3,
                    size: 26,
                    color: AppCoreColors.editorialInk,
                  ),
                  title: Text(
                    actions[i].$1,
                    style: text.titleMedium?.copyWith(
                      color: AppCoreColors.editorialInk,
                    ),
                  ),
                  subtitle: Text(
                    actions[i].$2,
                    style: text.bodySmall?.copyWith(
                      color: AppCoreColors.editorialInk,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_outward_rounded,
                    size: 20,
                    color: AppCoreColors.editorialInk,
                  ),
                  onTap: () => Get.toNamed(actions[i].$4),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final oneColumn = MediaQuery.textScalerOf(context).scale(14) > 20;
            final width = oneColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(Routes.recommendations),
                    icon: const Icon(Icons.explore_outlined, size: 20),
                    label: const Text('For you'),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(Routes.calendar),
                    icon: const Icon(Icons.calendar_today_outlined, size: 20),
                    label: const Text('Plan ahead'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
