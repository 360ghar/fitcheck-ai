import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/app_ui.dart';
import '../../models/gift_models.dart';

/// Home banner for an incoming gift or a free invitation, on the same torn
/// marigold strip as the referral banner it replaces.
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
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final hasIncoming = priority == GiftDashboardPriority.incoming;
    final greeting = hasIncoming
        ? giftOccasionGreeting(incoming!.occasion, incoming!.occasionGreeting)
        : null;
    final title = hasIncoming
        ? incomingCount > 1
              ? '$incomingCount gifts are waiting for you'
              : 'A gift is waiting for you'
        : 'Send a free ${_term(allowance!.durationMonths)} invitation';
    final remaining = allowance?.remainingCount ?? 0;
    final body = hasIncoming
        ? incomingCount > 1
              ? 'Open your gifts to claim them with your verified email.'
              : '${greeting == null ? '' : '$greeting. '}${incoming!.fromName} '
                    'sent you ${_term(incoming!.durationMonths)} of FitCheck Pro.'
        : '$remaining free ${_term(allowance!.durationMonths)} '
              'invitation${remaining == 1 ? '' : 's'} left.';

    return PaperSurface(
      stock: PaperStockId.marigold,
      color: tokens.marigold.tint,
      deckle: PaperEdge.bottom,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineSmall?.copyWith(fontSize: 22)),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            body,
            style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacing8),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: tokens.marigold.accent,
            ),
            onPressed: onOpen,
            icon: Icon(
              hasIncoming ? Icons.card_giftcard_outlined : Icons.send_outlined,
              size: 18,
            ),
            label: Text(hasIncoming ? 'Open gifts' : 'Send invitation'),
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
