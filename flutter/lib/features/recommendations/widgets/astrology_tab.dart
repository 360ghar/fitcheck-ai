import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/providers/wardrobe_providers.dart';
import '../providers/recommendations_providers.dart';
import 'recommendation_widgets.dart';

/// Lucky colours for a day and closet picks in them.
class AstrologyTab extends ConsumerStatefulWidget {
  const AstrologyTab({super.key});

  @override
  ConsumerState<AstrologyTab> createState() => _AstrologyTabState();
}

class _AstrologyTabState extends ConsumerState<AstrologyTab>
    with AutomaticKeepAliveClientMixin {
  String _mode = 'daily';
  DateTime _date = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  AstrologyNotifier get _astrology => ref.read(astrologyProvider.notifier);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reading = ref.watch(astrologyProvider);
    return RefreshIndicator(
      onRefresh: _astrology.retry,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing8,
            ),
            sliver: SliverToBoxAdapter(child: _controls(reading.isLoading)),
          ),
          ..._results(reading),
        ],
      ),
    );
  }

  Widget _controls(bool loading) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'daily',
            label: Text(context.l10n.recommendMoodEveryday),
          ),
          ButtonSegment(
            value: 'important_meeting',
            label: Text(context.l10n.recommendMoodBigMeeting),
          ),
        ],
        selected: {_mode},
        showSelectedIcon: false,
        onSelectionChanged: (s) => setState(() => _mode = s.first),
      ),
      const SizedBox(height: AppConstants.spacing12),
      InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: context.l10n.recommendDayLabel,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(AppDateUtils.formatMonthDayYear(_date)),
        ),
      ),
      const SizedBox(height: AppConstants.spacing12),
      ElevatedButton(
        onPressed: loading
            ? null
            : () => _astrology.fetch(mode: _mode, date: _date),
        child: Text(
          loading
              ? context.l10n.recommendReadingStars
              : context.l10n.recommendGetMyColours,
        ),
      ),
    ],
  );

  List<Widget> _results(AsyncValue<Map<String, dynamic>?> reading) {
    if (reading.isLoading) {
      return [
        SliverPadding(
          padding: tabPadding,
          sliver: SliverList.separated(
            itemCount: 3,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppConstants.spacing12),
            itemBuilder: (_, _) => const SkeletonCard(height: 120),
          ),
        ),
      ];
    }
    final data = reading.value;
    if (reading.hasError && data == null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorState(error: reading.error, onRetry: _astrology.retry),
        ),
      ];
    }
    if (data == null || data.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            scene: PaperScenes.home,
            title: context.l10n.recommendLuckyColoursTitle,
            message: context.l10n.recommendLuckyColoursBody,
          ),
        ),
      ];
    }
    final sections = data['status']?.toString() == 'profile_required'
        ? [_ProfileRequired(notes: _strings(data['notes']))]
        : [
            _ColourSection(
              title: context.l10n.recommendLuckyColoursSection,
              colours: _maps(data['lucky_colors']),
            ),
            _ColourSection(
              title: context.l10n.recommendAvoidColoursSection,
              colours: _maps(data['avoid_colors']),
            ),
            _PicksSection(groups: _maps(data['wardrobe_picks'])),
            _OutfitsSection(outfits: _maps(data['suggested_outfits'])),
          ];
    return [
      if (reading.hasError)
        SliverToBoxAdapter(
          child: AppErrorBanner(
            error: reading.error,
            onRetry: _astrology.retry,
          ),
        ),
      SliverPadding(
        padding: tabPadding,
        sliver: SliverList.separated(
          itemCount: sections.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppConstants.spacing16),
          itemBuilder: (_, i) => sections[i],
        ),
      ),
    ];
  }
}

List<Map<String, dynamic>> _maps(dynamic value) => value is List
    ? [
        for (final v in value)
          if (v is Map) Map<String, dynamic>.from(v),
      ]
    : const [];

List<String> _strings(dynamic value) =>
    value is List ? [for (final v in value) v.toString()] : const [];

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => PaperSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppConstants.spacing12),
        ...children,
      ],
    ),
  );
}

class _Quiet extends StatelessWidget {
  const _Quiet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: PaperTokens.of(context).textSecondary,
    ),
  );
}

class _ProfileRequired extends StatelessWidget {
  const _ProfileRequired({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) => _Section(
    title: context.l10n.recommendBirthDateTitle,
    children: [
      _Quiet(context.l10n.recommendBirthDateBody),
      for (final note in notes) ...[
        const SizedBox(height: AppConstants.spacing4),
        _Quiet(note),
      ],
      const SizedBox(height: AppConstants.spacing16),
      ElevatedButton(
        onPressed: () => context.push(Routes.profileEdit),
        child: Text(context.l10n.recommendEditProfile),
      ),
    ],
  );
}

class _ColourSection extends StatelessWidget {
  const _ColourSection({required this.title, required this.colours});

