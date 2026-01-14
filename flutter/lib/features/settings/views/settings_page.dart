import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/settings_controller.dart';
import '../models/user_preferences_model.dart';

/// Settings page - full implementation with user preferences management
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller after the widget is fully created
    controller = Get.find<SettingsController>();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                sliver: Obx(() => _buildContent()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAppBar() {
    final tokens = AppUiTokens.of(context);

    return SliverAppBar(
      floating: true,
      elevation: 0,
      title: Text(
        'Settings',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value && controller.preferences.value == null) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final prefs = controller.preferences.value ?? UserPreferencesModel();

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildAppearanceSection(prefs),
        const SizedBox(height: AppConstants.spacing24),
        _buildNotificationsSection(prefs),
        const SizedBox(height: AppConstants.spacing24),
        _buildStylePreferencesSection(prefs),
        const SizedBox(height: AppConstants.spacing24),
        _buildAiSection(),
        const SizedBox(height: AppConstants.spacing24),
        _buildSubscriptionSection(),
        const SizedBox(height: AppConstants.spacing24),
        _buildAccountSection(),
      ]),
    );
  }

  Widget _buildAppearanceSection(UserPreferencesModel prefs) {
    return _buildSection(
      title: 'Appearance',
      children: [
        _buildThemeModeSelector(prefs),
        _buildTemperatureUnitSelector(prefs),
      ],
    );
  }

  Widget _buildThemeModeSelector(UserPreferencesModel prefs) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeLabel(prefs.themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeModeDialog(prefs),
    );
  }

  Widget _buildTemperatureUnitSelector(UserPreferencesModel prefs) {
    final isFahrenheit = prefs.temperatureUnit == TemperatureUnit.fahrenheit;
    return ListTile(
      leading: const Icon(Icons.thermostat),
      title: const Text('Temperature Unit'),
      subtitle: Text(isFahrenheit ? 'Fahrenheit' : 'Celsius'),
      trailing: Switch(
        value: isFahrenheit,
        onChanged: (value) {
          controller.updateTemperatureUnit(
            value ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius,
          );
        },
      ),
    );
  }

  Widget _buildNotificationsSection(UserPreferencesModel prefs) {
    return _buildSection(
      title: 'Notifications',
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive notifications on your device'),
          value: prefs.notificationsEnabled ?? true,
          onChanged: controller.toggleNotifications,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.email),
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive updates via email'),
          value: prefs.emailNotificationsEnabled ?? true,
          onChanged: controller.toggleEmailNotifications,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.checkroom),
          title: const Text('Outfit Reminders'),
          subtitle: const Text('Get reminded to log your outfits'),
          value: prefs.outfitRemindersEnabled ?? true,
          onChanged: controller.toggleOutfitReminders,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.summarize),
          title: const Text('Weekly Summary'),
          subtitle: const Text('Receive weekly outfit summary'),
          value: prefs.weeklySummaryEnabled ?? true,
          onChanged: controller.toggleWeeklySummary,
        ),
      ],
    );
  }

  Widget _buildStylePreferencesSection(UserPreferencesModel prefs) {
    return _buildSection(
      title: 'Style Preferences',
      children: [
        ListTile(
          leading: const Icon(Icons.style),
          title: const Text('Preferred Styles'),
          subtitle: prefs.preferredStyles == null || prefs.preferredStyles!.isEmpty
              ? const Text('No preferences set')
              : Text(prefs.preferredStyles!.take(3).join(', ') +
                  (prefs.preferredStyles!.length > 3 ? '...' : '')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showStylePreferencesDialog(prefs),
        ),
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Preferred Colors'),
          subtitle: prefs.preferredColors == null || prefs.preferredColors!.isEmpty
              ? const Text('No preferences set')
              : Text(prefs.preferredColors!.take(3).join(', ') +
                  (prefs.preferredColors!.length > 3 ? '...' : '')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showColorPreferencesDialog(prefs),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Account',
      children: [
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showChangePasswordDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export Data'),
          subtitle: const Text('Download your data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showExportDataDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Permanently delete your account'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeleteAccountDialog(),
        ),
      ],
    );
  }

  Widget _buildAiSection() {
    return _buildSection(
      title: 'AI',
      children: [
        ListTile(
          leading: const Icon(Icons.auto_awesome),
          title: const Text('AI Provider'),
          subtitle: const Text('Configure AI extraction and generation'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed(Routes.aiSettings),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return _buildSection(
      title: 'Subscription',
      children: [
        ListTile(
          leading: const Icon(Icons.credit_card),
          title: const Text('Manage Subscription'),
          subtitle: const Text('View plan, usage, and upgrade'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed(Routes.subscription),
        ),
        ListTile(
          leading: const Icon(Icons.card_giftcard),
          title: const Text('Refer a Friend'),
          subtitle: const Text('Get 1 month free for each referral'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed(Routes.referral),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: AppConstants.spacing8),
        AppGlassCard(
          padding: const EdgeInsets.all(0),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showThemeModeDialog(UserPreferencesModel prefs) {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeModeLabel(mode)),
              value: mode,
              groupValue: prefs.themeMode ?? AppThemeMode.system,
              onChanged: (value) {
                if (value != null) {
                  controller.updateThemeMode(value);
                  Get.back();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showStylePreferencesDialog(UserPreferencesModel prefs) {
    final styles = [
      'Casual',
      'Formal',
      'Sporty',
      'Bohemian',
      'Minimalist',
      'Streetwear',
      'Vintage',
      'Preppy'
    ];
    final selected = prefs.preferredStyles ?? [];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferred Styles',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: styles.map((style) {
                  final isSelected = selected.contains(style);
                  return FilterChip(
                    label: Text(style),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.addPreferredStyle(style);
                      } else {
                        controller.removePreferredStyle(style);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing16),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPreferencesDialog(UserPreferencesModel prefs) {
    final colors = [
      'Black',
      'White',
      'Gray',
      'Navy',
      'Brown',
      'Red',
      'Blue',
      'Green',
      'Pink',
      'Purple',
      'Yellow',
      'Orange'
    ];
    final selected = prefs.preferredColors ?? [];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferred Colors',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: colors.map((color) {
                  final isSelected = selected.contains(color);
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.addPreferredColor(color);
                      } else {
                        controller.removePreferredColor(color);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing16),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !controller.isChangingPassword.value,
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !controller.isChangingPassword.value,
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !controller.isChangingPassword.value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: controller.isChangingPassword.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.isChangingPassword.value
                ? null
                : () async {
                    if (currentPasswordController.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter your current password');
                      return;
                    }
                    if (newPasswordController.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter a new password');
                      return;
                    }
                    if (newPasswordController.text != confirmPasswordController.text) {
                      Get.snackbar('Error', 'Passwords do not match');
                      return;
                    }
                    try {
                      await controller.changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                    } catch (e) {
                      // Error handled by controller
                    }
                  },
            child: controller.isChangingPassword.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change'),
          ),
        ],
      )),
      barrierDismissible: false,
    );
  }

  void _showExportDataDialog() {
    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'We will prepare a download link with all your data. You will receive an email when it\'s ready.',
        ),
        actions: [
          TextButton(
            onPressed: controller.isExportingData.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.isExportingData.value
                ? null
                : () async {
                    await controller.exportData();
                    Get.back();
                  },
            child: controller.isExportingData.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Export'),
          ),
        ],
      )),
      barrierDismissible: false,
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: controller.isDeletingAccount.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.isDeletingAccount.value
                ? null
                : () async {
                    try {
                      await controller.deleteAccount();
                    } catch (e) {
                      // Error handled by controller
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: controller.isDeletingAccount.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Delete'),
          ),
        ],
      )),
      barrierDismissible: false,
    );
  }

  String _getThemeModeLabel(AppThemeMode? mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
      default:
        return 'System';
    }
  }
}
