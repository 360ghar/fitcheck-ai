import 'package:fitcheck_ai/app/themes/app_colors.dart';
import 'package:fitcheck_ai/core/constants/app_core_colors.dart';
import 'package:fitcheck_ai/app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('body, control and section text meet AA contrast in both themes', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final scheme = theme.colorScheme;
      for (final pair in [
        (scheme.onSurface, scheme.surface),
        (scheme.onSurfaceVariant, scheme.surface),
        (scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
        (scheme.onPrimary, scheme.primary),
        (scheme.onPrimaryContainer, scheme.primaryContainer),
        (scheme.onSecondary, scheme.secondary),
        (scheme.onSecondaryContainer, scheme.secondaryContainer),
        (scheme.error, scheme.surface),
        for (final field in [
          AppCoreColors.editorialRose,
          AppCoreColors.editorialLinen,
          AppCoreColors.editorialSage,
          AppCoreColors.editorialSlate,
        ])
          (AppCoreColors.editorialInk, field),
      ]) {
        final a = pair.$1.computeLuminance();
        final b = pair.$2.computeLuminance();
        expect(
          (a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05)),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });
  test('light theme uses the muted brand and flat surfaces', () {
    final theme = AppTheme.lightTheme;

    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.textTheme.headlineMedium?.fontFamily, 'BodoniModa');
    expect(
      theme.filledButtonTheme.style?.minimumSize?.resolve(<WidgetState>{}),
      const Size(48, 48),
    );
    expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.floatingActionButtonTheme.elevation, 0);
    expect(
      theme.elevatedButtonTheme.style?.minimumSize?.resolve(<WidgetState>{}),
      const Size(48, 48),
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
    expect(theme.inputDecorationTheme.focusedBorder, isA<OutlineInputBorder>());
    expect(theme.appBarTheme.scrolledUnderElevation, 0);
    expect(theme.cardTheme.elevation, 0);
  });
}
