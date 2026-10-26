import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/body_profile_model.dart';
import '../providers/body_profiles_provider.dart';

/// Saved measurements used for fit and try-on.
class BodyProfilesPage extends ConsumerWidget {
  const BodyProfilesPage({super.key});

  static void _openSheet(BuildContext context, [BodyProfileModel? profile]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BodyProfileSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(bodyProfilesProvider);
    final notifier = ref.read(bodyProfilesProvider.notifier);

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.profileBodyProfiles)),
        body: AppPageBackground(
          child: RefreshIndicator(
            onRefresh: notifier.refresh,
            child: switch (profiles) {
              AsyncValue(:final value?) when value.isEmpty => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (profiles.hasError)
                    AppErrorBanner(
                      error: profiles.error,
                      onRetry: notifier.refresh,
                    ),
                  AppEmptyState(
                    scene: PaperScenes.studio,
                    title: context.l10n.profileBodyEmptyTitle,
                    message: context.l10n.profileBodyEmptyBody,
                    actionLabel: context.l10n.profileBodyAdd,
                    actionIcon: Icons.add_rounded,
                    onAction: () => _openSheet(context),
                  ),
                ],
              ),
              AsyncValue(:final value?) => _ProfileList(
                profiles: value,
                error: profiles.hasError ? profiles.error : null,
                onAdd: () => _openSheet(context),
                onEdit: (p) => _openSheet(context, p),
              ),
              AsyncValue(:final error?) when !profiles.isLoading => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  AppErrorState(error: error, onRetry: notifier.refresh),
                ],
              ),
              _ => ListView(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                children: const [
                  SkeletonPulse(
                    child: Column(
                      children: [
                        SkeletonBox(
                          height: 88,
                          borderRadius: AppConstants.radius12,
                        ),
                        SizedBox(height: AppConstants.spacing12),
                        SkeletonBox(
                          height: 88,
                          borderRadius: AppConstants.radius12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileList extends ConsumerWidget {
  const _ProfileList({
    required this.profiles,
    required this.error,
    required this.onAdd,
    required this.onEdit,
  });

  final List<BodyProfileModel> profiles;
  final Object? error;
  final VoidCallback onAdd;
  final ValueChanged<BodyProfileModel> onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final busy = ref.watch(bodyProfileBusyProvider);
    final notifier = ref.read(bodyProfilesProvider.notifier);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        if (error != null)
          AppErrorBanner(error: error, onRetry: notifier.refresh),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing4,
            0,
            AppConstants.spacing4,
            AppConstants.spacing16,
          ),
          child: Text(
            context.l10n.profileBodyDefaultNote,
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
        ),
        for (final profile in profiles) ...[
          PaperSurface(
            padding: const EdgeInsetsDirectional.only(
              start: AppConstants.spacing16,
              top: AppConstants.spacing12,
              end: AppConstants.spacing4,
              bottom: AppConstants.spacing12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: profile.name,
                          children: [
                            if (profile.isDefault)
                              TextSpan(
                                text:
                                    '  ${context.l10n.profileBodyDefaultBadge}',
                                style: text.bodyMedium?.copyWith(
                                  color: tokens.stock.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        context.l10n.bodyProfileMeasurements(
                          profile.heightCm.toStringAsFixed(0),
                          profile.weightKg.toStringAsFixed(1),
                        ),
                        style: text.bodyMedium?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      Text(
                        context.l10n.bodyProfileBuildSkin(profile.bodyShape, profile.skinTone),
                        style: text.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (busy.contains(profile.id))
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  PopupMenuButton<String>(
                    tooltip: context.l10n.bodyProfileOptionsFor(profile.name),
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) => switch (value) {
                      'edit' => onEdit(profile),
                      'default' => notifier.setDefault(profile.id),
                      _ => _confirmDelete(context, ref, profile),
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(context.l10n.actionEdit),
                      ),
                      if (!profile.isDefault)
                        PopupMenuItem(
                          value: 'default',
                          child: Text(context.l10n.profileBodyMakeDefault),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          context.l10n.actionDelete,
                          style: TextStyle(color: tokens.error),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
        ],
        const SizedBox(height: AppConstants.spacing8),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(context.l10n.profileBodyAdd),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BodyProfileModel profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.bodyProfileDeleteTitle(profile.name)),
        content: Text(context.l10n.profileBodyDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(dialogContext).error,
            ),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(bodyProfilesProvider.notifier).delete(profile.id);
    }
  }
}

/// Create or edit form. Owns its text controllers and disposes them after
/// the sheet's exit animation.
class _BodyProfileSheet extends ConsumerStatefulWidget {
  const _BodyProfileSheet({this.profile});

  /// Null to create a new profile.
  final BodyProfileModel? profile;

  @override
  ConsumerState<_BodyProfileSheet> createState() => _BodyProfileSheetState();
}

class _BodyProfileSheetState extends ConsumerState<_BodyProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile?.name);
  late final _height = TextEditingController(
    // toString(), not toStringAsFixed(0): a fractional height must not be
    // silently rounded the moment the form opens.
    text: widget.profile?.heightCm.toString(),
  );
  late final _weight = TextEditingController(
    text: widget.profile?.weightKg.toString(),
  );
  late final _shape = TextEditingController(
    text: widget.profile?.bodyShape ?? 'Regular',
  );
  late final _tone = TextEditingController(
    text: widget.profile?.skinTone ?? 'Medium',
  );
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _height, _weight, _shape, _tone]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? context.l10n.profileBodyRequired : null;

  String? Function(String?) _number(double max) => (value) {
    final n = double.tryParse(value?.trim() ?? '');
    if (value?.trim().isEmpty ?? true) return context.l10n.profileBodyRequired;
    if (n == null || n <= 0 || n > max) return context.l10n.profileBodyCheckNumber;
    return null;
  };

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final notifier = ref.read(bodyProfilesProvider.notifier);
    final height = double.parse(_height.text.trim());
    final weight = double.parse(_weight.text.trim());
    final profile = widget.profile;
    final saved = profile == null
        ? await notifier.create(
            CreateBodyProfileRequest(
              name: _name.text.trim(),
              heightCm: height,
              weightKg: weight,
              bodyShape: _shape.text.trim(),
              skinTone: _tone.text.trim(),
            ),
          )
        : await notifier.edit(
            profile.id,
            UpdateBodyProfileRequest(
              name: _name.text.trim(),
              heightCm: height,
              weightKg: weight,
              bodyShape: _shape.text.trim(),
              skinTone: _tone.text.trim(),
            ),
          );
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppConstants.spacing12);
    const across = SizedBox(width: AppConstants.spacing12);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.profile == null
                      ? context.l10n.profileBodyNew
                      : context.l10n.profileEditTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppConstants.spacing20),
                TextFormField(
                  controller: _name,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: context.l10n.authName,
                    hintText: context.l10n.profileBodyNameHint,
                  ),
                  validator: _required,
                ),
                gap,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _height,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.profileBodyHeight,
                          suffixText: 'cm',
                        ),
                        validator: _number(300),
                      ),
                    ),
                    across,
                    Expanded(
                      child: TextFormField(
                        controller: _weight,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.profileBodyWeight,
                          suffixText: 'kg',
                        ),
                        validator: _number(500),
                      ),
                    ),
                  ],
                ),
                gap,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _shape,
                        enabled: !_saving,
                        decoration: InputDecoration(
                          labelText: context.l10n.profileBodyBuild,
                        ),
                        validator: _required,
                      ),
                    ),
                    across,
                    Expanded(
                      child: TextFormField(
                        controller: _tone,
                        enabled: !_saving,
                        decoration: InputDecoration(
                          labelText: context.l10n.profileBodySkinTone,
                        ),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.actionSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
