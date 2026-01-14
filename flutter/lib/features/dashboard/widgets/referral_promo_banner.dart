import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Promotional banner for referral program, displayed on dashboard
class ReferralPromoBanner extends StatelessWidget {
  final bool isUrgent;
  final VoidCallback? onDismiss;
  final VoidCallback onCopyLink;
  final VoidCallback onShare;

  const ReferralPromoBanner({
    super.key,
    this.isUrgent = false,
    this.onDismiss,
    required this.onCopyLink,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isUrgent
              ? const [Color(0xFFF59E0B), Color(0xFF6366F1), Color(0xFF9333EA)]
              : const [Color(0xFF6366F1), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withAlpha(13),
            ),
          ),
          Padding(
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
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
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
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUrgent
                                ? 'Share your link - you both get rewarded.'
                                : 'Both you and your friend get 1 month of Pro.',
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dismiss button (hidden when urgent)
                    if (!isUrgent && onDismiss != null)
                      GestureDetector(
                        onTap: onDismiss,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            color: Colors.white.withAlpha(179),
                            size: 20,
                          ),
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
                      child: _ActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: onShare,
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withAlpha(128)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
