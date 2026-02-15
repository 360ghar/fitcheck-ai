import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/body_profile_controller.dart';
import '../models/body_profile_model.dart';

/// Body profiles page for managing size and fit preferences
class BodyProfilesPage extends StatelessWidget {
  const BodyProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BodyProfileController>();
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Profiles'),
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.profiles.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  children: const [
                    ShimmerCard(height: 80),
                    SizedBox(height: AppConstants.spacing24),
                    ShimmerCard(height: 48),
                    SizedBox(height: AppConstants.spacing24),
                    ShimmerBox(width: 120, height: 20),
                    SizedBox(height: AppConstants.spacing12),
                    ShimmerListTile(hasLeading: true, hasSubtitle: true),
                    SizedBox(height: AppConstants.spacing8),
                    ShimmerListTile(hasLeading: true, hasSubtitle: true),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchProfiles,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card
                    _buildInfoCard(context, tokens),
                    const SizedBox(height: AppConstants.spacing24),

                    // Add button
                    ElevatedButton.icon(
                      onPressed: () => _showAddProfileDialog(context, controller),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Body Profile'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing24),

                    // Profiles list
                    Text(
                      'Your Profiles',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),

                    if (controller.profiles.isEmpty)
                      _buildEmptyState(context, tokens)
                    else
                      ...controller.profiles.map(
                        (profile) => _buildProfileCard(context, profile, controller),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, AppUiTokens tokens) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: tokens.brandColor,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              'Save your measurements and size preferences for better recommendations',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppUiTokens tokens) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.accessibility_new,
              size: 48,
              color: tokens.textMuted,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'No body profiles yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Add your first profile to get size recommendations',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    BodyProfileModel profile,
    BodyProfileController controller,
  ) {
    final tokens = AppUiTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (profile.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.brandColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.brandColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.heightCm.toStringAsFixed(0)} cm • ${profile.weightKg.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                      Text(
                        '${profile.bodyShape} • ${profile.skinTone}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditProfileDialog(context, profile, controller);
                        break;
                      case 'default':
                        controller.setDefault(profile.id);
                        break;
                      case 'delete':
                        _confirmDelete(context, profile, controller);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!profile.isDefault)
                      const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context, BodyProfileController controller) {
    final nameController = TextEditingController();
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final bodyShapeController = TextEditingController(text: 'Regular');
    final skinToneController = TextEditingController(text: 'Medium');
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: AppUiTokens.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Body Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Profile Name *',
                      hintText: 'e.g., Main Profile',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a profile name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm) *',
                            hintText: '170',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final height = double.tryParse(value);
                            if (height == null || height <= 0 || height > 300) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: TextFormField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg) *',
                            hintText: '70',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0 || weight > 500) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: bodyShapeController,
                          decoration: const InputDecoration(
                            labelText: 'Body Shape *',
                            hintText: 'Athletic',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: TextFormField(
                          controller: skinToneController,
                          decoration: const InputDecoration(
                            labelText: 'Skin Tone *',
                            hintText: 'Medium',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                final request = CreateBodyProfileRequest(
                                  name: nameController.text.trim(),
                                  heightCm: double.parse(heightController.text),
                                  weightKg: double.parse(weightController.text),
                                  bodyShape: bodyShapeController.text.trim(),
                                  skinTone: skinToneController.text.trim(),
                                );

                                final success = await controller.createProfile(request);
                                if (success) {
                                  Get.back();
                                  Get.snackbar(
                                    'Success',
                                    'Body profile created',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: controller.isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Profile'),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    BodyProfileModel profile,
    BodyProfileController controller,
  ) {
    final nameController = TextEditingController(text: profile.name);
    final heightController = TextEditingController(text: profile.heightCm.toString());
    final weightController = TextEditingController(text: profile.weightKg.toString());
    final bodyShapeController = TextEditingController(text: profile.bodyShape);
    final skinToneController = TextEditingController(text: profile.skinTone);
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: AppUiTokens.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Body Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Profile Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a profile name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm) *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final height = double.tryParse(value);
                            if (height == null || height <= 0 || height > 300) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: TextFormField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg) *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0 || weight > 500) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: bodyShapeController,
                          decoration: const InputDecoration(
                            labelText: 'Body Shape *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: TextFormField(
                          controller: skinToneController,
                          decoration: const InputDecoration(
                            labelText: 'Skin Tone *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                final request = UpdateBodyProfileRequest(
                                  name: nameController.text.trim(),
                                  heightCm: double.parse(heightController.text),
                                  weightKg: double.parse(weightController.text),
                                  bodyShape: bodyShapeController.text.trim(),
                                  skinTone: skinToneController.text.trim(),
                                );

                                final success = await controller.updateProfile(profile.id, request);
                                if (success) {
                                  Get.back();
                                  Get.snackbar(
                                    'Success',
                                    'Body profile updated',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: controller.isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update Profile'),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(
    BuildContext context,
    BodyProfileModel profile,
    BodyProfileController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteProfile(profile.id);
              if (success) {
                Get.snackbar(
                  'Success',
                  'Body profile deleted',
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
