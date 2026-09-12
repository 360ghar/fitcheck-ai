import 'package:flutter/material.dart';
import '../constants/app_core_colors.dart';
import '../constants/app_constants.dart';

// Export image widgets for convenience
export 'app_image.dart';
export 'sliver_product_grid.dart';
export '../constants/app_core_colors.dart';
export 'app_image_viewer.dart';

// Export offline/error banner
export 'app_error_banner.dart';

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
  final Color navBackground;
  final Color navBorder;
  final Color brandColor;

  factory AppUiTokens.of(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final textMuted = textSecondary;
    final brandColor = theme.colorScheme.primary;

    final cardColor = isDarkMode
        ? AppCoreColors.surfaceDark
        : AppCoreColors.surfaceLight;
    final cardBorderColor = isDarkMode
        ? AppCoreColors.borderDark
        : AppCoreColors.borderLight;
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

    return Material(
      color: tokens.isDarkMode
          ? AppCoreColors.backgroundDark
          : AppCoreColors.backgroundLight,
      // Phone layouts are unchanged (phones are already narrower than
      // maxContentWidth) while tablets / desktop web are capped at a readable
      // content width. Align top-center preserves existing top-aligned scroll
      // behavior; scrollables still fill the available width.
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
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

    return Material(
      color: tokens.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.radius16,
        ),
        side: BorderSide(color: tokens.cardBorderColor),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.spacing16),
        child: child,
      ),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
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

/// A section field, shared by magazine pages without changing control semantics.
class AppEditorialHeader extends StatelessWidget {
  const AppEditorialHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppCoreColors.editorialInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppCoreColors.editorialInk),
          ),
          if (trailing != null) ...[const SizedBox(height: 16), trailing!],
        ],
      ),
    );
  }
}
