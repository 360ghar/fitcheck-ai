import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/subscription_controller.dart';
import '../models/subscription_model.dart';
import 'widgets/plan_card.dart';
import 'widgets/usage_progress.dart';
import 'widgets/referral_share_card.dart';

/// Subscription management page
class SubscriptionPage extends GetView<SubscriptionController> {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.subscription.value == null) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: const [
                ShimmerCard(height: 140),
                SizedBox(height: AppConstants.spacing24),
                ShimmerCard(height: 180),
                SizedBox(height: AppConstants.spacing24),
                ShimmerCard(height: 120),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchSubscription();
            await controller.fetchReferralCode();
            await controller.fetchPlans();
            await controller.fetchReferralStats();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current plan card
              _buildCurrentPlanCard(context, theme),
              const SizedBox(height: 24),

              // Usage section
              _buildUsageSection(context, theme),
              const SizedBox(height: 24),

              // Upgrade section (for free users)
              if (!controller.isPro) ...[
                _buildUpgradeSection(context, theme),
                const SizedBox(height: 24),
              ],

              // Referral section
              _buildReferralSection(context, theme),
              const SizedBox(height: 24),

              // Cancel section (for pro users)
              if (controller.isPro && !controller.isCancelled)
                _buildCancelSection(context, theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, ThemeData theme) {
    final sub = controller.subscription.value;

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                controller.isPro ? Icons.star : Icons.person,
                color: controller.isPro ? Colors.amber : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    Text(
                      controller.planName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isPro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          if (controller.isCancelled && sub?.currentPeriodEnd != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Subscription ends on ${_formatDate(sub!.currentPeriodEnd!)}',
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (sub?.referralCreditMonths != null && sub!.referralCreditMonths > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${sub.referralCreditMonths} month${sub.referralCreditMonths > 1 ? 's' : ''} of referral credit',
                    style: TextStyle(color: Colors.green.shade800, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageSection(BuildContext context, ThemeData theme) {
    final usage = controller.usage.value;
    if (usage == null) return const SizedBox.shrink();

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Usage',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          UsageProgress(
            label: 'Item Extractions',
            current: usage.monthlyExtractions,
            max: usage.monthlyExtractionsLimit,
            icon: Icons.camera_alt,
          ),
          const SizedBox(height: 16),
          UsageProgress(
            label: 'Outfit Visualizations',
            current: usage.monthlyGenerations,
            max: usage.monthlyGenerationsLimit,
            icon: Icons.auto_awesome,
          ),
          if (controller.isNearLimit && !controller.isPro) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'re approaching your usage limit. Upgrade for more!',
                      style: TextStyle(color: Colors.amber.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpgradeSection(BuildContext context, ThemeData theme) {
    // Get pro plan details from controller (backend returns single "pro" plan with both prices)
    final proPlan = controller.plans.firstWhereOrNull((p) => p.id == 'pro');

    final monthlyPrice = proPlan?.priceMonthly ?? 20.0;
    final yearlyPrice = proPlan?.priceYearly ?? 200.0;
    final savings = (monthlyPrice * 12 - yearlyPrice).toStringAsFixed(0);

    // Get limits from pro plan
    final extractionsLimit = proPlan?.monthlyExtractions ?? 200;
    final generationsLimit = proPlan?.monthlyGenerations ?? 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upgrade to Pro',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PlanCard(
                name: 'Monthly',
                price: '\$${monthlyPrice.toStringAsFixed(0)}',
                period: '/month',
                onTap: () => controller.startCheckout('pro_monthly'),
                isLoading: controller.isCheckingOut.value,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PlanCard(
                name: 'Yearly',
                price: '\$${yearlyPrice.toStringAsFixed(0)}',
                period: '/year',
                badge: 'Save \$$savings',
                onTap: () => controller.startCheckout('pro_yearly'),
                isLoading: controller.isCheckingOut.value,
                isHighlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Pro includes: $extractionsLimit extractions, $generationsLimit visualizations, virtual try-on, priority support',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection(BuildContext context, ThemeData theme) {
    final code = controller.referralCode.value;
    if (code == null) return const SizedBox.shrink();

    return ReferralShareCard(
      code: code.code,
      shareUrl: code.shareUrl,
      timesUsed: code.timesUsed,
      onCopy: controller.copyReferralLink,
      onShare: controller.shareReferralLink,
    );
  }

  Widget _buildCancelSection(BuildContext context, ThemeData theme) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancel Subscription',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll retain access until the end of your billing period.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _showCancelDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade300),
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel? You\'ll retain access until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.cancelSubscription();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
