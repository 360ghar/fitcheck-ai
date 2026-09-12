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
import '../../wardrobe/repositories/item_repository.dart';
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
  final RxList<File> tempFiles = <File>[].obs;
  final Rx<ItemModel?> selectedWardrobeItem = Rx<ItemModel?>(null);
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

  Future<void> pickClothingImage() => _pickClothing(ImageSource.gallery);

  Future<void> pickClothingFromCamera() => _pickClothing(ImageSource.camera);

  Future<void> _pickClothing(ImageSource source) async {
    if (isLoading.value || isGenerating.value) return;
    isLoading.value = true;
    try {
      final allowed = source == ImageSource.camera
          ? await PermissionHelper.confirmCameraRationale()
          : await PermissionHelper.confirmPhotoRationale();
      if (!allowed || isClosed) return;
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null && !isClosed) setClothingImage(File(image.path));
    } catch (error) {
      if (!isClosed) {
        await PermissionHelper.handleImagePickerError(
          error,
          permissionName: source == ImageSource.camera ? 'Camera' : 'Photos',
        );
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  /// The API accepts one garment. Replace it only after the new image is ready.
  void setClothingImage(
    File image, {
    ItemModel? wardrobeItem,
    bool temporary = false,
  }) {
    _cleanupTempFiles();
    clothingImage.value = image;
    selectedWardrobeItem.value = wardrobeItem;
    if (temporary) tempFiles.add(image);
    error.value = '';
    _clearGeneratedResult();
  }

  void removeCurrentImage() {
    if (isGenerating.value || isLoading.value) return;
    _cleanupTempFiles();
    clothingImage.value = null;
    selectedWardrobeItem.value = null;
    error.value = '';
    _clearGeneratedResult();
  }

  /// Downloads the chosen garment before replacing the current selection.
  Future<bool> pickClothingFromWardrobe(ItemModel item) async {
    if (isLoading.value || isGenerating.value) return false;
    if (selectedWardrobeItem.value?.id == item.id) return true;
    if (item.itemImages == null || item.itemImages!.isEmpty) {
      error.value = 'This item has no photo. Choose another garment.';
      return false;
    }

    isLoading.value = true;
    error.value = '';
    final primaryImage = item.itemImages!.firstWhere(
      (image) => image.isPrimary,
      orElse: () => item.itemImages!.first,
    );
    final file = File(
      '${Directory.systemTemp.path}/tryon_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    try {
      try {
        await _apiClient.dio.download(primaryImage.url, file.path);
      } catch (_) {
        final storagePath = primaryImage.storagePath;
        if (storagePath == null || storagePath.isEmpty) rethrow;
        final freshUrl = await ItemRepository().remintImageUrl(storagePath);
        if (freshUrl == null || freshUrl.isEmpty) rethrow;
        await _apiClient.dio.download(freshUrl, file.path);
      }
      if (isClosed) {
        if (file.existsSync()) file.deleteSync();
        return false;
      }
      setClothingImage(file, wardrobeItem: item, temporary: true);
      return true;
    } catch (e) {
      if (file.existsSync()) file.deleteSync();
      if (!isClosed) error.value = ErrorHandler.extractMessage(e);
      return false;
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> uploadUserAvatar() async {
    if (isGenerating.value || isUploadingAvatar.value) return;
    // Third-party AI data-sharing consent gate (Apple 5.1.2(i)) — the avatar
    // (face photo) is sent to AI providers for generation.
    if (!await Get.find<AiConsentService>().ensureConsent(
      featureLabel: 'Virtual Try-On',
    )) {
      return;
    }

    if (!await PermissionHelper.confirmPhotoRationale()) return;

    XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 75,
      );
    } catch (error) {
      if (!isClosed) {
        await PermissionHelper.handleImagePickerError(
          error,
          permissionName: 'Photos',
        );
      }
      return;
    }
    if (isClosed) return;

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

        final data = extractDataMap(response.data);
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
    if (isGenerating.value || isLoading.value || isUploadingAvatar.value) {
      return;
    }
    if (clothingImage.value == null) {
      ErrorHandler.showValidation(
        'Please select a clothing image first',
        title: 'Error',
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
      // The busy state starts before consent so a second tap cannot start a
      // second billable generation while the consent sheet is open.
      if (!await Get.find<AiConsentService>().ensureConsent(
            featureLabel: 'Virtual Try-On',
          ) ||
          isClosed) {
        return;
      }
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

      final result = extractDataMap(response.data);
      final imageUrl = result['image_url']?.toString() ?? '';
      final imageBase64 = result['image_base64']?.toString() ?? '';
      if (imageUrl.isEmpty && imageBase64.isEmpty) {
        throw Exception('No image returned from server');
      }
      if (isClosed) return;
      generatedImageUrl.value = imageUrl;
      generatedImageBase64.value = imageBase64;

      ErrorHandler.showSuccess(
        'Try-on generated successfully',
        title: 'Success',
      );
    } catch (e) {
      if (!isClosed) {
        error.value = ErrorHandler.extractMessage(e);
        ErrorHandler.showError(error.value, title: 'Error');
      }
    } finally {
      if (!isClosed) isGenerating.value = false;
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
      // URL-first: the backend persists the render and returns image_url;
      // the inline base64 fallback only appears if the storage write fails.
      'save_to_storage': true,
    };
  }

  /// Any change to the input garment (pick, switch, remove) invalidates the
  /// previously generated result so it can never be presented as matching the
  /// current selection.
  void _clearGeneratedResult() {
    generatedImageUrl.value = '';
    generatedImageBase64.value = '';
  }

  /// Normalize an API response payload to its result map.
  ///
  /// Accepts the canonical envelope (`{"data": {...}}`), the bare result
  /// object, and an ARRAY wrapper (`[{"data": {...}}]` / `[{...}]`) — some
  /// deployments have been observed returning array-wrapped generation
  /// results, which would otherwise surface as an empty map and a bogus
  /// "No image returned from server" error.
  @visibleForTesting
  static Map<String, dynamic> extractDataMap(dynamic payload) {
    dynamic candidate = payload;
    if (payload is List) {
      candidate = payload.isNotEmpty ? payload.first : null;
    }
    if (candidate is Map<String, dynamic>) {
      final data = candidate['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      // Bare result object (no envelope).
      return candidate;
    }
    return <String, dynamic>{};
  }
}

String _encodeBase64(Uint8List bytes) => base64Encode(bytes);
