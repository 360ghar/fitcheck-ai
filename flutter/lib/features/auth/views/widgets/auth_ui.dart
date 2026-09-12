import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';

class AuthUiTokens {
  AuthUiTokens._({
    required this.isDarkMode,
    required this.textColor,
    required this.secondaryTextColor,
    required this.brandColor,
    required this.cardColor,
    required this.cardBorderColor,
    required this.fieldFillColor,
    required this.fieldBorderColor,
    required this.fieldHintColor,
    required this.fieldIconColor,
  });

  final bool isDarkMode;
  final Color textColor;
  final Color secondaryTextColor;
  final Color brandColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color fieldFillColor;
  final Color fieldBorderColor;
  final Color fieldHintColor;
  final Color fieldIconColor;

  factory AuthUiTokens.of(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = scheme.onSurface;
    final secondaryTextColor = scheme.onSurfaceVariant;
    final brandColor = scheme.primary;
    final cardColor = scheme.surface;
    final cardBorderColor = scheme.outlineVariant;
    final fieldFillColor = scheme.surfaceContainerHighest;
    final fieldBorderColor = scheme.outlineVariant;
    final fieldHintColor = scheme.onSurfaceVariant;
    final fieldIconColor = scheme.onSurfaceVariant;

    return AuthUiTokens._(
      isDarkMode: isDarkMode,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      brandColor: brandColor,
      cardColor: cardColor,
      cardBorderColor: cardBorderColor,
      fieldFillColor: fieldFillColor,
      fieldBorderColor: fieldBorderColor,
      fieldHintColor: fieldHintColor,
      fieldIconColor: fieldIconColor,
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  static const String backgroundImage = 'assets/images/wardrobe-editorial.webp';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width < 360
        ? AppConstants.spacing16
        : AppConstants.spacing24;
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppConstants.spacing24,
        );

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).appBarTheme.systemOverlayStyle!,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Padding(padding: resolvedPadding, child: child),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthHeaderBar extends StatelessWidget {
  const AuthHeaderBar({
    super.key,
    required this.textColor,
    required this.brandColor,
    this.trailing,
  });

  final Color textColor;
  final Color brandColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Navigator.canPop(context))
          BackButton(color: textColor)
        else
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(AppConstants.radius12),
            ),
            child: Icon(
              Icons.checkroom_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 22,
            ),
          ),
        const SizedBox(width: AppConstants.spacing12),
        Expanded(
          child: Text(
            'FitCheck AI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              letterSpacing: -0.6,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = AuthUiTokens.of(context);
    return Material(
      color: tokens.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        side: BorderSide(color: tokens.cardBorderColor),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.spacing20),
        child: child,
      ),
    );
  }
}

/// HIG-compliant "Sign in with Apple" button.
///
/// Uses the native [SignInWithAppleButton] from the `sign_in_with_apple`
/// package, choosing black/white style based on the app's dark mode token and
/// matching the border radius / rhythm of the Google button. When [isLoading]
/// is true, taps are disabled and a spinner is shown in place of the button.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  // Match the vertical rhythm of the Google OutlinedButton (spacing16 padding
  // around ~20px content => ~52px tall).
  static const double _buttonHeight = 52;

  @override
  Widget build(BuildContext context) {
    final tokens = AuthUiTokens.of(context);

    if (isLoading) {
      return Container(
        height: _buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.isDarkMode ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              tokens.isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ),
      );
    }

    return SignInWithAppleButton(
      onPressed: onPressed,
      height: _buttonHeight,
      borderRadius: BorderRadius.circular(AppConstants.radius16),
      style: tokens.isDarkMode
          ? SignInWithAppleButtonStyle.white
          : SignInWithAppleButtonStyle.black,
    );
  }
}

class AuthFooterText extends StatelessWidget {
  const AuthFooterText({super.key, required this.textColor});

  final Color textColor;

  // Aliases of the single source of truth in AppConstants.
  static const String privacyPolicyUrl = AppConstants.privacyPolicyUrl;
  static const String termsOfServiceUrl = AppConstants.termsOfServiceUrl;

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      if (await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // Report launcher failures in the page instead of failing silently.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this link. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 12,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        TextButton(
          onPressed: () => _openUrl(context, privacyPolicyUrl),
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            textStyle: linkStyle,
          ),
          child: const Text('Privacy policy'),
        ),
        TextButton(
          onPressed: () => _openUrl(context, termsOfServiceUrl),
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            textStyle: linkStyle,
          ),
          child: const Text('Terms of service'),
        ),
      ],
    );
  }
}

class AuthFormStyles {
  AuthFormStyles._();

  static InputDecoration inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final tokens = AuthUiTokens.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: tokens.secondaryTextColor),
      hintStyle: TextStyle(color: tokens.fieldHintColor),
      filled: true,
      fillColor: tokens.fieldFillColor,
      prefixIcon: Icon(icon, color: tokens.fieldIconColor),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        borderSide: BorderSide(color: tokens.fieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        borderSide: BorderSide(color: tokens.brandColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        borderSide: BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
    );
  }
}
