import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
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
      padding: const EdgeInsetsDirectional.only(
        start: AppConstants.spacing16,
        top: AppConstants.spacing12,
        end: AppConstants.spacing4,
        bottom: AppConstants.spacing12,
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
                        ? context.l10n.referralBannerUrgent
                        : context.l10n.referralBannerTitle,
                    style: text.headlineSmall?.copyWith(fontSize: 22),
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  tooltip: context.l10n.referralBannerDismiss,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: onDismiss,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppConstants.spacing12,
            ),
            child: Text(
              context.l10n.referralBannerBody,
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
                  label: Text(context.l10n.referralBannerShare),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: tokens.marigold.accent,
                ),
                onPressed: onCopyLink,
                icon: const Icon(Icons.link_rounded, size: 18),
                label: Text(context.l10n.referralBannerCopy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
