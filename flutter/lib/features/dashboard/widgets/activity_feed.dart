import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

/// Activity feed section showing recent user activity
class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final tokens = AppUiTokens.of(context);

    return Obx(() {
      final activities = controller.dashboard.value?.recentActivity ?? [];

      return AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Recent Activity',
              subtitle: 'Your latest style moments',
              trailing: TextButton(
                onPressed: () => Get.toNamed(Routes.outfits),
                child: const Text('See all'),
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            if (activities.isEmpty)
              Text(
                'Start adding items or outfits to see activity here.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
              ),
            if (activities.isNotEmpty)
              Column(
                children: activities
                    .map((activity) => _ActivityRow(activity: activity))
                    .toList(),
              ),
          ],
        ),
      );
    });
  }
}

class _ActivityRow extends StatelessWidget {
  final DashboardActivity activity;

  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final icon = _activityIcon(activity.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.brandColor.withOpacity(0.12),
            ),
            child: Icon(icon, size: 18, color: tokens.brandColor),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(activity.timestamp),
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

  IconData _activityIcon(String type) {
    switch (type) {
      case 'outfit_created':
        return Icons.auto_awesome;
      case 'item_created':
      default:
        return Icons.checkroom;
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final local = timestamp.toLocal();
    return '${local.month}/${local.day}';
  }
}
