import 'package:flutter/material.dart';

/// App color scheme matching the web app
class AppColors {
  AppColors._();

  // Wardrobe Studio brand colors. These intentionally match frontend/DESIGN.md.
  static const Color primary = Color(0xFFE60023);
  static const Color primaryLight = Color(0xFFFFDDE3);
  static const Color primaryDark = Color(0xFFCC001F);
  static const Color primaryContainer = Color(0xFFFFE8EC);

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

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFFBFBF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF6F6F3);
  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onSurfaceVariantLight = Color(0xFF62625B);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF1A1A17);
  static const Color surfaceDark = Color(0xFF232320);
  static const Color surfaceVariantDark = Color(0xFF2C2C28);
  static const Color onBackgroundDark = Color(0xFFFBFBF9);
  static const Color onSurfaceDark = Color(0xFFFBFBF9);
  static const Color onSurfaceVariantDark = Color(0xFFC8C8C1);

  // Border Colors
  static const Color borderLight = Color(0xFFDADAD3);
  static const Color borderDark = Color(0xFF3A3A35);

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0x80000000);
}
