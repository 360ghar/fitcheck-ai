import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Legal page with Privacy Policy and Terms of Service links
class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  static const String privacyPolicyUrl = 'https://fitcheckaiapp.com/privacy';
  static const String termsOfServiceUrl = 'https://fitcheckaiapp.com/terms';

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal'),
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppGlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: tokens.brandColor,
                          ),
                          const SizedBox(width: AppConstants.spacing12),
                          Text(
                            'Legal Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'Review our policies to understand how we protect your privacy and the terms governing your use of FitCheck AI.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Privacy Policy
                AppGlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: tokens.brandColor,
                    ),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('How we collect and use your data'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(privacyPolicyUrl),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing12),

                // Terms of Service
                AppGlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: tokens.brandColor,
                    ),
                    title: const Text('Terms of Service'),
                    subtitle: const Text('Rules for using our service'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(termsOfServiceUrl),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Open Source Licenses
                AppGlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.code,
                      color: tokens.textMuted,
                    ),
                    title: const Text('Open Source Licenses'),
                    subtitle: const Text('Third-party software licenses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'FitCheck AI',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
