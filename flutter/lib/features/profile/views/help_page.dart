import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Help and support page
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick help
                AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: tokens.brandColor,
                          ),
                          const SizedBox(width: AppConstants.spacing12),
                          Text(
                            'Need Help?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'Our support team is here to help you make the most of FitCheck AI.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      ElevatedButton.icon(
                        onPressed: () => _contactSupport(),
                        icon: const Icon(Icons.email),
                        label: const Text('Contact Support'),
                      ),
                    ],
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
                  'How do I add items to my wardrobe?',
                  'Tap the Add button in the Wardrobe tab. You can take a photo, choose from gallery, or enter details manually. Our AI will automatically detect items from your photos.',
                  tokens,
                ),

                _buildFaqItem(
                  'How does outfit matching work?',
                  'Go to Recommendations and select items you own. We\'ll suggest matching items and complete outfits based on your wardrobe.',
                  tokens,
                ),

                _buildFaqItem(
                  'Can I use my own photos for try-on?',
                  'Yes! Upload a full-body photo as your avatar, then upload clothing items to see how they look on you.',
                  tokens,
                ),

                _buildFaqItem(
                  'How do I earn achievements?',
                  'Use the app regularly! Log outfits, get recommendations, and engage with features to unlock achievements and build your streak.',
                  tokens,
                ),

                _buildFaqItem(
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email Support'),
                        subtitle: const Text('support@fitcheck.ai'),
                        onTap: () => _contactSupport(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.chat),
                        title: const Text('Live Chat'),
                        subtitle: const Text('Available 9am-5pm EST'),
                        onTap: () => _openChat(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.book),
                        title: const Text('Documentation'),
                        subtitle: const Text('View full documentation'),
                        onTap: () => _openDocs(),
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

  Widget _buildFaqItem(String question, String answer, AppUiTokens tokens) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      title: Text(
        question,
        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.spacing16, right: AppConstants.spacing16, bottom: AppConstants.spacing12),
          child: Text(
            answer,
            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: tokens.textMuted,
                ),
          ),
        ),
      ],
    );
  }

  void _contactSupport() {
    // Open email or support form
    Get.snackbar(
      'Contact',
      'Opening support form...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openChat() {
    Get.snackbar(
      'Chat',
      'Live chat opening soon...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openDocs() {
    // Open documentation URL
    Get.snackbar(
      'Docs',
      'Opening documentation...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
