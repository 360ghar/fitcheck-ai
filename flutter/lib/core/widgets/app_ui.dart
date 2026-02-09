import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

// Export image widgets for convenience
export 'app_image.dart';
export 'app_image_viewer.dart';

// Export shimmer/skeleton widgets
export 'shimmer_widgets.dart';

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
    final textPrimary = theme.colorScheme.onBackground;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final textMuted = textSecondary.withOpacity(isDarkMode ? 0.7 : 0.65);
    final brandColor = theme.colorScheme.primary;

    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [
              const Color(0xFF0B0B12),
              const Color(0xFF111827),
              const Color(0xFF0B0B12),
            ]
          : [
              const Color(0xFFF8FAFC),
              const Color(0xFFEFF2FF),
              const Color(0xFFFFFFFF),
            ],
    );

    final cardColor = isDarkMode
        ? const Color(0xFF111827).withOpacity(0.72)
        : Colors.white.withOpacity(0.9);
    final cardBorderColor = textPrimary.withOpacity(isDarkMode ? 0.12 : 0.08);
    final cardShadowColor = Colors.black.withOpacity(isDarkMode ? 0.35 : 0.12);

    final navBackground = isDarkMode
        ? const Color(0xFF0B0F1D).withOpacity(0.9)
        : Colors.white.withOpacity(0.95);
    final navBorder = textPrimary.withOpacity(isDarkMode ? 0.18 : 0.1);

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
  const AppPageBackground({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: tokens.backgroundGradient,
        // Also set a solid color fallback for the area behind bottom nav
        color: tokens.isDarkMode
            ? const Color(0xFF0B0B12)
            : const Color(0xFFF8FAFC),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
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

    return Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: tokens.cardColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.radius16,
        ),
        border: Border.all(color: tokens.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: tokens.cardShadowColor,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
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
