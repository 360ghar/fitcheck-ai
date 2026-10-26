import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../models/item_model.dart';
import '../providers/item_add_provider.dart';
import 'bounding_box_painter.dart';
import 'extracted_item_card.dart' show GeneratedImage;
import 'extraction_progress_card.dart' show PaperProgressTrack;
import 'garment_glyph.dart';
import 'manual_entry_form.dart' show UseCasePicker;

// The single-photo extraction views. Each part watches only the fields it
// shows, so a progress event does not rebuild the piece grid.

/// The photo being scanned, with detected-piece boxes overlaid as soon as
/// the scan reports them.
class ExtractionPhoto extends StatelessWidget {
  const ExtractionPhoto({
    super.key,
    required this.image,
    this.height = 220,
    this.boxes = const [],
  });

  final File image;
  final double height;

  /// Bounding boxes (`{x, y, width, height}` + `label`) painted over the
  /// photo. Empty while nothing is detected yet.
  final List<Map<String, dynamic>> boxes;

  @override
  Widget build(BuildContext context) {
    final photo = PaperSurface(
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
    if (boxes.isEmpty) return photo;
    final tokens = PaperTokens.of(context);
    return BoundingBoxOverlay(
      boundingBoxes: boxes,
      color: tokens.stock.accent,
      imageFilePath: image.path,
      child: photo,
    );
  }
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
    final boxes = ref.watch(
      provider.select((s) => s.itemBoxes.values.toList()),
    );
    final (phase, progress, secondsLeft) = ref.watch(
      provider.select((s) => (s.phase, s.progress, s.secondsLeft)),
    );
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final (title, detail) = phaseCopy(phase);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        if (image != null) ExtractionPhoto(image: image, boxes: boxes),
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
                context.l10n.photoshootAboutSecondsLeft(secondsLeft),
                style: text.bodySmall?.copyWith(color: tokens.textSecondary),
              ),
          ],
        ),
        if (phase == 'generating') _PieceStatusList(session: session),
        const SizedBox(height: AppConstants.spacing24),
        // Leaving never stops the scan: the registry owns the job and the
        // shade notifies when it finishes. Back does the same; this button
        // makes the capability discoverable.
        Center(
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ErrorHandler.showInfo(
                context.l10n.batchStillWorkingMessage,
                title: context.l10n.batchRunningInBackgroundTitle,
              );
            },
            icon: const Icon(Icons.notifications_active_rounded, size: 20),
            label: Text(context.l10n.batchSendToBackgroundAction),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: ref.read(provider.notifier).cancelExtraction,
            child: Text(context.l10n.actionCancel),
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
                context.l10n.photoshootStudioPhotosReadyCount(done, statuses.length),
                style: text.bodyMedium,
              ),
            ),
            for (final status in statuses.values)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppConstants.spacing4,
                ),
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
    final boxes = ref.watch(
      provider.select((s) => s.itemBoxes.values.toList()),
    );
    final failure = ref.watch(provider.select((s) => s.failure));
    final notifier = ref.read(provider.notifier);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: StillGeneratingBanner(session: session),
              ),
              if (failure != null)
                SliverToBoxAdapter(
                  child: AppErrorBanner(
                    message: context.l10n.batchStudioPhotosStoppedBody,
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
                      ExtractionPhoto(image: image, height: 160, boxes: boxes),
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
                          ? context.l10n.batchSavingLabel
                          : included == 0
                          ? context.l10n.batchChoosePiecesToSave
                          : included == 1
                          ? 'Save 1 piece'
                          : 'Save $included pieces',
                    ),
                  ),
                  TextButton(
                    onPressed: saving ? null : notifier.reset,
                    child: Text(context.l10n.batchStartOverAction),
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
              ? context.l10n.batchTapPieceToSkip
              : context.l10n.photoshootStudioPhotosReadyTap(ready, count),
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
      padding: const EdgeInsetsDirectional.only(
        start: AppConstants.spacing16,
        top: AppConstants.spacing12,
        end: AppConstants.spacing4,
        bottom: AppConstants.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.batchPeopleInPhotosTitle, style: text.titleSmall),
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
                  child: Text(context.l10n.batchIncludeAction),
                ),
                TextButton(
                  onPressed: g.included == 0 ? null : () => onSet(g.key, false),
                  child: Text(context.l10n.batchSkipAction),
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
            padding: const EdgeInsetsDirectional.only(
              start: AppConstants.spacing12,
              top: AppConstants.spacing8,
              end: AppConstants.spacing4,
              bottom: AppConstants.spacing8,
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
                            ? context.l10n.batchYourPhotoIsUsedLabel
                            : context.l10n.batchMakingStudioPhotoLabel,
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

/// Banner shown atop the review grid while studio photos still generate.
/// Leaving is safe: the scan continues in the background and notifies.
class StillGeneratingBanner extends ConsumerWidget {
  const StillGeneratingBanner({super.key, required this.session});

  final int session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(
      itemAddProvider(
        session,
      ).select((s) => s.itemStatus.values.any((v) => v == 'pending')),
    );
    if (!pending) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        0,
      ),
      child: PaperSurface(
        padding: const EdgeInsetsDirectional.only(
          start: AppConstants.spacing16,
          top: AppConstants.spacing12,
          end: AppConstants.spacing8,
          bottom: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: PaperTokens.of(context).stock.accent,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Text(
                context.l10n.batchStudioPhotosOnWayBody,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PaperTokens.of(context).textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ErrorHandler.showInfo(
                  context.l10n.batchStillWorkingMessage,
                  title: context.l10n.batchRunningInBackgroundTitle,
                );
              },
              child: Text(context.l10n.batchLeaveAction),
            ),
          ],
        ),
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
      helper: context.l10n.batchUseCaseHelper,
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
      child: Text(context.l10n.batchEnterDetailsYourselfAction),
    );
    final another = TextButton(
      onPressed: notifier.reset,
      child: Text(context.l10n.batchChooseAnotherPhotoAction),
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
        context.l10n.batchConnectionLostTitle,
        context.l10n.batchConnectionLostBody,
        context.l10n.batchTryAgainAction,
        retry,
        [manual],
      ),
      ItemAddFailureKind.dailyLimit => (
        PaperScenes.oops,
        context.l10n.batchDailyLimitTitle,
        paywall
            ? context.l10n.batchDailyLimitBodyPaywall
            : context.l10n.batchDailyLimitBodyFree,
        paywall ? context.l10n.batchSeePlansAction : null,
        paywall ? () => context.push(Routes.subscription) : null,
        [manual],
      ),
      ItemAddFailureKind.busy => (
        PaperScenes.oops,
        context.l10n.batchAiBusyTitle,
        context.l10n.batchAiBusyBody,
        context.l10n.batchTryAgainAction,
        retry,
        [manual],
      ),
      ItemAddFailureKind.noItems => (
        PaperScenes.closet,
        context.l10n.batchNoPiecesFoundTitle,
        context.l10n.batchNoPiecesBody,
        context.l10n.batchChooseAnotherPhotoAction,
        notifier.reset,
        [manual],
      ),
      ItemAddFailureKind.aiUnavailable => (
        PaperScenes.oops,
        context.l10n.batchScanningUnavailableTitle,
        context.l10n.batchScanningUnavailableBody,
        context.l10n.batchEnterDetailsYourselfAction,
        notifier.openManualEntry,
        [another],
      ),
      ItemAddFailureKind.other => (
        PaperScenes.oops,
        context.l10n.batchScanDidNotFinishTitle,
        failure.message.isEmpty
            ? context.l10n.batchTryAgainBody
            : failure.message,
        context.l10n.batchTryAgainAction,
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
