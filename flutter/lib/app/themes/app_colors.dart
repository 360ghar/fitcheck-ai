import 'package:flutter/material.dart';
import '../../core/constants/app_core_colors.dart';

/// Mobile magazine colour scheme
class AppColors {
  AppColors._();

  // Muted fashion editorial palette. Editorial panels live in core.
  static const Color primary = Color(0xFF3F5148);
  static const Color primaryLight = Color(0xFFDDE4DA);
  static const Color primaryDark = Color(0xFF2D3C34);
  static const Color primaryContainer = Color(0xFFE0E6DC);
  static const Color primaryDarkMode = Color(0xFFC5CEBB);

  static const Color secondary = Color(0xFF78685E);
  static const Color secondaryLight = AppCoreColors.editorialRose;
  static const Color secondaryDark = Color(0xFF51433A);

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
  static const Color surfaceVariantLight = Color(0xFFF0EFE9);
  static const Color onBackgroundLight = Color(0xFF2C302D);
  static const Color onSurfaceLight = Color(0xFF2C302D);
  static const Color onSurfaceVariantLight = Color(0xFF646960);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = AppCoreColors.backgroundDark;
  static const Color surfaceDark = AppCoreColors.surfaceDark;
  static const Color surfaceVariantDark = Color(0xFF343A35);
  static const Color onBackgroundDark = Color(0xFFF5F5EF);
  static const Color onSurfaceDark = Color(0xFFF5F5EF);
  static const Color onSurfaceVariantDark = Color(0xFFBFC6BD);

  // Border Colors
  static const Color borderLight = AppCoreColors.borderLight;
  static const Color borderDark = AppCoreColors.borderDark;

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0x80000000);
}
