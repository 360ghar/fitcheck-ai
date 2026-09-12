import 'package:get/get.dart';
import '../../../core/utils/frame_safe.dart';

/// Retains visited destinations and both Studio tools until the session ends.
class MainShellController extends GetxController {
  MainShellController({int initialTab = 0, int initialStudioTool = 0})
    : currentIndex = initialTab.obs,
      loadedTabs = <int>{initialTab}.obs,
      studioTool = initialStudioTool.obs,
      loadedStudioTools = <int>{initialStudioTool}.obs;

  final RxInt currentIndex;
  final RxSet<int> loadedTabs;
  final RxInt studioTool;
  final RxSet<int> loadedStudioTools;

  void changeTab(int index) {
    if (index < 0 || index >= 5) return;
    afterBuildPhase(() {
      if (isClosed) return;
      loadedTabs.add(index);
      currentIndex.value = index;
    });
  }

  void changeStudioTool(int index) {
    if (index < 0 || index >= 2) return;
    afterBuildPhase(() {
      if (isClosed) return;
      loadedStudioTools.add(index);
      studioTool.value = index;
    });
  }

  bool isTabLoaded(int index) => loadedTabs.contains(index);

  void resetForNewSession() {
    afterBuildPhase(() {
      if (isClosed) return;
      currentIndex.value = 0;
      loadedTabs
        ..clear()
        ..add(0);
      studioTool.value = 0;
      loadedStudioTools
        ..clear()
        ..add(0);
    });
  }
}
