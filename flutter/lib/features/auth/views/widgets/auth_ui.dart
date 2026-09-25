import 'package:flutter/material.dart';

import 'google_mark.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_ui.dart';

/// Shared frame for the sign-in screens: a paper landscape across the top of
/// the screen, the form on the page below it.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.sceneFraction = 0.34,
    this.showBack = false,
  });

  final Widget child;

  /// Height of the scene band as a fraction of the screen height.
  final double sceneFraction;

  /// Shows a back button over the scene.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return PaperStockScope(
      stock: PaperStockId.ink,
      child: Builder(
        builder: (context) {
          final tokens = PaperTokens.of(context);
          final dark = Theme.of(context).brightness == Brightness.dark;
          final size = MediaQuery.sizeOf(context);
          // The back button gets its own row above the scene, clear of the
          // garments on the line.
          final sceneTop =
              MediaQuery.paddingOf(context).top +
              (showBack ? kMinInteractiveDimension + AppConstants.spacing8 : 0);
          final band = size.height * sceneFraction + sceneTop;
          final gutter = size.width < 360
              ? AppConstants.spacing16
              : AppConstants.spacing24;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Scaffold(
              backgroundColor: tokens.stock.page,
              body: DecoratedBox(
                decoration: BoxDecoration(image: paperGrain(context)),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: band,
                        child: Stack(
                          children: [
                            // Starts below the status bar so the garments
                            // never sit under the clock.
                            Positioned.fill(
                              top: sceneTop,
                              child: const PaperScene(
                                preset: PaperScenes.auth,
                                height: null,
                              ),
                            ),
                            if (showBack)
                              SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppConstants.spacing4,
                                  ),
                                  child: IconButton(
                                    tooltip: 'Back',
                                    icon: const Icon(Icons.arrow_back_rounded),
                                    onPressed: () =>
                                        Navigator.maybePop(context),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            gutter,
                            AppConstants.spacing8,
                            gutter,
                            AppConstants.spacing16,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Screen title and one line of help under it.
class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.headlineMedium),
        const SizedBox(height: AppConstants.spacing8),
        Text(
          subtitle,
          style: text.bodyLarge?.copyWith(
            color: PaperTokens.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}

/// "or" between the email form and the social sign-in buttons.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return Text(
      'or',
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
    );
  }
}

/// Neutral "Continue with Google" button in the paper card style.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(foregroundColor: tokens.textPrimary),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GoogleMark(),
                  SizedBox(width: AppConstants.spacing12),
                  Text('Continue with Google'),
                ],
              ),
      ),
    );
  }
}

/// Filled primary action with an inline spinner while [isLoading].
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Container(
        height: _buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ),
      );
    }

    return SignInWithAppleButton(
      onPressed: onPressed,
      height: _buttonHeight,
      borderRadius: BorderRadius.circular(AppConstants.radius16),
      style: isDarkMode
          ? SignInWithAppleButtonStyle.white
          : SignInWithAppleButtonStyle.black,
    );
  }
}

/// Privacy and terms links.
class AuthFooterText extends StatelessWidget {
  const AuthFooterText({super.key});

  static const String privacyPolicyUrl = AppConstants.privacyPolicyUrl;
  static const String termsOfServiceUrl = AppConstants.termsOfServiceUrl;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final style = TextButton.styleFrom(
      foregroundColor: tokens.textSecondary,
      textStyle: Theme.of(context).textTheme.bodySmall,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          style: style,
          onPressed: () => _openUrl(privacyPolicyUrl),
          child: const Text('Privacy policy'),
        ),
        Text('·', style: TextStyle(color: tokens.textMuted)),
        TextButton(
          style: style,
          onPressed: () => _openUrl(termsOfServiceUrl),
          child: const Text('Terms of service'),
        ),
      ],
    );
  }
}

/// Input decoration for the sign-in forms. Colours come from the theme.
class AuthFormStyles {
  AuthFormStyles._();

  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixIcon: suffixIcon,
  );
}

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// A loose shape check. The auth server does the real validation.
bool isValidEmail(String value) => _email.hasMatch(value);
