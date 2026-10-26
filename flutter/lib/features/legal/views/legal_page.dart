import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
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

  Future<void> _openSupportEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query:
          'subject=${Uri.encodeComponent(context.l10n.legalReportAbuse)}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final l10n = context.l10n;
    Widget external(IconData icon) =>
        Icon(icon, color: tokens.textMuted, size: 20);

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsPrivacyTerms)),
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
                  l10n.legalIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ),
              PaperGroup(
                title: l10n.legalPolicies,
                children: [
                  PaperNavRow(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.paywallPrivacy,
                    subtitle: l10n.legalPrivacySubtitle,
                    trailing: external(Icons.open_in_new_rounded),
                    onTap: () => _openUrl(privacyPolicyUrl),
                  ),
                  PaperNavRow(
                    icon: Icons.description_outlined,
                    title: l10n.legalTermsTitle,
                    subtitle: l10n.legalTermsSubtitle,
                    trailing: external(Icons.open_in_new_rounded),
                    onTap: () => _openUrl(termsOfServiceUrl),
                  ),
                  PaperNavRow(
                    icon: Icons.code_rounded,
                    title: l10n.legalLicences,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: l10n.appName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing24),
              PaperGroup(
                title: l10n.profileSupport,
                children: [
                  PaperNavRow(
                    icon: Icons.support_agent_outlined,
                    title: l10n.profileSupport,
                    subtitle: l10n.legalSupportSubtitle,
                    trailing: external(Icons.open_in_new_rounded),
                    onTap: () => _openUrl(AppConstants.supportUrl),
                  ),
                  PaperNavRow(
                    icon: Icons.flag_outlined,
                    title: l10n.legalReportAbuse,
                    subtitle:
                        context.l10n.legalSupportEmailBody(AppConstants.supportEmail),
                    trailing: external(Icons.mail_outline_rounded),
                    onTap: () => _openSupportEmail(context),
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
