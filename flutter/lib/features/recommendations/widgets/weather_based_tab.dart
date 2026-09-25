import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../providers/recommendations_providers.dart';
import 'recommendation_widgets.dart';

/// Today's weather for a city and the closet pieces that suit it.
class WeatherBasedTab extends ConsumerStatefulWidget {
  const WeatherBasedTab({super.key});

  @override
  ConsumerState<WeatherBasedTab> createState() => _WeatherBasedTabState();
}

class _WeatherBasedTabState extends ConsumerState<WeatherBasedTab>
    with AutomaticKeepAliveClientMixin {
  final _city = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  WeatherNotifier get _weather => ref.read(weatherProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Show the saved city in the field, so the user sees what was searched.
    ref.listenManual(weatherSetupProvider, (_, next) {
      final saved = next.value?.location ?? '';
      if (_city.text.isEmpty && saved.isNotEmpty) _city.text = saved;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    _weather.search(_city.text);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final weather = ref.watch(weatherProvider);

    return RefreshIndicator(
      onRefresh: _weather.retry,
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
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _city,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  ElevatedButton(
                    onPressed: weather.isLoading ? null : _search,
                    child: const Text('Check'),
                  ),
                ],
              ),
            ),
          ),
          ..._results(weather),
        ],
      ),
    );
  }

  List<Widget> _results(AsyncValue<WeatherReport?> weather) {
    if (weather.isLoading) {
      return [
        SliverPadding(
          padding: tabPadding,
          sliver: SliverList.list(
            children: const [
              SkeletonCard(height: 150),
              SizedBox(height: AppConstants.spacing16),
              SkeletonGridLoaderBox(itemCount: 2, childAspectRatio: 0.78),
            ],
          ),
        ),
      ];
    }
    final report = weather.value;
    if (weather.hasError && report == null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorState(error: weather.error, onRetry: _weather.retry),
        ),
      ];
    }
    if (report == null) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            scene: PaperScenes.home,
            title: "What's the weather?",
            message: 'Enter your city to get picks for today.',
          ),
        ),
      ];
    }
    final text = Theme.of(context).textTheme;
    final tokens = PaperTokens.of(context);
    return [
      if (weather.hasError)
        SliverToBoxAdapter(
          child: AppErrorBanner(error: weather.error, onRetry: _weather.retry),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          AppConstants.spacing8,
          AppConstants.spacing16,
          AppConstants.spacing20,
        ),
        sliver: SliverToBoxAdapter(child: _WeatherCard(report: report)),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Wear today', style: text.headlineSmall),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                [
                  for (final c in report.categories)
                    Category.values.asNameMap()[c]?.displayName ??
                        capitalizeWords(c),
                ].join(' · '),
                style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ),
      ),
      if (report.items.isEmpty)
        SliverPadding(
          padding: tabPadding,
          sliver: SliverToBoxAdapter(
            child: Text(
              'No pieces in your closet for this weather yet.',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ),
        )
      else
        SliverPadding(
          padding: tabPadding,
          sliver: SliverGrid.builder(
            gridDelegate: pieceGridDelegate,
            itemCount: report.items.length,
            itemBuilder: (context, i) => PieceCard.item(report.items[i]),
          ),
        ),
    ];
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.report});

  final WeatherReport report;

  static IconData _icon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('storm') || c.contains('thunder')) {
      return Icons.thunderstorm_outlined;
    }
    if (c.contains('snow')) return Icons.ac_unit_rounded;
    if (c.contains('rain') || c.contains('drizzle')) {
      return Icons.water_drop_outlined;
    }
    if (c.contains('cloud') || c.contains('fog') || c.contains('mist')) {
      return Icons.cloud_outlined;
    }
    return Icons.wb_sunny_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final condition = capitalizeWords(report.condition);
    // 0° is a real reading, so only an unknown value shows a dash.
    final figure = report.displayTemperature?.toString() ?? '–';
    return PaperSurface(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing20,
        AppConstants.spacing16,
        AppConstants.spacing20,
        AppConstants.spacing20,
      ),
      semanticLabel:
          '${report.displayTemperature ?? 'Unknown'} ${report.unitLabel}, '
          '$condition in ${report.location}',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        figure,
                        style: text.displayLarge?.copyWith(height: 1.1),
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      Text(
                        report.unitLabel,
                        style: text.headlineSmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (condition.isNotEmpty)
                    Text(condition, style: text.titleMedium),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    report.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Icon(_icon(report.condition), size: 56, color: tokens.stock.accent),
          ],
        ),
      ),
    );
  }
}
