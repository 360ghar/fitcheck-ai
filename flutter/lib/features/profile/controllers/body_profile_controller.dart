import 'package:get/get.dart';
import '../models/body_profile_model.dart';
import '../repositories/body_profile_repository.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Controller for managing body profiles
class BodyProfileController extends GetxController {
  final BodyProfileRepository _repository = BodyProfileRepository();

  // State
  final RxList<BodyProfileModel> profiles = <BodyProfileModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  /// Fetch all body profiles
  Future<void> fetchProfiles() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    try {
      isLoading.value = true;
      error.value = '';
      profiles.value = await _repository.getBodyProfiles();
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new body profile
  Future<bool> createProfile(CreateBodyProfileRequest request) async {
    try {
      isSaving.value = true;
      error.value = '';
      final newProfile = await _repository.createBodyProfile(request);
      profiles.add(newProfile);

      // If this is the default, update other profiles in list
      if (newProfile.isDefault) {
        profiles.value = profiles.map((p) =>
          p.id == newProfile.id ? p : p.copyWith(isDefault: false)
        ).toList();
      }

      return true;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update body profile
  Future<bool> updateProfile(String id, UpdateBodyProfileRequest request) async {
    try {
      isSaving.value = true;
      error.value = '';
      final updated = await _repository.updateBodyProfile(id, request);

      final index = profiles.indexWhere((p) => p.id == id);
      if (index >= 0) {
        profiles[index] = updated;

        // Handle default flag
        if (updated.isDefault) {
          profiles.value = profiles.map((p) =>
            p.id == id ? p : p.copyWith(isDefault: false)
          ).toList();
        }
      }

      return true;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete body profile
  Future<bool> deleteProfile(String id) async {
    try {
      await _repository.deleteBodyProfile(id);
      profiles.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
      return false;
    }
  }

  /// Set profile as default
  Future<bool> setDefault(String id) async {
    return updateProfile(id, const UpdateBodyProfileRequest(isDefault: true));
  }
}
