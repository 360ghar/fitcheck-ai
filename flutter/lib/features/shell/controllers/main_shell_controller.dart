import 'package:get/get.dart';
import '../../../core/utils/frame_safe.dart';

/// Controller for MainShellPage - manages tab navigation
class MainShellController extends GetxController {
  /// Current tab index (0-4)
  final RxInt currentIndex = 0.obs;
  final RxSet<int> loadedTabs = <int>{0}.obs;

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

  /// Reset tab state so the next session starts clean.
  ///
  /// The controller is `permanent` (it must outlive the shell route), so
  /// logout does not dispose it. Without this reset, user B inherits user A's
  /// last-opened tab (landing on More instead of Home) and `loadedTabs`
  /// mounts every previously visited tab at once, firing all of their
  /// controllers' fetches for the new account in parallel.
  ///
  /// Runs through [afterBuildPhase] for the same reason as [onInit]: the
  /// shell page's Obx widgets stay subscribed to both fields for good.
  void resetForNewSession() {
    afterBuildPhase(() {
      if (isClosed) return;
      currentIndex.value = 0;
      loadedTabs
        ..clear()
        ..add(0);
    });
  }
}
