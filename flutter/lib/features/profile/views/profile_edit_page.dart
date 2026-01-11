import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../auth/controllers/auth_controller.dart';
import '../repositories/profile_repository.dart';

/// Edit profile page
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final ProfileRepository _repository = ProfileRepository();

  late TextEditingController _nameController;
  final Rx<File?> newAvatar = Rx<File?>(null);
  final RxBool isSaving = false.obs;

  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.user.value;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _currentAvatarUrl = user?.avatarUrl;
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
      String? avatarUrl = _currentAvatarUrl;

      // Upload avatar if changed
      if (newAvatar.value != null) {
        avatarUrl = await _repository.uploadAvatar(newAvatar.value!);
      }

      // Update profile
      await _repository.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      // Refresh user data in AuthController
      final authController = Get.find<AuthController>();
      await authController.refreshUser();

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
                  GestureDetector(
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
                                    : _currentAvatarUrl != null &&
                                            _currentAvatarUrl!.isNotEmpty
                                        ? Image.network(
                                            _currentAvatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _buildAvatarPlaceholder(
                                                        tokens),
                                          )
                                        : _buildAvatarPlaceholder(tokens),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                Text(
                                  'Tap to change',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
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
                  ),

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

                  const SizedBox(height: AppConstants.spacing32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(AppUiTokens tokens) {
    return Container(
      color: tokens.brandColor,
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
