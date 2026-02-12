import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../controllers/main_shell_controller.dart';
import '../../dashboard/views/dashboard_content.dart';
import '../../wardrobe/views/wardrobe_content.dart';
import '../../outfits/views/outfits_content.dart';
import '../../photoshoot/views/photoshoot_content.dart';
import '../../dashboard/views/more_content.dart';

/// Main shell page with persistent navbar and IndexedStack for tab switching.
/// This eliminates navbar animation when switching between main tabs.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainShellController>();

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: List.generate(
            5,
            (index) => _buildTabContent(index, controller),
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => _buildFloatingActionButton(controller.currentIndex.value),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTabChanged: controller.changeTab,
        ),
      ),
    );
  }

  Widget _buildTabContent(int index, MainShellController controller) {
    if (!controller.isTabLoaded(index)) {
      return const SizedBox.shrink();
    }

    switch (index) {
      case 0:
        return const DashboardContent();
      case 1:
        return const PhotoshootContent();
      case 2:
        return const WardrobeContent();
      case 3:
        return const OutfitsContent();
      case 4:
        return const MoreContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingActionButton(int currentIndex) {
    switch (currentIndex) {
      case 2: // Wardrobe
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.wardrobeAdd),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        );
      case 3: // Outfits
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.outfitBuilder),
          icon: const Icon(Icons.add),
          label: const Text('Create Outfit'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
