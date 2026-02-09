import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/recommendations_controller.dart';

/// Astrology tab - lucky colors and outfit picks
class AstrologyTab extends StatelessWidget {
  const AstrologyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final RecommendationsController controller =
        Get.find<RecommendationsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(context, controller, tokens),
          const SizedBox(height: AppConstants.spacing16),
          Obx(() {
            if (controller.astrologyError.value.isNotEmpty) {
              return _buildErrorCard(
                context,
                controller.astrologyError.value,
                tokens,
              );
            }

            if (controller.isLoadingAstrology.value) {
              return ShimmerGridLoaderBox(
                crossAxisCount: 1,
                itemCount: 3,
                childAspectRatio: 3.2,
              );
            }

            final data = controller.astrologyData.value;
            if (data == null || data.isEmpty) {
              return _buildEmptyState(context, tokens);
            }

            final status = data['status']?.toString() ?? 'ready';
            if (status == 'profile_required') {
              return _buildProfileRequiredCard(context, tokens);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorSection(
                  context: context,
                  tokens: tokens,
                  title: 'Lucky Colors',
                  colors: _asMapList(data['lucky_colors']),
                ),
                const SizedBox(height: AppConstants.spacing16),
                _buildColorSection(
                  context: context,
                  tokens: tokens,
                  title: 'Lower-Priority Colors',
                  colors: _asMapList(data['avoid_colors']),
                ),
                const SizedBox(height: AppConstants.spacing16),
                _buildWardrobePicks(
                  context: context,
                  tokens: tokens,
                  picks: _asMapList(data['wardrobe_picks']),
                ),
                const SizedBox(height: AppConstants.spacing16),
                _buildSuggestedOutfits(
                  context: context,
                  tokens: tokens,
                  outfits: _asMapList(data['suggested_outfits']),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    RecommendationsController controller,
    AppUiTokens tokens,
  ) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Astrology Color Guide',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.astrologyMode.value,
                    decoration: const InputDecoration(
                      labelText: 'Recommendation Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(
                        value: 'important_meeting',
                        child: Text('Important Meeting'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.astrologyMode.value = value;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Obx(
            () => InkWell(
              onTap: () => _pickDate(context, controller),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Target Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(controller.astrologyTargetDate.value),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isLoadingAstrology.value
                    ? null
                    : () => controller.fetchAstrologyRecommendations(),
                icon: controller.isLoadingAstrology.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  controller.isLoadingAstrology.value
                      ? 'Checking...'
                      : 'Get Astrology Colors',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppUiTokens tokens) {
    return AppGlassCard(
      child: Column(
        children: [
          Icon(Icons.stars_outlined, size: 56, color: tokens.textMuted),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            'Pick a date and get your lucky colors',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'We will suggest color-first outfit picks from your wardrobe.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRequiredCard(BuildContext context, AppUiTokens tokens) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of birth needed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Add your date of birth to get astrology recommendations.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: AppConstants.spacing12),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.profileEdit),
            child: const Text('Complete Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String error,
    AppUiTokens tokens,
  ) {
    return AppGlassCard(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: tokens.textMuted),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection({
    required BuildContext context,
    required AppUiTokens tokens,
    required String title,
    required List<Map<String, dynamic>> colors,
  }) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          if (colors.isEmpty)
            Text(
              'No colors available for this section.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            )
          else
            ...colors.map((color) {
              final name = color['name']?.toString() ?? 'Unknown';
              final hex = color['hex']?.toString() ?? '#E5E7EB';
              final reason = color['reason']?.toString() ?? '';
              final confidence = color['confidence'] as num?;

              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  border: Border.all(color: tokens.cardBorderColor),
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _parseHexColor(hex),
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.cardBorderColor),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: tokens.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (reason.isNotEmpty)
                            Text(
                              reason,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: tokens.textMuted),
                            ),
                        ],
                      ),
                    ),
                    if (confidence != null)
                      Text(
                        '${(confidence * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.brandColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWardrobePicks({
    required BuildContext context,
    required AppUiTokens tokens,
    required List<Map<String, dynamic>> picks,
  }) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wardrobe Picks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          if (picks.isEmpty)
            Text(
              'No matching wardrobe picks yet.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            )
          else
            ...picks.map((group) {
              final category = group['category']?.toString() ?? 'other';
              final items = _asMapList(group['items']);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    ...items.map((item) {
                      final name = item['name']?.toString() ?? 'Unknown';
                      final imageUrl = _extractItemImage(item);
                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.spacing8,
                        ),
                        padding: const EdgeInsets.all(AppConstants.spacing8),
                        decoration: BoxDecoration(
                          border: Border.all(color: tokens.cardBorderColor),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radius12,
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radius8,
                              ),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: imageUrl != null
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : Container(
                                        color: tokens.cardColor.withOpacity(
                                          0.4,
                                        ),
                                        child: Icon(
                                          Icons.image,
                                          color: tokens.textMuted,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacing8),
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: tokens.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSuggestedOutfits({
    required BuildContext context,
    required AppUiTokens tokens,
    required List<Map<String, dynamic>> outfits,
  }) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Outfits',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          if (outfits.isEmpty)
            Text(
              'No complete outfit could be assembled.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            )
          else
            ...outfits.map((outfit) {
              final description =
                  outfit['description']?.toString() ?? 'Suggested outfit';
              final matchScore = outfit['match_score'] as num?;
              final itemIds =
                  (outfit['item_ids'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  const <String>[];

              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spacing8),
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  border: Border.all(color: tokens.cardBorderColor),
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: tokens.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (matchScore != null)
                          Text(
                            '${matchScore.round()}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: tokens.brandColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                      ],
                    ),
                    if (itemIds.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacing6),
                      Text(
                        itemIds.join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    RecommendationsController controller,
  ) async {
    final current =
        DateTime.tryParse(controller.astrologyTargetDate.value) ??
        DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.astrologyTargetDate.value = picked
          .toIso8601String()
          .split('T')
          .first;
    }
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  String? _extractItemImage(Map<String, dynamic> item) {
    final images = item['item_images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map<String, dynamic>) {
        return first['thumbnail_url']?.toString() ??
            first['image_url']?.toString();
      }
    }
    return item['image_url']?.toString();
  }

  Color _parseHexColor(String value) {
    final normalized = value.replaceAll('#', '').trim();
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final colorInt = int.tryParse(hex, radix: 16);
    if (colorInt == null) return const Color(0xFFE5E7EB);
    return Color(colorInt);
  }
}
