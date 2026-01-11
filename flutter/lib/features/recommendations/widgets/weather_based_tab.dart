import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/models/item_model.dart';
import '../controllers/recommendations_controller.dart';

/// Weather-Based Tab - Get recommendations based on weather
class WeatherBasedTab extends StatelessWidget {
  const WeatherBasedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final RecommendationsController controller = Get.find<RecommendationsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing16),
      child: Column(
        children: [
          // Location input
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.weatherLocation.value = value,
                    decoration: InputDecoration(
                      labelText: 'Your Location',
                      hintText: 'Enter city name',
                      filled: true,
                      fillColor: tokens.cardColor.withOpacity(0.5),
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radius12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoadingWeather.value
                          ? null
                          : () => controller.fetchWeatherRecommendations(),
                      child: controller.isLoadingWeather.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Get Recs'),
                    )),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacing16),

          // Weather display
          Obx(() {
            if (controller.weatherError.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                padding: const EdgeInsets.all(AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: tokens.cardColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                  border: Border.all(color: tokens.cardBorderColor),
                ),
                child: Text(
                  controller.weatherError.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final weather = controller.weatherData.value;
            if (weather == null || weather.isEmpty) {
              return const SizedBox.shrink();
            }

            final temperature = weather['temperature'] as num? ?? 0;
            final condition = weather['condition']?.toString() ?? 'Unknown';
            final icon = _getWeatherIcon(condition);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
              padding: const EdgeInsets.all(AppConstants.spacing16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tokens.brandColor.withOpacity(0.1),
                    tokens.brandColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radius12),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 48, color: tokens.brandColor),
                  const SizedBox(width: AppConstants.spacing16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${temperature.toInt()} F',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        condition.split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' '),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    controller.weatherLocation.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppConstants.spacing16),

          // Recommended categories
          Obx(() {
            if (controller.preferredCategories.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
              child: Wrap(
                spacing: AppConstants.spacing8,
                children: controller.preferredCategories.map((cat) {
                  return Chip(
                    label: Text(cat.split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')),
                    backgroundColor: tokens.brandColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
            );
          }),

          const SizedBox(height: AppConstants.spacing24),

          // Recommendations
          Obx(() {
            if (controller.isLoadingWeather.value) {
              return const Padding(
                padding: EdgeInsets.only(top: AppConstants.spacing16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.weatherError.value.isNotEmpty) {
              return const SizedBox.shrink();
            }

            if (controller.weatherData.value == null || controller.weatherData.value!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 64,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      'Enter your location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'We\'ll suggest items based on the weather',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textMuted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (controller.weatherRecommendations.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      'No items match this weather',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacing16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.spacing12,
                crossAxisSpacing: AppConstants.spacing12,
                childAspectRatio: 0.75,
              ),
              itemCount: controller.weatherRecommendations.length,
              itemBuilder: (context, index) {
                final item = controller.weatherRecommendations[index];
                return _buildItemCard(context, item, tokens, controller);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ItemModel item,
    AppUiTokens tokens,
    RecommendationsController controller,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius8),
              child: item.itemImages != null && item.itemImages!.isNotEmpty
                  ? Image.network(
                      item.itemImages!.first.url,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: tokens.cardColor.withOpacity(0.5),
                      child: Icon(
                        Icons.image,
                        color: tokens.textMuted,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          // Name
          Text(
            item.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Category
          Text(
            item.category.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sunny') || lower.contains('clear')) return Icons.wb_sunny;
    if (lower.contains('cloud')) return Icons.cloud;
    if (lower.contains('rain')) return Icons.water_drop;
    if (lower.contains('snow')) return Icons.ac_unit;
    if (lower.contains('storm')) return Icons.thunderstorm;
    if (lower.contains('fog') || lower.contains('mist')) return Icons.cloud;
    return Icons.wb_sunny;
  }
}
