import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/condition.dart' as domain;
import '../controllers/wardrobe_controller.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';

/// Edit page for a single wardrobe item
class ItemEditPage extends StatefulWidget {
  final String itemId;

  const ItemEditPage({
    super.key,
    required this.itemId,
  });

  @override
  State<ItemEditPage> createState() => _ItemEditPageState();
}

class _ItemEditPageState extends State<ItemEditPage> {
  final _formKey = GlobalKey<FormState>();
  final WardrobeController _wardrobeController = Get.find<WardrobeController>();
  final ItemRepository _itemRepository = ItemRepository();

  // Text controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _brandController;
  late TextEditingController _sizeController;
  late TextEditingController _materialController;
  late TextEditingController _patternController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;

  // Reactive state
  final Rx<Category> selectedCategory = Category.tops.obs;
  final Rx<domain.Condition> selectedCondition = domain.Condition.clean.obs;
  final RxSet<String> selectedColors = <String>{}.obs;
  final RxSet<String> selectedTags = <String>{}.obs;
  final RxBool isSaving = false.obs;
  final RxList<File> newImages = <File>[].obs;
  final RxSet<String> imagesToDelete = <String>{}.obs;

  final ImagePicker _imagePicker = ImagePicker();

  // Common color options
  static const List<String> commonColors = [
    'Black', 'White', 'Gray', 'Red', 'Blue', 'Green', 'Yellow',
    'Pink', 'Purple', 'Orange', 'Brown', 'Beige', 'Navy', 'Cream',
  ];

  ItemModel? _item;

  @override
  void initState() {
    super.initState();
    _item = _wardrobeController.items.firstWhereOrNull((i) => i.id == widget.itemId);
    if (_item != null) {
      _initializeControllers(_item!);
    }
  }

  void _initializeControllers(ItemModel item) {
    _nameController = TextEditingController(text: item.name);
    _descriptionController = TextEditingController(text: item.description ?? '');
    _brandController = TextEditingController(text: item.brand ?? '');
    _sizeController = TextEditingController(text: item.size ?? '');
    _materialController = TextEditingController(text: item.material ?? '');
    _patternController = TextEditingController(text: item.pattern ?? '');
    _priceController = TextEditingController(text: item.price?.toString() ?? '');
    _locationController = TextEditingController(text: item.location ?? '');

    selectedCategory.value = item.category;
    selectedCondition.value = item.condition;
    if (item.colors != null) selectedColors.addAll(item.colors!);
    if (item.tags != null) selectedTags.addAll(item.tags!);
  }

  Future<void> _pickImage() async {
    // Use pickMultipleMedia to select multiple images at once
    final List<XFile> images = await _imagePicker.pickMultipleMedia(
      imageQuality: 85,
    );

    for (final image in images) {
      // Only add image files
      if (image.path.endsWith('.jpg') ||
          image.path.endsWith('.jpeg') ||
          image.path.endsWith('.png')) {
        newImages.add(File(image.path));
      }
    }

    if (images.isNotEmpty && mounted) {
      Get.snackbar(
        'Images Added',
        '${images.length} image(s) added',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      newImages.add(File(image.path));
    }
  }

  void _toggleImageDelete(String imageId) {
    if (imagesToDelete.contains(imageId)) {
      imagesToDelete.remove(imageId);
    } else {
      imagesToDelete.add(imageId);
    }
    imagesToDelete.refresh();
  }

  void _removeNewImage(int index) {
    newImages.removeAt(index);
    newImages.refresh();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    isSaving.value = true;

    try {
      final request = UpdateItemRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _nameController.text.trim() != _item!.name ? selectedCategory.value : null,
        colors: selectedColors.isEmpty ? null : selectedColors.toList(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        size: _sizeController.text.trim().isEmpty ? null : _sizeController.text.trim(),
        material: _materialController.text.trim().isEmpty ? null : _materialController.text.trim(),
        pattern: _patternController.text.trim().isEmpty ? null : _patternController.text.trim(),
        condition: selectedCondition.value,
        price: _priceController.text.trim().isEmpty
            ? null
            : double.tryParse(_priceController.text.trim()),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        tags: selectedTags.isEmpty ? null : selectedTags.toList(),
      );

      // Update item
      final updated = await _itemRepository.updateItem(widget.itemId, request);

      // Delete images if any
      for (final imageId in imagesToDelete) {
        await _itemRepository.deleteItemImage(widget.itemId, imageId);
      }

      // Upload new images if any
      if (newImages.isNotEmpty) {
        await _itemRepository.uploadImages(widget.itemId, newImages);
      }

      // Refresh wardrobe
      _wardrobeController.fetchItems(refresh: true);

      Get.back();
      Get.snackbar(
        'Success',
        'Item updated successfully',
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _materialController.dispose();
    _patternController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Item')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: isSaving.value ? null : _saveChanges,
            child: isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
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
                  // Images section
                  _buildImagesSection(tokens),

                  const SizedBox(height: AppConstants.spacing24),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name *',
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
                  Obx(() => DropdownButtonFormField<Category>(
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
                      )),

                  const SizedBox(height: AppConstants.spacing16),

                  // Condition
                  Obx(() => DropdownButtonFormField<domain.Condition>(
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
                      )),

                  const SizedBox(height: AppConstants.spacing16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Colors
                  _buildColorSelector(tokens),

                  const SizedBox(height: AppConstants.spacing16),

                  // Brand, Size, Material row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
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
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Price & Location row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Storage Location',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacing24),

                  // Delete button
                  OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Item'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection(AppUiTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                TextButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
          ],
        ),

        if (_item!.itemImages != null && _item!.itemImages!.isNotEmpty || newImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images
                ...?_item!.itemImages!.map((image) {
                  final isDeleting = imagesToDelete.contains(image.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radius8),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: AppImage(
                              imageUrl: image.url,
                              fit: BoxFit.contain,
                              enableZoom: false,
                              backgroundColor: isDeleting
                                  ? Colors.black.withOpacity(0.5)
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            backgroundColor: isDeleting ? Colors.red : Colors.white,
                            child: IconButton(
                              icon: Icon(
                                isDeleting ? Icons.close : Icons.delete_outline,
                                color: isDeleting ? Colors.white : Colors.black,
                              ),
                              onPressed: () => _toggleImageDelete(image.id),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // New images
                ...newImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radius8),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.file(
                              image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.black),
                              onPressed: () => _removeNewImage(index),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

        // Empty state
        if ((_item!.itemImages == null || _item!.itemImages!.isEmpty) && newImages.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: tokens.cardBorderColor),
              borderRadius: BorderRadius.circular(AppConstants.radius8),
            ),
            child: Center(
              child: Text(
                'No photos yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ),
          ),
      ],
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

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('This action cannot be undone. The item will be permanently removed from your wardrobe.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              try {
                await _itemRepository.deleteItem(widget.itemId);
                _wardrobeController.fetchItems(refresh: true);
                Get.back(); // Close edit page
                Get.snackbar(
                  'Deleted',
                  'Item removed from wardrobe',
                  snackPosition: SnackPosition.TOP,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  e.toString().replaceAll('Exception: ', ''),
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
