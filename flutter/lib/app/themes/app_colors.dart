import 'package:flutter/material.dart';
import '../../core/constants/app_core_colors.dart';

/// App color scheme matching the web app
class AppColors {
  AppColors._();

  // Wardrobe Studio brand colors. These intentionally match frontend/DESIGN.md
  // (Brand Red moved to hsl(354 100% 44%) = #e00016 on 2026-07-31).
  static const Color primary = Color(0xFFE00016);
  static const Color primaryLight = Color(0xFFFFDDE3);
  static const Color primaryDark = Color(0xFFCC001F);
  static const Color primaryContainer = Color(0xFFFFE8EC);
  // Lightened dark-mode accent for AA contrast on dark surfaces.
  static const Color primaryDarkMode = Color(0xFFFF9AAA);

  // Editorial purple is reserved for AI picks and recommendation context.
  static const Color secondary = Color(0xFF7E238B);
  static const Color secondaryLight = Color(0xFFEFD9F2);
  static const Color secondaryDark = Color(0xFF5B1666);

  // Success Colors
  static const Color success = Color(0xFF103C25);
  static const Color successLight = Color(0xFFC7F0DA);
  static const Color successDark = Color(0xFF082A18);

  // Warning Colors
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFCD34D); // Amber 300
  static const Color warningDark = Color(0xFFD97706); // Amber 600

  // Error Colors
  static const Color error = Color(0xFF9E0A0A);
  static const Color errorLight = Color(0xFFF8D0D0);
  static const Color errorDark = Color(0xFF760707);
  static const Color errorDarkMode = Color(0xFFFF9B9B);

  // Neutral Colors - Light Mode
  // Aliased from AppCoreColors so core widgets and the app theme share one
  // source of truth for the neutral palette.
  static const Color backgroundLight = AppCoreColors.backgroundLight;
  static const Color surfaceLight = AppCoreColors.surfaceLight;
  static const Color surfaceVariantLight = Color(0xFFF6F6F3);
  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onSurfaceVariantLight = Color(0xFF62625B);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = AppCoreColors.backgroundDark;
  static const Color surfaceDark = AppCoreColors.surfaceDark;
  static const Color surfaceVariantDark = Color(0xFF2C2C28);
  static const Color onBackgroundDark = Color(0xFFFBFBF9);
  static const Color onSurfaceDark = Color(0xFFFBFBF9);
  static const Color onSurfaceVariantDark = Color(0xFFC8C8C1);

  // Border Colors
  static const Color borderLight = AppCoreColors.borderLight;
  static const Color borderDark = AppCoreColors.borderDark;

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0x80000000);
}
