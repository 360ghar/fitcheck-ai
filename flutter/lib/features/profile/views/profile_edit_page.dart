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
  late TextEditingController _birthDateController;
  late TextEditingController _birthTimeController;
  late TextEditingController _birthPlaceController;
  final Rx<File?> newAvatar = Rx<File?>(null);
  final RxBool isSaving = false.obs;

  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.user.value;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _birthDateController = TextEditingController(text: user?.birthDate ?? '');
    _birthTimeController = TextEditingController(
      text: _toTimeInput(user?.birthTime),
    );
    _birthPlaceController = TextEditingController(text: user?.birthPlace ?? '');
    _currentAvatarUrl = user?.avatarUrl;

    _loadProfileDetails();
  }

  Future<void> _loadProfileDetails() async {
    try {
      final profile = await _repository.getProfile();
      if (!mounted) return;

      final birthDate = profile['birth_date']?.toString() ?? '';
      final birthTime = _toTimeInput(profile['birth_time']?.toString());
      final birthPlace = profile['birth_place']?.toString() ?? '';
      final fullName = profile['full_name']?.toString();
      final avatarUrl = profile['avatar_url']?.toString();

      setState(() {
        if (fullName != null && fullName.isNotEmpty) {
          _nameController.text = fullName;
        }
        _birthDateController.text = birthDate;
        _birthTimeController.text = birthTime;
        _birthPlaceController.text = birthPlace;
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          _currentAvatarUrl = avatarUrl;
        }
      });
    } catch (_) {
      // Keep existing local values if profile fetch fails.
    }
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
    if (_birthDateController.text.trim().isEmpty &&
        _birthTimeController.text.trim().isNotEmpty) {
      Get.snackbar(
        'Date of Birth Required',
        'Please select date of birth if birth time is provided.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

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
        birthDate: _birthDateController.text.trim().isEmpty
            ? null
            : _birthDateController.text.trim(),
        birthTime: _toApiTime(_birthTimeController.text),
        birthPlace: _birthPlaceController.text.trim().isEmpty
            ? null
            : _birthPlaceController.text.trim(),
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
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
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
          Obx(
            () => TextButton(
              onPressed: isSaving.value ? null : _saveChanges,
              child: isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
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
                                    ? Image.file(avatar, fit: BoxFit.cover)
                                    : _currentAvatarUrl != null &&
                                          _currentAvatarUrl!.isNotEmpty
                                    ? Image.network(
                                        _currentAvatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildAvatarPlaceholder(tokens),
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
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                Text(
                                  'Tap to change',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: tokens.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.camera_alt, color: tokens.brandColor),
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

                  const SizedBox(height: AppConstants.spacing16),

                  InkWell(
                    onTap: () => _pickBirthDate(context),
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth (Optional)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  InkWell(
                    onTap: () => _pickBirthTime(context),
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _birthTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Birth Time (Optional)',
                          helperText: 'Improves Vedic recommendation quality',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing16),

                  TextFormField(
                    controller: _birthPlaceController,
                    decoration: const InputDecoration(
                      labelText: 'Birth Place (Optional)',
                      hintText: 'e.g. New Delhi, India',
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

  Widget _buildAvatarPlaceholder(AppUiTokens tokens) {
    return Container(
      color: tokens.brandColor,
      child: const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final current =
        DateTime.tryParse(_birthDateController.text) ?? DateTime(1995, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      _birthDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _pickBirthTime(BuildContext context) async {
    final current =
        _parseTimeOfDay(_birthTimeController.text) ??
        const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      _birthTimeController.text = '$hour:$minute';
    }
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String? _toApiTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length == 5) return '$trimmed:00';
    return trimmed;
  }

  String _toTimeInput(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.length >= 5 ? value.substring(0, 5) : value;
  }
}
