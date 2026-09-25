import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_ui.dart';

/// Matches [ReferralCodeNotifier.share]: iPad needs a popover origin.
typedef ReferralShareCallback =
    Future<void> Function({Rect? sharePositionOrigin});

/// The user's referral code with copy and share actions.
class ReferralShareCard extends StatelessWidget {
  const ReferralShareCard({
    super.key,
    required this.code,
    required this.timesUsed,
    required this.onCopy,
    required this.onShare,
  });

  final String code;
  final int timesUsed;
  final VoidCallback onCopy;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Invite a friend', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'You and your friend each get a month of Pro.',
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing16),
          PaperSurface(
            lift: 0,
            grain: false,
            color: tokens.stock.sunk,
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing4,
              AppConstants.spacing8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your code',
                        style: text.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      SelectableText(
                        code,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  tooltip: 'Copy link',
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Builder(
            builder: (buttonContext) => ElevatedButton.icon(
              onPressed: () =>
                  onShare(sharePositionOrigin: _originFrom(buttonContext)),
              icon: const Icon(Icons.ios_share_rounded, size: 20),
              label: const Text('Share invite'),
            ),
          ),
          if (timesUsed > 0) ...[
            const SizedBox(height: AppConstants.spacing12),
            Text(
              timesUsed == 1
                  ? '1 friend has used your code.'
                  : '$timesUsed friends have used your code.',
              style: text.bodySmall?.copyWith(color: tokens.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
