import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/frame_safe.dart';

/// Controller for MainShellPage - manages tab navigation
class MainShellController extends GetxController {
  /// Current tab index (0-4)
  final RxInt currentIndex = 0.obs;
  final RxSet<int> loadedTabs = <int>{0}.obs;

  /// Tab routes in order
  static const List<String> tabRoutes = [
    Routes.home,
    Routes.photoshoot,
    Routes.wardrobe,
    Routes.outfits,
    Routes.more,
  ];

  @override
  void onInit() {
    super.onInit();
    // This controller is `permanent` and MainShellPage's three Obx widgets stay
    // subscribed to loadedTabs for the app's lifetime, so never write it while a
    // frame is in flight. See [afterBuildPhase].
    afterBuildPhase(() {
      if (!isClosed) loadedTabs.add(currentIndex.value);
    });
  }

  /// Change the current tab
  void changeTab(int index) {
    if (index >= 0 && index < 5 && currentIndex.value != index) {
      currentIndex.value = index;
      loadedTabs.add(index);
    }
  }

  bool isTabLoaded(int index) => loadedTabs.contains(index);

  /// Get tab index for a route (for deep linking)
  static int getIndexForRoute(String route) {
    final normalized = route.split('?').first;

    // Handle "More" submenu routes
    const moreRoutes = {
      Routes.tryOn,
      Routes.recommendations,
      Routes.calendar,
      Routes.gamification,
      Routes.profile,
      Routes.settings,
    };
    if (moreRoutes.contains(normalized) ||
        moreRoutes.any((item) => normalized.startsWith('$item/'))) {
      return 4; // More tab
    }

    // Check main tab routes
    for (int i = 0; i < tabRoutes.length; i++) {
      if (tabRoutes[i] == normalized ||
          normalized.startsWith('${tabRoutes[i]}/')) {
        return i;
      }
    }
    return 0; // Default to Home
  }

  /// Navigate to a specific tab by route
  void navigateToTab(String route) {
    final index = getIndexForRoute(route);
    changeTab(index);
  }
}
