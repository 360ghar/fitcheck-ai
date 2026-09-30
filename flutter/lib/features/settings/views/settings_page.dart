import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/app_version_label.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_preferences_model.dart';
import '../providers/settings_provider.dart';
import '../widgets/paper_group.dart';

const _styles = [
  'Casual', 'Formal', 'Sporty', 'Bohemian', //
  'Minimalist', 'Streetwear', 'Vintage', 'Preppy',
];

const _colors = [
  'Black', 'White', 'Gray', 'Navy', 'Brown', 'Red', //
  'Blue', 'Green', 'Pink', 'Purple', 'Yellow', 'Orange',
];

/// Preferences, plan links and account actions.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final prefs = settings.preferences;

    final Widget body;
    if (prefs == null) {
      body = settings.loadError != null && !settings.isLoading
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                AppErrorState(
                  error: settings.loadError,
                  onRetry: notifier.fetchPreferences,
                ),
              ],
            )
          : const _SettingsSkeleton();
    } else {
      body = _SettingsList(prefs: prefs, loadError: settings.loadError);
    }

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: AppPageBackground(
          child: RefreshIndicator(
            onRefresh: notifier.fetchPreferences,
            child: body,
          ),
        ),
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: const [
        SkeletonPulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 110, height: 16),
              SizedBox(height: AppConstants.spacing8),
              SkeletonBox(height: 132, borderRadius: AppConstants.radius12),
              SizedBox(height: AppConstants.spacing24),
              SkeletonBox(width: 110, height: 16),
              SizedBox(height: AppConstants.spacing8),
              SkeletonBox(height: 196, borderRadius: AppConstants.radius12),
              SizedBox(height: AppConstants.spacing24),
              SkeletonBox(width: 110, height: 16),
              SizedBox(height: AppConstants.spacing8),
              SkeletonBox(height: 120, borderRadius: AppConstants.radius12),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList({required this.prefs, required this.loadError});

  final UserPreferencesModel prefs;
  final Object? loadError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    const gap = SizedBox(height: AppConstants.spacing24);
    final theme =
        prefs.themeMode ?? ref.read(themeServiceProvider).appThemeMode;
    final fahrenheit = prefs.temperatureUnit == TemperatureUnit.fahrenheit;

    String summary(List<String>? values) =>
        values == null || values.isEmpty ? 'None chosen' : values.join(', ');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        if (loadError != null) ...[
          AppErrorBanner(error: loadError, onRetry: notifier.fetchPreferences),
          const SizedBox(height: AppConstants.spacing8),
        ],
        PaperGroup(
          title: 'Appearance',
          children: [
            _ChoiceRow<AppThemeMode>(
              label: 'Theme',
              value: theme,
              options: const {
                AppThemeMode.system: 'System',
                AppThemeMode.light: 'Light',
                AppThemeMode.dark: 'Dark',
              },
              onChanged: notifier.updateThemeMode,
            ),
            _ChoiceRow<TemperatureUnit>(
              label: 'Temperature',
              value: fahrenheit
                  ? TemperatureUnit.fahrenheit
                  : TemperatureUnit.celsius,
              options: const {
                TemperatureUnit.celsius: '°C',
                TemperatureUnit.fahrenheit: '°F',
              },
              onChanged: notifier.updateTemperatureUnit,
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: 'Notifications',
          children: [
            SwitchListTile(
              title: const Text('Email updates'),
              subtitle: Text(
                'News and tips by email',
                style: TextStyle(color: tokens.textMuted),
              ),
              value: prefs.emailNotificationsEnabled ?? true,
              onChanged: notifier.toggleEmailNotifications,
            ),
            SwitchListTile(
              title: const Text('Outfit reminders'),
              subtitle: Text(
                'A nudge to log what you wore',
                style: TextStyle(color: tokens.textMuted),
              ),
              value: prefs.outfitRemindersEnabled ?? true,
              onChanged: notifier.toggleOutfitReminders,
            ),
            SwitchListTile(
              title: const Text('Weekly summary'),
              subtitle: Text(
                'Your week in outfits',
                style: TextStyle(color: tokens.textMuted),
              ),
              value: prefs.weeklySummaryEnabled ?? true,
              onChanged: notifier.toggleWeeklySummary,
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: 'Style',
          children: [
            PaperNavRow(
              icon: Icons.style_outlined,
              title: 'Styles you like',
              subtitle: summary(prefs.preferredStyles),
              onTap: () => _openChoices(
                context,
                title: 'Styles you like',
                options: _styles,
                selected: prefs.preferredStyles ?? const [],
                onToggle: (value, on) => on
                    ? notifier.addPreferredStyle(value)
                    : notifier.removePreferredStyle(value),
              ),
            ),
            PaperNavRow(
              icon: Icons.palette_outlined,
              title: 'Colours you like',
              subtitle: summary(prefs.preferredColors),
              onTap: () => _openChoices(
                context,
                title: 'Colours you like',
                options: _colors,
                selected: prefs.preferredColors ?? const [],
                onToggle: (value, on) => on
                    ? notifier.addPreferredColor(value)
                    : notifier.removePreferredColor(value),
              ),
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: 'Plan and AI',
          children: [
            PaperNavRow(
              icon: Icons.workspace_premium_outlined,
              title: 'Plan and billing',
              subtitle: EnvConfig.paywallEnabled
                  ? 'Plan, usage and upgrades'
                  : 'Plan and usage',
              onTap: () => context.push(Routes.subscription),
            ),
            PaperNavRow(
              icon: Icons.card_giftcard_outlined,
              title: 'Invite friends',
              subtitle: 'A free month for each friend who joins',
              onTap: () => context.push(Routes.referral),
            ),
            PaperNavRow(
              icon: Icons.auto_awesome_outlined,
              title: 'AI provider',
              subtitle: 'Use your own model for tagging and images',
              onTap: () => context.push(Routes.aiSettings),
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: 'About',
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('App version'),
              subtitle: AppVersionLabel(
                style: text.bodyMedium?.copyWith(color: tokens.textMuted),
              ),
            ),
            PaperNavRow(
              icon: Icons.shield_outlined,
              title: 'Privacy and terms',
              onTap: () => context.push(Routes.legal),
            ),
            PaperNavRow(
              icon: Icons.flag_outlined,
              title: 'Report a problem',
              onTap: () => context.push(Routes.feedback),
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: 'Account',
          children: [
            PaperNavRow(
              icon: Icons.lock_outline_rounded,
              title: 'Change password',
              onTap: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _ChangePasswordDialog(),
              ),
            ),
            PaperNavRow(
              icon: Icons.download_outlined,
              title: 'Export your data',
              onTap: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _ExportDialog(),
              ),
            ),
            PaperNavRow(
              icon: Icons.delete_outline_rounded,
              title: 'Delete account',
              color: tokens.error,
              onTap: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _DeleteAccountDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openChoices(
    BuildContext context, {
    required String title,
    required List<String> options,
    required List<String> selected,
    required void Function(String value, bool on) onToggle,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChoiceSheet(
        title: title,
        options: options,
        initial: selected,
        onToggle: onToggle,
      ),
    );
  }
}

/// A label with a segmented control under it.
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing16,
        AppConstants.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppConstants.spacing8),
          SegmentedButton<T>(
            showSelectedIcon: false,
            // The tint alone barely shows on dark paper; the tonal accent does.
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: PaperTokens.of(context).stock.accent,
              selectedForegroundColor: PaperTokens.of(context).stock.onAccent,
            ),
            segments: [
              for (final e in options.entries)
                ButtonSegment(value: e.key, label: Text(e.value)),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ],
      ),
    );
  }
}

/// Multi-select chips. Renders from its own selection so a tap shows at
/// once and an in-flight save cannot flip it back.
class _ChoiceSheet extends StatefulWidget {
  const _ChoiceSheet({
    required this.title,
    required this.options,
    required this.initial,
    required this.onToggle,
  });

  final String title;
  final List<String> options;
  final List<String> initial;
  final void Function(String value, bool on) onToggle;

  @override
  State<_ChoiceSheet> createState() => _ChoiceSheetState();
}

class _ChoiceSheetState extends State<_ChoiceSheet> {
  late final Set<String> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing24,
          AppConstants.spacing24,
          AppConstants.spacing24,
          AppConstants.spacing8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Wrap(
              spacing: AppConstants.spacing8,
              runSpacing: AppConstants.spacing8,
              children: [
                for (final option in widget.options)
                  FilterChip(
                    label: Text(option),
                    selected: _selected.contains(option),
                    onSelected: (on) {
                      setState(
                        () => on
                            ? _selected.add(option)
                            : _selected.remove(option),
                      );
                      widget.onToggle(option, on);
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateNew(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter a new password';
    if (password.length < 8) return 'Use at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Add an uppercase letter';
    if (!password.contains(RegExp(r'[a-z]'))) return 'Add a lowercase letter';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Add a number';
    return null;
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final changed = await ref
        .read(settingsProvider.notifier)
        .changePassword(_current.text, _next.text);
    if (!mounted) return;
    // On failure the dialog stays open with what was typed.
    if (changed) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy =
        _busy || ref.watch(authProvider.select((s) => s.busy)) != AuthBusy.none;
    return AlertDialog(
      title: const Text('Change password'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _current,
                obscureText: true,
                enabled: !busy,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Enter your current password' : null,
              ),
              const SizedBox(height: AppConstants.spacing12),
              TextFormField(
                controller: _next,
                obscureText: true,
                enabled: !busy,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(labelText: 'New password'),
                validator: _validateNew,
              ),
              const SizedBox(height: AppConstants.spacing12),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                enabled: !busy,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
                validator: (v) =>
                    v != _next.text ? 'The passwords do not match' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: busy ? null : _submit,
          child: busy ? const _ButtonSpinner() : const Text('Change'),
        ),
      ],
    );
  }
}

class _ExportDialog extends ConsumerStatefulWidget {
  const _ExportDialog();

  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    await ref.read(settingsProvider.notifier).exportData();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export your data'),
      content: const Text(
        'We prepare a file with everything you saved and open the download.',
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _export,
          child: _busy ? const _ButtonSpinner() : const Text('Export'),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  bool _busy = false;

  Future<void> _delete() async {
    setState(() => _busy = true);
    final deleted = await ref.read(settingsProvider.notifier).deleteAccount();
    // On success, sign-out replaces every route, this dialog included.
    if (!deleted && mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final error = PaperTokens.of(context).error;
    return AlertDialog(
      title: const Text('Delete your account?'),
      content: const Text(
        'This removes your closet, outfits and photos for good. '
        'You cannot undo it.',
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _delete,
          style: TextButton.styleFrom(foregroundColor: error),
          child: _busy ? const _ButtonSpinner() : const Text('Delete'),
        ),
      ],
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
