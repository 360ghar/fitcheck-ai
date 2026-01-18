import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../models/photoshoot_models.dart';
import '../repositories/photoshoot_repository.dart';

/// Steps in the photoshoot generation flow
enum PhotoshootStep {
  upload,
  configure,
  generating,
  results,
}

/// Controller for AI Photoshoot Generator feature
class PhotoshootController extends GetxController {
  final PhotoshootRepository _repository = PhotoshootRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // TextEditingController for custom prompt field
  final TextEditingController customPromptController = TextEditingController();

  // Current step in the flow
  final Rx<PhotoshootStep> currentStep = PhotoshootStep.upload.obs;

  // Photo upload state (1-4 photos)
  final RxList<File> selectedPhotos = <File>[].obs;
  static const int maxPhotos = 4;

  // Configuration state
  final Rx<PhotoshootUseCase> selectedUseCase = PhotoshootUseCase.linkedin.obs;
  final RxString customPrompt = ''.obs;
  final RxInt numImages = 10.obs;
  static const int minImages = 1;
  static const int maxImages = 10;

  // Usage state
  final Rx<PhotoshootUsage?> usage = Rx<PhotoshootUsage?>(null);
  final RxBool isLoadingUsage = false.obs;

  // Generation state
  final RxBool isGenerating = false.obs;
  final RxInt generationProgress = 0.obs;
  final RxString generationStatus = ''.obs;

  // Results state
  final RxList<GeneratedImage> generatedImages = <GeneratedImage>[].obs;
  final RxString sessionId = ''.obs;

  // Download state
  final RxBool isDownloading = false.obs;
  final RxInt downloadingIndex = (-1).obs;

  // Error state
  final RxString error = ''.obs;

  // Computed properties
  int get remainingToday => usage.value?.remaining ?? 10;
  int get effectiveMaxImages => remainingToday.clamp(minImages, maxImages);
  bool get canGenerate =>
      selectedPhotos.isNotEmpty &&
      numImages.value <= remainingToday &&
      (selectedUseCase.value != PhotoshootUseCase.custom ||
          customPrompt.value.isNotEmpty);

  @override
  void onInit() {
    super.onInit();
    fetchUsage();
  }

  @override
  void onClose() {
    customPromptController.dispose();
    super.onClose();
  }

  /// Fetch current usage stats
  Future<void> fetchUsage() async {
    isLoadingUsage.value = true;
    try {
      usage.value = await _repository.getUsage();
      // Adjust numImages if it exceeds remaining
      if (numImages.value > remainingToday) {
        numImages.value = remainingToday.clamp(minImages, maxImages);
      }
    } catch (e) {
      // Non-blocking, default to free limits
      usage.value = const PhotoshootUsage();
    } finally {
      isLoadingUsage.value = false;
    }
  }

  /// Pick photos from gallery (adds to existing photos)
  Future<void> pickPhotos() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Calculate how many more photos we can add
        final spotsAvailable = maxPhotos - selectedPhotos.length;
        if (spotsAvailable <= 0) {
          Get.snackbar('Limit Reached', 'Maximum $maxPhotos photos allowed');
          return;
        }

