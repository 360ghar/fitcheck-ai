import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart'
    as dio
    show FormData, MultipartFile, Options, ResponseType;
import 'package:gal/gal.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/ai_consent_service.dart';
import '../../../core/utils/permission_helper.dart';
import '../../wardrobe/models/item_model.dart';
import '../../../core/utils/error_handler.dart';

/// Try-On controller
/// Manages virtual try-on feature
class TryOnController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final Future<void> Function(Uint8List bytes, String name) _imageSaver;
  final Future<List<int>> Function(String url) _imageDownloader;

  TryOnController({
    Future<void> Function(Uint8List bytes, String name)? imageSaver,
    Future<List<int>> Function(String url)? imageDownloader,
  }) : _imageSaver =
           imageSaver ??
           ((bytes, name) => Gal.putImageBytes(bytes, name: name)),
       _imageDownloader =
           imageDownloader ??
           ((url) async {
             final response = await ApiClient.instance.dio.get<List<int>>(
               url,
               options: dio.Options(responseType: dio.ResponseType.bytes),
             );
             return response.data ?? const <int>[];
           });

  // Reactive state
  final Rx<File?> clothingImage = Rx<File?>(null);
  final RxList<File> clothingImages =
      <File>[].obs; // Support multiple clothing images
  final RxList<File> tempFiles = <File>[].obs; // Track temp files for cleanup
  final Rx<ItemModel?> selectedWardrobeItem = Rx<ItemModel?>(null);
  final RxList<ItemModel> selectedWardrobeItems =
      <ItemModel>[].obs; // Support multiple wardrobe items
  final RxString userAvatarUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isAvatarReady = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString generatedImageUrl = ''.obs;
  final RxString generatedImageBase64 = ''.obs;
  final RxString error = ''.obs;
  final RxInt currentImageIndex =
      0.obs; // For switching between multiple images

  // Options
  final RxString selectedStyle = 'casual'.obs;
  final RxString selectedBackground = 'studio white'.obs;
  final RxString selectedPose = 'standing front'.obs;

  // Style options
  static const List<String> styles = [
    'casual',
    'formal',
    'business',
    'sporty',
    'streetwear',
    'elegant',
  ];

  // Background options
  static const List<String> backgrounds = [
    'studio white',
    'studio gray',
    'urban street',
    'nature',
    'minimal',
  ];

  // Pose options
  static const List<String> poses = [
    'standing front',
    'standing side',
    'walking',
    'casual',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserAvatar();
  }

  @override
  void onClose() {
    // Clean up temp files to prevent memory leaks
    _cleanupTempFiles();
    super.onClose();
  }

  /// Clean up temporary files created during try-on
  void _cleanupTempFiles() {
    for (final file in tempFiles) {
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    tempFiles.clear();
  }

  Future<void> _loadUserAvatar() async {
    try {
      final response = await _apiClient.get('${ApiConstants.users}/me');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final avatar = (data['data'] as Map<String, dynamic>?)?['avatar_url']
            ?.toString();
        if (avatar != null && avatar.isNotEmpty) {
          userAvatarUrl.value = avatar;
          isAvatarReady.value = true;
        }
      }
    } catch (_) {
      // Non-blocking: show empty state if avatar is not available.
    }
  }

  Future<void> pickClothingImage() async {
    if (!await PermissionHelper.confirmPhotoRationale()) return;

    final List<XFile> images;
    try {
      // Support multiple image selection
      images = await _imagePicker.pickMultipleMedia(imageQuality: 85);
    } catch (e) {
      await PermissionHelper.showDeniedRecovery(permissionName: 'Photos');
      return;
    }

    if (images.isNotEmpty) {
      // Clear previous selection; a gallery selection supersedes any
      // wardrobe-item selection (the one-item guard must not then block on
      // stale multi-item state).
      clothingImages.clear();
      selectedWardrobeItem.value = null;
      selectedWardrobeItems.clear();

      // Add all selected images
      for (final image in images) {
        // Only add image files (case-insensitive check)
        final pathLower = image.path.toLowerCase();
        if (pathLower.endsWith('.jpg') ||
            pathLower.endsWith('.jpeg') ||
            pathLower.endsWith('.png') ||
            pathLower.endsWith('.webp')) {
          clothingImages.add(File(image.path));
        }
      }

      // Set first image as current
      if (clothingImages.isNotEmpty) {
        clothingImage.value = clothingImages.first;
        currentImageIndex.value = 0;
      }

      _clearGeneratedResult();

      ErrorHandler.showSuccess(
        '${clothingImages.length} clothing image(s) selected',
        title: 'Images Added',
      );
    }
  }

  Future<void> pickClothingFromCamera() async {
    if (!await PermissionHelper.confirmCameraRationale()) return;

    final XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      await PermissionHelper.showDeniedRecovery(permissionName: 'Camera');
      return;
    }

    if (image != null) {
      // Add to existing images or start new list
      final file = File(image.path);
      clothingImages.add(file);
      clothingImage.value = file;
      // A camera selection supersedes any wardrobe-item selection: clear both
      // the single-item pointer and the multi-item list so the one-item guard
      // cannot block on stale multi-item state.
      selectedWardrobeItem.value = null;
      selectedWardrobeItems.clear();
      currentImageIndex.value = clothingImages.length - 1;
      _clearGeneratedResult();

      ErrorHandler.showSuccess(
        'Photo added (${clothingImages.length} total)',
        title: 'Photo Added',
      );
    }
  }

  /// Switch to next clothing image
  void nextImage() {
    if (clothingImages.length > 1) {
      currentImageIndex.value =
          (currentImageIndex.value + 1) % clothingImages.length;
      clothingImage.value = clothingImages[currentImageIndex.value];
      _clearGeneratedResult(); // Clear previous result when switching
    }
  }

  /// Switch to previous clothing image
  void previousImage() {
    if (clothingImages.length > 1) {
      currentImageIndex.value =
          (currentImageIndex.value - 1 + clothingImages.length) %
          clothingImages.length;
      clothingImage.value = clothingImages[currentImageIndex.value];
      _clearGeneratedResult(); // Clear previous result when switching
    }
  }

  /// Get current image index display text
  String get currentImageDisplay => clothingImages.length > 1
      ? '${currentImageIndex.value + 1} / ${clothingImages.length}'
      : '';

  /// Remove clothing image at current index
  void removeCurrentImage() {
    if (clothingImages.isNotEmpty) {
      clothingImages.removeAt(currentImageIndex.value);
      if (clothingImages.isEmpty) {
        clothingImage.value = null;
        currentImageIndex.value = 0;
      } else {
        if (currentImageIndex.value >= clothingImages.length) {
          currentImageIndex.value = clothingImages.length - 1;
        }
        clothingImage.value = clothingImages[currentImageIndex.value];
      }
      _clearGeneratedResult();
    }
  }

  /// Select a clothing item from wardrobe (adds to list)
  Future<void> pickClothingFromWardrobe(ItemModel item) async {
    try {
      // Check if already selected
      if (selectedWardrobeItems.any((i) => i.id == item.id)) {
        ErrorHandler.showInfo(
          '${item.name} is already in your selection',
          title: 'Already Selected',
        );
        return;
      }

      // Get the primary image or first image from the item
      if (item.itemImages == null || item.itemImages!.isEmpty) {
        ErrorHandler.showValidation(
          'This item has no images',
          title: 'No Image',
        );
        return;
      }

      final primaryImage = item.itemImages!.firstWhere(
        (img) => img.isPrimary,
        orElse: () => item.itemImages!.first,
      );

      // Download the image from URL and save as temp file
      // Reuse the existing Dio instance from ApiClient to avoid memory leaks
      final tempDir = Directory.systemTemp;
      final fileName =
          'tryon_${item.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';

      await _apiClient.dio.download(primaryImage.url, filePath);

      // Track temp file for cleanup
      final tempFile = File(filePath);
      tempFiles.add(tempFile);

      // Add to lists
      selectedWardrobeItems.add(item);
      clothingImages.add(tempFile);

      // Set as current if this is the first item
      if (selectedWardrobeItems.length == 1) {
        clothingImage.value = File(filePath);
        currentImageIndex.value = 0;
        selectedWardrobeItem.value = item;
      }

      _clearGeneratedResult();

      // Don't close the dialog - let user select more items
      ErrorHandler.showSuccess(
        '${item.name} added (${selectedWardrobeItems.length} total)',
        title: 'Added',
      );
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError('Failed to load item image', title: 'Error');
    }
  }

  /// Check if an item is already selected
  bool isWardrobeItemSelected(String itemId) {
    return selectedWardrobeItems.any((i) => i.id == itemId);
  }

  /// Remove a wardrobe item from selection
  void removeWardrobeItem(String itemId) {
    final index = selectedWardrobeItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      selectedWardrobeItems.removeAt(index);

      // Clean up temp file if it exists
      if (clothingImages.length > index) {
        final imageToRemove = clothingImages[index];
        if (tempFiles.contains(imageToRemove)) {
          try {
            if (imageToRemove.existsSync()) {
              imageToRemove.deleteSync();
            }
          } catch (e) {
            // Ignore cleanup errors
          }
          tempFiles.remove(imageToRemove);
        }
        clothingImages.removeAt(index);
      }

      // Update current image
      if (clothingImages.isEmpty) {
        clothingImage.value = null;
        selectedWardrobeItem.value = null;
        currentImageIndex.value = 0;
      } else {
        if (currentImageIndex.value >= clothingImages.length) {
          currentImageIndex.value = clothingImages.length - 1;
        }
        clothingImage.value = clothingImages[currentImageIndex.value];
        selectedWardrobeItem.value =
            selectedWardrobeItems[currentImageIndex.value];
      }
      _clearGeneratedResult();
    }
  }

  Future<void> uploadUserAvatar() async {
    // Third-party AI data-sharing consent gate (Apple 5.1.2(i)) — the avatar
    // (face photo) is sent to AI providers for generation.
    if (!await Get.find<AiConsentService>().ensureConsent(
      featureLabel: 'Virtual Try-On',
    )) {
      return;
    }

    if (!await PermissionHelper.confirmPhotoRationale()) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 75,
    );

    if (image != null) {
      final file = File(image.path);
      // Remember the last good avatar so a failed upload can restore it
      // instead of leaving a broken local path + isAvatarReady=false, which
      // would also block try-on generation with a misleading "still uploading".
      final previousAvatar = userAvatarUrl.value;
      final previousReady = isAvatarReady.value;

      userAvatarUrl.value = file.path;
      isAvatarReady.value = false;
      isUploadingAvatar.value = true;
      error.value = '';
      try {
        // Use a longer timeout for avatar upload
        final response = await _apiClient.post(
          '${ApiConstants.users}/me/avatar',
          data: dio.FormData.fromMap({
            'file': await dio.MultipartFile.fromFile(
              file.path,
              filename: 'avatar.jpg',
            ),
          }),
        );

        final data = _extractDataMap(response.data);
        final avatar = data['avatar_url']?.toString();
        if (avatar == null || avatar.isEmpty) {
          throw Exception('Avatar upload failed');
        }
        userAvatarUrl.value = avatar;
        isAvatarReady.value = true;
        ErrorHandler.showSuccess('Profile photo updated', title: 'Success');
      } catch (e) {
        error.value = ErrorHandler.extractMessage(e);
        // Restore the previous avatar so the screen reflects what is actually
        // usable (and generation stays unlocked when it was before).
        userAvatarUrl.value = previousAvatar;
        isAvatarReady.value = previousReady;
        ErrorHandler.showError(
          'Server is taking too long to respond. Please try again later or use a smaller image.',
          title: 'Upload Failed',
        );
      } finally {
        isUploadingAvatar.value = false;
      }
    }
  }

  Future<void> generateTryOn() async {
    // Third-party AI data-sharing consent gate (Apple 5.1.2(i)) — must run
    // before any image bytes are read or uploaded.
    if (!await Get.find<AiConsentService>().ensureConsent(
      featureLabel: 'Virtual Try-On',
    )) {
      return;
    }

    if (clothingImage.value == null) {
      ErrorHandler.showValidation(
        'Please select a clothing image first',
        title: 'Error',
      );
      return;
    }

    // The current backend contract accepts one `clothing_image`. Do not let
    // the multi-select UI silently discard garments; require an explicit
    // single-garment selection until the API supports a list/composite input.
    if (clothingImages.length > 1 || selectedWardrobeItems.length > 1) {
      ErrorHandler.showValidation(
        'Try-on currently supports one clothing item at a time. Remove the extra items and try again.',
        title: 'One item at a time',
      );
      return;
    }

    if (userAvatarUrl.value.isEmpty) {
      ErrorHandler.showValidation(
        'Please upload a photo of yourself first',
        title: 'Avatar Required',
      );
      return;
    }

    if (!isAvatarReady.value) {
      ErrorHandler.showValidation(
        'Please wait for your profile photo to finish uploading',
        title: 'Avatar Uploading',
      );
      return;
    }

    isGenerating.value = true;
    error.value = '';

    try {
      final bytes = await clothingImage.value!.readAsBytes();
      final clothingBase64 = await compute(_encodeBase64, bytes);

      final response = await _apiClient.postWithExtendedTimeout(
        '${ApiConstants.ai}/try-on',
        data: buildTryOnPayload(
          [clothingBase64],
          style: selectedStyle.value,
          background: selectedBackground.value,
          pose: selectedPose.value,
        ),
      );

      final result = _extractDataMap(response.data);
      final imageUrl = result['image_url']?.toString();
      final imageBase64 = result['image_base64']?.toString();
      generatedImageUrl.value = imageUrl ?? '';
      generatedImageBase64.value = imageBase64 ?? '';

      if (generatedImageUrl.value.isEmpty &&
          generatedImageBase64.value.isEmpty) {
        throw Exception('No image returned from server');
      }

      ErrorHandler.showSuccess(
        'Try-on generated successfully',
        title: 'Success',
      );
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Error');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> downloadResult() async {
    final imageUrl = generatedImageUrl.value;
    final imageBase64 = generatedImageBase64.value;
    if (imageUrl.isEmpty && imageBase64.isEmpty) return;

    try {
      final bytes = imageBase64.isNotEmpty
          ? Uint8List.fromList(base64Decode(imageBase64.split(',').last))
          : Uint8List.fromList(await _imageDownloader(imageUrl));
      if (bytes.isEmpty) throw Exception('The generated image was empty.');

      await _imageSaver(
        bytes,
        'tryon_${DateTime.now().millisecondsSinceEpoch}',
      );
      ErrorHandler.showSuccess('Image saved to gallery', title: 'Saved');
    } catch (e) {
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(error.value, title: 'Download failed');
    }
  }

  /// Build the request accepted by the current singular try-on API contract.
  @visibleForTesting
  static Map<String, dynamic> buildTryOnPayload(
    List<String> clothingImages, {
    required String style,
    required String background,
    required String pose,
  }) {
    if (clothingImages.length != 1) {
      throw ArgumentError('Try-on requires exactly one clothing image.');
    }
    return {
      'clothing_image': clothingImages.single,
      'style': style,
      'background': background,
      'pose': pose,
      'lighting': 'professional studio lighting',
      'save_to_storage': false,
    };
  }

  /// Any change to the input garment (pick, switch, remove) invalidates the
  /// previously generated result so it can never be presented as matching the
  /// current selection.
  void _clearGeneratedResult() {
    generatedImageUrl.value = '';
    generatedImageBase64.value = '';
  }

  void reset() {
    clothingImage.value = null;
    clothingImages.clear();
    currentImageIndex.value = 0;
    selectedWardrobeItem.value = null;
    selectedWardrobeItems.clear();
    generatedImageUrl.value = '';
    generatedImageBase64.value = '';
    error.value = '';
    selectedStyle.value = 'casual';
    selectedBackground.value = 'studio white';
    selectedPose.value = 'standing front';
    // Clean up temp files on reset
    _cleanupTempFiles();
  }

  Map<String, dynamic> _extractDataMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return <String, dynamic>{};
  }
}

String _encodeBase64(Uint8List bytes) => base64Encode(bytes);
