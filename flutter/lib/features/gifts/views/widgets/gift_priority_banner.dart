import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_ui.dart';
import '../../models/gift_models.dart';

class GiftPriorityBanner extends StatelessWidget {
  const GiftPriorityBanner({
    super.key,
    required this.priority,
    this.incoming,
    this.incomingCount = 0,
    this.allowance,
    required this.onOpen,
  });

  final GiftDashboardPriority priority;
  final GiftVoucher? incoming;
  final int incomingCount;
  final GiftAllowance? allowance;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);
    final hasIncoming = priority == GiftDashboardPriority.incoming;
    final incomingGreeting = hasIncoming
        ? giftOccasionGreeting(incoming!.occasion, incoming!.occasionGreeting)
        : null;
    final title = hasIncoming
        ? incomingCount > 1
              ? '$incomingCount gifts are waiting for you'
              : 'A gift is waiting for you'
        : 'Send a free ${_term(allowance!.durationMonths)} invitation';
    final body = hasIncoming
        ? incomingCount > 1
              ? 'Open your gift inbox to review and claim them with your verified email.'
              : '${incomingGreeting == null ? '' : '$incomingGreeting · '}${incoming!.fromName} sent you ${_term(incoming!.durationMonths)} of FitCheck Pro.'
        : '${allowance!.remainingCount} free ${_term(allowance!.durationMonths)} invitation${allowance!.remainingCount == 1 ? '' : 's'} available.';

    return AppGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing8),
            decoration: BoxDecoration(
              color: tokens.brandColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radius12),
            ),
            child: Icon(
              hasIncoming ? Icons.card_giftcard : Icons.auto_awesome,
              color: tokens.brandColor,
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: AppConstants.spacing12),
                FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(hasIncoming ? 'Open gifts' : 'Send invitation'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _term(int months) {
    if (months == 1) return '1 month';
    if (months == 12) return '1 year';
    return '$months months';
  }
}
