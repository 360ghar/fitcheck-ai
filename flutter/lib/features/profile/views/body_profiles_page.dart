import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';

/// Body profiles page for managing size and fit preferences
class BodyProfilesPage extends StatelessWidget {
  const BodyProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Profiles'),
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info text
                AppGlassCard(
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
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Add new profile button
                ElevatedButton.icon(
                  onPressed: () => _showAddProfileDialog(),
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

                // Placeholder for now
                AppGlassCard(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProfileDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: AppUiTokens.of(Get.context!).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Body Profile',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  hintText: 'e.g., Casual Fit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        hintText: '5\'10"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        hintText: '150 lbs',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Save Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
