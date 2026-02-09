import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../domain/enums/category.dart';
import '../../../domain/enums/style.dart';
import '../controllers/recommendations_controller.dart';

/// Shopping Tab - Get shopping suggestions for wardrobe gaps
class ShoppingTab extends StatelessWidget {
  const ShoppingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final RecommendationsController controller = Get.find<RecommendationsController>();

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            children: [
              // Category and Style row
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.shoppingCategory.value == 'all'
                              ? null
                              : controller.shoppingCategory.value,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radius12),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                            ...Category.values.map((cat) {
                              return DropdownMenuItem(
                                value: cat.name,
                                child: Text(cat.displayName),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            if (value != null) controller.shoppingCategory.value = value;
                          },
                        )),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.shoppingStyle.value == 'all'
                              ? null
                              : controller.shoppingStyle.value,
                          decoration: InputDecoration(
                            labelText: 'Style',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radius12),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text('All Styles')),
                            ...Style.values.map((style) {
                              return DropdownMenuItem(
                                value: style.name,
                                child: Text(style.displayName),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            if (value != null) controller.shoppingStyle.value = value;
                          },
                        )),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacing12),

              // Budget slider
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Max Budget',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '\$${controller.shoppingBudget.value.toInt()}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: tokens.brandColor,
                                ),
                          ),
                        ],
                      ),
                      Slider(
                        value: controller.shoppingBudget.value,
                        min: 20,
                        max: 500,
                        divisions: 24,
                        label: '\$${controller.shoppingBudget.value.toInt()}',
                        onChanged: (value) => controller.shoppingBudget.value = value,
                      ),
                    ],
                  )),

              const SizedBox(height: AppConstants.spacing12),

              // Search button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.isLoadingShopping.value
                          ? null
                          : () => controller.fetchShoppingRecommendations(),
                      icon: controller.isLoadingShopping.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        controller.isLoadingShopping.value ? 'Searching...' : 'Get Recommendations',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                    )),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacing16),

        // Results
        Expanded(
          child: Obx(() {
            if (controller.isLoadingShopping.value) {
              return Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: ShimmerGridLoaderBox(
                  crossAxisCount: 2,
                  itemCount: 6,
                  childAspectRatio: 0.75,
                ),
              );
            }

            if (controller.shoppingError.value.isNotEmpty) {
              return Center(
                child: AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      Text(
                        controller.shoppingError.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      TextButton(
                        onPressed: controller.fetchShoppingRecommendations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.shoppingRecommendations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      'Set your filters and search',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tokens.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'We\'ll suggest items to fill wardrobe gaps',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.spacing12,
                crossAxisSpacing: AppConstants.spacing12,
                childAspectRatio: 0.75,
              ),
              itemCount: controller.shoppingRecommendations.length,
              itemBuilder: (context, index) {
                final item = controller.shoppingRecommendations[index];
                return _buildShoppingCard(context, item, tokens);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildShoppingCard(
    BuildContext context,
    Map<String, dynamic> item,
    AppUiTokens tokens,
  ) {
    final category = item['category']?.toString() ?? 'Unknown';
    final description = item['description']?.toString();
    final priorityLabel = item['priority']?.toString() ?? '';
    final priorityScore = _priorityScore(priorityLabel);
    final wouldComplete = item['would_complete'] as num?;
    final estimatedCpw = item['estimated_cpw'] as num?;

    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority badge
          if (priorityScore > 0)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing8,
                  vertical: AppConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priorityScore),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                ),
                child: Text(
                  _getPriorityLabel(priorityScore),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Image placeholder
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius8),
              child: Container(
                color: tokens.cardColor.withOpacity(0.3),
                child: Icon(
                  Icons.shopping_bag,
                  color: tokens.textMuted,
                  size: 40,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacing8),

          // Name
          Text(
            _formatCategory(category),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (description != null) ...[
            const SizedBox(height: AppConstants.spacing4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (wouldComplete != null || estimatedCpw != null) ...[
            const SizedBox(height: AppConstants.spacing4),
            Text(
              _buildFootnote(wouldComplete, estimatedCpw),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.brandColor,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  int _priorityScore(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 8;
      case 'medium':
        return 5;
      case 'low':
        return 2;
      default:
        return 0;
    }
  }

  String _formatCategory(String category) {
    return category
        .split('_')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _buildFootnote(num? wouldComplete, num? estimatedCpw) {
    final parts = <String>[];
    if (wouldComplete != null) {
      parts.add('+$wouldComplete outfits');
    }
    if (estimatedCpw != null) {
      parts.add('\$${estimatedCpw.toStringAsFixed(2)} CPW');
    }
    return parts.join(' | ');
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 8) return Colors.red;
    if (priority >= 5) return Colors.orange;
    return Colors.green;
  }

  String _getPriorityLabel(int priority) {
    if (priority >= 8) return 'HIGH PRIORITY';
    if (priority >= 5) return 'MEDIUM';
    return 'LOW PRIORITY';
  }
}