        // Add new photos to existing ones (up to the limit)
        final newFiles = images.take(spotsAvailable).map((x) => File(x.path)).toList();
        selectedPhotos.addAll(newFiles);
        error.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick photos: ${e.toString()}');
    }
  }

  /// Pick a single photo from camera
  Future<void> pickFromCamera() async {
    if (selectedPhotos.length >= maxPhotos) {
      Get.snackbar('Limit Reached', 'Maximum $maxPhotos photos allowed');
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedPhotos.add(File(image.path));
        error.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to access camera: ${e.toString()}');
    }
  }

  /// Remove a photo from selection
  void removePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }

  /// Update selected use case
  void setUseCase(PhotoshootUseCase useCase) {
    selectedUseCase.value = useCase;
    if (useCase != PhotoshootUseCase.custom) {
      customPrompt.value = '';
    }
  }

  /// Update custom prompt
  void setCustomPrompt(String prompt) {
    customPrompt.value = prompt;
  }

  /// Update number of images
  void setNumImages(int count) {
    numImages.value = count.clamp(minImages, effectiveMaxImages);
  }

  /// Navigate to next step
  void nextStep() {
    switch (currentStep.value) {
      case PhotoshootStep.upload:
        if (selectedPhotos.isEmpty) {
          Get.snackbar('No Photos', 'Please add at least one photo');
          return;
        }
        currentStep.value = PhotoshootStep.configure;
        break;
      case PhotoshootStep.configure:
        if (!canGenerate) {
          if (selectedUseCase.value == PhotoshootUseCase.custom &&
              customPrompt.value.isEmpty) {
            Get.snackbar('Custom Prompt Required', 'Please enter a custom prompt');
            return;
          }
          if (numImages.value > remainingToday) {
            _showReferralPrompt();
            return;
          }
        }
        generatePhotoshoot();
        break;
      case PhotoshootStep.generating:
        // No action during generation
        break;
      case PhotoshootStep.results:
        // Reset for new generation
        reset();
        break;
    }
  }

  /// Go back to previous step
  void previousStep() {
    switch (currentStep.value) {
      case PhotoshootStep.upload:
        // Already at first step
        break;
      case PhotoshootStep.configure:
        currentStep.value = PhotoshootStep.upload;
        break;
      case PhotoshootStep.generating:
        // Cannot go back during generation
        break;
      case PhotoshootStep.results:
        currentStep.value = PhotoshootStep.configure;
        break;
    }
  }

  /// Generate photoshoot images
  Future<void> generatePhotoshoot() async {
    if (!canGenerate) return;

    isGenerating.value = true;
    error.value = '';
    generationProgress.value = 0;
    generationStatus.value = 'Preparing your photos...';
    currentStep.value = PhotoshootStep.generating;

    try {
      // Convert photos to base64
      generationStatus.value = 'Processing photos...';
      final List<String> photosBase64 = await Future.wait(
        selectedPhotos.map((file) async {
          final bytes = await file.readAsBytes();
          return await compute(_encodeBase64, bytes);
        }),
      );

      generationStatus.value = 'Generating ${numImages.value} images...';
      generationProgress.value = 20;

      // Make API call
      final result = await _repository.generate(
        photos: photosBase64,
        useCase: selectedUseCase.value,
        customPrompt: selectedUseCase.value == PhotoshootUseCase.custom
            ? customPrompt.value
            : null,
        numImages: numImages.value,
      );

      generationProgress.value = 100;
      sessionId.value = result.sessionId;
      generatedImages.value = result.images;

      if (result.usage != null) {
        usage.value = result.usage;
      }

      currentStep.value = PhotoshootStep.results;

      Get.snackbar(
        'Success',
        '${generatedImages.length} images generated!',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');

      // Check if limit exceeded
      if (error.value.contains('limit') || error.value.contains('exceeded')) {
        _showReferralPrompt();
      } else {
        Get.snackbar('Generation Failed', error.value);
      }

      currentStep.value = PhotoshootStep.configure;
    } finally {
      isGenerating.value = false;
    }
  }

  /// Download a single image to gallery
  Future<void> downloadImage(int index) async {
    if (index < 0 || index >= generatedImages.length) return;
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadingIndex.value = index;

    try {
      final image = generatedImages[index];
      final bytes = await _getImageBytes(image);

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        name: 'photoshoot_${sessionId.value}_$index',
      );

      if (result['isSuccess'] == true) {
        Get.snackbar('Saved', 'Image saved to gallery');
      } else {
        Get.snackbar('Error', 'Failed to save image');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save image: $e');
    } finally {
      isDownloading.value = false;
      downloadingIndex.value = -1;
    }
  }

  /// Download all images to gallery
  Future<void> downloadAll() async {
    if (generatedImages.isEmpty) return;
    if (isDownloading.value) return;

    isDownloading.value = true;

    try {
      int savedCount = 0;
      for (int i = 0; i < generatedImages.length; i++) {
        downloadingIndex.value = i;
        final image = generatedImages[i];
        final bytes = await _getImageBytes(image);

        final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(bytes),
          quality: 100,
          name: 'photoshoot_${sessionId.value}_$i',
        );

        if (result['isSuccess'] == true) {
          savedCount++;
        }
      }

      Get.snackbar(
        'Saved',
        '$savedCount of ${generatedImages.length} images saved to gallery',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save images: $e');
    } finally {
      isDownloading.value = false;
      downloadingIndex.value = -1;
    }
  }

  Future<List<int>> _getImageBytes(GeneratedImage image) async {
    final base64Data = image.imageBase64;
    if (base64Data != null && base64Data.isNotEmpty) {
      return base64Decode(base64Data);
    }

    final url = image.imageUrl;
    if (url != null && url.isNotEmpty) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      throw Exception('Failed to download image (${response.statusCode})');
    }

    throw Exception('No image data available');
  }

  /// Show referral prompt when limit exceeded
  void _showReferralPrompt() {
    Get.dialog(
      ReferralLimitDialog(
        onReferFriend: () {
          Get.back();
          Get.toNamed(Routes.referral);
        },
        onUpgrade: () {
          Get.back();
          Get.toNamed(Routes.subscription);
        },
      ),
      barrierDismissible: true,
    );
  }

  /// Reset to initial state for new generation
  void reset() {
    selectedPhotos.clear();
    customPrompt.value = '';
    customPromptController.clear();
    numImages.value = effectiveMaxImages.clamp(minImages, maxImages);
    generatedImages.clear();
    sessionId.value = '';
    error.value = '';
    generationProgress.value = 0;
    generationStatus.value = '';
    isDownloading.value = false;
    downloadingIndex.value = -1;
    currentStep.value = PhotoshootStep.upload;
    fetchUsage();
  }
}

String _encodeBase64(Uint8List bytes) => base64Encode(bytes);

/// Referral limit dialog widget
class ReferralLimitDialog extends StatelessWidget {
  final VoidCallback onReferFriend;
  final VoidCallback onUpgrade;

  const ReferralLimitDialog({
    super.key,
    required this.onReferFriend,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Limit Reached'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_camera,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            "You've used all your free images today!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Refer a friend and both get 1 month Pro free!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onUpgrade,
          child: const Text('Upgrade to Pro'),
        ),
        ElevatedButton(
          onPressed: onReferFriend,
          child: const Text('Refer a Friend'),
        ),
      ],
    );
  }
}
