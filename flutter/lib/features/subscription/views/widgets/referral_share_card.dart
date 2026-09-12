import 'package:flutter/material.dart';
import '../../../../core/widgets/app_ui.dart';

/// Callback matching [SubscriptionController.shareReferralLink] so iPad gets a popover origin.
typedef ReferralShareCallback =
    Future<void> Function({Rect? sharePositionOrigin});

/// Card for sharing referral code
class ReferralShareCard extends StatelessWidget {
  final String code;
  final String shareUrl;
  final int timesUsed;
  final VoidCallback onCopy;
  final ReferralShareCallback onShare;

  const ReferralShareCard({
    super.key,
    required this.code,
    required this.shareUrl,
    required this.timesUsed,
    required this.onCopy,
    required this.onShare,
  });

  Rect? _originFrom(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppCoreColors.editorialRose,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: AppCoreColors.editorialInk,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Refer a Friend',
                          style: TextStyle(
                            color: AppCoreColors.editorialInk,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Both get 1 month of Pro free!',
                          style: TextStyle(
                            color: AppCoreColors.editorialInk,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Code',
                            style: TextStyle(
                              color: AppCoreColors.editorialInk,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            code,
                            style: const TextStyle(
                              color: AppCoreColors.editorialInk,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onCopy,
                      icon: const Icon(
                        Icons.copy,
                        color: AppCoreColors.editorialInk,
                      ),
                      tooltip: 'Copy referral link',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.link),
                      label: const Text('Copy Link'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppCoreColors.editorialInk,
                        side: const BorderSide(
                          color: AppCoreColors.editorialInk,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (buttonContext) {
                        return ElevatedButton.icon(
                          onPressed: () => onShare(
                            sharePositionOrigin: _originFrom(buttonContext),
                          ),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppCoreColors.editorialInk,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (timesUsed > 0) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '$timesUsed friend${timesUsed == 1 ? '' : 's'} have used your code!',
                    style: TextStyle(
                      color: AppCoreColors.editorialInk,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
