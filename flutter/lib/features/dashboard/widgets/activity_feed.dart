import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/repositories/item_repository.dart';
import '../models/dashboard_models.dart';

/// Latest additions to the closet and outfits.
class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key, required this.activities});

  final List<DashboardActivity> activities;

  static final ItemRepository _itemRepository = ItemRepository();

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recently', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing8),
          if (activities.isEmpty)
            Text(
              'New pieces and outfits show up here.',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            )
          else
            for (final activity in activities.take(6))
              _ActivityRow(activity: activity),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final DashboardActivity activity;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final icon = activity.type == 'outfit_created'
        ? Icons.style_outlined
        : Icons.checkroom_outlined;
    final image = (activity.imageUrl?.isNotEmpty ?? false)
        ? activity.imageUrl
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radius8),
            child: SizedBox.square(
              dimension: 44,
              child: ColoredBox(
                color: tokens.stock.sunk,
                child: image == null
                    ? Icon(icon, size: 20, color: tokens.textSecondary)
                    : AppImage(
                        imageUrl: (activity.thumbnailUrl?.isNotEmpty ?? false)
                            ? activity.thumbnailUrl
                            : image,
                        fallbackUrl: image,
                        // Item cutouts are cropped tight, so cover would cut
                        // their edges; outfit looks are photos.
                        fit: activity.type == 'outfit_created'
                            ? BoxFit.cover
                            : BoxFit.contain,
                        width: 44,
                        height: 44,
                        memCacheWidth: 132,
                        enableZoom: false,
                        errorIcon: icon,
                        storagePath: activity.storagePath,
                        remintUrl: ActivityFeed._itemRepository.remintImageUrl,
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              activity.description,
              style: text.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (activity.timestamp case final at?)
            Padding(
              padding: const EdgeInsets.only(left: AppConstants.spacing8),
              child: Text(
                AppDateUtils.formatRelativeTime(at.toLocal()),
                style: text.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