  final String title;
  final List<Map<String, dynamic>> colours;

  static Color? _parse(String? hex) {
    final value = hex?.replaceAll('#', '').trim() ?? '';
    final parsed = int.tryParse(
      value.length == 6 ? 'FF$value' : value,
      radix: 16,
    );
    return parsed == null ? null : Color(parsed);
  }

  static double? _confidence(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}'.trim());

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return _Section(
      title: title,
      children: [
        if (colours.isEmpty) _Quiet(context.l10n.recommendNothingThisDay),
        for (final c in colours)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacing6,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A colour swatch is the data itself, not decoration.
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _parse(c['hex']?.toString()) ?? tokens.stock.sunk,
                    shape: BoxShape.circle,
                    border: Border.all(color: tokens.stock.edge),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['name']?.toString() ??
                            context.l10n.recommendUnnamedColour,
                        style: text.titleSmall,
                      ),
                      if ((c['reason']?.toString() ?? '').isNotEmpty)
                        Text(
                          c['reason'].toString(),
                          style: text.bodySmall?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_confidence(c['confidence']) case final confidence?)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: AppConstants.spacing8),
                    child: Text(
                      '${(confidence * 100).round()}%',
                      style: text.labelLarge?.copyWith(
                        color: tokens.stock.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PicksSection extends ConsumerWidget {
  const _PicksSection({required this.groups});

  final List<Map<String, dynamic>> groups;

  /// Thumbnail first for a small tile, with the full size as the fallback.
  static ({String? url, String? fallback, String? storagePath}) _image(
    Map<String, dynamic> item,
  ) {
    for (final key in ['images', 'item_images']) {
      final images = item[key];
      if (images is List && images.isNotEmpty && images.first is Map) {
        final m = images.first as Map;
        final full = m['image_url']?.toString() ?? m['url']?.toString();
        final thumb = m['thumbnail_url']?.toString();
        final url = (thumb?.isNotEmpty ?? false) ? thumb : full;
        if (url != null && url.isNotEmpty) {
          return (
            url: url,
            fallback: full,
            storagePath: m['storage_path']?.toString(),
          );
        }
      }
    }
    final flat = item['image_url']?.toString();
    return (
      url: (flat?.isNotEmpty ?? false) ? flat : null,
      fallback: null,
      storagePath: null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final remint = ref.read(itemRepositoryProvider).remintImageUrl;
    return _Section(
      title: context.l10n.recommendFromCloset,
      children: [
        if (groups.isEmpty) _Quiet(context.l10n.recommendNoPiecesInColours),
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppConstants.spacing4,
              bottom: AppConstants.spacing8,
            ),
            child: Text(
              capitalizeWords(
                group['category']?.toString() ??
                    context.l10n.categoryOther,
              ),
              style: text.titleSmall?.copyWith(color: tokens.textSecondary),
            ),
          ),
          for (final item in _maps(group['items']))
            Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radius8),
                    child: SizedBox.square(
                      dimension: 48,
                      child: ColoredBox(
                        color: tokens.stock.sunk,
                        child: switch (_image(item)) {
                          (
                            url: final url?,
                            :final fallback,
                            :final storagePath,
                          ) =>
                            AppImage(
                              imageUrl: url,
                              fallbackUrl: fallback,
                              // Contain: item cutouts are cropped tight, so
                              // cover would cut the garment's edges off.
                              fit: BoxFit.contain,
                              enableZoom: false,
                              memCacheWidth: 144,
                              storagePath: storagePath,
                              remintUrl: remint,
                            ),
                          _ => Icon(
                            Icons.checkroom_outlined,
                            color: tokens.textMuted,
                          ),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Text(
                      item['name']?.toString() ??
                          context.l10n.statsUnnamedPiece,
                      style: text.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _OutfitsSection extends StatelessWidget {
  const _OutfitsSection({required this.outfits});

  final List<Map<String, dynamic>> outfits;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return _Section(
      title: context.l10n.recommendOutfitIdeas,
      children: [
        if (outfits.isEmpty)
          _Quiet(context.l10n.recommendNoOutfitsInColours),
        for (final o in outfits)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacing6,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    o['description']?.toString() ??
                        context.l10n.recommendDefaultOutfitIdea,
                    style: text.bodyLarge,
                  ),
                ),
                if (o['match_score'] case final num score)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: AppConstants.spacing8),
                    child: Text(
                      context.l10n.recommendMatchPercent(score.round()),
                      style: text.labelLarge?.copyWith(
                        color: tokens.stock.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
