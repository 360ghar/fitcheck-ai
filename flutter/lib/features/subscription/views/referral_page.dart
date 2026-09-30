import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_providers.dart';
import 'widgets/referral_share_card.dart';

/// The referral code, how referrals work, and the user's totals.
class ReferralPage extends ConsumerWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(referralCodeProvider);
    final stats = ref.watch(referralStatsProvider);
    final notifier = ref.read(referralCodeProvider.notifier);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(
      AppConstants.spacing16,
      AppConstants.spacing8,
      AppConstants.spacing16,
      AppConstants.spacing32 + bottom,
    );
    const gap = SizedBox(height: AppConstants.spacing20);

    final Widget body;
    if (!code.hasValue) {
      body = code.hasError
          ? AppErrorState(error: code.error, onRetry: notifier.refresh)
          : ListView(
              padding: padding,
              children: const [
                SizedBox(height: AppConstants.spacing8),
                SkeletonPulse(
                  child: Column(
                    children: [
                      SkeletonBox(
                        height: 230,
                        borderRadius: AppConstants.radius12,
                      ),
                      gap,
                      SkeletonBox(
                        height: 220,
                        borderRadius: AppConstants.radius12,
                      ),
                    ],
                  ),
                ),
              ],
            );
    } else {
      final c = code.requireValue;
      body = RefreshIndicator(
        onRefresh: () => Future.wait([
          notifier.refresh(),
          ref
              .refresh(referralStatsProvider.future)
              .then<void>((_) {}, onError: (Object _) {}),
        ]),
        child: ListView(
          padding: padding,
          children: [
            if (code.hasError)
              AppErrorBanner(error: code.error, onRetry: notifier.refresh),
            const SizedBox(height: AppConstants.spacing8),
            ReferralShareCard(
              code: c.code,
              timesUsed: c.timesUsed,
              onCopy: notifier.copyLink,
              onShare: notifier.share,
            ),
            gap,
            const _HowItWorks(),
            gap,
            switch (stats) {
              AsyncValue(:final value?) => _Stats(stats: value),
              AsyncValue(:final error?) => AppErrorBanner(
                error: error,
                onRetry: () => ref.invalidate(referralStatsProvider),
              ),
              _ => const SkeletonCard(height: 120),
            },
          ],
        ),
      );
    }

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: const Text('Refer a friend')),
        body: AppPageBackground(child: body),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    const steps = [
      ('Share your link', 'Send it to a friend.'),
      ('They sign up', 'Your friend joins from the link.'),
      ('You both get Pro', 'Each of you gets a month of Pro free.'),
    ];
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: text.headlineSmall),
          for (final (i, (title, detail)) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacing16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The figure is the marker: no circle behind it.
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${i + 1}',
                      style: text.displaySmall?.copyWith(
                        color: tokens.stock.accent,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          detail,
                          style: text.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.stats});

  final ReferralStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    Widget figure(int value, String label) => Expanded(
      child: Column(
        children: [
          Text('$value', style: text.displaySmall),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            label,
            style: text.bodySmall?.copyWith(color: tokens.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    return PaperSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your referrals', style: text.headlineSmall),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              figure(stats.totalReferrals, 'Invited'),
              figure(stats.successfulReferrals, 'Joined'),
              figure(stats.monthsEarned, 'Months earned'),
            ],
          ),
        ],
      ),
    );
  }
}
