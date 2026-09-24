import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/models/item_model.dart';
import '../../wardrobe/widgets/garment_glyph.dart';
import '../models/outfit_model.dart';
import '../providers/outfit_providers.dart';

/// One outfit. Shows the cached list copy at once, then the fresh fetch.
class OutfitDetailPage extends ConsumerWidget {
  const OutfitDetailPage({super.key, required this.outfitId});

  final String outfitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(outfitDetailProvider(outfitId));
    final cached = ref.watch(
      outfitsProvider.select(
        (s) => s.value?.items.where((o) => o.id == outfitId).firstOrNull,
      ),
    );
    final outfit = detail.value ?? cached;
    final refresh = ref.read(outfitDetailProvider(outfitId).notifier).refresh;

    return PaperStockScope(
      stock: PaperStockId.marigold,
      child: Scaffold(
        body: AppPageBackground(
          child: outfit == null
              ? (detail.hasError
                    ? SafeArea(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                tooltip: 'Back',
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () => Navigator.maybePop(context),
                              ),
                            ),
                            Expanded(
                              child: AppErrorState(
                                error: detail.error,
                                onRetry: refresh,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SafeArea(child: SkeletonDetailPage()))
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(wearHistoryProvider(outfitId));
                    await refresh();
                  },
                  child: _Body(
                    outfit: outfit,
                    error: detail.hasError ? detail.error : null,
                    onRetry: refresh,
                  ),
                ),
        ),
        bottomNavigationBar: outfit == null ? null : _WornBar(id: outfit.id),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.outfit, required this.onRetry, this.error});

  final OutfitModel outfit;
  final Object? error;
  final VoidCallback onRetry;

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final url = await ref.read(outfitsProvider.notifier).share(outfit.id);
    if (url == null || !context.mounted) return;
    final text = 'My outfit "${outfit.name}" on FitCheck AI: $url';
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final image = outfit.outfitImages?.firstOrNull?.url;
    if (image != null) {
      try {
        // Uses the configured client: auth headers and timeouts apply.
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/outfit_share_${outfit.id}.png');
        await ApiClient.instance.dio.download(image, file.path);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: text,
          sharePositionOrigin: origin,
        );
        if (await file.exists()) await file.delete();
        return;
      } catch (_) {
        // Share the link alone when the image download fails.
      }
    }
    await Share.share(text, sharePositionOrigin: origin);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this outfit?'),
        content: Text(
          '"${outfit.name}" is removed. Its pieces stay in your closet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: PaperTokens.of(context).error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final deleted = await ref.read(outfitsProvider.notifier).delete(outfit.id);
    if (deleted && context.mounted) Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final busy = ref.watch(
      outfitsBusyProvider.select((s) => s.contains(outfit.id)),
    );
    final images = outfit.outfitImages ?? const [];
    final pieces = outfit.items ?? const <ItemModel>[];
    final summary = [
      if (outfit.style != null) outfit.style!.displayName,
      if (outfit.season != null) outfit.season!.displayName,
      '${pieces.isEmpty ? outfit.itemIds.length : pieces.length} pieces',
      if (outfit.isDraft) 'Draft',
    ].join(' · ');

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          // Grained like the page, so content scrolling under it is hidden
          // and there is no seam.
          flexibleSpace: const PaperGrainFill(),
          actions: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push(Routes.outfitEdit(outfit.id)),
            ),
            Builder(
              builder: (buttonContext) => IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () => _share(buttonContext, ref),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (value) => value == 'duplicate'
                  ? ref.read(outfitsProvider.notifier).duplicate(outfit.id)
                  : _delete(context, ref),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Text('Duplicate'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: PaperTokens.of(context).error),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (error != null)
          SliverToBoxAdapter(
            child: AppErrorBanner(error: error, onRetry: onRetry),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          sliver: SliverList.list(
            children: [
              PaperSurface(
                padding: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                grain: false,
                color: tokens.stock.sunk,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: images.isNotEmpty
                      ? AppImage(
                          imageUrl: images.first.url,
                          fit: BoxFit.contain,
                          backgroundColor: tokens.stock.sunk,
                          galleryUrls: [for (final i in images) i.url],
                          memCacheWidth: 1080,
                          storagePath: images.first.storagePath,
                          remintUrl: ref
                              .read(outfitRepositoryProvider)
                              .remintImageUrl,
                          semanticLabel: outfit.name,
                        )
                      : _Collage(pieces: pieces),
                ),
              ),
              const SizedBox(height: AppConstants.spacing20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(outfit.name, style: text.headlineMedium),
                        const SizedBox(height: AppConstants.spacing4),
                        Text(
                          summary,
                          style: text.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: outfit.isFavorite
                        ? 'Remove favourite'
                        : 'Save to favourites',
                    onPressed: busy
                        ? null
                        : () => ref
                              .read(outfitsProvider.notifier)
                              .toggleFavorite(outfit.id),
                    icon: Icon(
                      outfit.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: tokens.stock.accent,
                      size: 28,
                    ),
                  ),
                ],
              ),
              if (outfit.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppConstants.spacing12),
                Text(outfit.description!, style: text.bodyLarge),
              ],
              if (pieces.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing20),
                Text('Pieces', style: text.headlineSmall),
                const SizedBox(height: AppConstants.spacing8),
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: pieces.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppConstants.spacing12),
                    itemBuilder: (context, i) => _PieceTile(item: pieces[i]),
                  ),
                ),
              ],
              const SizedBox(height: AppConstants.spacing16),
              PaperSurface(
                child: Row(
                  children: [
                    _Figure(
                      value: paperFigure(outfit.wornCount),
                      label: 'times worn',
                    ),
                    _Figure(
                      value: outfit.lastWornAt == null
                          ? 'Never'
                          : AppDateUtils.formatRelativeTime(outfit.lastWornAt!),
                      label: 'last worn',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              _WearHistory(outfit: outfit),
              const SizedBox(height: AppConstants.spacing24),
            ],
          ),
        ),
      ],
    );
  }
}

