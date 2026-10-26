import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/widgets/app_ui.dart';
import '../../settings/widgets/paper_group.dart';

List<(String, String)> _faqs(AppLocalizations l10n) => [
  (l10n.profileFaqAddPiecesTitle, l10n.profileFaqAddPiecesBody),
  (l10n.profileFaqMatchingTitle, l10n.profileFaqMatchingBody),
  (l10n.profileFaqTryOnTitle, l10n.profileFaqTryOnBody),
  (l10n.profileFaqRewardsTitle, l10n.profileFaqRewardsBody),
  (l10n.profileFaqPrivacyTitle, l10n.profileFaqPrivacyBody),
];

/// Common questions and ways to reach us.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Future<void> _openDocs() async {
    final url = Uri.parse('https://fitcheckaiapp.com/docs');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;

    return PaperStockScope(
      stock: PaperStockId.stone,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.profileHelp)),
        body: AppPageBackground(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing32 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              PaperSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileHelpContactTitle,
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      context.l10n.profileHelpContactBody,
                      style: text.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    ElevatedButton(
                      onPressed: () => context.push(Routes.feedback),
                      child: Text(context.l10n.profileHelpContactAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              PaperGroup(
                title: context.l10n.profileHelpFaqTitle,
                children: [
                  for (final (question, answer) in _faqs(context.l10n))
                    ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(question, style: text.bodyLarge),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        AppConstants.spacing16,
                        0,
                        AppConstants.spacing16,
                        AppConstants.spacing16,
                      ),
                      expandedAlignment: AlignmentDirectional.centerStart,
                      children: [
                        Text(
                          answer,
                          style: text.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing24),
              PaperGroup(
                title: context.l10n.profileHelpMoreTitle,
                children: [
                  PaperNavRow(
                    icon: Icons.menu_book_outlined,
                    title: context.l10n.profileHelpGuides,
                    subtitle: context.l10n.profileHelpGuidesBody,
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      color: tokens.textMuted,
                      size: 20,
                    ),
                    onTap: _openDocs,
                  ),
                  PaperNavRow(
                    icon: Icons.shield_outlined,
                    title: context.l10n.settingsPrivacyTerms,
                    onTap: () => context.push(Routes.legal),
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
