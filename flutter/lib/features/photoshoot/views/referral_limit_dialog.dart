import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/photoshoot_provider.dart';

/// Starts a generation and offers the referral dialog when today's limit
/// is used up.
Future<void> startPhotoshoot(BuildContext context, WidgetRef ref) async {
  final result = await ref.read(photoshootProvider.notifier).generate();
  if (result == PhotoshootStart.limitReached && context.mounted) {
    await showReferralLimitDialog(context);
  }
}

/// Shown when today's photoshoot images are used up.
Future<void> showReferralLimitDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => PaperStockScope(
    stock: PaperStockId.stone,
    child: ReferralLimitDialog(
      onReferFriend: () {
        Navigator.pop(context);
        context.push(Routes.referral);
      },
      // The upgrade path shows only while the paywall is on.
      onUpgrade: EnvConfig.paywallEnabled
          ? () {
              Navigator.pop(context);
              context.push(Routes.subscription);
            }
          : null,
    ),
  ),
);

class ReferralLimitDialog extends StatelessWidget {
  const ReferralLimitDialog({
    super.key,
    required this.onReferFriend,
    this.onUpgrade,
  });

  final VoidCallback onReferFriend;

  /// When null, the upgrade action is hidden.
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return AlertDialog(
      title: Text(context.l10n.referralLimitTitle),
      content: Text(
        context.l10n.referralLimitBody,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
      actions: [
        if (onUpgrade != null)
          TextButton(onPressed: onUpgrade, child: Text(context.l10n.actionUpgrade)),
        ElevatedButton(
          onPressed: onReferFriend,
          child: Text(context.l10n.referralLimitRefer),
        ),
      ],
    );
  }
}
