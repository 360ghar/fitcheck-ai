import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/widgets/app_ui.dart';
import 'widgets/auth_ui.dart';

/// First screen for signed-out users.
class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return AuthScaffold(
      sceneFraction: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BrandWordmark(size: 40),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            context.l10n.authEntryBody,
            style: text.bodyLarge?.copyWith(color: tokens.textSecondary),
          ),
          const Spacer(),
          const SizedBox(height: AppConstants.spacing24),
          AuthPrimaryButton(
            label: context.l10n.authCreateCloset,
            onPressed: () => context.push(Routes.register),
          ),
          const SizedBox(height: AppConstants.spacing8),
          TextButton(
            onPressed: () => context.push(Routes.login),
            style: TextButton.styleFrom(foregroundColor: tokens.textPrimary),
            child: Text(context.l10n.introHaveAccount),
          ),
          const SizedBox(height: AppConstants.spacing8),
          const AuthFooterText(),
        ],
      ),
    );
  }
}
