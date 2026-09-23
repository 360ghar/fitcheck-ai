import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../models/item_model.dart';
import '../providers/item_add_provider.dart';
import 'extracted_item_card.dart' show GeneratedImage;
import 'extraction_progress_card.dart' show PaperProgressTrack;
import 'garment_glyph.dart';
import 'manual_entry_form.dart' show UseCasePicker;

// The single-photo extraction views. Each part watches only the fields it
// shows, so a progress event does not rebuild the piece grid.

/// The photo being scanned.
class ExtractionPhoto extends StatelessWidget {
  const ExtractionPhoto({super.key, required this.image, this.height = 220});

  final File image;
  final double height;

  @override
  Widget build(BuildContext context) => PaperSurface(
    padding: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    grain: false,
    color: PaperTokens.of(context).stock.sunk,
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Image.file(
        image,
        fit: BoxFit.cover,
        cacheWidth: 1080,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    ),
  );
}

/// Upload, analysis and (before any piece is shown) studio-photo progress.
class ExtractionProcessingView extends ConsumerWidget {
  const ExtractionProcessingView({super.key, required this.session});

  final int session;

  static (String, String) phaseCopy(String phase) => switch (phase) {
    'upload' => ('Uploading your photo', 'This takes a few seconds.'),
    'connected' => ('Uploading your photo', 'Connected. Starting the scan.'),
    'analyzing' => ('Looking at your photo', 'Finding each piece you wear.'),
    'extracting' => ('Pieces found', 'Getting the details of each one.'),
    'generating' => ('Making studio photos', 'A clean photo of each piece.'),
    'complete' => ('Done', 'Your pieces are ready.'),
    _ => ('Working on it', 'This takes up to a minute.'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemAddProvider(session);
    final image = ref.watch(provider.select((s) => s.image));
    final (phase, progress, secondsLeft) = ref.watch(
      provider.select((s) => (s.phase, s.progress, s.secondsLeft)),
    );
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final (title, detail) = phaseCopy(phase);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        if (image != null) ExtractionPhoto(image: image),
        const SizedBox(height: AppConstants.spacing24),
        Text(title, style: text.headlineSmall),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          detail,
          style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppConstants.spacing16),
        PaperProgressTrack(value: progress / 100, semanticLabel: title),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          children: [
            Text(
              '${progress.round()}%',
              style: text.bodySmall?.copyWith(color: tokens.textSecondary),
            ),
            const Spacer(),
            if (secondsLeft > 0)
              Text(
                'About $secondsLeft s left',
                style: text.bodySmall?.copyWith(color: tokens.textSecondary),
              ),
          ],
        ),
        if (phase == 'generating') _PieceStatusList(session: session),
        const SizedBox(height: AppConstants.spacing24),
        Center(
          child: TextButton(
            onPressed: ref.read(provider.notifier).cancelExtraction,
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}

class _PieceStatusList extends ConsumerWidget {
  const _PieceStatusList({required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(
      itemAddProvider(session).select((s) => s.itemStatus),
    );
    if (statuses.isEmpty) return const SizedBox.shrink();
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final done = statuses.values.where((s) => s == 'complete').length;
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing20),
      child: PaperSurface(
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$done of ${statuses.length} studio photos ready',
                style: text.bodyMedium,
              ),
            ),
            for (final status in statuses.values)
              Padding(
                padding: const EdgeInsets.only(left: AppConstants.spacing4),
                child: Icon(
                  switch (status) {
                    'complete' => Icons.check_rounded,
                    'failed' => Icons.error_outline_rounded,
                    _ => Icons.schedule_rounded,
                  },
                  size: 20,
                  color: switch (status) {
                    'complete' => tokens.success,
                    'failed' => tokens.error,
                    _ => tokens.textMuted,
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The found pieces: include toggles, use cases and the save action.
class ExtractionResultsView extends ConsumerWidget {
  const ExtractionResultsView({super.key, required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemAddProvider(session);
    final image = ref.watch(provider.select((s) => s.image));
    final failure = ref.watch(provider.select((s) => s.failure));
    final notifier = ref.read(provider.notifier);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (failure != null)
                SliverToBoxAdapter(
                  child: AppErrorBanner(
                    message:
                        'Studio photos stopped early. You can still save these pieces.',
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacing16,
                  AppConstants.spacing8,
                  AppConstants.spacing16,
                  0,
                ),
                sliver: SliverList.list(
                  children: [
                    if (image != null)
                      ExtractionPhoto(image: image, height: 160),
                    const SizedBox(height: AppConstants.spacing20),
                    _ResultsHeader(session: session),
                    _PeopleControls(session: session),
                    const SizedBox(height: AppConstants.spacing16),
                  ],
                ),
              ),
              _PieceGrid(session: session),
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                sliver: SliverToBoxAdapter(
                  child: PaperSurface(child: _UseCases(session: session)),
                ),
              ),
            ],
          ),
        ),
        PaperActionBar(
          child: Consumer(
            builder: (context, ref, _) {
              final (saving, included) = ref.watch(
                provider.select((s) => (s.saving, s.includedCount)),
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: saving || included == 0
                        ? null
                        : () async {
                            final result = await notifier.saveGeneratedItems();
                            if (result.failed == 0 &&
                                result.saved.isNotEmpty &&
                                context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: Text(
                      saving
                          ? 'Saving'
                          : included == 0
                          ? 'Choose pieces to save'
                          : included == 1
                          ? 'Save 1 piece'
                          : 'Save $included pieces',
                    ),
                  ),
                  TextButton(
                    onPressed: saving ? null : notifier.reset,
                    child: const Text('Start over'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultsHeader extends ConsumerWidget {
  const _ResultsHeader({required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (count, ready) = ref.watch(
      itemAddProvider(session).select((s) => (s.items.length, s.readyCount)),
    );
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count == 1 ? '1 piece found' : '$count pieces found',
          style: text.headlineSmall,
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          ready >= count
              ? 'Tap a piece to skip it.'
              : '$ready of $count studio photos ready. Tap a piece to skip it.',
          style: text.bodyMedium?.copyWith(
            color: PaperTokens.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PeopleControls extends ConsumerWidget {
  const _PeopleControls({required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemAddProvider(session);
    final items = ref.watch(provider.select((s) => s.items));
    final groups = personGroups([
      for (final i in items)
        (
          key: i.personId ?? 'unassigned',
          label: i.personLabel,
          you: i.isCurrentUserPerson,
          included: i.includeInWardrobe,
        ),
    ]);
    if (groups.length < 2) return const SizedBox.shrink();
    final notifier = ref.read(provider.notifier);
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing16),
      child: PersonGroupList(
        groups: groups,
        onSet: notifier.setPersonInclusion,
      ),
    );
  }
}

/// One person in a photo and how many of their pieces are included.
typedef PersonGroup = ({String key, String label, int included, int total});

/// Groups pieces by person, in first-seen order.
List<PersonGroup> personGroups(
  List<({String key, String? label, bool you, bool included})> pieces,
) {
  final order = <String>[];
  final labels = <String, String>{};
  final included = <String, int>{};
  final total = <String, int>{};
  for (final p in pieces) {
    if (!total.containsKey(p.key)) order.add(p.key);
    final label = p.label?.trim() ?? '';
    labels[p.key] ??= label.isEmpty
        ? (p.you ? 'You' : 'Person')
        : (p.you && label.toLowerCase() != 'you' ? '$label (you)' : label);
    total[p.key] = (total[p.key] ?? 0) + 1;
    included[p.key] = (included[p.key] ?? 0) + (p.included ? 1 : 0);
  }
  return [
    for (final k in order)
      (key: k, label: labels[k]!, included: included[k]!, total: total[k]!),
  ];
}

/// People in the photos, with include-all and skip-all per person.
class PersonGroupList extends StatelessWidget {
  const PersonGroupList({super.key, required this.groups, required this.onSet});

  final List<PersonGroup> groups;
  final void Function(String key, bool include) onSet;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return PaperSurface(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing4,
        AppConstants.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('People in the photos', style: text.titleSmall),
          for (final g in groups)
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: g.label),
                        TextSpan(
                          text: '  ${g.included} of ${g.total}',
                          style: TextStyle(color: tokens.textMuted),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: g.included == g.total
                      ? null
                      : () => onSet(g.key, true),
                  child: const Text('Include'),
                ),
                TextButton(
                  onPressed: g.included == 0 ? null : () => onSet(g.key, false),
                  child: const Text('Skip'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PieceGrid extends ConsumerWidget {
  const _PieceGrid({required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemAddProvider(session);
    final items = ref.watch(provider.select((s) => s.items));
    final notifier = ref.read(provider.notifier);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: AppConstants.spacing12,
          crossAxisSpacing: AppConstants.spacing12,
          childAspectRatio: 0.74,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => _PieceCard(
          item: items[i],
          onToggle: () => notifier.toggleInclude(items[i].tempId),
        ),
      ),
    );
  }
}

class _PieceCard extends StatelessWidget {
  const _PieceCard({required this.item, required this.onToggle});

  final DetectedItemDataWithImage item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final included = item.includeInWardrobe;
    final name = item.name ?? item.subCategory ?? item.category;
    final failed = item.generationError != null || item.status == 'failed';
    final url = item.generatedImageUrl;
    final glyph = Center(
      child: GarmentGlyph(
        category: Category.fromString(item.category),
        size: 64,
      ),
    );

    return PaperSurface(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      grain: false,
      lift: included ? 1 : 0.4,
      color: included ? tokens.stock.card : tokens.stock.sunk,
      onTap: onToggle,
      semanticLabel: '$name, ${included ? 'included' : 'skipped'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Opacity(
              opacity: included ? 1 : 0.5,
              child: ColoredBox(
                color: tokens.stock.sunk,
                child: url != null
                    ? GeneratedImage(url: url, fallback: glyph)
                    : glyph,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing12,
              AppConstants.spacing8,
              AppConstants.spacing4,
              AppConstants.spacing8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall,
                      ),
                      Text(
                        url != null
                            ? (item.colors?.take(2).join(', ') ?? '')
                            : failed
                            ? 'Your photo is used'
                            : 'Making studio photo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: failed && url == null
                              ? tokens.warning
                              : tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox.square(
                  dimension: 44,
                  child: Checkbox(
                    value: included,
                    onChanged: (_) => onToggle(),
                    semanticLabel: included ? 'Skip $name' : 'Include $name',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UseCases extends ConsumerWidget {
  const _UseCases({required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemAddProvider(session);
    return UseCasePicker(
      selected: ref.watch(provider.select((s) => s.useCases)),
      onToggle: ref.read(provider.notifier).toggleUseCase,
      helper: 'Added to every piece you save.',
    );
  }
}

/// The scan stopped with nothing to show. Copy and next step follow the
/// failure kind.
class ExtractionFailureView extends ConsumerWidget {
  const ExtractionFailureView({super.key, required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemAddProvider(session);
    final failure = ref.watch(provider.select((s) => s.failure));
    final image = ref.watch(provider.select((s) => s.image));
    final notifier = ref.read(provider.notifier);
    if (failure == null) return const SizedBox.shrink();

    void retry() {
      if (image != null) notifier.processImage(image);
    }

    final manual = TextButton(
      onPressed: notifier.openManualEntry,
      child: const Text('Enter details yourself'),
    );
    final another = TextButton(
      onPressed: notifier.reset,
      child: const Text('Choose another photo'),
    );
    final paywall = EnvConfig.paywallEnabled;

    final (
      scene,
      title,
      message,
      action,
      onAction,
      secondary,
    ) = switch (failure.kind) {
      ItemAddFailureKind.connection => (
        PaperScenes.offline,
        'Connection lost',
        'Check your connection, then try again.',
        'Try again',
        retry,
        [manual],
      ),
      ItemAddFailureKind.dailyLimit => (
        PaperScenes.oops,
        'Daily limit reached',
        paywall
            ? 'Upgrade to Pro for more scans, or enter the details yourself.'
            : 'Your scans reset tomorrow. You can enter the details yourself now.',
        paywall ? 'See plans' : null,
        paywall ? () => context.push(Routes.subscription) : null,
        [manual],
      ),
      ItemAddFailureKind.busy => (
        PaperScenes.oops,
        'Our AI is busy',
        'This is on our side. Try again in a few minutes.',
        'Try again',
        retry,
        [manual],
      ),
      ItemAddFailureKind.noItems => (
        PaperScenes.closet,
        'No pieces found',
        'Try a clearer photo, or enter the details yourself.',
        'Choose another photo',
        notifier.reset,
        [manual],
      ),
      ItemAddFailureKind.aiUnavailable => (
        PaperScenes.oops,
        'Scanning is unavailable',
        'Enter the details yourself for now.',
        'Enter details yourself',
        notifier.openManualEntry,
        [another],
      ),
      ItemAddFailureKind.other => (
        PaperScenes.oops,
        'The scan did not finish',
        failure.message.isEmpty ? 'Try again.' : failure.message,
        'Try again',
        retry,
        [manual],
      ),
    };

    return SingleChildScrollView(
      child: AppEmptyState(
        scene: scene,
        title: title,
        message: message,
        actionLabel: action,
        onAction: onAction,
        secondary: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...secondary,
            if (failure.kind != ItemAddFailureKind.aiUnavailable &&
                failure.kind != ItemAddFailureKind.noItems)
              another,
          ],
        ),
      ),
    );
  }
}
