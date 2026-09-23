import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../subscription/views/widgets/referral_share_card.dart';

/// Referral invitation on a torn strip of marigold paper.
class ReferralPromoBanner extends StatelessWidget {
  const ReferralPromoBanner({
    super.key,
    this.isUrgent = false,
    this.onDismiss,
    required this.onCopyLink,
    required this.onShare,
  });

  /// The user is near a plan limit: the copy leads with that.
  final bool isUrgent;
  final VoidCallback? onDismiss;
  final VoidCallback onCopyLink;
  final ReferralShareCallback onShare;

  Rect? _originFrom(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return PaperSurface(
      stock: PaperStockId.marigold,
      color: tokens.marigold.tint,
      deckle: PaperEdge.bottom,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing4,
        AppConstants.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppConstants.spacing4),
                  child: Text(
                    isUrgent
                        ? 'Running low? Invite a friend.'
                        : 'Give a month, get a month.',
                    style: text.headlineSmall?.copyWith(fontSize: 22),
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  tooltip: 'Dismiss for a week',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: onDismiss,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacing12),
            child: Text(
              'You and your friend each get a month of Pro.',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Row(
            children: [
              Builder(
                builder: (buttonContext) => TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: tokens.marigold.accent,
                  ),
                  onPressed: () =>
                      onShare(sharePositionOrigin: _originFrom(buttonContext)),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Share invite'),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: tokens.marigold.accent,
                ),
                onPressed: onCopyLink,
                icon: const Icon(Icons.link_rounded, size: 18),
                label: const Text('Copy link'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
