import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_core_colors.dart';
import '../../subscription/views/widgets/referral_share_card.dart';

/// Promotional banner for referral program, displayed on dashboard
class ReferralPromoBanner extends StatelessWidget {
  final bool isUrgent;
  final VoidCallback? onDismiss;
  final VoidCallback onCopyLink;
  final ReferralShareCallback onShare;

  const ReferralPromoBanner({
    super.key,
    this.isUrgent = false,
    this.onDismiss,
    required this.onCopyLink,
    required this.onShare,
  });

  Rect? _originFrom(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isUrgent
            ? AppCoreColors.editorialLinen
            : AppCoreColors.editorialSage,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppCoreColors.editorialInk.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: AppCoreColors.editorialInk,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUrgent
                            ? 'Running low? Refer a friend!'
                            : 'Refer a friend, get 1 month Pro free!',
                        style: const TextStyle(
                          color: AppCoreColors.editorialInk,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUrgent
                            ? 'Share your link - you both get rewarded.'
                            : 'Both you and your friend get 1 month of Pro.',
                        style: const TextStyle(
                          color: AppCoreColors.editorialInk,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Dismiss remains hidden when urgent.
                if (!isUrgent && onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    tooltip: 'Dismiss',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      color: AppCoreColors.editorialInk,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.link,
                    label: 'Copy Link',
                    onTap: onCopyLink,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing8),
                Expanded(
                  child: Builder(
                    builder: (buttonContext) {
                      return _ActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: () => onShare(
                          sharePositionOrigin: _originFrom(buttonContext),
                        ),
                        isPrimary: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppCoreColors.editorialInk,
          foregroundColor: AppCoreColors.backgroundLight,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppCoreColors.editorialInk,
        side: const BorderSide(color: AppCoreColors.editorialInk),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
