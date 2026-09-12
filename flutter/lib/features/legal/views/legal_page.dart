import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';

/// Legal page with Privacy Policy and Terms of Service links
class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  // Aliases of the single source of truth in AppConstants — three copies of
  // these URLs used to drift independently.
  static const String privacyPolicyUrl = AppConstants.privacyPolicyUrl;
  static const String termsOfServiceUrl = AppConstants.termsOfServiceUrl;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Legal'), elevation: 0),
      body: AppPageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppEditorialHeader(
                  title: 'Your privacy',
                  subtitle:
                      'Review our policies, account terms, and support options.',
                  color: AppCoreColors.editorialSlate,
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
                    onTap: () => _openUrl(context, privacyPolicyUrl),
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
                    onTap: () => _openUrl(context, termsOfServiceUrl),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Support hub (ASC Support URL) + abuse contact.
                AppGlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.support_agent_outlined,
                      color: tokens.brandColor,
                    ),
                    title: const Text('Support'),
                    subtitle: const Text('Help, contact, and privacy requests'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(context, AppConstants.supportUrl),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing12),

                // Report a Problem / Abuse — visible without login so App Store
                // reviewers can find the abuse/support contact (Guideline 1.2).
                AppGlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.flag_outlined,
                      color: tokens.brandColor,
                    ),
                    title: const Text('Report a Problem / Abuse'),
                    subtitle: const Text(
                      'Email ${AppConstants.supportEmail} to report '
                      'objectionable content or abuse. We aim to review '
                      'within 24 hours.',
                    ),
                    trailing: const Icon(Icons.email_outlined),
                    onTap: () => _openSupportEmail(context),
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Open Source Licenses
                AppGlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(Icons.code, color: tokens.textMuted),
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

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      if (await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open this link. Please try again.'),
      ),
    );
  }

  Future<void> _openSupportEmail(BuildContext context) => _openUrl(
    context,
    Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query: 'subject=${Uri.encodeComponent('Report a Problem / Abuse')}',
    ).toString(),
  );
}
