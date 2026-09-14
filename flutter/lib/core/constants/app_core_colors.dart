import 'package:flutter/material.dart';

/// Core neutral colors used by shared core widgets. Single source of truth
/// for the neutral surface palette; app/themes/app_colors.dart aliases these
/// so core widgets and the app theme cannot drift apart (and core widgets
/// keep no dependency on the app/ layer, per ARCHITECTURE.md).
class AppCoreColors {
  AppCoreColors._();

  static const Color backgroundLight = Color(0xFFFBFAF7);
  static const Color backgroundDark = Color(0xFF1F2321);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF282D29);
  static const Color borderLight = Color(0xFFDEDFD5);
  static const Color borderDark = Color(0xFF485047);
  // Editorial section fields keep the same dark ink in both appearances.
  static const Color editorialRose = Color(0xFFE6DED7);
  static const Color editorialLinen = Color(0xFFE6E4D8);
  static const Color editorialSage = Color(0xFFD7DFD4);
  static const Color editorialSlate = Color(0xFFDDE2E3);
  static const Color editorialInk = Color(0xFF2C302D);
}
