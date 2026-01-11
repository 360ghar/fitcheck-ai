import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../../../domain/enums/season.dart';
import '../controllers/outfit_list_controller.dart';
import '../models/outfit_model.dart';

/// Edit page for an existing outfit
class OutfitEditPage extends StatefulWidget {
  final String outfitId;

  const OutfitEditPage({
    super.key,
    required this.outfitId,
  });

  @override
  State<OutfitEditPage> createState() => _OutfitEditPageState();
}

class _OutfitEditPageState extends State<OutfitEditPage> {
  final _formKey = GlobalKey<FormState>();
  final OutfitListController _outfitsController = Get.find<OutfitListController>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;

  final Rx<Style?> selectedStyle = Rx<Style?>(null);
  final Rx<Season?> selectedSeason = Rx<Season?>(null);
  final RxString selectedOccasion = ''.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isDraft = false.obs;
  final RxBool isPublic = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<File> newImages = <File>[].obs;
  final RxSet<String> imagesToDelete = <String>{}.obs;

  final ImagePicker _imagePicker = ImagePicker();

  OutfitModel? _outfit;

  // Occasion options
  static const List<String> occasions = [
    'casual', 'formal', 'business', 'sporty', 'date night',
    'party', 'wedding', 'interview', 'weekend', 'travel'
  ];

  @override
  void initState() {
    super.initState();
    _outfit = _outfitsController.outfits.firstWhereOrNull((o) => o.id == widget.outfitId);
    if (_outfit != null) {
      _initializeControllers(_outfit!);
    }
  }

  void _initializeControllers(OutfitModel outfit) {
    _nameController = TextEditingController(text: outfit.name);
    _descriptionController = TextEditingController(text: outfit.description ?? '');
    _tagsController = TextEditingController(text: outfit.tags?.join(', ') ?? '');
    selectedStyle.value = outfit.style;
    selectedSeason.value = outfit.season;
    selectedOccasion.value = outfit.occasion ?? '';
    isFavorite.value = outfit.isFavorite;
    isDraft.value = outfit.isDraft;
    isPublic.value = outfit.isPublic;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      newImages.add(File(image.path));
    }
  }

  void _removeNewImage(int index) {
    newImages.removeAt(index);
    newImages.refresh();
  }

  void _toggleImageDelete(String imageId) {
    if (imagesToDelete.contains(imageId)) {
      imagesToDelete.remove(imageId);
    } else {
      imagesToDelete.add(imageId);
    }
    imagesToDelete.refresh();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    isSaving.value = true;

    try {
      final request = UpdateOutfitRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        style: selectedStyle.value,
        season: selectedSeason.value,
        occasion: selectedOccasion.value.isEmpty ? null : selectedOccasion.value,
        tags: _tagsController.text.trim().isEmpty
            ? null
            : _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        isFavorite: isFavorite.value,
        isDraft: isDraft.value,
        isPublic: isPublic.value,
      );

      await _outfitsController.updateOutfit(widget.outfitId, request);

      // Handle image deletions
      for (final imageId in imagesToDelete) {
        // Would call delete API here
      }

      // Upload new images
      if (newImages.isNotEmpty) {
        // Would call upload API here
      }

      _outfitsController.fetchOutfits(refresh: true);

      Get.back();
      Get.snackbar(
        'Success',
        'Outfit updated successfully',
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
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    if (_outfit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Outfit')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Outfit'),
        elevation: 0,
        actions: [
          Obx(() => TextButton(
                onPressed: isSaving.value ? null : _saveChanges,
                child: isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              )),
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
                      labelText: 'Outfit Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an outfit name';
                      }
                      return null;
                    },
                  ),

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

                  // Style & Season row
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<Style>(
                              value: selectedStyle.value,
                              decoration: const InputDecoration(
                                labelText: 'Style',
                                border: OutlineInputBorder(),
                              ),
                              items: Style.values.map((style) {
                                return DropdownMenuItem(
                                  value: style,
                                  child: Text(style.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedStyle.value = value;
                              },
                            )),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<Season>(
                              value: selectedSeason.value,
                              decoration: const InputDecoration(
                                labelText: 'Season',
                                border: OutlineInputBorder(),
                              ),
                              items: Season.values.map((season) {
                                return DropdownMenuItem(
                                  value: season,
                                  child: Text(season.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedSeason.value = value;
                              },
                            )),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Occasion
                  Obx(() => DropdownButtonFormField<String>(
                        value: selectedOccasion.value.isEmpty ? null : selectedOccasion.value,
                        decoration: const InputDecoration(
                          labelText: 'Occasion',
                          border: OutlineInputBorder(),
                        ),
                        items: occasions.map((occasion) {
                          return DropdownMenuItem(
                            value: occasion,
                            child: Text(occasion.split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) selectedOccasion.value = value;
                        },
                      )),

                  const SizedBox(height: AppConstants.spacing16),

                  // Tags
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing24),

                  // Toggles section
                  AppGlassCard(
                    child: Column(
                      children: [
                        Obx(() => SwitchListTile(
                              title: const Text('Favorite'),
                              subtitle: const Text('Add to your favorites'),
                              value: isFavorite.value,
                              onChanged: (value) => isFavorite.value = value,
                            )),
                        const Divider(),
                        Obx(() => SwitchListTile(
                              title: const Text('Draft'),
                              subtitle: const Text('Save as draft (not visible in main list)'),
                              value: isDraft.value,
                              onChanged: (value) => isDraft.value = value,
                            )),
                        const Divider(),
                        Obx(() => SwitchListTile(
                              title: const Text('Public'),
                              subtitle: const Text('Allow sharing with public link'),
                              value: isPublic.value,
                              onChanged: (value) => isPublic.value = value,
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing32),

                  // Delete button
                  OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Outfit'),
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
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photo'),
            ),
          ],
        ),

        if (_outfit!.outfitImages != null && _outfit!.outfitImages!.isNotEmpty || newImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images
                ...?_outfit!.outfitImages!.map((image) {
                  final isDeleting = imagesToDelete.contains(image.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radius8),
                          child: CachedNetworkImage(
                            imageUrl: image.url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            color: isDeleting ? Colors.black.withOpacity(0.5) : null,
                            colorBlendMode: isDeleting ? BlendMode.srcOver : null,
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
                                size: 16,
                              ),
                              onPressed: () => _toggleImageDelete(image.id),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              padding: EdgeInsets.zero,
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
                          child: Image.file(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.black, size: 16),
                              onPressed: () => _removeNewImage(index),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              padding: EdgeInsets.zero,
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
      ],
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Outfit?'),
        content: const Text('This action cannot be undone. The outfit will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await _outfitsController.deleteOutfit(widget.outfitId);
                Get.back(); // Close edit page
                Get.snackbar(
                  'Deleted',
                  'Outfit removed successfully',
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
