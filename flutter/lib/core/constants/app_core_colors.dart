import 'package:flutter/material.dart';

/// Core neutral colors used by shared core widgets. Single source of truth
/// for the neutral surface palette; app/themes/app_colors.dart aliases these
/// so core widgets and the app theme cannot drift apart (and core widgets
/// keep no dependency on the app/ layer, per ARCHITECTURE.md).
class AppCoreColors {
  AppCoreColors._();

  static const Color backgroundLight = Color(0xFFFBFBF9);
  static const Color backgroundDark = Color(0xFF1A1A17);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF232320);
  static const Color borderLight = Color(0xFFDADAD3);
  static const Color borderDark = Color(0xFF3A3A35);
}
