import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_ui.dart';

/// Muted offline/error banner for list screens (outfits, wardrobe): a
/// cloud-off icon plus the message on a card. Shared so the content screens
/// cannot drift apart; render it inside a `SliverToBoxAdapter`.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing4,
        AppConstants.spacing16,
        AppConstants.spacing4,
      ),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 20, color: tokens.textMuted),
          const SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
