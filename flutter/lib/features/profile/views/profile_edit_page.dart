import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Edit profile page
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final Rx<File?> newAvatar = Rx<File?>(null);
  final RxBool isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    // TODO: Get user data from auth controller
    _nameController = TextEditingController(text: 'User Name');
    _bioController = TextEditingController(text: 'Fashion enthusiast');
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      newAvatar.value = File(image.path);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    isSaving.value = true;

    try {
      // TODO: Implement profile update
      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.TOP,
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
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                children: [
                  // Avatar section
                  Obx(() => GestureDetector(
                        onTap: _pickAvatar,
                        child: AppGlassCard(
                          padding: const EdgeInsets.all(AppConstants.spacing20),
                          child: Row(
                            children: [
                              Obx(() {
                                final avatar = newAvatar.value;

                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: tokens.brandColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: avatar != null
                                        ? Image.file(
                                            avatar,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: tokens.brandColor,
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              }),
                              const SizedBox(width: AppConstants.spacing16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profile Photo',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: AppConstants.spacing4),
                                    Text(
                                      'Tap to change',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: tokens.textMuted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.camera_alt,
                                color: tokens.brandColor,
                              ),
                            ],
                          ),
                        ),
                      )),

                  const SizedBox(height: AppConstants.spacing24),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  // Bio field
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
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
}
