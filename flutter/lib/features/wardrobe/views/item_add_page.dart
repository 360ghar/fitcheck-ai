import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/item_add_controller.dart';
import '../widgets/ai_extraction_widget.dart';
import '../widgets/manual_entry_form.dart';

/// Page for adding new items to wardrobe
/// Supports: Camera capture, Gallery pick, Manual entry
class ItemAddPage extends StatefulWidget {
  const ItemAddPage({super.key});

  @override
  State<ItemAddPage> createState() => _ItemAddPageState();
}

class _ItemAddPageState extends State<ItemAddPage> {
  final ItemAddController controller = Get.put(ItemAddController());
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    Get.delete<ItemAddController>();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      controller.processImage(File(image.path));
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      controller.processImage(File(image.path));
    }
  }

  void _showManualEntry() {
    Get.to(() => const ManualEntryForm());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: Obx(() {
            // Show AI extraction when processing
            if (controller.isProcessing.value && controller.selectedImage.value != null) {
              return AIExtractionWidget(
                imageFile: controller.selectedImage.value!,
                extractionResult: controller.extractionResult.value,
                isProcessing: controller.isProcessing.value,
                onRetake: () => controller.reset(),
                onSaveExtracted: (items) => controller.saveExtractedItems(items),
                onManualEntry: () => controller.proceedToManualEntry(),
              );
            }

            // Show manual entry form when user skipped AI
            if (controller.showManualEntry.value) {
              return ManualEntryForm(
                imageFile: controller.selectedImage.value,
              );
            }

            // Show initial options
            return _buildInitialOptions(tokens);
          }),
        ),
      ),
    );
  }

  Widget _buildInitialOptions(AppUiTokens tokens) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      children: [
        const SizedBox(height: AppConstants.spacing24),

        // Header
        Text(
          'Add to Your Wardrobe',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing8),
        Text(
          'Choose how you want to add your item',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.textMuted,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.spacing32),

        // Camera Option
        AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: InkWell(
            onTap: _pickFromCamera,
            borderRadius: BorderRadius.circular(AppConstants.radius16),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: tokens.brandColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 32,
                    color: tokens.brandColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  'Take Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Use your camera to capture the item',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Gallery Option
        AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: InkWell(
            onTap: _pickFromGallery,
            borderRadius: BorderRadius.circular(AppConstants.radius16),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: tokens.brandColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library,
                    size: 32,
                    color: tokens.brandColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  'Choose from Gallery',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Select an existing photo from your device',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Manual Entry Option
        AppGlassCard(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: InkWell(
            onTap: _showManualEntry,
            borderRadius: BorderRadius.circular(AppConstants.radius16),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: tokens.brandColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 32,
                    color: tokens.brandColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Text(
                  'Enter Manually',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Add item details without a photo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacing24),

        // Info text
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing12),
          decoration: BoxDecoration(
            color: tokens.brandColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radius12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: tokens.brandColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Text(
                  'AI will automatically detect items from your photo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.brandColor,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing12),
      ],
    );
  }
}