/// Up to four piece photos when the outfit has no image of its own.
class _Collage extends ConsumerWidget {
  const _Collage({required this.pieces});

  final List<ItemModel> pieces;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = pieces.take(4).toList();
    if (shown.isEmpty) {
      return Center(
        child: Icon(
          Icons.style_outlined,
          size: 64,
          color: PaperTokens.of(context).textMuted,
        ),
      );
    }
    return GridView.count(
      crossAxisCount: shown.length == 1 ? 1 : 2,
      // Two pieces stand side by side at full height.
      childAspectRatio: shown.length == 2 ? 0.5 : 1,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacing8),
      mainAxisSpacing: AppConstants.spacing8,
      crossAxisSpacing: AppConstants.spacing8,
      children: [for (final p in shown) _PieceImage(item: p)],
    );
  }
}

class _PieceImage extends ConsumerWidget {
  const _PieceImage({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = item.itemImages?.firstOrNull;
    final tokens = PaperTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radius8),
      child: ColoredBox(
        color: image == null ? tokens.stock.tint : tokens.stock.card,
        child: image == null
            ? Center(child: GarmentGlyph(category: item.category, size: 96))
            : AppImage(
                imageUrl: image.url,
                fit: BoxFit.contain,
                enableZoom: false,
                memCacheWidth: 360,
                storagePath: image.storagePath,
                remintUrl: ref.read(outfitRepositoryProvider).remintImageUrl,
                semanticLabel: item.name,
              ),
      ),
    );
  }
}

class _PieceTile extends StatelessWidget {
  const _PieceTile({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: PaperSurface(
        padding: EdgeInsets.zero,
        grain: false,
        clipBehavior: Clip.antiAlias,
        onTap: () =>
            context.push(Routes.item(item.id)),
        semanticLabel: item.name,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _PieceImage(item: item)),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing6),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: text.displaySmall?.copyWith(fontSize: 28),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: text.bodySmall?.copyWith(
              color: PaperTokens.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WearHistory extends ConsumerWidget {
  const _WearHistory({required this.outfit});

  final OutfitModel outfit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final Widget body;
    if (outfit.wornCount == 0) {
      body = Text(
        'Wear it once and the dates show up here.',
        style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
      );
    } else {
      final history = ref.watch(wearHistoryProvider(outfit.id));
      body = switch (history) {
        AsyncValue(:final value?) => Column(
          children: [
            for (final entry in value.take(8))
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing6,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 18,
                      color: tokens.stock.accent,
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Text(
                        AppDateUtils.formatMonthDayYear(entry.wornAt.toLocal()),
                        style: text.bodyMedium,
                      ),
                    ),
                    if (entry.notes?.isNotEmpty ?? false)
                      Flexible(
                        child: Text(
                          entry.notes!,
                          style: text.bodySmall?.copyWith(
                            color: tokens.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            // The first eight are a preview, not the whole history.
            if (value.length > 8)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Wear history'),
                      // Long histories must scroll inside the dialog instead
                      // of pushing the Close action off-screen.
                      scrollable: true,
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final entry in value)
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.event_available_outlined,
                                  size: 18,
                                ),
                                title: Text(
                                  AppDateUtils.formatMonthDayYear(
                                    entry.wornAt.toLocal(),
                                  ),
                                ),
                                subtitle: (entry.notes?.isNotEmpty ?? false)
                                    ? Text(entry.notes!)
                                    : null,
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  child: Text('Show all ${value.length}'),
                ),
              ),
          ],
        ),
        AsyncValue(hasError: true) => Row(
          children: [
            Expanded(
              child: Text(
                "Couldn't load the dates.",
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(wearHistoryProvider(outfit.id)),
              child: const Text('Retry'),
            ),
          ],
        ),
        _ => const SkeletonListLoaderBox(itemCount: 2, hasLeading: false),
      };
    }
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Worn on', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          body,
        ],
      ),
    );
  }
}

class _WornBar extends ConsumerWidget {
  const _WornBar({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(outfitsBusyProvider.select((s) => s.contains(id)));
    return PaperActionBar(
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: busy
              ? null
              : () => ref.read(outfitsProvider.notifier).markAsWorn(id),
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.today_outlined),
          label: const Text('Wore it today'),
        ),
      ),
    );
  }
}
