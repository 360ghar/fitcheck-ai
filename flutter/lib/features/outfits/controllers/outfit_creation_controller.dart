import 'package:get/get.dart';
import '../../../../domain/enums/style.dart';
import '../../../../domain/enums/season.dart';
import '../../../core/services/notification_service.dart';
import '../models/outfit_model.dart';
import '../repositories/outfit_repository.dart';
import 'outfit_list_controller.dart';

/// Controller for outfit creation flow
/// Focused responsibility: Managing outfit creation form and submission
class OutfitCreationController extends GetxController {
  final OutfitRepository _repository = OutfitRepository();

  // Creation state
  final RxList<String> selectedItemIds = <String>[].obs;
  final RxBool isCreating = false.obs;
  final RxString name = ''.obs;
  final RxString description = ''.obs;
  final Rx<Style?> selectedStyle = Rx<Style?>(null);
  final Rx<Season?> selectedSeason = Rx<Season?>(null);
  final RxString occasion = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final RxString error = ''.obs;

  // Getters
  bool get hasSelectedItems => selectedItemIds.isNotEmpty;
  bool get hasName => name.value.isNotEmpty;
  bool get canCreate => hasSelectedItems && hasName;

  @override
  void onClose() {
    clearCreationState();
    super.onClose();
  }

  /// Add or remove item from outfit selection
  void toggleItemForOutfit(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  /// Check if item is selected
  bool isItemSelected(String itemId) {
    return selectedItemIds.contains(itemId);
  }

  /// Set outfit name
  void setName(String value) {
    name.value = value;
  }

  /// Set outfit description
  void setDescription(String value) {
    description.value = value;
  }

  /// Set outfit style
  void setStyle(Style? style) {
    selectedStyle.value = style;
  }

  /// Set outfit season
  void setSeason(Season? season) {
    selectedSeason.value = season;
  }

  /// Set occasion
  void setOccasion(String value) {
    occasion.value = value;
  }

  /// Add tag
  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
    }
  }

  /// Remove tag
  void removeTag(String tag) {
    tags.remove(tag);
  }

  /// Clear all creation state
  void clearCreationState() {
    selectedItemIds.clear();
    name.value = '';
    description.value = '';
    selectedStyle.value = null;
    selectedSeason.value = null;
    occasion.value = '';
    tags.clear();
    isCreating.value = false;
    error.value = '';
  }

  /// Create outfit
  Future<bool> createOutfit() async {
    if (!hasSelectedItems) {
      NotificationService.instance.showWarning(
        'Please select at least one item for your outfit',
        title: 'No Items',
      );
      return false;
    }

    if (!hasName) {
      NotificationService.instance.showWarning(
        'Please give your outfit a name',
        title: 'No Name',
      );
      return false;
    }

    try {
      isCreating.value = true;
      error.value = '';

      final request = CreateOutfitRequest(
        name: name.value,
        description: description.value.isEmpty ? null : description.value,
        itemIds: selectedItemIds.toList(),
        style: selectedStyle.value,
        season: selectedSeason.value,
        occasion: occasion.value.isEmpty ? null : occasion.value,
        tags: tags.isEmpty ? null : tags.toList(),
      );

      final newOutfit = await _repository.createOutfit(request);

      // Notify the list controller to add the new outfit
      if (Get.isRegistered<OutfitListController>()) {
        Get.find<OutfitListController>().addOutfit(newOutfit);
      }

      clearCreationState();

      NotificationService.instance.showSuccess(
        'Your outfit has been saved',
        title: 'Outfit Created',
      );

      return true;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      NotificationService.instance.showError(error.value);
      return false;
    } finally {
      isCreating.value = false;
    }
  }
}
