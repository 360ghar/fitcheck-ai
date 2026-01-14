import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';
import 'widgets/referral_share_card.dart';

/// Dedicated referral sharing page
class ReferralPage extends GetView<SubscriptionController> {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer a Friend'),
        elevation: 0,
      ),
      body: Obx(() {
        final code = controller.referralCode.value;
        final stats = controller.referralStats.value;

        if (code == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Share card
            ReferralShareCard(
              code: code.code,
              shareUrl: code.shareUrl,
              timesUsed: code.timesUsed,
              onCopy: controller.copyReferralLink,
              onShare: controller.shareReferralLink,
            ),
            const SizedBox(height: 24),

            // How it works
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How It Works',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      theme,
                      1,
                      'Share your code',
                      'Send your unique referral link to friends',
                    ),
                    _buildStep(
                      theme,
                      2,
                      'Friend signs up',
                      'They create an account using your link',
                    ),
                    _buildStep(
                      theme,
                      3,
                      'Both get rewarded',
                      'You both receive 1 month of Pro free!',
                    ),
                  ],
                ),
              ),
            ),

            // Stats (if available)
            if (stats != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Referral Stats',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStat(
                              theme,
                              stats.totalReferrals.toString(),
                              'Total Referrals',
                            ),
                          ),
                          Expanded(
                            child: _buildStat(
                              theme,
                              stats.successfulReferrals.toString(),
                              'Successful',
                            ),
                          ),
                          Expanded(
                            child: _buildStat(
                              theme,
                              '${stats.monthsEarned}',
                              'Months Earned',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildStep(ThemeData theme, int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
