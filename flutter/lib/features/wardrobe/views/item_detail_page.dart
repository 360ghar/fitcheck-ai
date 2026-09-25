import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/constants/use_cases.dart';
import '../models/item_model.dart';
import '../providers/wardrobe_providers.dart';
import '../widgets/garment_glyph.dart';

/// One closet piece. Shows the cached list copy at once, then the fresh
/// fetch (image URLs are presigned and expire).
class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(itemDetailProvider(itemId));
    final cached = ref.watch(
      wardrobeProvider.select(
        (s) => s.value?.items.where((i) => i.id == itemId).firstOrNull,
      ),
    );
    final item = detail.value ?? cached;
    final refresh = ref.read(itemDetailProvider(itemId).notifier).refresh;

    return PaperStockScope(
      stock: PaperStockId.moss,
      child: Scaffold(
        body: AppPageBackground(
          child: item == null
              ? (detail.hasError
                    ? SafeArea(
                        child: Column(
                          children: [
                            const _BackRow(),
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
                  onRefresh: refresh,
                  child: _DetailBody(
                    item: item,
                    error: detail.hasError ? detail.error : null,
                    onRetry: refresh,
                  ),
                ),
        ),
        bottomNavigationBar: item == null ? null : _WornBar(item: item),
      ),
    );
  }
}

class _BackRow extends StatelessWidget {
  const _BackRow();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => Navigator.maybePop(context),
    ),
  );
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.item, required this.onRetry, this.error});

  final ItemModel item;
  final Object? error;
  final VoidCallback onRetry;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this piece?'),
        content: const Text('Outfits that use it lose this piece.'),
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
    final deleted = await ref.read(wardrobeProvider.notifier).deleteItem(item.id);
    if (deleted && context.mounted) Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final busy = ref.watch(
      wardrobeBusyProvider.select((s) => s.contains(item.id)),
    );
    final images = item.itemImages ?? const [];
    final summary = [
      item.category.displayName,
      item.condition.displayName,
      if (item.brand?.isNotEmpty ?? false) item.brand!,
      if (item.size?.isNotEmpty ?? false) 'Size ${item.size}',
    ].join(' · ');
    final details = <(String, String)>[
      if (item.colors?.isNotEmpty ?? false) ('Colours', item.colors!.join(', ')),
      if (item.material?.isNotEmpty ?? false) ('Material', item.material!),
      if (item.pattern?.isNotEmpty ?? false) ('Pattern', item.pattern!),
      if (item.occasionTags?.isNotEmpty ?? false)
        ('Use cases', item.occasionTags!.map(UseCases.displayLabel).join(', ')),
      if (item.location?.isNotEmpty ?? false) ('Kept in', item.location!),
      if (item.price != null) ('Price', item.price!.toStringAsFixed(2)),
      if (item.purchaseDate != null)
        ('Bought', AppDateUtils.formatMonthDayYear(item.purchaseDate!)),
      if (item.tags?.isNotEmpty ?? false) ('Tags', item.tags!.join(', ')),
      if (item.createdAt != null)
        ('Added', AppDateUtils.formatRelativeTime(item.createdAt!)),
    ];

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
              onPressed: () => context.push(
                Routes.itemEdit(item.id),
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(context, ref),
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
                  child: images.isEmpty
                      ? Center(
                          child: GarmentGlyph(
                            category: item.category,
                            size: 120,
                          ),
                        )
                      : AppImage(
                          imageUrl: images.first.url,
                          fit: BoxFit.contain,
                          backgroundColor: tokens.stock.sunk,
                          galleryUrls: [for (final i in images) i.url],
                          memCacheWidth: 1080,
                          storagePath: images.first.storagePath,
                          remintUrl: ref
                              .read(itemRepositoryProvider)
                              .remintImageUrl,
                          semanticLabel: item.name,
                        ),
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
                        Text(item.name, style: text.headlineMedium),
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
                    tooltip: item.isFavorite
                        ? 'Remove favourite'
                        : 'Add to favourites',
                    onPressed: busy
                        ? null
                        : () => ref
                              .read(wardrobeProvider.notifier)
                              .toggleFavorite(item.id),
                    icon: Icon(
                      item.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: tokens.stock.accent,
                      size: 28,
                    ),
                  ),
                ],
              ),
              if (item.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppConstants.spacing12),
                Text(item.description!, style: text.bodyLarge),
              ],
              const SizedBox(height: AppConstants.spacing20),
              PaperSurface(
                child: Row(
                  children: [
                    _Figure(value: paperFigure(item.wornCount), label: 'times worn'),
                    _Figure(
                      value: item.lastWornAt == null
                          ? 'Never'
                          : AppDateUtils.formatRelativeTime(item.lastWornAt!),
                      label: 'last worn',
                    ),
                  ],
                ),
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing16),
                PaperSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing16,
                    vertical: AppConstants.spacing8,
                  ),
                  child: Column(
                    children: [
                      for (final (label, value) in details)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacing8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 104,
                                child: Text(
                                  label,
                                  style: text.bodyMedium?.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(value, style: text.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppConstants.spacing24),
            ],
          ),
        ),
      ],
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

class _WornBar extends ConsumerWidget {
  const _WornBar({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(
      wardrobeBusyProvider.select((s) => s.contains(item.id)),
    );
    return PaperActionBar(
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: busy
              ? null
              : () => ref.read(wardrobeProvider.notifier).markAsWorn(item.id),
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
