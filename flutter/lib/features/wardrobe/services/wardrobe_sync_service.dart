import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/item_model.dart';
import '../controllers/wardrobe_controller.dart';

/// Provides a stable interface for other controllers (ItemAddController,
/// BatchExtractionController) to synchronise newly created items into the
/// [WardrobeController] without calling [Get.find] directly.
///
/// This breaks the cross-controller coupling described in FL5.
class WardrobeSyncService extends GetxService {
  /// Add a single newly created [ItemModel] to the wardrobe controller's list.
  void addItem(ItemModel item) {
    if (!Get.isRegistered<WardrobeController>()) {
      debugPrint('WardrobeSyncService: WardrobeController not registered, skipping');
      return;
    }
    Get.find<WardrobeController>().addItem(item);
  }

  /// Add multiple newly created [ItemModel]s to the wardrobe controller.
  void addItems(List<ItemModel> items) {
    if (!Get.isRegistered<WardrobeController>()) {
      debugPrint('WardrobeSyncService: WardrobeController not registered, skipping');
      return;
    }
    Get.find<WardrobeController>().addItems(items);
  }

  /// Fetch items from the wardrobe controller with an optional refresh.
  Future<void> fetchItems({bool refresh = true}) async {
    if (!Get.isRegistered<WardrobeController>()) {
      debugPrint('WardrobeSyncService: WardrobeController not registered, skipping');
      return;
    }
    await Get.find<WardrobeController>().fetchItems(refresh: refresh);
  }
}
