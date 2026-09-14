import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/constants/use_cases.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../services/wardrobe_sync_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/permission_helper.dart';

/// Manual entry form for adding items
/// Can be used with or without an image
class ManualEntryForm extends StatefulWidget {
  final File? imageFile;
  final ItemRepository? repository;
  final ImagePicker? imagePicker;
  final ValueChanged<ItemModel>? onSaved;

  const ManualEntryForm({
    super.key,
    this.imageFile,
    this.repository,
    this.imagePicker,
    this.onSaved,
  });

  @override
  State<ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<ManualEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();
  final _materialController = TextEditingController();
  final _patternController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();
  final _locationController = TextEditingController();
  final _customUseCaseController = TextEditingController();

  final Rx<Category> selectedCategory = Category.tops.obs;
  final Rx<domain.Condition> selectedCondition = domain.Condition.clean.obs;
  final RxSet<String> selectedColors = <String>{}.obs;
  final RxSet<String> selectedTags = <String>{}.obs;
  final RxSet<String> selectedUseCases = <String>{}.obs;
  final RxBool isSaving = false.obs;
  final RxList<File> additionalImages = <File>[].obs;

  late final ImagePicker _imagePicker = widget.imagePicker ?? ImagePicker();
  late final ItemRepository _repository = widget.repository ?? ItemRepository();

  // Common color options
  static const List<String> commonColors = [
    'Black',
    'White',
    'Gray',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Pink',
    'Purple',
    'Orange',
    'Brown',
    'Beige',
    'Navy',
    'Cream',
  ];

  void _submitForm() async {
    if (isSaving.value || !_formKey.currentState!.validate()) return;

    isSaving.value = true;

    try {
      final photos = [
        if (widget.imageFile != null) widget.imageFile!,
        ...additionalImages,
      ];

      // A10-02: "Add item details without a photo" is the advertised flow and
      // the backend supports photo-less items (createItem posts no image) —
      // the old hard block ("Image Required") contradicted the card copy.
      final request = CreateItemRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: selectedCategory.value,
        colors: selectedColors.isEmpty ? null : selectedColors.toList(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        size: _sizeController.text.trim().isEmpty
            ? null
            : _sizeController.text.trim(),
        material: _materialController.text.trim().isEmpty
            ? null
            : _materialController.text.trim(),
        pattern: _patternController.text.trim().isEmpty
            ? null
            : _patternController.text.trim(),
        condition: selectedCondition.value,
        price: _priceController.text.trim().isEmpty
            ? null
            : double.tryParse(_priceController.text.trim()),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        tags: selectedTags.isEmpty ? null : selectedTags.toList(),
        occasionTags: selectedUseCases.isEmpty
            ? null
            : UseCases.normalizeList(selectedUseCases),
      );

      var created = await _repository.createItem(request);
      var failedUploads = 0;
      // Use one upload path for every selected photo. A supplied primary photo
      // plus one added photo must not skip the added photo.
      for (final photo in photos) {
        try {
          final uploaded = await _repository.uploadImages(created.id, [photo]);
          if (uploaded.isEmpty) {
            failedUploads++;
          } else {
            created = created.copyWith(
              itemImages: [...?created.itemImages, ...uploaded],
            );
          }
        } catch (e, stackTrace) {
          failedUploads++;
          ErrorHandler.reportError(
            e,
            'Manual item photo upload failed',
            stackTrace: stackTrace,
          );
        }
      }

      // Keep the closet list in sync (FL5 pattern — go through
      // WardrobeSyncService, not Get.find on the controller directly).
      final sync = Get.isRegistered<WardrobeSyncService>()
          ? Get.find<WardrobeSyncService>()
          : WardrobeSyncService();
      sync.addItem(created);

      if (!mounted) return;
      if (widget.onSaved != null) {
        widget.onSaved!(created);
      } else {
        Navigator.of(context).pop(created);
      }
      // Present the save result after the navigation frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (failedUploads > 0) {
          ErrorHandler.showWarning(
            'Item saved. $failedUploads ${failedUploads == 1 ? 'photo' : 'photos'} could not upload. '
            'Open Edit Item to add them again.',
            title: 'Some Photos Need Attention',
          );
        } else {
          ErrorHandler.showSuccess(
            '"${created.name}" added to your closet',
            title: 'Success',
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(ErrorHandler.extractMessage(e), title: 'Error');
      }
    } finally {
      if (mounted) isSaving.value = false;
    }
  }

