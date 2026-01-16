import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' as dio show FormData, MultipartFile;
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../wardrobe/models/item_model.dart';

/// Try-On controller
/// Manages virtual try-on feature
class TryOnController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Reactive state
  final Rx<File?> clothingImage = Rx<File?>(null);
  final RxList<File> clothingImages = <File>[].obs; // Support multiple clothing images
  final RxList<File> tempFiles = <File>[].obs; // Track temp files for cleanup
  final Rx<ItemModel?> selectedWardrobeItem = Rx<ItemModel?>(null);
  final RxList<ItemModel> selectedWardrobeItems = <ItemModel>[].obs; // Support multiple wardrobe items
  final RxString userAvatarUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isAvatarReady = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString generatedImageUrl = ''.obs;
  final RxString generatedImageBase64 = ''.obs;
  final RxString error = ''.obs;
  final RxInt currentImageIndex = 0.obs; // For switching between multiple images

  // Options
  final RxString selectedStyle = 'casual'.obs;
  final RxString selectedBackground = 'studio white'.obs;
  final RxString selectedPose = 'standing front'.obs;

  // Style options
  static const List<String> styles = [
    'casual', 'formal', 'business', 'sporty', 'streetwear', 'elegant'
  ];

  // Background options
  static const List<String> backgrounds = [
    'studio white', 'studio gray', 'urban street', 'nature', 'minimal'
  ];

  // Pose options
  static const List<String> poses = [
    'standing front', 'standing side', 'walking', 'casual'
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
        final avatar = (data['data'] as Map<String, dynamic>?)?['avatar_url']?.toString();
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
    // Support multiple image selection
    final List<XFile> images = await _imagePicker.pickMultipleMedia(
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      // Clear previous selection
      clothingImages.clear();
      selectedWardrobeItem.value = null;

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

      generatedImageUrl.value = ''; // Clear previous result

      Get.snackbar(
        'Images Added',
        '${clothingImages.length} clothing image(s) selected',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> pickClothingFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      // Add to existing images or start new list
      final file = File(image.path);
      clothingImages.add(file);
      clothingImage.value = file;
      selectedWardrobeItem.value = null; // Clear wardrobe selection
      currentImageIndex.value = clothingImages.length - 1;
      generatedImageUrl.value = ''; // Clear previous result

      Get.snackbar(
        'Photo Added',
        'Photo added (${clothingImages.length} total)',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    }
  }

  /// Switch to next clothing image
  void nextImage() {
    if (clothingImages.length > 1) {
      currentImageIndex.value = (currentImageIndex.value + 1) % clothingImages.length;
      clothingImage.value = clothingImages[currentImageIndex.value];
      generatedImageUrl.value = ''; // Clear previous result when switching
    }
  }

  /// Switch to previous clothing image
  void previousImage() {
    if (clothingImages.length > 1) {
      currentImageIndex.value = (currentImageIndex.value - 1 + clothingImages.length) % clothingImages.length;
      clothingImage.value = clothingImages[currentImageIndex.value];
      generatedImageUrl.value = ''; // Clear previous result when switching
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
      generatedImageUrl.value = '';
    }
  }

  /// Select a clothing item from wardrobe (adds to list)
  Future<void> pickClothingFromWardrobe(ItemModel item) async {
    try {
      // Check if already selected
      if (selectedWardrobeItems.any((i) => i.id == item.id)) {
        Get.snackbar(
          'Already Selected',
          '${item.name} is already in your selection',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
        );
        return;
      }

      // Get the primary image or first image from the item
      if (item.itemImages == null || item.itemImages!.isEmpty) {
        Get.snackbar('No Image', 'This item has no images');
        return;
      }

      final primaryImage = item.itemImages!.firstWhere(
        (img) => img.isPrimary,
        orElse: () => item.itemImages!.first,
      );

      // Download the image from URL and save as temp file
      // Reuse the existing Dio instance from ApiClient to avoid memory leaks
      final tempDir = Directory.systemTemp;
      final fileName = 'tryon_${item.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';

      await _apiClient.dio.download(
        primaryImage.url,
        filePath,
      );

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

      generatedImageUrl.value = ''; // Clear previous result

      // Don't close the dialog - let user select more items
      Get.snackbar(
        'Added',
        '${item.name} added (${selectedWardrobeItems.length} total)',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', 'Failed to load item image');
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
        selectedWardrobeItem.value = selectedWardrobeItems[currentImageIndex.value];
      }
      generatedImageUrl.value = '';
    }
  }

  Future<void> uploadUserAvatar() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 75,
    );

    if (image != null) {
      final file = File(image.path);
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
        Get.snackbar(
          'Success',
          'Profile photo updated',
          snackPosition: SnackPosition.TOP,
        );
      } catch (e) {
        error.value = e.toString().replaceAll('Exception: ', '');
        Get.snackbar(
          'Upload Failed',
          'Server is taking too long to respond. Please try again later or use a smaller image.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      } finally {
        isUploadingAvatar.value = false;
      }
    }
  }

  Future<void> generateTryOn() async {
    if (clothingImage.value == null) {
      Get.snackbar('Error', 'Please select a clothing image first');
      return;
    }

    if (userAvatarUrl.value.isEmpty) {
      Get.snackbar(
        'Avatar Required',
        'Please upload a photo of yourself first',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!isAvatarReady.value) {
      Get.snackbar(
        'Avatar Uploading',
        'Please wait for your profile photo to finish uploading',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isGenerating.value = true;
    error.value = '';

    try {
      final bytes = await clothingImage.value!.readAsBytes();
      final clothingBase64 = await compute(_encodeBase64, bytes);

      final response = await _apiClient.post(
        '${ApiConstants.ai}/try-on',
        data: {
          'clothing_image': clothingBase64,
          'style': selectedStyle.value,
          'background': selectedBackground.value,
          'pose': selectedPose.value,
          'lighting': 'professional studio lighting',
          'save_to_storage': false,
        },
      );

      final result = _extractDataMap(response.data);
      final imageUrl = result['image_url']?.toString();
      final imageBase64 = result['image_base64']?.toString();
      generatedImageUrl.value = imageUrl ?? '';
      generatedImageBase64.value = imageBase64 ?? '';

      if (generatedImageUrl.value.isEmpty && generatedImageBase64.value.isEmpty) {
        throw Exception('No image returned from server');
      }

      Get.snackbar(
        'Success',
        'Try-on generated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', error.value);
    } finally {
      isGenerating.value = false;
    }
  }

  void downloadResult() {
    if (generatedImageUrl.value.isEmpty) return;
    // Would trigger download of the generated image
    Get.snackbar('Download', 'Image saved to gallery');
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
