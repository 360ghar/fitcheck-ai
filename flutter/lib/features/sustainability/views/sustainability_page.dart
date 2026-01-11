import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Sustainability goals tracking
class SustainabilityPage extends StatelessWidget {
  const SustainabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainability'),
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Overview card
                AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sustainable Fashion',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.spacing4),
                            Text(
                              'Track your wardrobe sustainability',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: tokens.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Worn Items',
                        '45/120',
                        Icons.checkroom,
                        Colors.green,
                        tokens,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Unworn',
                        '75',
                        Icons.access_time,
                        Colors.orange,
                        tokens,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Goals section
                Text(
                  'Sustainability Goals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacing12),

                _buildGoalCard(
                  context,
                  title: 'Wear Everything',
                  description: 'Wear each item at least once this month',
                  progress: 0.45,
                  icon: Icons.checkroom,
                  tokens: tokens,
                ),

                const SizedBox(height: AppConstants.spacing12),

                _buildGoalCard(
                  context,
                  title: 'No New Purchases',
                  description: 'Go 30 days without buying new clothes',
                  progress: 0.7,
                  icon: Icons.block,
                  tokens: tokens,
                ),

                const SizedBox(height: AppConstants.spacing12),

                _buildGoalCard(
                  context,
                  title: 'Second Hand First',
                  description: '50% of items should be second hand',
                  progress: 0.3,
                  icon: Icons.recycling,
                  tokens: tokens,
                ),

                const SizedBox(height: AppConstants.spacing32),

                // Tips section
                AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: AppConstants.spacing12),
                          Text(
                            'Sustainability Tips',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      _buildTip(
                        context,
                        'Rotate your wardrobe',
                        'Try to wear different items each week to maximize use.',
                        tokens,
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      _buildTip(
                        context,
                        'Care for your clothes',
                        'Follow care instructions to extend garment life.',
                        tokens,
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      _buildTip(
                        context,
                        'Repair and reuse',
                        'Consider repairing instead of replacing damaged items.',
                        tokens,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    AppUiTokens tokens,
  ) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required String title,
    required String description,
    required double progress,
    required IconData icon,
    required AppUiTokens tokens,
  }) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade400.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.green.shade400, size: 20),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: tokens.cardColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String title, String description, AppUiTokens tokens) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: tokens.brandColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
