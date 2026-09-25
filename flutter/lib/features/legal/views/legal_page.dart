import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../settings/widgets/paper_group.dart';

/// Policies, support and abuse contact. Reachable without signing in so App
/// Review can find the abuse contact (Guideline 1.2).
class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  // Aliases of the single source of truth in AppConstants.
  static const String privacyPolicyUrl = AppConstants.privacyPolicyUrl;
  static const String termsOfServiceUrl = AppConstants.termsOfServiceUrl;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query: 'subject=${Uri.encodeComponent('Report a problem or abuse')}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    Widget external(IconData icon) =>
        Icon(icon, color: tokens.textMuted, size: 20);

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: const Text('Privacy and terms')),
        body: AppPageBackground(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacing4,
                  0,
                  AppConstants.spacing4,
                  AppConstants.spacing16,
                ),
                child: Text(
                  'How we protect your data, and the terms for using '
                  'FitCheck AI.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ),
              PaperGroup(
                title: 'Policies',
                children: [
                  PaperNavRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    subtitle: 'What we collect and why',
                    trailing: external(Icons.open_in_new_rounded),
                    onTap: () => _openUrl(privacyPolicyUrl),
                  ),
                  PaperNavRow(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    subtitle: 'The rules for using the app',
                    trailing: external(Icons.open_in_new_rounded),
                    onTap: () => _openUrl(termsOfServiceUrl),
                  ),
                  PaperNavRow(
                    icon: Icons.code_rounded,
                    title: 'Open-source licences',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'FitCheck AI',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing24),
              PaperGroup(
                title: 'Support',
                children: [
                  PaperNavRow(
                    icon: Icons.support_agent_outlined,
                    title: 'Support',
                    subtitle: 'Help, contact and privacy requests',
                    trailing: external(Icons.open_in_new_rounded),
                    onTap: () => _openUrl(AppConstants.supportUrl),
                  ),
                  PaperNavRow(
                    icon: Icons.flag_outlined,
                    title: 'Report a problem or abuse',
                    subtitle:
                        'Email ${AppConstants.supportEmail}. We review '
                        'reports within 24 hours.',
                    trailing: external(Icons.mail_outline_rounded),
                    onTap: _openSupportEmail,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
