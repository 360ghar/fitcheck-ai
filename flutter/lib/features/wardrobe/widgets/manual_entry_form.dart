import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../controllers/item_add_controller.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';

/// Manual entry form for adding items
/// Can be used with or without an image
class ManualEntryForm extends StatefulWidget {
  final File? imageFile;

  const ManualEntryForm({
    super.key,
    this.imageFile,
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

  final Rx<Category> selectedCategory = Category.tops.obs;
  final Rx<domain.Condition> selectedCondition = domain.Condition.clean.obs;
  final RxSet<String> selectedColors = <String>{}.obs;
  final RxSet<String> selectedTags = <String>{}.obs;
  final RxBool isSaving = false.obs;
  final Rx<File?> additionalImage = Rx<File?>(null);

  final ImagePicker _imagePicker = ImagePicker();

  // Common color options
  static const List<String> commonColors = [
    'Black', 'White', 'Gray', 'Red', 'Blue', 'Green', 'Yellow',
    'Pink', 'Purple', 'Orange', 'Brown', 'Beige', 'Navy', 'Cream',
  ];

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    isSaving.value = true;

    try {
      final controller = Get.find<ItemAddController>();

      // Use provided image or additional image
      final imageToUse = widget.imageFile ?? additionalImage.value;

      if (imageToUse == null) {
        Get.snackbar(
          'Image Required',
          'Please add a photo of the item',
          snackPosition: SnackPosition.TOP,
        );
        isSaving.value = false;
        return;
      }

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
      );

      final created = await ItemRepository().createItemWithImage(
        image: imageToUse,
        request: request,
      );

      Get.back(); // Close form
      Get.back(); // Close item add page
      Get.snackbar(
        'Success',
        '"${created.name}" added to your wardrobe',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _pickAdditionalImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      additionalImage.value = File(image.path);
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item Details'),
        elevation: 0,
      ),
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
                  Obx(() => ElevatedButton(
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
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(AppUiTokens tokens) {
    final image = widget.imageFile ?? additionalImage.value;

    if (image != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            child: Image.file(
              image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: AppConstants.spacing8,
            right: AppConstants.spacing8,
            child: CircleAvatar(
              backgroundColor: tokens.cardColor,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.imageFile != null
                    ? null
                    : () => additionalImage.value = null,
              ),
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
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: tokens.brandColor.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radius12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: tokens.brandColor,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Add Photo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.brandColor,
                  ),
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
      value: selectedCategory.value,
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
      value: selectedCondition.value,
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
              selectedColor: tokens.brandColor.withOpacity(0.2),
              checkmarkColor: tokens.brandColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
