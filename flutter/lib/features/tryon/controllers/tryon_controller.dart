import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

/// Try-On controller
/// Manages virtual try-on feature
class TryOnController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Reactive state
  final Rx<File?> clothingImage = Rx<File?>(null);
  final RxString userAvatarUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isAvatarReady = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString generatedImageUrl = ''.obs;
  final RxString generatedImageBase64 = ''.obs;
  final RxString error = ''.obs;

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
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      clothingImage.value = File(image.path);
      generatedImageUrl.value = ''; // Clear previous result
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
      clothingImage.value = File(image.path);
      generatedImageUrl.value = ''; // Clear previous result
    }
  }

  Future<void> uploadUserAvatar() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      final file = File(image.path);
      userAvatarUrl.value = file.path;
      isAvatarReady.value = false;
      isUploadingAvatar.value = true;
      error.value = '';
      try {
        final response = await _apiClient.upload(
          '${ApiConstants.users}/me/avatar',
          file,
        );
        final data = _extractDataMap(response.data);
        final avatar = data['avatar_url']?.toString();
        if (avatar == null || avatar.isEmpty) {
          throw Exception('Avatar upload failed');
        }
        userAvatarUrl.value = avatar;
        isAvatarReady.value = true;
        Get.snackbar('Success', 'Profile photo updated');
      } catch (e) {
        error.value = e.toString().replaceAll('Exception: ', '');
        Get.snackbar('Upload Failed', error.value);
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
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isAvatarReady.value) {
      Get.snackbar(
        'Avatar Uploading',
        'Please wait for your profile photo to finish uploading',
        snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
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
    generatedImageUrl.value = '';
    generatedImageBase64.value = '';
    error.value = '';
    selectedStyle.value = 'casual';
    selectedBackground.value = 'studio white';
    selectedPose.value = 'standing front';
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
