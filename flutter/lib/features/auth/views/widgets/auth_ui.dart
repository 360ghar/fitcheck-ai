import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';

class AuthUiTokens {
  AuthUiTokens._({
    required this.isDarkMode,
    required this.textColor,
    required this.secondaryTextColor,
    required this.brandColor,
    required this.overlayGradient,
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
  final LinearGradient overlayGradient;
  final Color cardColor;
  final Color cardBorderColor;
  final Color fieldFillColor;
  final Color fieldBorderColor;
  final Color fieldHintColor;
  final Color fieldIconColor;

  factory AuthUiTokens.of(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = textColor.withOpacity(isDarkMode ? 0.78 : 0.68);
    final brandColor = Theme.of(context).colorScheme.primary;
    final overlayGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDarkMode
          ? [
              Colors.black.withOpacity(0.35),
              Colors.black.withOpacity(0.65),
              Colors.black.withOpacity(0.9),
            ]
          : [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.55),
              Colors.white.withOpacity(0.75),
            ],
    );
    final cardColor =
        isDarkMode ? Colors.black.withOpacity(0.48) : Colors.white.withOpacity(0.85);
    final cardBorderColor = textColor.withOpacity(isDarkMode ? 0.18 : 0.12);
    final fieldFillColor =
        isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
    final fieldBorderColor = textColor.withOpacity(isDarkMode ? 0.25 : 0.2);
    final fieldHintColor = textColor.withOpacity(isDarkMode ? 0.55 : 0.5);
    final fieldIconColor = textColor.withOpacity(isDarkMode ? 0.7 : 0.6);

    return AuthUiTokens._(
      isDarkMode: isDarkMode,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      brandColor: brandColor,
      overlayGradient: overlayGradient,
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
  const AuthScaffold({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  static const String backgroundImage = 'assets/images/auth_background.jpg';

  @override
  Widget build(BuildContext context) {
    final tokens = AuthUiTokens.of(context);
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width < 360
        ? AppConstants.spacing16
        : AppConstants.spacing24;
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppConstants.spacing24,
        );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: tokens.overlayGradient),
            ),
          ),
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: (tokens.isDarkMode
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor:
                  tokens.isDarkMode ? Colors.black : Colors.white,
              statusBarIconBrightness:
                  tokens.isDarkMode ? Brightness.light : Brightness.dark,
              systemNavigationBarIconBrightness:
                  tokens.isDarkMode ? Brightness.light : Brightness.dark,
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: resolvedPadding,
                        child: child,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: brandColor,
            borderRadius: BorderRadius.circular(AppConstants.radius12),
          ),
          child: const Icon(
            Icons.checkroom_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: AppConstants.spacing12),
        Expanded(
          child: Text(
            'FitCheck AI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = AuthUiTokens.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.spacing20),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radius24),
        border: Border.all(color: tokens.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(tokens.isDarkMode ? 0.35 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthFooterText extends StatelessWidget {
  const AuthFooterText({
    super.key,
    required this.textColor,
  });

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      'PRIVACY POLICY  |  TERMS OF SERVICE',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor.withOpacity(0.65),
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w500,
      ),
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
      labelStyle: TextStyle(color: tokens.textColor.withOpacity(0.7)),
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
