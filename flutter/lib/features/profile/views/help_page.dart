import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../settings/widgets/paper_group.dart';

const _faqs = [
  (
    'How do I add pieces to my closet?',
    'Tap Add item on the Closet tab. Take a photo or pick one from your '
        'gallery; we find each piece and tag it for you.',
  ),
  (
    'How does outfit matching work?',
    'Open For you and pick pieces you own. We suggest what goes with them '
        'and build full outfits from your closet.',
  ),
  (
    'Can I use my own photos for try-on?',
    'Yes. Add a full-length photo of yourself, then choose pieces to see '
        'them on you.',
  ),
  (
    'How do I earn rewards?',
    'Plan and log outfits often. Streaks and achievements build as you go.',
  ),
  (
    'Is my closet private?',
    'Yes. Your closet and outfits are private unless you share a link to '
        'one outfit.',
  ),
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
        appBar: AppBar(title: const Text('Help')),
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
                    Text('Ask us anything', style: text.headlineSmall),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'Send a message and we reply by email, usually within '
                      'a day.',
                      style: text.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    ElevatedButton(
                      onPressed: () => context.push(Routes.feedback),
                      child: const Text('Contact support'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              PaperGroup(
                title: 'Common questions',
                children: [
                  for (final (question, answer) in _faqs)
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
                      expandedAlignment: Alignment.centerLeft,
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
                title: 'More help',
                children: [
                  PaperNavRow(
                    icon: Icons.menu_book_outlined,
                    title: 'Guides',
                    subtitle: 'How each feature works',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      color: tokens.textMuted,
                      size: 20,
                    ),
                    onTap: _openDocs,
                  ),
                  PaperNavRow(
                    icon: Icons.shield_outlined,
                    title: 'Privacy and terms',
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
