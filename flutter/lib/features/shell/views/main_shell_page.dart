import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../controllers/main_shell_controller.dart';
import '../../dashboard/views/dashboard_content.dart';
import '../../wardrobe/views/wardrobe_content.dart';
import '../../outfits/views/outfits_content.dart';
import '../../profile/views/profile_content.dart';
import 'studio_content.dart';

/// One navigation surface with lazy, retained destinations.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key, this.initialTab, this.initialStudioTool});

  final int? initialTab;
  final int? initialStudioTool;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late final MainShellController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MainShellController>();
    if (widget.initialStudioTool != null) {
      controller.changeStudioTool(widget.initialStudioTool!);
    }
    if (widget.initialTab != null) controller.changeTab(widget.initialTab!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;
        return Obx(() {
          final selected = controller.currentIndex.value;
          final canPopRoute = Navigator.of(context).canPop();
          return PopScope(
            canPop: canPopRoute || selected == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) controller.changeTab(0);
            },
            child: Scaffold(
              appBar: canPopRoute
                  ? AppBar(
                      leading: const BackButton(),
                      title: Text(
                        AppBottomNavigationBar.navigationItems[selected].label,
                      ),
                    )
                  : null,
              body: Row(
                children: [
                  if (useRail) ...[
                    NavigationRail(
                      scrollable: true,
                      selectedIndex: selected,
                      onDestinationSelected: controller.changeTab,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final item
                            in AppBottomNavigationBar.navigationItems)
                          NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.activeIcon),
                            label: Text(item.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                  ],
                  Expanded(
                    key: const ValueKey('shell-destinations'),
                    child: IndexedStack(
                      index: selected,
                      children: List.generate(
                        5,
                        (index) => TickerMode(
                          enabled: selected == index,
                          child: controller.isTabLoaded(index)
                              ? _tab(index)
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: _floatingAction(selected),
              bottomNavigationBar: useRail
                  ? null
                  : AppBottomNavigationBar(
                      currentIndex: selected,
                      onTabChanged: controller.changeTab,
                    ),
            ),
          );
        });
      },
    );
  }

  Widget _tab(int index) => switch (index) {
    0 => const DashboardContent(),
    1 => const WardrobeContent(),
    2 => const OutfitsContent(),
    3 => const StudioContent(),
    _ => const ProfileContent(),
  };

  Widget? _floatingAction(int selected) => switch (selected) {
    1 => FloatingActionButton.extended(
      onPressed: () => Get.toNamed(Routes.wardrobeAdd),
      tooltip: 'Add closet item',
      icon: const Icon(Icons.add),
      label: const Text('Add item'),
    ),
    2 => FloatingActionButton.extended(
      onPressed: () => Get.toNamed(Routes.outfitBuilder),
      tooltip: 'Create outfit',
      icon: const Icon(Icons.add),
      label: const Text('Create outfit'),
    ),
    _ => null,
  };
}