  Future<void> _pickAdditionalImage() async {
    if (isSaving.value) return;
    // Use pickMultipleMedia to select multiple images at once
    List<XFile> images;
    try {
      images = await _imagePicker.pickMultipleMedia(imageQuality: 85);
    } catch (error) {
      if (mounted) {
        await PermissionHelper.handleImagePickerError(
          error,
          permissionName: 'Photos',
        );
      }
      return;
    }
    if (!mounted) return;

    for (final image in images) {
      // Only add image files (case-insensitive check)
      final path = image.path.toLowerCase();
      if (path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.webp') ||
          path.endsWith('.heic') ||
          path.endsWith('.heif') ||
          path.endsWith('.bmp') ||
          path.endsWith('.tif') ||
          path.endsWith('.tiff')) {
        additionalImages.add(File(image.path));
      }
    }
  }

  void _removeAdditionalImage(int index) {
    additionalImages.removeAt(index);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _materialController.dispose();
    _patternController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    _locationController.dispose();
    _customUseCaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item Details'), elevation: 0),
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image preview
                  Obx(() => _buildImagePreview(tokens)),

                  const SizedBox(height: AppConstants.spacing16),

                  // Required fields section
                  _buildSectionHeader('Required', tokens),

                  const SizedBox(height: AppConstants.spacing8),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name *',
                      hintText: 'e.g., Blue Cotton T-Shirt',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an item name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Category
                  Obx(() => _buildCategoryDropdown(tokens)),

                  const SizedBox(height: AppConstants.spacing16),

                  // Condition
                  Obx(() => _buildConditionDropdown(tokens)),

                  const SizedBox(height: AppConstants.spacing24),

                  // Optional fields section
                  _buildSectionHeader('Optional Details', tokens),

                  const SizedBox(height: AppConstants.spacing8),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add any notes about this item...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Colors
                  Obx(() => _buildColorSelector(tokens)),

                  const SizedBox(height: AppConstants.spacing16),

                  // Use cases
                  Obx(() => _buildUseCaseSelector(tokens)),

                  const SizedBox(height: AppConstants.spacing16),

                  // Brand & Size row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            hintText: 'e.g., Nike',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: TextFormField(
                          controller: _sizeController,
                          decoration: const InputDecoration(
                            labelText: 'Size',
                            hintText: 'e.g., M',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Material & Pattern row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _materialController,
                          decoration: const InputDecoration(
                            labelText: 'Material',
                            hintText: 'e.g., Cotton',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: TextFormField(
                          controller: _patternController,
                          decoration: const InputDecoration(
                            labelText: 'Pattern',
                            hintText: 'e.g., Solid',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'e.g., 49.99',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Location',
                      hintText: 'e.g., Closet A, Shelf 2',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing24),

                  // Save button
                  Obx(
                    () => ElevatedButton(
                      onPressed: isSaving.value ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(AppUiTokens tokens) {
    final hasMainImage = widget.imageFile != null;
    final hasAdditionalImages = additionalImages.isNotEmpty;
    // When no main image, the first additional image is shown as preview
    final extraCount = hasMainImage
        ? additionalImages.length
        : (additionalImages.length - 1);

    if (hasMainImage || hasAdditionalImages) {
      // Build list of all images to display
      final List<File> allImages = [];
      if (hasMainImage) allImages.add(widget.imageFile!);
      allImages.addAll(additionalImages);

      return Column(
        children: [
          // Main image preview
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radius12),
                child: Image.file(
                  widget.imageFile ?? additionalImages.first,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              if (extraCount > 0)
                Positioned(
                  top: AppConstants.spacing8,
                  left: AppConstants.spacing8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing8,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.cardColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                    ),
                    child: Text(
                      '+$extraCount more',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ),
              if (!hasMainImage && allImages.isNotEmpty)
                Positioned(
                  top: AppConstants.spacing8,
                  right: AppConstants.spacing8,
                  child: IconButton.filled(
                    tooltip: 'Remove all photos',
                    onPressed: () => additionalImages.clear(),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      backgroundColor: tokens.cardColor,
                      foregroundColor: tokens.textPrimary,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ),
            ],
          ),

          // Show additional images as thumbnails
          if (hasAdditionalImages && allImages.length > 1)
            Container(
              height: 80,
              margin: const EdgeInsets.only(top: AppConstants.spacing8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: additionalImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radius8,
                          ),
                          child: Image.file(
                            additionalImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton.filled(
                            tooltip: 'Remove photo ${index + 1}',
                            onPressed: () => _removeAdditionalImage(index),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              backgroundColor: tokens.cardColor.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: tokens.textPrimary,
                            ),
                            icon: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Add more images button
          const SizedBox(height: AppConstants.spacing8),
          OutlinedButton.icon(
            onPressed: _pickAdditionalImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add More Photos'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ],
      );
    }

    // Upload placeholder
    return InkWell(
      onTap: _pickAdditionalImage,
      borderRadius: BorderRadius.circular(AppConstants.radius12),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200),
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          border: Border.all(
            color: tokens.brandColor.withValues(alpha: 0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radius12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: tokens.brandColor),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Add Photo (Multiple)',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: tokens.brandColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppUiTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacing4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: tokens.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(AppUiTokens tokens) {
    return DropdownButtonFormField<Category>(
      isExpanded: true,
      initialValue: selectedCategory.value,
      decoration: const InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(),
      ),
      items: Category.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) selectedCategory.value = value;
      },
    );
  }

  Widget _buildConditionDropdown(AppUiTokens tokens) {
    return DropdownButtonFormField<domain.Condition>(
      isExpanded: true,
      initialValue: selectedCondition.value,
      decoration: const InputDecoration(
        labelText: 'Condition *',
        border: OutlineInputBorder(),
      ),
      items: domain.Condition.values.map((condition) {
        return DropdownMenuItem(
          value: condition,
          child: Text(condition.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) selectedCondition.value = value;
      },
    );
  }

  Widget _buildColorSelector(AppUiTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colors',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        Wrap(
          spacing: AppConstants.spacing8,
          runSpacing: AppConstants.spacing8,
          children: commonColors.map((color) {
            final isSelected = selectedColors.contains(color);
            return FilterChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  selectedColors.add(color);
                } else {
                  selectedColors.remove(color);
                }
                selectedColors.refresh();
              },
              selectedColor: tokens.brandColor.withValues(alpha: 0.2),
              checkmarkColor: tokens.brandColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUseCaseSelector(AppUiTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Use Cases',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacing8),
        Wrap(
          spacing: AppConstants.spacing8,
          runSpacing: AppConstants.spacing8,
          children: UseCases.defaults.map((useCase) {
            final isSelected = selectedUseCases.contains(useCase);
            return FilterChip(
              label: Text(UseCases.displayLabel(useCase)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  selectedUseCases.add(useCase);
                } else {
                  selectedUseCases.remove(useCase);
                }
                selectedUseCases.refresh();
              },
              selectedColor: tokens.brandColor.withValues(alpha: 0.2),
              checkmarkColor: tokens.brandColor,
            );
          }).toList(),
        ),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customUseCaseController,
                decoration: const InputDecoration(
                  labelText: 'Custom use case',
                  hintText: 'e.g., brunch',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _addCustomUseCase(),
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            OutlinedButton(
              onPressed: _addCustomUseCase,
              child: const Text('Add'),
            ),
          ],
        ),
        if (selectedUseCases.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacing8),
          Wrap(
            spacing: AppConstants.spacing8,
            runSpacing: AppConstants.spacing8,
            children: selectedUseCases.map((useCase) {
              return Chip(
                label: Text(UseCases.displayLabel(useCase)),
                onDeleted: () {
                  selectedUseCases.remove(useCase);
                  selectedUseCases.refresh();
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _addCustomUseCase() {
    final normalized = UseCases.normalize(_customUseCaseController.text);
    if (normalized.isEmpty) return;
    selectedUseCases.add(normalized);
    selectedUseCases.refresh();
    _customUseCaseController.clear();
  }
}
