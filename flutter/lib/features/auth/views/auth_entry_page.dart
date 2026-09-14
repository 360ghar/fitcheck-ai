import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import 'widgets/auth_ui.dart';
import '../../../core/widgets/app_ui.dart';

class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AuthUiTokens.of(context);
    final screenSize = MediaQuery.of(context).size;
    final bodySize = (screenSize.width * 0.045).clamp(14.0, 18.0);

    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeaderBar(
            textColor: tokens.textColor,
            brandColor: tokens.brandColor,
          ),
          const SizedBox(height: 32),
          Text(
            'This is\nyour style.',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              height: 1.02,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.45,
                  child: Image.asset(
                    AuthScaffold.backgroundImage,
                    fit: BoxFit.cover,
                    semanticLabel: 'Wardrobe inspiration',
                  ),
                ),
                Container(
                  color: AppCoreColors.editorialRose,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Your closet. New possibilities.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppCoreColors.editorialInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Save the pieces you love. Create outfits, try new looks, and make every day feel like you.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.secondaryTextColor),
          ),
          const SizedBox(height: 24),
          _buildActionSection(context, tokens, bodySize),
        ],
      ),
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    AuthUiTokens tokens,
    double bodySize,
  ) {
    final buttonPadding = EdgeInsets.symmetric(
      vertical: bodySize < 16 ? 14 : 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => Get.toNamed(Routes.register),
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.brandColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radius16),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          child: const Text('Sign Up'),
        ),
        const SizedBox(height: AppConstants.spacing12),
        OutlinedButton(
          onPressed: () => Get.toNamed(Routes.login),
          style: OutlinedButton.styleFrom(
            foregroundColor: tokens.textColor,
            side: BorderSide(color: tokens.textColor.withValues(alpha: 0.65)),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radius16),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          child: const Text('Log In'),
        ),
        const SizedBox(height: AppConstants.spacing20),
        Center(child: AuthFooterText(textColor: tokens.textColor)),
      ],
    );
  }
}
