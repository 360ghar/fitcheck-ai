import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env_config.dart';
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
      title: const Text("You've used today's photos"),
      content: Text(
        'Your free photos come back tomorrow. Refer a friend and you both '
        'get a month of Pro free.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
      actions: [
        if (onUpgrade != null)
          TextButton(onPressed: onUpgrade, child: const Text('Upgrade')),
        ElevatedButton(
          onPressed: onReferFriend,
          child: const Text('Refer a friend'),
        ),
      ],
    );
  }
}
