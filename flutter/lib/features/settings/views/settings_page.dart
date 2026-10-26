import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_registry.dart';
import '../../../core/i18n/taxonomy_l10n.dart';
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
        appBar: AppBar(title: Text(context.l10n.settingsTitle)),
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
    final l10n = context.l10n;

    // The stored values stay English (they are sent to the API); only the way
    // they are shown is translated.
    String summary(List<String>? values) => values == null || values.isEmpty
        ? l10n.settingsNoneChosen
        : values.map((value) => localizedTaxonomy(l10n, value)).join(', ');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(
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
          title: context.l10n.settingsAppearance,
          children: [
            PaperNavRow(
              icon: Icons.translate_rounded,
              title: context.l10n.settingsLanguage,
              subtitle: LocaleRegistry.forLocale(
                    Localizations.localeOf(context),
                  )?.nativeName ??
                  context.localeNativeName,
              onTap: () => context.push(Routes.language),
            ),
            _ChoiceRow<AppThemeMode>(
              label: l10n.settingsTheme,
              value: theme,
              options: {
                AppThemeMode.system: l10n.settingsThemeSystem,
                AppThemeMode.light: l10n.settingsThemeLight,
                AppThemeMode.dark: l10n.settingsThemeDark,
              },
              onChanged: notifier.updateThemeMode,
            ),
            _ChoiceRow<TemperatureUnit>(
              label: l10n.settingsTemperature,
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
          title: context.l10n.settingsNotifications,
          children: [
            SwitchListTile(
              title: Text(l10n.settingsEmailUpdates),
              subtitle: Text(
                l10n.settingsEmailUpdatesBody,
                style: TextStyle(color: tokens.textMuted),
              ),
              value: prefs.emailNotificationsEnabled ?? true,
              onChanged: notifier.toggleEmailNotifications,
            ),
            SwitchListTile(
              title: Text(l10n.settingsOutfitReminders),
              subtitle: Text(
                l10n.settingsOutfitRemindersBody,
                style: TextStyle(color: tokens.textMuted),
              ),
              value: prefs.outfitRemindersEnabled ?? true,
              onChanged: notifier.toggleOutfitReminders,
            ),
            SwitchListTile(
              title: Text(l10n.settingsWeeklySummary),
              subtitle: Text(
                l10n.settingsWeeklySummaryBody,
                style: TextStyle(color: tokens.textMuted),
              ),
              value: prefs.weeklySummaryEnabled ?? true,
              onChanged: notifier.toggleWeeklySummary,
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: l10n.settingsStyleSection,
          children: [
            PaperNavRow(
              icon: Icons.style_outlined,
              title: l10n.settingsPreferredStyles,
              subtitle: summary(prefs.preferredStyles),
              onTap: () => _openChoices(
                context,
                title: l10n.settingsPreferredStyles,
                options: _styles,
                selected: prefs.preferredStyles ?? const [],
                onToggle: (value, on) => on
                    ? notifier.addPreferredStyle(value)
                    : notifier.removePreferredStyle(value),
              ),
            ),
            PaperNavRow(
              icon: Icons.palette_outlined,
              title: l10n.settingsPreferredColours,
              subtitle: summary(prefs.preferredColors),
              onTap: () => _openChoices(
                context,
                title: l10n.settingsPreferredColours,
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
          title: l10n.settingsPlanAiSection,
          children: [
            PaperNavRow(
              icon: Icons.workspace_premium_outlined,
              title: l10n.settingsPlanBilling,
              subtitle: EnvConfig.paywallEnabled
                  ? l10n.settingsPlanBillingBody
                  : l10n.settingsPlanUsageBody,
              onTap: () => context.push(Routes.subscription),
            ),
            PaperNavRow(
              icon: Icons.card_giftcard_outlined,
              title: l10n.settingsInviteFriends,
              subtitle: l10n.settingsInviteFriendsBody,
              onTap: () => context.push(Routes.referral),
            ),
            PaperNavRow(
              icon: Icons.auto_awesome_outlined,
              title: l10n.settingsAiProvider,
              subtitle: l10n.settingsAiProviderBody,
              onTap: () => context.push(Routes.aiSettings),
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: l10n.settingsAboutSection,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(l10n.settingsAppVersion),
              subtitle: AppVersionLabel(
                style: text.bodyMedium?.copyWith(color: tokens.textMuted),
              ),
            ),
            PaperNavRow(
              icon: Icons.shield_outlined,
              title: l10n.settingsPrivacyTerms,
              onTap: () => context.push(Routes.legal),
            ),
            PaperNavRow(
              icon: Icons.flag_outlined,
              title: l10n.settingsReportProblem,
              onTap: () => context.push(Routes.feedback),
            ),
          ],
        ),
        gap,
        PaperGroup(
          title: l10n.settingsAccountSection,
          children: [
            PaperNavRow(
              icon: Icons.lock_outline_rounded,
              title: l10n.settingsChangePassword,
              onTap: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _ChangePasswordDialog(),
              ),
            ),
            PaperNavRow(
              icon: Icons.download_outlined,
              title: l10n.settingsExportData,
              onTap: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _ExportDialog(),
              ),
            ),
            PaperNavRow(
              icon: Icons.delete_outline_rounded,
              title: l10n.settingsDeleteAccount,
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
      padding: const EdgeInsetsDirectional.fromSTEB(
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
        padding: const EdgeInsetsDirectional.fromSTEB(
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
                    label: Text(localizedTaxonomy(context.l10n, option)),
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
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.actionDone),
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

  /// Takes the localizations rather than reading them off a context: the
  /// validator runs from the form, which is below this widget's own context.
  String? _validateNew(AppLocalizations l10n, String? value) {
    final password = value ?? '';
    if (password.isEmpty) return l10n.settingsEnterNewPassword;
    if (password.length < 8) return l10n.settingsPasswordMin8;
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return l10n.settingsPasswordNeedsUpper;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return l10n.settingsPasswordNeedsLower;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return l10n.settingsPasswordNeedsDigit;
    }
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsChangePassword),
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
                decoration: InputDecoration(
                  labelText: l10n.settingsCurrentPassword,
                ),
                validator: (v) => (v ?? '').isEmpty
                    ? l10n.settingsEnterCurrentPassword
                    : null,
              ),
              const SizedBox(height: AppConstants.spacing12),
              TextFormField(
                controller: _next,
                obscureText: true,
                enabled: !busy,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(labelText: l10n.settingsNewPassword),
                validator: (v) => _validateNew(l10n, v),
              ),
              const SizedBox(height: AppConstants.spacing12),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                enabled: !busy,
                decoration: InputDecoration(
                  labelText: l10n.settingsConfirmNewPassword,
                ),
                validator: (v) =>
                    v != _next.text ? l10n.settingsPasswordsNoMatch : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        ElevatedButton(
          onPressed: busy ? null : _submit,
          child: busy ? const _ButtonSpinner() : Text(l10n.settingsChangeAction),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsExportData),
      content: Text(l10n.settingsExportBody),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _export,
          child: _busy ? const _ButtonSpinner() : Text(l10n.settingsExportAction),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsDeleteAccountTitle),
      content: Text(l10n.settingsDeleteAccountBody),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _busy ? null : _delete,
          style: TextButton.styleFrom(foregroundColor: error),
          child: _busy ? const _ButtonSpinner() : Text(l10n.actionDelete),
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
