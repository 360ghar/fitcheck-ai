import 'package:flutter/material.dart';

/// App color scheme matching the web app
class AppColors {
  AppColors._();

  // Primary Colors - Indigo
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryContainer = Color(0xFFE0E7FF); // Indigo 100

  // Secondary Colors - Rose (for favorites)
  static const Color secondary = Color(0xFFF43F5E); // Rose 500
  static const Color secondaryLight = Color(0xFFFDA4AF); // Rose 300
  static const Color secondaryDark = Color(0xFFE11D48); // Rose 600

  // Success Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFF6EE7B7); // Emerald 300
  static const Color successDark = Color(0xFF059669); // Emerald 600

  // Warning Colors
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFCD34D); // Amber 300
  static const Color warningDark = Color(0xFFD97706); // Amber 600

  // Error Colors
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color errorDark = Color(0xFFDC2626); // Red 600

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC); // Matches AppPageBackground gradient start
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color onBackgroundLight = Color(0xFF09090B);
  static const Color onSurfaceLight = Color(0xFF09090B);
  static const Color onSurfaceVariantLight = Color(0xFF64748B);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0B0B12); // Matches AppPageBackground gradient start
  static const Color surfaceDark = Color(0xFF18181B);
  static const Color surfaceVariantDark = Color(0xFF27272A);
  static const Color onBackgroundDark = Color(0xFFFAFAFA);
  static const Color onSurfaceDark = Color(0xFFFAFAFA);
  static const Color onSurfaceVariantDark = Color(0xFFA1A1AA);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF27272A);

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0x80000000);

  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [secondaryLight, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism
  static Color glassLight(Color color) => color.withOpacity(0.1);
  static Color glassDark(Color color) => color.withOpacity(0.2);
  static Color glassBorderLight(Color color) => color.withOpacity(0.2);
  static Color glassBorderDark(Color color) => color.withOpacity(0.3);
}
