import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Help and support page
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), elevation: 0),
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppEditorialHeader(
                  title: 'Here to help',
                  subtitle:
                      'Get help with your wardrobe, account, or a problem in the app.',
                  color: AppCoreColors.editorialSlate,
                  trailing: FilledButton.icon(
                    onPressed: _contactSupport,
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact support'),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // FAQ section
                Text(
                  'Frequently Asked Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),

                _buildFaqItem(
                  context,
                  'How do I add items to my wardrobe?',
                  'Tap the Add button in the Closet tab. You can take a photo, choose from gallery, or enter details manually. Our AI will automatically detect items from your photos.',
                  tokens,
                ),

                _buildFaqItem(
                  context,
                  'How does outfit matching work?',
                  'Go to Recommendations and select items you own. We\'ll suggest matching items and complete outfits based on your wardrobe.',
                  tokens,
                ),

                _buildFaqItem(
                  context,
                  'Can I use my own photos for try-on?',
                  'Yes! Upload a full-body photo as your avatar, then upload clothing items to see how they look on you.',
                  tokens,
                ),

                _buildFaqItem(
                  context,
                  'How do I earn achievements?',
                  'Use the app regularly! Log outfits, get recommendations, and engage with features to unlock achievements and build your streak.',
                  tokens,
                ),

                _buildFaqItem(
                  context,
                  'Is my data private?',
                  'Yes! Your wardrobe and outfits are private by default. You can choose to share specific outfits with public links.',
                  tokens,
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Contact section
                AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Still have questions?',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email Support'),
                        subtitle: const Text(AppConstants.supportEmail),
                        onTap: () => _openLink(
                          context,
                          Uri(
                            scheme: 'mailto',
                            path: AppConstants.supportEmail,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.chat),
                        title: const Text('Send a request'),
                        subtitle: const Text(
                          'Report a problem or send feedback',
                        ),
                        onTap: _contactSupport,
                      ),
                      ListTile(
                        leading: const Icon(Icons.book),
                        title: const Text('Help center'),
                        subtitle: const Text('Guides and contact options'),
                        onTap: () => _openLink(
                          context,
                          Uri.parse(AppConstants.supportUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    String question,
    String answer,
    AppUiTokens tokens,
  ) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      title: Text(
        question,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spacing16,
            right: AppConstants.spacing16,
            bottom: AppConstants.spacing12,
          ),
          child: Text(
            answer,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ),
      ],
    );
  }

  void _contactSupport() {
    Get.toNamed(Routes.feedback);
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open this link. Use Contact support to send a request.',
        ),
      ),
    );
  }
}
