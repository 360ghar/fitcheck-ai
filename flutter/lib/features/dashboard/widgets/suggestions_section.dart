import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/repositories/item_repository.dart';
import '../models/dashboard_models.dart';

/// Today's weather note and outfit of the day. Hidden when neither exists.
class SuggestionsSection extends StatelessWidget {
  const SuggestionsSection({super.key, required this.suggestions});

  final DashboardSuggestions suggestions;

  // Presigned image URLs expire after 1h; a failed load re-mints the URL
  // from the durable storage key.
  static final ItemRepository _itemRepository = ItemRepository();

  @override
  Widget build(BuildContext context) {
    final weather = suggestions.weatherBased;
    final outfit = suggestions.outfitOfTheDay;
    if (weather == null && outfit == null) return const SizedBox.shrink();
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;

    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today', style: text.headlineSmall),
          if (weather != null) ...[
            const SizedBox(height: AppConstants.spacing12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.wb_sunny_outlined, color: tokens.stock.accent),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (weather.temperature != null)
                          TextSpan(
                            text: '${weather.temperature!.round()}°C  ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        TextSpan(
                          text:
                              weather.recommendation ??
                              'Dress for the day ahead.',
                        ),
                      ],
                    ),
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
          if (outfit != null) ...[
            const SizedBox(height: AppConstants.spacing16),
            InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radius12),
              onTap: outfit.id == null
                  ? null
                  : () => context.push(Routes.outfit(outfit.id!)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                    child: SizedBox.square(
                      dimension: 72,
                      child: ColoredBox(
                        color: tokens.stock.sunk,
                        child: _nonEmpty(outfit.imageUrl) == null
                            ? Icon(Icons.style_outlined, color: tokens.textMuted)
                            : AppImage(
                                imageUrl:
                                    _nonEmpty(outfit.thumbnailUrl) ??
                                    outfit.imageUrl,
                                fallbackUrl: outfit.imageUrl,
                                fit: BoxFit.cover,
                                enableZoom: false,
                                memCacheWidth: 216,
                                errorIcon: Icons.style_outlined,
                                storagePath: outfit.storagePath,
                                remintUrl: _itemRepository.remintImageUrl,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outfit of the day',
                          style: text.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                        Text(
                          outfit.name ?? 'A fresh look',
                          style: text.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String? _nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;
}
