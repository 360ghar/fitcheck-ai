import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import 'widgets/auth_ui.dart';

class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AuthUiTokens.of(context);
    final screenSize = MediaQuery.of(context).size;
    final titleSize = (screenSize.width * 0.1).clamp(30.0, 44.0);
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
          _buildHeroText(
            titleSize,
            bodySize,
            tokens,
          ),
          _buildActionSection(tokens, bodySize),
        ],
      ),
    );
  }

  Widget _buildHeroText(
    double titleSize,
    double bodySize,
    AuthUiTokens tokens,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your AI-Powered\nVirtual Closet',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: tokens.textColor,
            height: 1.05,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        Text(
          'Organize your wardrobe, visualize new looks, and master your '
          'style with high-precision AI guidance built for you.',
          style: TextStyle(
            fontSize: bodySize,
            color: tokens.secondaryTextColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(
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
            foregroundColor: Colors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radius16),
            ),
            textStyle: const TextStyle(
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
            side: BorderSide(color: tokens.textColor.withOpacity(0.65)),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radius16),
            ),
            textStyle: const TextStyle(
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
