import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

/// Suggestions section showing weather and outfit of the day
class SuggestionsSection extends StatelessWidget {
  const SuggestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final tokens = AppUiTokens.of(context);

    return Obx(() {
      final suggestions = controller.dashboard.value?.suggestions;
      final weather = suggestions?.weatherBased;
      final outfit = suggestions?.outfitOfTheDay;

      return AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Today\'s Suggestions',
              subtitle: 'AI-curated styling ideas',
            ),
            const SizedBox(height: AppConstants.spacing12),
            if (weather == null && outfit == null)
              Text(
                'No suggestions yet. Add more outfits to unlock daily ideas.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            if (weather != null) ...[
              _WeatherSuggestion(weather: weather),
              if (outfit != null) const SizedBox(height: AppConstants.spacing12),
            ],
            if (outfit != null) _OutfitSuggestion(outfit: outfit),
          ],
        ),
      );
    });
  }
}

class _WeatherSuggestion extends StatelessWidget {
  final DashboardWeatherSuggestion weather;

  const _WeatherSuggestion({required this.weather});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final tempLabel = weather.temperature == null
        ? 'Weather'
        : '${weather.temperature!.toStringAsFixed(1)} deg C';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        color: tokens.cardColor.withOpacity(0.65),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.brandColor.withOpacity(0.15),
            ),
            child: Icon(Icons.wb_sunny_rounded, color: tokens.brandColor),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tempLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  weather.recommendation ?? 'Style smart for the day ahead.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
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

class _OutfitSuggestion extends StatelessWidget {
  final DashboardOutfitOfTheDay outfit;

  const _OutfitSuggestion({required this.outfit});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        color: tokens.cardColor.withOpacity(0.65),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius12),
            child: Container(
              width: 64,
              height: 64,
              color: tokens.cardBorderColor.withOpacity(0.2),
              child: outfit.imageUrl == null
                  ? Icon(Icons.image, color: tokens.textMuted)
                  : CachedNetworkImage(
                      imageUrl: outfit.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: tokens.cardBorderColor.withOpacity(0.2),
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image, color: tokens.textMuted),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  outfit.name ?? 'Fresh look ready',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.outfits),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
