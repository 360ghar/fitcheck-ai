import 'package:fitcheck_ai/app/themes/app_colors.dart';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light theme uses the Wardrobe Studio red and flat surfaces', () {
    final theme = AppTheme.lightTheme;

    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.floatingActionButtonTheme.elevation, 0);
    expect(
      theme.elevatedButtonTheme.style?.minimumSize?.resolve(<WidgetState>{}),
      const Size(44, 44),
    );
  });

  test('dark theme uses the AA-safe accent and flat app bar', () {
    final theme = AppTheme.darkTheme;

    expect(theme.colorScheme.primary, AppColors.primaryDarkMode);
    expect(theme.colorScheme.error, AppColors.errorDarkMode);
    expect(
      theme.textButtonTheme.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppColors.primaryDarkMode,
    );
    expect(
      theme.inputDecorationTheme.focusedBorder,
      isA<OutlineInputBorder>(),
    );
    expect(theme.appBarTheme.scrolledUnderElevation, 0);
    expect(theme.cardTheme.elevation, 0);
  });
}
