import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/profile_repository.dart';
import 'profile_content.dart' show ProfileAvatar;

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

/// Name, photo and optional birth details.
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  late final TextEditingController _nameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _birthTimeController;
  late final TextEditingController _birthPlaceController;
  File? _newAvatar;
  bool _saving = false;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _birthDateController = TextEditingController(text: user?.birthDate ?? '');
    _birthTimeController = TextEditingController(
      text: _toTimeInput(user?.birthTime),
    );
    _birthPlaceController = TextEditingController(text: user?.birthPlace ?? '');
    _currentAvatarUrl = user?.avatarUrl;
    _loadProfileDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileDetails() async {
    try {
      final profile = await _repository.getProfile();
      if (!mounted) return;
      final fullName = profile['full_name']?.toString();
      final avatarUrl = profile['avatar_url']?.toString();
      setState(() {
        if (fullName != null && fullName.isNotEmpty) {
          _nameController.text = fullName;
        }
        _birthDateController.text = profile['birth_date']?.toString() ?? '';
        _birthTimeController.text = _toTimeInput(
          profile['birth_time']?.toString(),
        );
        _birthPlaceController.text = profile['birth_place']?.toString() ?? '';
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          _currentAvatarUrl = avatarUrl;
        }
      });
    } catch (_) {
      // The cached profile values stay in the form.
    }
  }

  Future<void> _pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() => _newAvatar = File(image.path));
    }
  }

  Future<void> _saveChanges() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_birthDateController.text.trim().isEmpty &&
        _birthTimeController.text.trim().isNotEmpty) {
      ErrorHandler.showValidation(
        'Add a date of birth to go with the birth time.',
        title: 'Date of birth needed',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      var avatarUrl = _currentAvatarUrl;
      if (_newAvatar case final file?) {
        avatarUrl = await _repository.uploadAvatar(file);
      }
      // An empty field is sent as '' (clear); null would mean "unchanged".
      final result = await _repository.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: avatarUrl,
        birthDate: _birthDateController.text.trim(),
        birthTime: _toApiTimeOrClear(_birthTimeController.text),
        birthPlace: _birthPlaceController.text.trim(),
      );
      final meta = result['meta'];
      final skipped =
          meta is Map<String, dynamic> && meta['skipped_fields'] is List
          ? (meta['skipped_fields'] as List).map((e) => e.toString()).toSet()
          : const <String>{};
      await ref.read(authProvider.notifier).refreshUser();
      if (!mounted) return;
      if (skipped.any(
        (f) => f == 'birth_date' || f == 'birth_time' || f == 'birth_place',
      )) {
        ErrorHandler.showWarning(
          'We saved your name and photo. Birth details did not save; try '
          'again later.',
          title: 'Partly saved',
        );
        setState(() => _saving = false);
        return;
      }
      ErrorHandler.showSuccess('Your profile is saved.', title: 'Saved');
      Navigator.pop(context);
    } catch (e, stack) {
      ErrorHandler.showError(e, title: 'Not saved', stackTrace: stack);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final user = ref.watch(authProvider.select((s) => s.user));
    const gap = SizedBox(height: AppConstants.spacing16);
    final avatar = _newAvatar;
    final url = _currentAvatarUrl;

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing8),
              child: TextButton(
                onPressed: _saving ? null : _saveChanges,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        body: AppPageBackground(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaperSurface(
                    semanticLabel: 'Change profile photo',
                    onTap: _saving ? null : _pickAvatar,
                    child: Row(
                      children: [
                        if (avatar != null)
                          ClipOval(
                            child: Image.file(
                              avatar,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          ProfileAvatar(
                            user: user?.copyWith(avatarUrl: url),
                            radius: 36,
                          ),
                        const SizedBox(width: AppConstants.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Profile photo', style: text.titleMedium),
                              Text(
                                'Tap to choose a new one',
                                style: text.bodySmall?.copyWith(
                                  color: tokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.photo_camera_outlined,
                          color: tokens.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Enter your name'
                        : null,
                  ),
                  gap,
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    enabled: !_saving,
                    onTap: () => _pickBirthDate(context),
                    decoration: const InputDecoration(
                      labelText: 'Date of birth (optional)',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  gap,
                  TextFormField(
                    controller: _birthTimeController,
                    readOnly: true,
                    enabled: !_saving,
                    onTap: () => _pickBirthTime(context),
                    decoration: const InputDecoration(
                      labelText: 'Birth time (optional)',
                      helperText: 'Makes Vedic suggestions more exact',
                      suffixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                  gap,
                  TextFormField(
                    controller: _birthPlaceController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Birth place (optional)',
                      hintText: 'For example, New Delhi, India',
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

  /// API format (HH:mm:ss), or '' — the repository's clear sentinel when the
  /// field was emptied.
  String _toApiTimeOrClear(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.length == 5) return '$trimmed:00';
    return trimmed;
  }

  String _toTimeInput(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.length >= 5 ? value.substring(0, 5) : value;
  }
}
