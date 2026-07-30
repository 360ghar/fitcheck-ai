import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../constants/app_constants.dart';

// Export image widgets for convenience
export 'app_image.dart';
export 'app_image_viewer.dart';

// Export shimmer/skeleton widgets
export 'shimmer_widgets.dart';

// Export inline processing status (spinner + phase text for buttons)
export 'inline_processing_status.dart';

// Export infinite scroll wrapper
export 'infinite_scroll_wrapper.dart';

class AppUiTokens {
  AppUiTokens._({
    required this.isDarkMode,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.cardColor,
    required this.cardBorderColor,
    required this.cardShadowColor,
    required this.backgroundGradient,
    required this.navBackground,
    required this.navBorder,
    required this.brandColor,
  });

  final bool isDarkMode;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color cardColor;
  final Color cardBorderColor;
  final Color cardShadowColor;
  final Gradient backgroundGradient;
  final Color navBackground;
  final Color navBorder;
  final Color brandColor;

  factory AppUiTokens.of(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final textMuted = textSecondary.withValues(alpha: isDarkMode ? 0.7 : 0.65);
    final brandColor = theme.colorScheme.primary;

    final background = isDarkMode
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final backgroundGradient = LinearGradient(colors: [background, background]);
    final cardColor = isDarkMode
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final cardBorderColor = isDarkMode
        ? AppColors.borderDark
        : AppColors.borderLight;
    final cardShadowColor = Colors.transparent;
    final navBackground = cardColor;
    final navBorder = cardBorderColor;

    return AppUiTokens._(
      isDarkMode: isDarkMode,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textMuted: textMuted,
      cardColor: cardColor,
      cardBorderColor: cardBorderColor,
      cardShadowColor: cardShadowColor,
      backgroundGradient: backgroundGradient,
      navBackground: navBackground,
      navBorder: navBorder,
      brandColor: brandColor,
    );
  }
}

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      color: tokens.isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.radius16,
        ),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: child,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
